[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$StarCraftIIPath
)

$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepositoryRoot = Split-Path -Parent $PSScriptRoot

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Resolve-StarCraftIIPath {
    param([string]$RequestedPath)

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) { $candidates += $RequestedPath }
    $repositoryParent = Split-Path -Parent $RepositoryRoot
    if ((Split-Path -Leaf $repositoryParent) -ieq 'Mods') {
        $candidates += (Split-Path -Parent $repositoryParent)
    }
    $candidates += @('C:\Program Files (x86)\StarCraft II', 'C:\Program Files\StarCraft II')

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        $resolved = [System.IO.Path]::GetFullPath($candidate)
        if (Test-Path -LiteralPath (Join-Path $resolved 'Mods\CMRE\CMRE_Core_Triggers.SC2Mod') -PathType Container) {
            return $resolved
        }
    }
    throw '找不到 CMRE_Core_Triggers.SC2Mod。请确认本合集位于游戏根目录的 Mods 文件夹中。'
}

function Get-CommanderName {
    param([string]$Commander)
    switch ($Commander) {
        'TerranRaynor' { return '雷诺' }
        'ProtossArtanis' { return '阿塔尼斯' }
        default { return $Commander }
    }
}

try {
    $ResolvedStarCraftIIPath = Resolve-StarCraftIIPath -RequestedPath $StarCraftIIPath
    $SelectionFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_自制威望选择.txt'
    $StateFile = Join-Path $ResolvedStarCraftIIPath 'Mods\CMRE\CMRE_CustomPrestiges.state.json'
    $Installer = Join-Path $PSScriptRoot 'Install-CMRECustomPrestiges.ps1'
    $ManifestFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'prestiges') -Filter 'prestige.json' -File -Recurse | Sort-Object FullName)

    $Modules = @(
        foreach ($manifestFile in $ManifestFiles) {
            $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            [pscustomobject]@{
                Id = [string]$manifest.id
                Name = [string]$manifest.name.zhCN
                Commander = Get-CommanderName -Commander ([string]$manifest.commander)
            }
        }
    )

    $SelectedIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    if (Test-Path -LiteralPath $SelectionFile -PathType Leaf) {
        foreach ($line in @(Get-Content -LiteralPath $SelectionFile -Encoding UTF8)) {
            $moduleId = $line.Trim()
            if (-not [string]::IsNullOrWhiteSpace($moduleId) -and -not $moduleId.StartsWith('#')) {
                [void]$SelectedIds.Add($moduleId)
            }
        }
    }
    else {
        foreach ($module in $Modules) { [void]$SelectedIds.Add($module.Id) }
    }
}
catch {
    [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'CMRE 威望选择器', 'OK', 'Error')
    exit 1
}

$Form = New-Object System.Windows.Forms.Form
$Form.Text = 'CMRE 自制威望选择器'
$Form.StartPosition = 'CenterScreen'
$Form.Size = New-Object System.Drawing.Size(790, 470)
$Form.MinimumSize = New-Object System.Drawing.Size(700, 400)
$Form.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 9)

$Description = New-Object System.Windows.Forms.Label
$Description.Text = '勾选需要安装的威望。保存后会自动安装勾选项，并卸载未勾选项。'
$Description.AutoSize = $true
$Description.Location = New-Object System.Drawing.Point(18, 18)
$Form.Controls.Add($Description)

$CommanderLabel = New-Object System.Windows.Forms.Label
$CommanderLabel.Text = '指挥官：'
$CommanderLabel.AutoSize = $true
$CommanderLabel.Location = New-Object System.Drawing.Point(18, 55)
$Form.Controls.Add($CommanderLabel)

$CommanderFilter = New-Object System.Windows.Forms.ComboBox
$CommanderFilter.DropDownStyle = 'DropDownList'
$CommanderFilter.Location = New-Object System.Drawing.Point(80, 50)
$CommanderFilter.Size = New-Object System.Drawing.Size(160, 28)
[void]$CommanderFilter.Items.Add('全部指挥官')
foreach ($commander in @($Modules.Commander | Sort-Object -Unique)) {
    [void]$CommanderFilter.Items.Add($commander)
}
$CommanderFilter.SelectedIndex = 0
$Form.Controls.Add($CommanderFilter)

$List = New-Object System.Windows.Forms.ListView
$List.Location = New-Object System.Drawing.Point(18, 84)
$List.Size = New-Object System.Drawing.Size(738, 264)
$List.Anchor = 'Top,Bottom,Left,Right'
$List.View = 'Details'
$List.CheckBoxes = $true
$List.FullRowSelect = $true
$List.GridLines = $true
$List.HideSelection = $false
[void]$List.Columns.Add('威望', 245)
[void]$List.Columns.Add('指挥官', 110)
[void]$List.Columns.Add('当前状态', 95)
[void]$List.Columns.Add('模块 ID', 270)
$Form.Controls.Add($List)

function Get-InstalledIds {
    $ids = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    if (Test-Path -LiteralPath $StateFile -PathType Leaf) {
        $state = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($module in @($state.modules)) { [void]$ids.Add([string]$module.id) }
    }
    return $ids
}

function Refresh-ModuleList {
    $installedIds = Get-InstalledIds
    $selectedCommander = [string]$CommanderFilter.SelectedItem
    $List.BeginUpdate()
    try {
        $List.Items.Clear()
        foreach ($module in $Modules) {
            if ($selectedCommander -ne '全部指挥官' -and $module.Commander -ne $selectedCommander) { continue }
            $item = New-Object System.Windows.Forms.ListViewItem($module.Name)
            [void]$item.SubItems.Add($module.Commander)
            [void]$item.SubItems.Add($(if ($installedIds.Contains($module.Id)) { '已安装' } else { '未安装' }))
            [void]$item.SubItems.Add($module.Id)
            $item.Tag = $module.Id
            $item.Checked = $SelectedIds.Contains($module.Id)
            [void]$List.Items.Add($item)
        }
    }
    finally { $List.EndUpdate() }
}

function Save-VisibleSelections {
    foreach ($item in $List.Items) {
        if ($item.Checked) {
            [void]$SelectedIds.Add([string]$item.Tag)
        }
        else {
            [void]$SelectedIds.Remove([string]$item.Tag)
        }
    }
}

$CommanderFilter.Add_SelectedIndexChanged({
    Save-VisibleSelections
    Refresh-ModuleList
})

$SelectAllButton = New-Object System.Windows.Forms.Button
$SelectAllButton.Text = '当前全选'
$SelectAllButton.Size = New-Object System.Drawing.Size(90, 32)
$SelectAllButton.Location = New-Object System.Drawing.Point(18, 365)
$SelectAllButton.Anchor = 'Bottom,Left'
$SelectAllButton.Add_Click({ foreach ($item in $List.Items) { $item.Checked = $true } })
$Form.Controls.Add($SelectAllButton)

$SelectNoneButton = New-Object System.Windows.Forms.Button
$SelectNoneButton.Text = '当前取消'
$SelectNoneButton.Size = New-Object System.Drawing.Size(90, 32)
$SelectNoneButton.Location = New-Object System.Drawing.Point(116, 365)
$SelectNoneButton.Anchor = 'Bottom,Left'
$SelectNoneButton.Add_Click({ foreach ($item in $List.Items) { $item.Checked = $false } })
$Form.Controls.Add($SelectNoneButton)

$CloseButton = New-Object System.Windows.Forms.Button
$CloseButton.Text = '关闭'
$CloseButton.Size = New-Object System.Drawing.Size(90, 32)
$CloseButton.Location = New-Object System.Drawing.Point(666, 365)
$CloseButton.Anchor = 'Bottom,Right'
$CloseButton.Add_Click({ $Form.Close() })
$Form.Controls.Add($CloseButton)

$SyncButton = New-Object System.Windows.Forms.Button
$SyncButton.Text = '保存并同步'
$SyncButton.Size = New-Object System.Drawing.Size(120, 32)
$SyncButton.Location = New-Object System.Drawing.Point(538, 365)
$SyncButton.Anchor = 'Bottom,Right'
$Form.Controls.Add($SyncButton)
$Form.AcceptButton = $SyncButton
$Form.CancelButton = $CloseButton

$Status = New-Object System.Windows.Forms.Label
$Status.Text = "选择记录：$SelectionFile"
$Status.AutoEllipsis = $true
$Status.Location = New-Object System.Drawing.Point(18, 407)
$Status.Size = New-Object System.Drawing.Size(738, 22)
$Status.Anchor = 'Bottom,Left,Right'
$Form.Controls.Add($Status)

$SyncButton.Add_Click({
    try {
        Save-VisibleSelections
        $lines = New-Object 'System.Collections.Generic.List[string]'
        [void]$lines.Add('# 每行一个需要安装的威望模块 ID；请优先使用图形选择器修改。')
        foreach ($module in $Modules) {
            if ($SelectedIds.Contains($module.Id)) { [void]$lines.Add($module.Id) }
        }
        [System.IO.File]::WriteAllLines($SelectionFile, $lines, $Utf8NoBom)

        $Form.UseWaitCursor = $true
        $SyncButton.Enabled = $false
        $Status.Text = '正在同步，请稍候……'
        $Form.Refresh()
        $output = (& $Installer -StarCraftIIPath $ResolvedStarCraftIIPath -Confirm:$false 2>&1 | Out-String)
        Refresh-ModuleList
        $Status.Text = "同步完成。已选择 $($SelectedIds.Count) 个威望。"
        [void][System.Windows.Forms.MessageBox]::Show("同步完成。`n`n已安装 $($SelectedIds.Count) 个威望。重新启动 CMRE 后生效。", 'CMRE 威望选择器', 'OK', 'Information')
    }
    catch {
        $Status.Text = '同步失败。'
        [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '同步失败', 'OK', 'Error')
    }
    finally {
        $Form.UseWaitCursor = $false
        $SyncButton.Enabled = $true
    }
})

Refresh-ModuleList
[void][System.Windows.Forms.Application]::Run($Form)
