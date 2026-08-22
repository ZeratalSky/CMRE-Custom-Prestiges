[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [string]$StarCraftIIPath,

    [Parameter(Mandatory = $false)]
    [switch]$SkipBackup
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$ResolvedStarCraftIIPath = [System.IO.Path]::GetFullPath($StarCraftIIPath)
$TargetMod = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'
$GameDataDirectory = Join-Path $TargetMod 'Base.SC2Data\GameData'

if (-not (Test-Path -LiteralPath $TargetMod -PathType Container)) {
    throw '找不到 CMRE_Core_Triggers.SC2Mod。请确认 -StarCraftIIPath 指向《星际争霸 II》根目录。'
}

function Load-XmlDocument {
    param([string]$Path)
    $document = New-Object System.Xml.XmlDocument
    $document.PreserveWhitespace = $true
    $document.Load($Path)
    return $document
}

function Save-XmlDocument {
    param([System.Xml.XmlDocument]$Document, [string]$Path)
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Encoding = $Utf8NoBom
    $settings.Indent = $false
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::None
    $writer = [System.Xml.XmlWriter]::Create($Path, $settings)
    try { $Document.Save($writer) } finally { $writer.Dispose() }
}

function Find-CatalogEntry {
    param([System.Xml.XmlDocument]$Document, [string]$Type, [string]$Id)
    foreach ($node in $Document.DocumentElement.ChildNodes) {
        if (($node.NodeType -eq [System.Xml.XmlNodeType]::Element) -and ($node.LocalName -eq $Type) -and ($node.GetAttribute('id') -eq $Id)) {
            return $node
        }
    }
    return $null
}

function Find-MatchingChild {
    param([System.Xml.XmlElement]$TargetEntry, [System.Xml.XmlElement]$SourceChild)
    foreach ($keyName in @('index', 'Id', 'id', 'Reference')) {
        if ($SourceChild.HasAttribute($keyName)) {
            $keyValue = $SourceChild.GetAttribute($keyName)
            foreach ($candidate in $TargetEntry.ChildNodes) {
                if (($candidate.NodeType -eq [System.Xml.XmlNodeType]::Element) -and ($candidate.LocalName -eq $SourceChild.LocalName) -and ($candidate.GetAttribute($keyName) -eq $keyValue)) {
                    return $candidate
                }
            }
            return $null
        }
    }
    foreach ($candidate in $TargetEntry.ChildNodes) {
        if (($candidate.NodeType -eq [System.Xml.XmlNodeType]::Element) -and ($candidate.OuterXml -eq $SourceChild.OuterXml)) { return $candidate }
    }
    return $null
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = Join-Path $ResolvedStarCraftIIPath "Mods\CMRE\_CMRECustomPrestigesBackup\uninstall-$timestamp"
$BackedUp = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

function Backup-TargetFile {
    param([string]$TargetFile)
    if ($SkipBackup -or $BackedUp.Contains($TargetFile)) { return }
    $relative = $TargetFile.Substring($TargetMod.Length).TrimStart('\')
    $backupFile = Join-Path $BackupRoot $relative
    New-Item -ItemType Directory -Path (Split-Path -Parent $backupFile) -Force | Out-Null
    Copy-Item -LiteralPath $TargetFile -Destination $backupFile -Force
    [void]$BackedUp.Add($TargetFile)
}

$ManifestFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'prestiges') -Filter 'prestige.json' -File -Recurse | Sort-Object FullName)
foreach ($manifestFile in $ManifestFiles) {
    $moduleRoot = Split-Path -Parent $manifestFile.FullName
    $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw | ConvertFrom-Json

    foreach ($catalogDefinition in @($manifest.catalog)) {
        $sourceFile = Join-Path $moduleRoot (Join-Path 'catalog' $catalogDefinition.file)
        $targetFile = Join-Path $GameDataDirectory $catalogDefinition.file
        if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { continue }
        $sourceDocument = Load-XmlDocument -Path $sourceFile
        $targetDocument = Load-XmlDocument -Path $targetFile
        $changed = $false

        foreach ($owned in @($catalogDefinition.ownedEntries)) {
            $targetEntry = Find-CatalogEntry -Document $targetDocument -Type $owned.type -Id $owned.id
            if ($null -ne $targetEntry) {
                [void]$targetDocument.DocumentElement.RemoveChild($targetEntry)
                $changed = $true
            }
        }

        foreach ($patch in @($catalogDefinition.patchEntries)) {
            $sourceEntry = Find-CatalogEntry -Document $sourceDocument -Type $patch.type -Id $patch.id
            $targetEntry = Find-CatalogEntry -Document $targetDocument -Type $patch.type -Id $patch.id
            if (($null -eq $sourceEntry) -or ($null -eq $targetEntry)) { continue }
            foreach ($sourceChild in @($sourceEntry.ChildNodes | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Element })) {
                $matchingChild = Find-MatchingChild -TargetEntry $targetEntry -SourceChild $sourceChild
                if ($null -ne $matchingChild) {
                    [void]$targetEntry.RemoveChild($matchingChild)
                    $changed = $true
                }
            }
        }

        if ($changed -and $PSCmdlet.ShouldProcess($targetFile, "卸载模块 $($manifest.id)")) {
            Backup-TargetFile -TargetFile $targetFile
            Save-XmlDocument -Document $targetDocument -Path $targetFile
        }
    }

    foreach ($localeDefinition in @($manifest.locales)) {
        $sourceFile = Join-Path $moduleRoot (Join-Path 'locales' $localeDefinition.file)
        $targetFile = Join-Path $TargetMod "$($localeDefinition.locale).SC2Data\LocalizedData\GameStrings.txt"
        if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { continue }
        $keys = @(
            Get-Content -LiteralPath $sourceFile |
                Where-Object { (-not [string]::IsNullOrWhiteSpace($_)) -and $_.Contains('=') } |
                ForEach-Object { $_.Substring(0, $_.IndexOf('=')) }
        )
        $originalLines = @(Get-Content -LiteralPath $targetFile)
        $remainingLines = @($originalLines | Where-Object {
            $line = $_
            -not ($keys | Where-Object { $line.StartsWith("$_=", [System.StringComparison]::Ordinal) })
        })
        if ($remainingLines.Count -ne $originalLines.Count -and $PSCmdlet.ShouldProcess($targetFile, "移除模块 $($manifest.id) 的本地化文本")) {
            Backup-TargetFile -TargetFile $targetFile
            [System.IO.File]::WriteAllLines($targetFile, $remainingLines, $Utf8NoBom)
        }
    }

    Write-Host "已卸载：$($manifest.name.zhCN) ($($manifest.id))" -ForegroundColor Yellow
}

$stateFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_CustomPrestiges.state.json'
if ((Test-Path -LiteralPath $stateFile -PathType Leaf) -and $PSCmdlet.ShouldProcess($stateFile, '移除安装状态')) {
    Remove-Item -LiteralPath $stateFile -Force
}

Write-Host '卸载完成。' -ForegroundColor Cyan
if (-not $SkipBackup) { Write-Host "卸载前备份：$BackupRoot" }

