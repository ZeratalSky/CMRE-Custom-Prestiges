[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [string]$StarCraftIIPath,

    [Parameter(Mandatory = $false)]
    [switch]$SkipBackup,

    [Parameter(Mandatory = $false)]
    [string[]]$ModuleId
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$ResolvedStarCraftIIPath = [System.IO.Path]::GetFullPath($StarCraftIIPath)
$TargetMod = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'
$GameDataDirectory = Join-Path $TargetMod 'Base.SC2Data\GameData'
$StateFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_CustomPrestiges.state.json'
$RecordFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_自制威望安装记录.txt'
$CacheRoot = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_CustomPrestiges.installed'

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

function Get-TextPatchMarkers {
    param([string]$ModuleId, [string]$PatchId)
    return [ordered]@{
        Begin = "// CMRE_CUSTOM_PRESTIGE_BEGIN $ModuleId $PatchId"
        End = "// CMRE_CUSTOM_PRESTIGE_END $ModuleId $PatchId"
    }
}

function Remove-TextPatchBlock {
    param([string]$Text, [string]$BeginMarker, [string]$EndMarker)
    $pattern = '(?ms)^[ \t]*' + [regex]::Escape($BeginMarker) + '[ \t]*\r?\n.*?^[ \t]*' + [regex]::Escape($EndMarker) + '[ \t]*(?:\r?\n)?'
    return [regex]::Replace($Text, $pattern, '')
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

$PreviousState = $null
if (Test-Path -LiteralPath $StateFile -PathType Leaf) {
    $PreviousState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
}

$RepositoryManifestFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'prestiges') -Filter 'prestige.json' -File -Recurse | Sort-Object FullName)
$ManifestRecords = @()
$RequestedModuleIds = @()

if (@($ModuleId).Count -gt 0) {
    $RequestedModuleIds = @($ModuleId | Select-Object -Unique)
}
elseif (($null -ne $PreviousState) -and (@($PreviousState.modules).Count -gt 0)) {
    $RequestedModuleIds = @($PreviousState.modules | ForEach-Object { [string]$_.id })
}
else {
    foreach ($repositoryManifestFile in $RepositoryManifestFiles) {
        $ManifestRecords += [ordered]@{ path = $repositoryManifestFile.FullName; fromCache = $false }
    }
}

foreach ($requestedModuleId in $RequestedModuleIds) {
    if ([string]::IsNullOrWhiteSpace($requestedModuleId) -or ($requestedModuleId -notmatch '^[A-Za-z0-9_.-]+$')) {
        throw "模块 ID 为空或含有不安全字符：$requestedModuleId"
    }

    $cachedManifestPath = Join-Path (Join-Path $CacheRoot $requestedModuleId) 'prestige.json'
    if (Test-Path -LiteralPath $cachedManifestPath -PathType Leaf) {
        $ManifestRecords += [ordered]@{ path = $cachedManifestPath; fromCache = $true }
        continue
    }

    $fallbackManifestPath = $null
    foreach ($repositoryManifestFile in $RepositoryManifestFiles) {
        $repositoryManifest = Get-Content -LiteralPath $repositoryManifestFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ([string]$repositoryManifest.id -eq $requestedModuleId) {
            $fallbackManifestPath = $repositoryManifestFile.FullName
            break
        }
    }
    if ($null -ne $fallbackManifestPath) {
        $ManifestRecords += [ordered]@{ path = $fallbackManifestPath; fromCache = $false }
    }
    else {
        Write-Warning "找不到模块 $requestedModuleId 的卸载快照，无法安全自动卸载。请从备份恢复或重新放回该模块后再同步。"
    }
}

$UninstalledModuleIds = @()
foreach ($manifestRecord in $ManifestRecords) {
    $moduleRoot = Split-Path -Parent $manifestRecord.path
    $manifest = Get-Content -LiteralPath $manifestRecord.path -Raw -Encoding UTF8 | ConvertFrom-Json

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
            Get-Content -LiteralPath $sourceFile -Encoding UTF8 |
                Where-Object { (-not [string]::IsNullOrWhiteSpace($_)) -and $_.Contains('=') } |
                ForEach-Object { $_.Substring(0, $_.IndexOf('=')) }
        )
        $originalLines = @(Get-Content -LiteralPath $targetFile -Encoding UTF8)
        $remainingLines = @($originalLines | Where-Object {
            $line = $_
            -not ($keys | Where-Object { $line.StartsWith("$_=", [System.StringComparison]::Ordinal) })
        })
        if ($remainingLines.Count -ne $originalLines.Count -and $PSCmdlet.ShouldProcess($targetFile, "移除模块 $($manifest.id) 的本地化文本")) {
            Backup-TargetFile -TargetFile $targetFile
            [System.IO.File]::WriteAllLines($targetFile, $remainingLines, $Utf8NoBom)
        }
    }

    foreach ($textPatch in @($manifest.textPatches | Where-Object { $null -ne $_ })) {
        $targetFile = [System.IO.Path]::GetFullPath((Join-Path $TargetMod ([string]$textPatch.target)))
        $targetPrefix = $TargetMod.TrimEnd('\') + '\'
        if (-not $targetFile.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "文本补丁目标超出 CMRE_Core_Triggers.SC2Mod：$($textPatch.target)"
        }
        if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { continue }

        $markers = Get-TextPatchMarkers -ModuleId ([string]$manifest.id) -PatchId ([string]$textPatch.id)
        $originalText = [System.IO.File]::ReadAllText($targetFile)
        $updatedText = Remove-TextPatchBlock -Text $originalText -BeginMarker $markers.Begin -EndMarker $markers.End
        if (($updatedText -ne $originalText) -and $PSCmdlet.ShouldProcess($targetFile, "移除模块 $($manifest.id) 的文本补丁 $($textPatch.id)")) {
            Backup-TargetFile -TargetFile $targetFile
            [System.IO.File]::WriteAllText($targetFile, $updatedText, $Utf8NoBom)
        }
    }

    $UninstalledModuleIds += [string]$manifest.id
    Write-Host "已卸载：$($manifest.name.zhCN) ($($manifest.id))" -ForegroundColor Yellow
}

foreach ($uninstalledModuleId in $UninstalledModuleIds) {
    $moduleCache = Join-Path $CacheRoot $uninstalledModuleId
    if ((Test-Path -LiteralPath $moduleCache) -and $PSCmdlet.ShouldProcess($moduleCache, "移除模块 $uninstalledModuleId 的卸载快照")) {
        Remove-Item -LiteralPath $moduleCache -Recurse -Force
    }
}

$RemainingModules = @()
if ($null -ne $PreviousState) {
    $RemainingModules = @($PreviousState.modules | Where-Object { $UninstalledModuleIds -notcontains [string]$_.id })
}

if ($RemainingModules.Count -gt 0) {
    $updatedState = [ordered]@{
        schemaVersion = 2
        installedAt = $PreviousState.installedAt
        synchronizedAt = (Get-Date).ToString('o')
        repositoryRoot = $PreviousState.repositoryRoot
        backupPath = $(if ($SkipBackup) { $PreviousState.backupPath } else { $BackupRoot })
        modules = $RemainingModules
    }
    if ($PSCmdlet.ShouldProcess($StateFile, '更新安装状态')) {
        [System.IO.File]::WriteAllText($StateFile, ($updatedState | ConvertTo-Json -Depth 8), $Utf8NoBom)
    }

    $recordLines = New-Object 'System.Collections.Generic.List[string]'
    [void]$recordLines.Add('CMRE 自制威望安装记录')
    [void]$recordLines.Add("更新时间：$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))")
    [void]$recordLines.Add("当前数量：$($RemainingModules.Count)")
    [void]$recordLines.Add('')
    [void]$recordLines.Add('序号 | 指挥官/威望 | 中文名称 | 模块 ID | 版本')
    [void]$recordLines.Add('-----|-------------|----------|---------|-----')
    $recordIndex = 1
    foreach ($remainingModule in $RemainingModules) {
        $sourcePath = $(if ([string]::IsNullOrWhiteSpace($remainingModule.sourcePath)) { '未知目录' } else { $remainingModule.sourcePath })
        $nameZhCN = $(if ([string]::IsNullOrWhiteSpace($remainingModule.nameZhCN)) { $remainingModule.id } else { $remainingModule.nameZhCN })
        [void]$recordLines.Add("$recordIndex | $sourcePath | $nameZhCN | $($remainingModule.id) | $($remainingModule.version)")
        $recordIndex++
    }
    if ($PSCmdlet.ShouldProcess($RecordFile, '更新中文安装记录')) {
        [System.IO.File]::WriteAllLines($RecordFile, $recordLines, $Utf8NoBom)
    }
}
else {
    if ((Test-Path -LiteralPath $StateFile -PathType Leaf) -and $PSCmdlet.ShouldProcess($StateFile, '移除安装状态')) {
        Remove-Item -LiteralPath $StateFile -Force
    }
    if ((Test-Path -LiteralPath $RecordFile -PathType Leaf) -and $PSCmdlet.ShouldProcess($RecordFile, '移除中文安装记录')) {
        Remove-Item -LiteralPath $RecordFile -Force
    }
    if ((Test-Path -LiteralPath $CacheRoot -PathType Container) -and
        (@(Get-ChildItem -LiteralPath $CacheRoot -Force).Count -eq 0) -and
        $PSCmdlet.ShouldProcess($CacheRoot, '移除空的卸载快照目录')) {
        Remove-Item -LiteralPath $CacheRoot -Force
    }
}

Write-Host "卸载完成：共处理 $($UninstalledModuleIds.Count) 个威望模块。" -ForegroundColor Cyan
if (-not $SkipBackup) { Write-Host "卸载前备份：$BackupRoot" }
