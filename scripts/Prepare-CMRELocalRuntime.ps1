[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StarCraftIIPath,

    [Parameter(Mandatory = $false)]
    [switch]$AllowEditorDownload,

    [Parameter(Mandatory = $false)]
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$StarCraftIIPath = [System.IO.Path]::GetFullPath($StarCraftIIPath)
$CmreRoot = Join-Path $StarCraftIIPath 'Mods\CMRE'
$GalaxyFile = Join-Path $CmreRoot 'CMRE_Core_Triggers.SC2Mod\Base.SC2Data\LibCOOC.galaxy'
$RuntimeRoot = Join-Path $CmreRoot 'CMRE_CustomPrestiges.runtime-backup'
$BackupFile = Join-Path $RuntimeRoot 'LibCOOC.galaxy.original'
$StateFile = Join-Path $CmreRoot 'CMRE_CustomPrestiges.runtime.json'
$CacheRoot = Join-Path $env:ProgramData 'Blizzard Entertainment\Battle.net\Cache'
$LocalPatchMarker = '// CMRE-Custom-Prestiges: force local task-map switching.'

function Get-Sha256 {
    param([string]$Path)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $bytes = $algorithm.ComputeHash($stream)
        return (($bytes | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally {
        $stream.Dispose()
        $algorithm.Dispose()
    }
}

function Get-CachePath {
    param([string]$Hash)
    return Join-Path $CacheRoot (Join-Path $Hash.Substring(0, 2) (Join-Path $Hash.Substring(2, 2) "$Hash.s2ma"))
}

function Get-DependencySource {
    param($Dependency)
    foreach ($hash in @($Dependency.Hashes)) {
        $candidate = Get-CachePath -Hash $hash
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }
    return $null
}

function Get-MissingDependencies {
    param([array]$Dependencies)
    return @($Dependencies | Where-Object {
        $target = Join-Path $StarCraftIIPath $_.Target
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { return $true }
        $targetHash = Get-Sha256 -Path $target
        return (@($_.Hashes) -notcontains $targetHash)
    })
}

function Start-DependencyDownload {
    $EditorCandidates = @(
        (Join-Path $StarCraftIIPath 'Support64\SC2Editor_x64.exe'),
        (Join-Path $StarCraftIIPath 'Support\SC2Editor.exe'),
        (Join-Path $StarCraftIIPath 'StarCraft II Editor_x64.exe'),
        (Join-Path $StarCraftIIPath 'StarCraft II Editor.exe')
    )
    $EditorPath = @($EditorCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1)
    if ($EditorPath.Count -eq 0) {
        throw '缺少星际争霸 II 编辑器，无法自动准备战网依赖。请在战网客户端中安装或扫描修复编辑器。'
    }

    if (Get-Process -Name 'SC2Editor_x64','SC2Editor' -ErrorAction SilentlyContinue) {
        throw '编辑器正在运行。请先关闭星际争霸 II 编辑器，再重新双击 BAT。'
    }

    $DownloadMap = Join-Path $StarCraftIIPath 'Maps\CM_CoopMaps\Rand\Rifts to Korhal.SC2Map'
    if (-not (Test-Path -LiteralPath $DownloadMap -PathType Leaf)) {
        throw "缺少用于准备依赖的任务地图：$DownloadMap"
    }

    Write-Host ''
    Write-Host '首次运行需要让编辑器从战网取得 CMRE 公开发布的依赖。' -ForegroundColor Yellow
    Write-Host '请保持战网客户端已登录、游戏本体未启动。编辑器打开并完成地图加载后，直接关闭编辑器即可。' -ForegroundColor Cyan
    Write-Host '如果弹出依赖错误，请选择“否”，关闭编辑器，然后回到这个窗口。' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '正在打开依赖准备地图……' -ForegroundColor Gray
    $process = Start-Process -FilePath $EditorPath[0] -ArgumentList @("`"$DownloadMap`"") -PassThru
    $process.WaitForExit()
    Start-Sleep -Milliseconds 800
}

function Ensure-DependencyFiles {
    param(
        [array]$Dependencies,
        [switch]$MayDownload
    )

    if (-not (Test-Path -LiteralPath $CacheRoot -PathType Container)) {
        throw "没有找到战网缓存目录：$CacheRoot。请先登录战网客户端并打开一次 CMRE 大厅版。"
    }

    $missing = Get-MissingDependencies -Dependencies $Dependencies
    $unavailable = @($missing | Where-Object { $null -eq (Get-DependencySource -Dependency $_) })
    if (($unavailable.Count -gt 0) -and $MayDownload) {
        Write-Host '本地缓存尚未包含全部依赖：' -ForegroundColor Yellow
        foreach ($dependency in $unavailable) { Write-Host "  - $($dependency.Name)" -ForegroundColor DarkYellow }
        Start-DependencyDownload
        $missing = Get-MissingDependencies -Dependencies $Dependencies
        $unavailable = @($missing | Where-Object { $null -eq (Get-DependencySource -Dependency $_) })
    }

    if ($unavailable.Count -gt 0) {
        $names = $unavailable | ForEach-Object { $_.Name }
        throw "战网缓存中仍缺少当前 CMRE 版本需要的依赖：$($names -join '、')。请先在战网大厅完整进入一次 CMRE，等待下载完成后关闭游戏，再重新运行 BAT。"
    }

    $installed = @()
    foreach ($dependency in $Dependencies) {
        $target = Join-Path $StarCraftIIPath $dependency.Target
        if (Test-Path -LiteralPath $target -PathType Container) {
            throw "发现无效的文件夹占位依赖：$target。请删除该文件夹后重新运行；真实依赖必须是 .SC2Mod 文件。"
        }
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $targetHash = Get-Sha256 -Path $target
            if (@($dependency.Hashes) -contains $targetHash) {
                Write-Host "依赖已存在：$($dependency.Name)" -ForegroundColor DarkGray
                continue
            }
        }

        $source = Get-DependencySource -Dependency $dependency
        if ($null -eq $source) { throw "无法定位依赖缓存：$($dependency.Name)" }
        $targetDirectory = Split-Path -Parent $target
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            $relativeBackup = [string]$dependency.Target
            $dependencyBackup = Join-Path $RuntimeRoot (Join-Path 'dependency-originals' $relativeBackup)
            New-Item -ItemType Directory -Path (Split-Path -Parent $dependencyBackup) -Force | Out-Null
            if (-not (Test-Path -LiteralPath $dependencyBackup -PathType Leaf)) {
                Copy-Item -LiteralPath $target -Destination $dependencyBackup
            }
            Copy-Item -LiteralPath $source -Destination $target -Force
            Write-Host "已备份并替换不匹配的依赖：$($dependency.Name)" -ForegroundColor Green
        }
        else {
            Copy-Item -LiteralPath $source -Destination $target
            Write-Host "已从本机战网缓存准备：$($dependency.Name)" -ForegroundColor Green
        }
        $installed += [pscustomobject][ordered]@{
            name = $dependency.Name
            target = $dependency.Target
            sourceHash = [System.IO.Path]::GetFileNameWithoutExtension($source)
        }
    }
    return @($installed)
}

function Ensure-CoreAliases {
    $aliases = @(
        [pscustomobject]@{ Target = 'Mods\CM\CM_Core_Base.SC2Mod'; Source = 'Mods\CMRE\CMRE_Core_Base.SC2Mod' },
        [pscustomobject]@{ Target = 'Mods\CM\CM_Core_Mengsk.SC2Mod'; Source = 'Mods\CMRE\CMRE_Core_Mengsk.SC2Mod' },
        [pscustomobject]@{ Target = 'Mods\CM\CM_Core_Stetmann.SC2Mod'; Source = 'Mods\CMRE\CMRE_Core_Stetmann.SC2Mod' }
    )
    $created = @()

    foreach ($alias in $aliases) {
        $source = Join-Path $StarCraftIIPath $alias.Source
        $target = Join-Path $StarCraftIIPath $alias.Target
        if (-not (Test-Path -LiteralPath $source -PathType Container)) {
            throw "CMRE 核心目录不完整：$source"
        }
        if (Test-Path -LiteralPath $target) {
            Write-Host "兼容路径已存在：$($alias.Target)" -ForegroundColor DarkGray
            continue
        }

        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        New-Item -ItemType Junction -Path $target -Target $source | Out-Null
        $created += [pscustomobject][ordered]@{ target = $alias.Target; source = $alias.Source }
        Write-Host "已建立核心兼容路径：$($alias.Target)" -ForegroundColor Green
    }
    return @($created)
}

function Patch-LocalMapSwitching {
    if (-not (Test-Path -LiteralPath $GalaxyFile -PathType Leaf)) {
        throw "缺少 CMRE 切图脚本：$GalaxyFile"
    }

    $content = [System.IO.File]::ReadAllText($GalaxyFile)
    $alreadyPatched = $content.Contains('lv_return = "CM_CoopMaps\\" + lv_race + "\\" + lv_file + ".SC2Map";') -and
        $content.Contains('if (false) {')

    New-Item -ItemType Directory -Path $RuntimeRoot -Force | Out-Null
    if (-not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) {
        if ($alreadyPatched) {
            $original = $content.Replace("    $LocalPatchMarker`r`n    if (false) {", '    if ((GameIsOnline() == true)) {')
            $original = $original.Replace("    $LocalPatchMarker`n    if (false) {", '    if ((GameIsOnline() == true)) {')
            $original = $original.Replace('    if (false) {', '    if ((GameIsOnline() == true)) {')
            $original = $original.Replace('    lv_return = "CM_CoopMaps\\" + lv_race + "\\" + lv_file + ".SC2Map";', '    lv_return = "\"CM_CoopMaps\\\\\" + lv_race + \"\\\\\" + lv_file + \".SC2Map\"";')
            [System.IO.File]::WriteAllText($BackupFile, $original, $Utf8NoBom)
        }
        else {
            Copy-Item -LiteralPath $GalaxyFile -Destination $BackupFile
        }
    }

    if (-not $alreadyPatched) {
        $pathFunctionStart = $content.IndexOf('string libCOOC_gf_CC_CampaignMapFile', [System.StringComparison]::Ordinal)
        $pathFunctionEnd = $content.IndexOf('int libCOOC_gf_CC_MapSlot', $pathFunctionStart, [System.StringComparison]::Ordinal)
        if (($pathFunctionStart -lt 0) -or ($pathFunctionEnd -lt 0)) { throw '无法定位 CMRE 本地地图路径函数。' }
        $pathFunction = $content.Substring($pathFunctionStart, $pathFunctionEnd - $pathFunctionStart)
        $assignments = [regex]::Matches($pathFunction, '(?m)^[ \t]*lv_return\s*=.*;\r?$')
        if ($assignments.Count -lt 2) { throw 'CMRE 地图路径函数结构与安装器不兼容。' }
        $assignment = $assignments[$assignments.Count - 1]
        $replacement = '    lv_return = "CM_CoopMaps\\" + lv_race + "\\" + lv_file + ".SC2Map";'
        $absoluteIndex = $pathFunctionStart + $assignment.Index
        $content = $content.Remove($absoluteIndex, $assignment.Length).Insert($absoluteIndex, $replacement)

        $loadFunctionStart = $content.IndexOf('void libCOOC_gf_LoadNextMap', [System.StringComparison]::Ordinal)
        $loadFunctionEnd = $content.IndexOf('void libCOOC_gf_CC_ObjectiveRegister', $loadFunctionStart, [System.StringComparison]::Ordinal)
        if (($loadFunctionStart -lt 0) -or ($loadFunctionEnd -lt 0)) { throw '无法定位 CMRE 切图函数。' }
        $loadFunction = $content.Substring($loadFunctionStart, $loadFunctionEnd - $loadFunctionStart)
        $onlineMatch = [regex]::Match($loadFunction, 'if\s*\(\(GameIsOnline\(\)\s*==\s*true\)\)\s*\{')
        if (-not $onlineMatch.Success) { throw 'CMRE 切图条件与安装器不兼容。' }
        $absoluteIndex = $loadFunctionStart + $onlineMatch.Index
        $replacement = "$LocalPatchMarker`r`n    if (false) {"
        $content = $content.Remove($absoluteIndex, $onlineMatch.Length).Insert($absoluteIndex, $replacement)

        [System.IO.File]::WriteAllText($GalaxyFile, $content, $Utf8NoBom)
        Write-Host '已启用 CMRE 本地任务地图切换。' -ForegroundColor Green
    }
    else {
        if (-not $content.Contains($LocalPatchMarker)) {
            $loadFunctionStart = $content.IndexOf('void libCOOC_gf_LoadNextMap', [System.StringComparison]::Ordinal)
            $loadFunctionEnd = $content.IndexOf('void libCOOC_gf_CC_ObjectiveRegister', $loadFunctionStart, [System.StringComparison]::Ordinal)
            if (($loadFunctionStart -lt 0) -or ($loadFunctionEnd -lt 0)) { throw '无法定位 CMRE 切图函数。' }
            $loadFunction = $content.Substring($loadFunctionStart, $loadFunctionEnd - $loadFunctionStart)
            $localMatch = [regex]::Match($loadFunction, 'if\s*\(false\)\s*\{')
            if (-not $localMatch.Success) { throw '无法标记已经存在的本地切图修改。' }
            $absoluteIndex = $loadFunctionStart + $localMatch.Index
            $replacement = "$LocalPatchMarker`r`n    if (false) {"
            $content = $content.Remove($absoluteIndex, $localMatch.Length).Insert($absoluteIndex, $replacement)
            [System.IO.File]::WriteAllText($GalaxyFile, $content, $Utf8NoBom)
        }
        Write-Host 'CMRE 本地任务地图切换已经启用。' -ForegroundColor DarkGray
    }

    return [ordered]@{
        backupFile = $BackupFile
        originalHash = Get-Sha256 -Path $BackupFile
        patchedHash = Get-Sha256 -Path $GalaxyFile
    }
}

function Restore-LocalRuntime {
    if (-not (Test-Path -LiteralPath $StateFile -PathType Leaf)) {
        Write-Host '没有检测到本工具的本地运行改动记录。' -ForegroundColor DarkGray
        return
    }

    $state = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ((Test-Path -LiteralPath $BackupFile -PathType Leaf) -and (Test-Path -LiteralPath $GalaxyFile -PathType Leaf)) {
        $currentHash = Get-Sha256 -Path $GalaxyFile
        if (($currentHash -eq [string]$state.mapSwitch.patchedHash) -or ([System.IO.File]::ReadAllText($GalaxyFile).Contains($LocalPatchMarker))) {
            Copy-Item -LiteralPath $BackupFile -Destination $GalaxyFile -Force
            Write-Host '已恢复 CMRE 原始切图脚本。' -ForegroundColor Green
        }
        else {
            Write-Host 'CMRE 切图脚本后来又被修改，未用旧备份覆盖它。' -ForegroundColor Yellow
        }
    }

    foreach ($alias in @($state.createdAliases)) {
        if (($null -eq $alias) -or [string]::IsNullOrWhiteSpace([string]$alias.target)) { continue }
        $target = [System.IO.Path]::GetFullPath((Join-Path $StarCraftIIPath ([string]$alias.target)))
        $allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $StarCraftIIPath 'Mods\CM')) + '\'
        if (-not $target.StartsWith($allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Host "跳过记录范围外的兼容路径：$target" -ForegroundColor Yellow
            continue
        }
        if (Test-Path -LiteralPath $target) {
            $item = Get-Item -LiteralPath $target -Force
            if ($item.LinkType -eq 'Junction') {
                [System.IO.Directory]::Delete($target, $false)
                Write-Host "已移除核心兼容路径：$target" -ForegroundColor Green
            }
        }
    }

    Remove-Item -LiteralPath $StateFile -Force
    Write-Host '外部依赖文件已保留，其他 CMRE 本地地图仍可继续使用。' -ForegroundColor DarkGray
}

if (-not (Test-Path -LiteralPath $CmreRoot -PathType Container)) {
    throw "没有找到 CMRE：$CmreRoot"
}

if ($Restore) {
    Restore-LocalRuntime
    return
}

if (Get-Process SC2_x64 -ErrorAction SilentlyContinue) {
    throw '星际争霸 II 正在运行。请先退出游戏，战网客户端可以保持登录。'
}

$Dependencies = @(
    [pscustomobject]@{ Name = 'CM_ArtPack_Base'; Target = 'Mods\CM_ArtPack\CM_ArtPack_Base.SC2Mod'; Hashes = @('b4d1b209983830b2a69202c80649f908ee9393db4ec93a58dc5686f71d3ce0d6','85c4bd00a8bcaf0ed16eeebf96cda38ae89efc6cc4d7ec88c099f1e2637204ea') },
    [pscustomobject]@{ Name = 'Campaign_DecensoredPatch'; Target = 'Mods\CM_ArtPack\Campaign_DecensoredPatch.SC2Mod'; Hashes = @('9249a63588d56f04c0edf0eba3d608beab000e38f24fa17911e666cb5ca1e9a5') },
    [pscustomobject]@{ Name = 'CM_ArtPack_Imbalyc'; Target = 'Mods\CM_ArtPack\CM_ArtPack_Imbalyc.SC2Mod'; Hashes = @('46ba949ada1cb9a6bc55114a3a4a4a0e4f642d95d8875387c52e1fd2a12f194c') },
    [pscustomobject]@{ Name = 'CMRE_IntegrationPack_Standard'; Target = 'Mods\CMRE\CMRE_IntegrationPack_Standard.SC2Mod'; Hashes = @('5dd3d923dbbc485222449377990ecc9569b9a8bb54e0e49701a246c327be1f3c','7e4d6cc71d613d04cc541bd492eb6ba871d24f2418ec580439cff332763deaac') },
    [pscustomobject]@{ Name = 'CM_MutatorsPack_CM'; Target = 'Mods\CMRE\CMRE_MutatorsPack_CM.SC2Mod'; Hashes = @('db242172a1cf743403933cca3ca678c7d8ecba979ccfeeebc507c3d9eb2e800d','1b1dc38fe6000ab97a4d56a0a65f9bde696f9a36f5940f30134c46da5186da0f','f9996297fd76e23a4c57949b0a01bb1d3edfb90ce186fe8112ae5280913501bb') },
    [pscustomobject]@{ Name = 'CM_PrestigePack_CM'; Target = 'Mods\CMRE\CMRE_PrestigePack_CM.SC2Mod'; Hashes = @('de1733d6bb4f78db76a3bddf71c4ff63de5ddfdd6b56d901d87d5993dc7e6fc2','c643ab4de3a4a7496852111d5ebc4f4afa906a729ba397b7d66e9bcdd8b48934') },
    [pscustomobject]@{ Name = 'CM_Core_Extra'; Target = 'Mods\CM\CM_Core_Extra.SC2Mod'; Hashes = @('5ce0d92b495b6db4fdc2b4b41a31e4a82b1f1fafcb67fc202d7976b0e8fe1771') }
)

$installedDependencies = Ensure-DependencyFiles -Dependencies $Dependencies -MayDownload:$AllowEditorDownload
$createdAliases = Ensure-CoreAliases
$mapSwitch = Patch-LocalMapSwitching

$previousInstalledDependencies = @()
$previousCreatedAliases = @()
if (Test-Path -LiteralPath $StateFile -PathType Leaf) {
    $previousState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $previousInstalledDependencies = @($previousState.installedDependencies | Where-Object { $null -ne $_.target })
    $previousCreatedAliases = @($previousState.createdAliases | Where-Object { $null -ne $_.target })
}
$allInstalledDependencies = @($previousInstalledDependencies) + @($installedDependencies)
$allInstalledDependencies = @($allInstalledDependencies | Group-Object target | ForEach-Object { $_.Group[0] })
$allCreatedAliases = @($previousCreatedAliases) + @($createdAliases)
$allCreatedAliases = @($allCreatedAliases | Group-Object target | ForEach-Object { $_.Group[0] })

$state = [ordered]@{
    schemaVersion = 1
    preparedAt = (Get-Date).ToString('o')
    installedDependencies = [object[]]$allInstalledDependencies
    createdAliases = [object[]]$allCreatedAliases
    mapSwitch = $mapSwitch
}
[System.IO.File]::WriteAllText($StateFile, ($state | ConvertTo-Json -Depth 8), $Utf8NoBom)

Write-Host ''
Write-Host '[成功] CMRE 本地任务运行环境已经准备完成。' -ForegroundColor Green
