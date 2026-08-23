[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Install', 'Uninstall', 'OpenTestMap', 'InstallAndLaunch', 'PrepareDependencies')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$ModsDirectory = Split-Path -Parent $RepositoryRoot
$ModsDirectoryName = Split-Path -Leaf $ModsDirectory
$StarCraftIIPath = Split-Path -Parent $ModsDirectory
$TriggerMod = Join-Path $StarCraftIIPath 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'

function Start-CMRELauncher {
    $LauncherMap = Join-Path $StarCraftIIPath 'Maps\CMRE\Launcher.SC2Map'
    if (-not (Test-Path -LiteralPath $LauncherMap)) {
        throw "没有找到 CMRE 启动器地图：$LauncherMap。请重新安装完整的 CMRE Maps 文件夹。"
    }

    $SwitcherCandidates = @(
        (Join-Path $StarCraftIIPath 'Support64\SC2Switcher_x64.exe'),
        (Join-Path $StarCraftIIPath 'Support\SC2Switcher.exe')
    )
    $SwitcherPath = @($SwitcherCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1)
    if ($SwitcherPath.Count -eq 0) {
        throw '没有找到《星际争霸 II》本地启动程序 SC2Switcher。请在战网客户端中扫描和修复游戏。'
    }

    Write-Host "CMRE 启动器：$LauncherMap" -ForegroundColor Gray
    Write-Host "游戏启动程序：$($SwitcherPath[0])" -ForegroundColor Gray
    if ($env:CMCP_NO_LAUNCH -eq '1') {
        Write-Host '[测试模式] 路径检查通过，未实际启动游戏。' -ForegroundColor DarkYellow
        return
    }

    Start-Process -FilePath $SwitcherPath[0] -WorkingDirectory $StarCraftIIPath -ArgumentList @('-run', "`"$LauncherMap`"")
    Write-Host ''
    Write-Host '[成功] 已启动本地 CMRE 启动器。' -ForegroundColor Green
    Write-Host '进入后可以继续选择指挥官、威望、突变因子和具体合作地图。' -ForegroundColor Cyan
}

try {
    Write-Host '========================================' -ForegroundColor DarkCyan
    if ($Action -eq 'Install') {
        Write-Host '       CMRE 自制威望一键安装器' -ForegroundColor Cyan
    }
    elseif ($Action -eq 'InstallAndLaunch') {
        Write-Host '       CMRE 威望同步与游戏启动器' -ForegroundColor Cyan
    }
    elseif ($Action -eq 'Uninstall') {
        Write-Host '       CMRE 自制威望一键卸载器' -ForegroundColor Cyan
    }
    elseif ($Action -eq 'PrepareDependencies') {
        Write-Host '       CMRE 首次依赖准备工具' -ForegroundColor Cyan
    }
    else {
        Write-Host '       CMRE 本地测试地图启动器' -ForegroundColor Cyan
    }
    Write-Host '========================================' -ForegroundColor DarkCyan
    Write-Host ''

    if ($ModsDirectoryName -ine 'Mods') {
        throw "当前文件夹没有直接放在游戏的 Mods 文件夹中。请把整个 $((Split-Path -Leaf $RepositoryRoot)) 文件夹移动到：<星际争霸 II 根目录>\Mods\"
    }
    if (-not (Test-Path -LiteralPath $TriggerMod -PathType Container)) {
        throw "没有找到 CMRE 核心模组：$TriggerMod。请先安装 CMRE，并确认 CMRE 文件夹没有改名。"
    }

    Write-Host "游戏目录：$StarCraftIIPath" -ForegroundColor Gray
    if ($Action -in @('Install', 'InstallAndLaunch')) {
        Write-Host '正在检查并同步 prestiges 目录，请稍候……' -ForegroundColor Gray
        Write-Host ''
        $CoreScript = Join-Path $PSScriptRoot 'Install-CMRECustomPrestiges.ps1'
        if (-not (Test-Path -LiteralPath $CoreScript -PathType Leaf)) {
            throw '安装核心脚本缺失。请重新下载完整仓库，不要单独移动 BAT 文件。'
        }
        & $CoreScript -StarCraftIIPath $StarCraftIIPath -Confirm:$false
        Write-Host ''
        Write-Host '[成功] 自制威望已经与 prestiges 目录同步完成。' -ForegroundColor Green
        Write-Host "安装记录：$(Join-Path $StarCraftIIPath 'Mods\CMRE\CMRE_自制威望安装记录.txt')" -ForegroundColor Cyan
        if ($Action -eq 'InstallAndLaunch') {
            Write-Host ''
            Write-Host '正在检查战网缓存并准备本地任务依赖……' -ForegroundColor Gray
            $RuntimeScript = Join-Path $PSScriptRoot 'Prepare-CMRELocalRuntime.ps1'
            if (-not (Test-Path -LiteralPath $RuntimeScript -PathType Leaf)) {
                throw '本地运行环境脚本缺失。请重新下载完整仓库。'
            }
            & $RuntimeScript -StarCraftIIPath $StarCraftIIPath -AllowEditorDownload
            Write-Host ''
            Write-Host '正在打开本地 CMRE 启动器……' -ForegroundColor Gray
            Start-CMRELauncher
        }
    }
    elseif ($Action -eq 'PrepareDependencies') {
        $RuntimeScript = Join-Path $PSScriptRoot 'Prepare-CMRELocalRuntime.ps1'
        if (-not (Test-Path -LiteralPath $RuntimeScript -PathType Leaf)) {
            throw '本地运行环境脚本缺失。请重新下载完整仓库。'
        }
        Write-Host '正在检查战网缓存并准备本地任务依赖……' -ForegroundColor Gray
        Write-Host ''
        & $RuntimeScript -StarCraftIIPath $StarCraftIIPath -AllowEditorDownload
    }
    elseif ($Action -eq 'Uninstall') {
        Write-Host '正在卸载本工具记录的全部自制威望，请稍候……' -ForegroundColor Gray
        Write-Host ''
        $CoreScript = Join-Path $PSScriptRoot 'Uninstall-CMRECustomPrestiges.ps1'
        if (-not (Test-Path -LiteralPath $CoreScript -PathType Leaf)) {
            throw '卸载核心脚本缺失。请重新下载完整仓库，不要单独移动 BAT 文件。'
        }
        & $CoreScript -StarCraftIIPath $StarCraftIIPath -Confirm:$false
        $RuntimeScript = Join-Path $PSScriptRoot 'Prepare-CMRELocalRuntime.ps1'
        if (Test-Path -LiteralPath $RuntimeScript -PathType Leaf) {
            & $RuntimeScript -StarCraftIIPath $StarCraftIIPath -Restore
        }
        Write-Host ''
        Write-Host '[成功] 本工具记录的自制威望已经卸载。' -ForegroundColor Green
    }
    else {
        $TestMap = Join-Path $StarCraftIIPath 'Maps\CMRE\TestMap.SC2Map'
        if (-not (Test-Path -LiteralPath $TestMap)) {
            throw "没有找到 CMRE 测试地图：$TestMap。请重新安装完整的 CMRE Maps 文件夹。"
        }

        $EditorCandidates = @(
            (Join-Path $StarCraftIIPath 'StarCraft II Editor_x64.exe'),
            (Join-Path $StarCraftIIPath 'StarCraft II Editor.exe'),
            (Join-Path $StarCraftIIPath 'Support64\SC2Editor_x64.exe'),
            (Join-Path $StarCraftIIPath 'Support\SC2Editor.exe')
        )
        $EditorPath = @($EditorCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1)
        if ($EditorPath.Count -eq 0) {
            throw '没有找到《星际争霸 II》编辑器。请在战网客户端中安装或修复游戏编辑器。'
        }

        Write-Host "测试地图：$TestMap" -ForegroundColor Gray
        Write-Host "游戏编辑器：$($EditorPath[0])" -ForegroundColor Gray
        if ($env:CMCP_NO_LAUNCH -eq '1') {
            Write-Host '[测试模式] 路径检查通过，未实际启动编辑器。' -ForegroundColor DarkYellow
        }
        else {
            Start-Process -FilePath $EditorPath[0] -ArgumentList @("`"$TestMap`"")
            Write-Host ''
            Write-Host '[成功] 已打开本地 CMRE 测试地图。' -ForegroundColor Green
            Write-Host '地图加载完成后，在编辑器顶部选择“文件 → 测试文档（Test Document）”。' -ForegroundColor Cyan
        }
    }

    exit 0
}
catch {
    Write-Host ''
    Write-Host "[失败] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '没有继续修改文件。请按上方提示检查目录。' -ForegroundColor Yellow
    exit 1
}
