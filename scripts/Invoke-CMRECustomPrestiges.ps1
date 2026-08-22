[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Install', 'Uninstall')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$ModsDirectory = Split-Path -Parent $RepositoryRoot
$ModsDirectoryName = Split-Path -Leaf $ModsDirectory
$StarCraftIIPath = Split-Path -Parent $ModsDirectory
$TriggerMod = Join-Path $StarCraftIIPath 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod'

try {
    Write-Host '========================================' -ForegroundColor DarkCyan
    if ($Action -eq 'Install') {
        Write-Host '       CMRE 自制威望一键安装器' -ForegroundColor Cyan
    }
    else {
        Write-Host '       CMRE 自制威望一键卸载器' -ForegroundColor Cyan
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
    if ($Action -eq 'Install') {
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
    }
    else {
        Write-Host '正在卸载本工具记录的全部自制威望，请稍候……' -ForegroundColor Gray
        Write-Host ''
        $CoreScript = Join-Path $PSScriptRoot 'Uninstall-CMRECustomPrestiges.ps1'
        if (-not (Test-Path -LiteralPath $CoreScript -PathType Leaf)) {
            throw '卸载核心脚本缺失。请重新下载完整仓库，不要单独移动 BAT 文件。'
        }
        & $CoreScript -StarCraftIIPath $StarCraftIIPath -Confirm:$false
        Write-Host ''
        Write-Host '[成功] 本工具记录的自制威望已经卸载。' -ForegroundColor Green
    }

    exit 0
}
catch {
    Write-Host ''
    Write-Host "[失败] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '没有继续修改文件。请按上方提示检查目录。' -ForegroundColor Yellow
    exit 1
}
