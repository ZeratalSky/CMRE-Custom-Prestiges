[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [string]$StarCraftIIPath,

    [Parameter(Mandatory = $false)]
    [switch]$SkipBackup
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepositoryRoot = Split-Path -Parent $PSScriptRoot

function Resolve-StarCraftIIPath {
    param([string]$RequestedPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        $candidates += $RequestedPath
    }
    $candidates += @(
        'C:\Program Files (x86)\StarCraft II',
        'C:\Program Files\StarCraft II'
    )

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        $resolved = [System.IO.Path]::GetFullPath($candidate)
        $triggerMod = Join-Path $resolved 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'
        if (Test-Path -LiteralPath $triggerMod -PathType Container) {
            return $resolved
        }
    }

    throw '找不到 CMRE_Core_Triggers.SC2Mod。请使用 -StarCraftIIPath 指定《星际争霸 II》根目录。'
}

function Load-XmlDocument {
    param([string]$Path)
    $document = New-Object System.Xml.XmlDocument
    $document.PreserveWhitespace = $true
    $document.Load($Path)
    return $document
}

function Save-XmlDocument {
    param(
        [System.Xml.XmlDocument]$Document,
        [string]$Path
    )
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Encoding = $Utf8NoBom
    $settings.Indent = $false
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::None
    $writer = [System.Xml.XmlWriter]::Create($Path, $settings)
    try { $Document.Save($writer) } finally { $writer.Dispose() }
}

function Find-CatalogEntry {
    param(
        [System.Xml.XmlDocument]$Document,
        [string]$Type,
        [string]$Id
    )
    foreach ($node in $Document.DocumentElement.ChildNodes) {
        if (($node.NodeType -eq [System.Xml.XmlNodeType]::Element) -and
            ($node.LocalName -eq $Type) -and
            ($node.GetAttribute('id') -eq $Id)) {
            return $node
        }
    }
    return $null
}

function Find-MatchingChild {
    param(
        [System.Xml.XmlElement]$TargetEntry,
        [System.Xml.XmlElement]$SourceChild
    )

    foreach ($keyName in @('index', 'Id', 'id', 'Reference')) {
        if ($SourceChild.HasAttribute($keyName)) {
            $keyValue = $SourceChild.GetAttribute($keyName)
            foreach ($candidate in $TargetEntry.ChildNodes) {
                if (($candidate.NodeType -eq [System.Xml.XmlNodeType]::Element) -and
                    ($candidate.LocalName -eq $SourceChild.LocalName) -and
                    ($candidate.GetAttribute($keyName) -eq $keyValue)) {
                    return $candidate
                }
            }
            return $null
        }
    }

    foreach ($candidate in $TargetEntry.ChildNodes) {
        if (($candidate.NodeType -eq [System.Xml.XmlNodeType]::Element) -and
            ($candidate.OuterXml -eq $SourceChild.OuterXml)) {
            return $candidate
        }
    }
    return $null
}

function Backup-TargetFile {
    param(
        [string]$TargetFile,
        [string]$TargetMod,
        [string]$BackupRoot,
        [System.Collections.Generic.HashSet[string]]$BackedUp
    )

    if ($SkipBackup -or $BackedUp.Contains($TargetFile)) { return }
    $relative = $TargetFile.Substring($TargetMod.Length).TrimStart('\')
    $backupFile = Join-Path $BackupRoot $relative
    $backupDirectory = Split-Path -Parent $backupFile
    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $TargetFile -Destination $backupFile -Force
    [void]$BackedUp.Add($TargetFile)
}

function Test-EntryDeclaration {
    param(
        $CatalogDefinition,
        [System.Xml.XmlElement]$SourceEntry
    )

    $type = $SourceEntry.LocalName
    $id = $SourceEntry.GetAttribute('id')
    $owned = @($CatalogDefinition.ownedEntries | Where-Object { ($_.type -eq $type) -and ($_.id -eq $id) })
    $patched = @($CatalogDefinition.patchEntries | Where-Object { ($_.type -eq $type) -and ($_.id -eq $id) })
    if (($owned.Count + $patched.Count) -ne 1) {
        throw "数据对象 $type/$id 必须在 prestige.json 中声明为 ownedEntries 或 patchEntries，且只能声明一次。"
    }
    return ($owned.Count -eq 1)
}

$ResolvedStarCraftIIPath = Resolve-StarCraftIIPath -RequestedPath $StarCraftIIPath
$TargetMod = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'
$GameDataDirectory = Join-Path $TargetMod 'Base.SC2Data\GameData'
$ManifestFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'prestiges') -Filter 'prestige.json' -File -Recurse | Sort-Object FullName)

if ($ManifestFiles.Count -eq 0) {
    throw '仓库中没有找到任何 prestige.json 威望模块。'
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = Join-Path $ResolvedStarCraftIIPath "Mods\CMRE\_CMRECustomPrestigesBackup\$timestamp"
$BackedUp = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$InstalledModules = @()

foreach ($manifestFile in $ManifestFiles) {
    $moduleRoot = Split-Path -Parent $manifestFile.FullName
    $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 1) {
        throw "不支持的模块清单版本：$($manifestFile.FullName)"
    }

    foreach ($catalogDefinition in @($manifest.catalog)) {
        $sourceFile = Join-Path $moduleRoot (Join-Path 'catalog' $catalogDefinition.file)
        $targetFile = Join-Path $GameDataDirectory $catalogDefinition.file
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) { throw "缺少数据片段：$sourceFile" }
        if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { throw "CMRE 缺少目标数据文件：$targetFile" }

        $sourceDocument = Load-XmlDocument -Path $sourceFile
        $targetDocument = Load-XmlDocument -Path $targetFile
        $changed = $false

        foreach ($sourceEntry in @($sourceDocument.DocumentElement.ChildNodes | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Element })) {
            $isOwned = Test-EntryDeclaration -CatalogDefinition $catalogDefinition -SourceEntry $sourceEntry
            $targetEntry = Find-CatalogEntry -Document $targetDocument -Type $sourceEntry.LocalName -Id $sourceEntry.GetAttribute('id')
            $importedEntry = $targetDocument.ImportNode($sourceEntry, $true)

            if ($isOwned) {
                if ($null -eq $targetEntry) {
                    [void]$targetDocument.DocumentElement.AppendChild($importedEntry)
                    $changed = $true
                }
                elseif ($targetEntry.OuterXml -ne $sourceEntry.OuterXml) {
                    [void]$targetDocument.DocumentElement.ReplaceChild($importedEntry, $targetEntry)
                    $changed = $true
                }
                continue
            }

            if ($null -eq $targetEntry) {
                throw "补丁目标不存在：$($sourceEntry.LocalName)/$($sourceEntry.GetAttribute('id'))"
            }

            foreach ($sourceChild in @($sourceEntry.ChildNodes | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Element })) {
                $matchingChild = Find-MatchingChild -TargetEntry $targetEntry -SourceChild $sourceChild
                $importedChild = $targetDocument.ImportNode($sourceChild, $true)
                if ($null -eq $matchingChild) {
                    [void]$targetEntry.AppendChild($importedChild)
                    $changed = $true
                }
                elseif ($matchingChild.OuterXml -ne $sourceChild.OuterXml) {
                    [void]$targetEntry.ReplaceChild($importedChild, $matchingChild)
                    $changed = $true
                }
            }
        }

        if ($changed -and $PSCmdlet.ShouldProcess($targetFile, "安装模块 $($manifest.id)")) {
            Backup-TargetFile -TargetFile $targetFile -TargetMod $TargetMod -BackupRoot $BackupRoot -BackedUp $BackedUp
            Save-XmlDocument -Document $targetDocument -Path $targetFile
        }
    }

    foreach ($localeDefinition in @($manifest.locales)) {
        $sourceFile = Join-Path $moduleRoot (Join-Path 'locales' $localeDefinition.file)
        $targetFile = Join-Path $TargetMod "$($localeDefinition.locale).SC2Data\LocalizedData\GameStrings.txt"
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) { throw "缺少本地化片段：$sourceFile" }
        if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { throw "CMRE 缺少本地化文件：$targetFile" }

        $targetLines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in @(Get-Content -LiteralPath $targetFile)) { [void]$targetLines.Add($line) }
        $changed = $false

        foreach ($sourceLine in @(Get-Content -LiteralPath $sourceFile)) {
            if ([string]::IsNullOrWhiteSpace($sourceLine) -or -not $sourceLine.Contains('=')) { continue }
            $key = $sourceLine.Substring(0, $sourceLine.IndexOf('='))
            $foundIndex = -1
            for ($index = 0; $index -lt $targetLines.Count; $index++) {
                if ($targetLines[$index].StartsWith("$key=", [System.StringComparison]::Ordinal)) {
                    $foundIndex = $index
                    break
                }
            }
            if ($foundIndex -lt 0) {
                [void]$targetLines.Add($sourceLine)
                $changed = $true
            }
            elseif ($targetLines[$foundIndex] -ne $sourceLine) {
                $targetLines[$foundIndex] = $sourceLine
                $changed = $true
            }
        }

        if ($changed -and $PSCmdlet.ShouldProcess($targetFile, "安装模块 $($manifest.id) 的本地化文本")) {
            Backup-TargetFile -TargetFile $targetFile -TargetMod $TargetMod -BackupRoot $BackupRoot -BackedUp $BackedUp
            [System.IO.File]::WriteAllLines($targetFile, $targetLines, $Utf8NoBom)
        }
    }

    $InstalledModules += [ordered]@{ id = $manifest.id; version = $manifest.version }
    Write-Host "已安装：$($manifest.name.zhCN) ($($manifest.id)) v$($manifest.version)" -ForegroundColor Green
}

$state = [ordered]@{
    schemaVersion = 1
    installedAt = (Get-Date).ToString('o')
    repositoryRoot = $RepositoryRoot
    backupPath = $(if ($SkipBackup) { $null } else { $BackupRoot })
    modules = $InstalledModules
}
$stateFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_CustomPrestiges.state.json'
if ($PSCmdlet.ShouldProcess($stateFile, '写入安装状态')) {
    [System.IO.File]::WriteAllText($stateFile, ($state | ConvertTo-Json -Depth 8), $Utf8NoBom)
}

Write-Host "完成：共处理 $($InstalledModules.Count) 个威望模块。" -ForegroundColor Cyan
if (-not $SkipBackup) { Write-Host "备份目录：$BackupRoot" }

