# 从零开始安装 CMRE 与自制威望

这份教程写给不熟悉 GitHub、PowerShell 或《星际争霸 II》模组目录的玩家。请按顺序完成，不要跳过 CMRE 的安装。

## 一、需要准备什么

1. Windows 版《星际争霸 II》。
2. CMRE 核心模组和地图。
3. 本仓库的自制威望文件。

CMRE 核心仓库：<https://github.com/WondersReady/CMRE_OpenSource>

本仓库：<https://github.com/ZeratalSky/CMRE-Custom-Prestiges>

## 二、找到《星际争霸 II》根目录

根目录是游戏实际安装所在的 `StarCraft II` 文件夹，不是“文档”里的账号或录像文件夹。常见示例：

```text
C:\Program Files (x86)\StarCraft II
D:\Games\StarCraft II
D:\Game\StarCraft2CN\StarCraft II
```

如果不知道安装位置，可以在战网客户端中打开《星际争霸 II》的设置，选择“在资源管理器中显示”或查看安装位置。

后面的教程统一用下面的示例表示根目录：

```text
D:\Game\StarCraft II
```

请替换成自己电脑上的真实路径。

## 三、下载 CMRE

1. 打开 [CMRE 核心仓库](https://github.com/WondersReady/CMRE_OpenSource)。
2. 点击页面右上方绿色的 **Code** 按钮。
3. 点击 **Download ZIP**。
4. 浏览器下载完成后，右键 ZIP 文件，选择“全部解压”。
5. 解压后会得到类似 `CMRE_OpenSource-main` 的文件夹。

如果 GitHub 页面显示为英文，只需要寻找绿色的 **Code** 按钮和菜单中的 **Download ZIP**，不需要注册 GitHub 账号。

## 四、把 CMRE 放到正确位置

打开解压后的 `CMRE_OpenSource-main`，里面可以看到 `Mods` 和 `Maps` 两个文件夹。把这两个文件夹复制到《星际争霸 II》根目录，并在 Windows 询问时选择合并同名文件夹。

正确做法：

```text
CMRE_OpenSource-main\Mods  ──复制──>  D:\Game\StarCraft II\Mods
CMRE_OpenSource-main\Maps  ──复制──>  D:\Game\StarCraft II\Maps
```

不要把整个 `CMRE_OpenSource-main` 文件夹直接放进 `Mods`，也不要把 `CMRE` 文件夹改名。

安装后至少应能看到：

```text
D:\Game\StarCraft II
├─ Mods
│  └─ CMRE
│     ├─ CMRE_Core_Base.SC2Mod
│     ├─ CMRE_Core_Mengsk.SC2Mod
│     ├─ CMRE_Core_Stetmann.SC2Mod
│     └─ CMRE_Core_Triggers.SC2Mod
└─ Maps
   ├─ CMRE
   │  ├─ Launcher.SC2Map
   │  └─ TestMap.SC2Map
   └─ CM_CoopMaps
```

其中下面这个目录是本自制威望安装器必须检查到的依赖：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_Core_Triggers.SC2Mod
```

CMRE 官方仓库还列出了部分完全本地运行场景可能需要的外部依赖，例如 `CM_ArtPack` 和 `CM_Core_Extra`。这些内容不由本仓库提供；如果 CMRE 启动地图提示缺少依赖，请以 [CMRE 仓库 README](https://github.com/WondersReady/CMRE_OpenSource#readme) 的最新说明为准。

## 五、下载本自制威望合集

1. 打开 [本仓库首页](https://github.com/ZeratalSky/CMRE-Custom-Prestiges)。
2. 点击绿色的 **Code** 按钮。
3. 点击 **Download ZIP**。
4. 下载完成后右键 ZIP 文件，选择“全部解压”。
5. 解压后会得到类似 `CMRE-Custom-Prestiges-main` 的文件夹。

这个文件夹可以放在桌面、下载目录或其他方便的位置，不必放进《星际争霸 II》的 `Mods` 文件夹。建议放到一个不会被随手删除的位置，例如：

```text
D:\SC2Mods\CMRE-Custom-Prestiges-main
```

不要单独移动 `scripts` 或 `prestiges`。正确的仓库结构应保持为：

```text
CMRE-Custom-Prestiges-main
├─ scripts
│  ├─ Install-CMRECustomPrestiges.ps1
│  └─ Uninstall-CMRECustomPrestiges.ps1
├─ prestiges
│  └─ raynor
│     └─ all-in-raiders
├─ docs
└─ README.md
```

## 六、安装自制威望

### 方法一：在文件夹中打开终端

1. 打开解压后的 `CMRE-Custom-Prestiges-main` 文件夹。
2. 在文件夹空白处按住 Shift 并点击鼠标右键，选择“在终端中打开”或“在此处打开 PowerShell”。Windows 11 也可以直接右键选择“在终端中打开”。
3. 复制下面的命令，替换游戏路径后按回车：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\Game\StarCraft II"
```

路径中含有空格时必须保留双引号。

### 方法二：从普通 PowerShell 运行

如果已经打开普通 PowerShell，可以在命令中写出脚本的完整路径：

```powershell
powershell -ExecutionPolicy Bypass -File "D:\SC2Mods\CMRE-Custom-Prestiges-main\scripts\Install-CMRECustomPrestiges.ps1" -StarCraftIIPath "D:\Game\StarCraft II"
```

安装器会自动完成以下工作：

1. 检查 CMRE 核心目录。
2. 扫描 `prestiges` 目录中的全部威望。
3. 自动卸载以前装过、但现在已经从目录移除的威望。
4. 备份即将修改的 CMRE 文件。
5. 安装或更新当前目录中的威望数据与文本。
6. 保存卸载快照和中文安装记录。

看到“CMRE 已与目录保持一致”即表示脚本执行完成。

## 七、检查是否安装成功

安装记录位于：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_自制威望安装记录.txt
```

用记事本打开后，可以看到当前实际安装的中文名称、模块 ID、版本和来源目录。

备份位于：

```text
D:\Game\StarCraft II\Mods\CMRE\_CMRECustomPrestigesBackup
```

卸载快照位于：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_CustomPrestiges.installed
```

请不要手工删除卸载快照，否则已经移出仓库的旧威望可能无法被安全清理。

随后可以使用 CMRE 自带的启动地图或测试地图检查指挥官选择界面：

```text
D:\Game\StarCraft II\Maps\CMRE\Launcher.SC2Map
D:\Game\StarCraft II\Maps\CMRE\TestMap.SC2Map
```

当前版本中，雷诺应出现第 4 个威望“全能游骑兵”。

## 八、增加、停用或恢复威望

`prestiges` 目录就是安装清单，不需要编辑额外的白名单：

- 新威望目录放入 `prestiges/<指挥官>/<威望>` 后，再运行安装器，即可安装。
- 想停用某个威望，把它的整个目录移到 `prestiges` 之外，再运行安装器，即可自动卸载。
- 想恢复威望，把目录移回原位，再运行安装器。
- `prestiges` 目录为空时，安装器会卸载本工具以前安装的全部威望。

不要只删除目录中的某一个 XML 文件；应移动或删除完整的威望目录。

## 九、更新 CMRE 或本仓库

### 更新 CMRE

重新从 CMRE 仓库下载最新版，把新的 `Mods` 和 `Maps` 合并到游戏根目录。CMRE 更新可能覆盖自制数据，所以更新 CMRE 后必须再次运行本仓库的安装器。

### 更新本仓库

不熟悉 Git 时，最简单的方法是重新点击 **Code → Download ZIP** 下载最新版。解压后保留需要启用的 `prestiges` 目录，再运行安装器。

安装器可以重复运行：已有内容会更新，不会重复添加；已经不在目录中的旧威望会自动清理。

## 十、卸载

### 只卸载一个威望

把对应威望目录移出 `prestiges`，然后再次运行安装器。

### 卸载本工具记录的全部自制威望

在仓库目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Uninstall-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\Game\StarCraft II"
```

卸载器只移除本仓库声明的自制条目和补丁节点，并在操作前备份，不会直接使用旧备份覆盖 CMRE 的其他后续改动。

## 十一、常见问题

### 提示“找不到 CMRE_Core_Triggers.SC2Mod”

- 检查 `-StarCraftIIPath` 是否指向游戏根目录。
- 检查是否错误地形成了 `Mods\CMRE_OpenSource-main\Mods\CMRE` 这样的多层目录。
- 正确路径必须是 `<游戏根目录>\Mods\CMRE\CMRE_Core_Triggers.SC2Mod`。

### PowerShell 阻止脚本运行

请完整使用教程中的 `powershell -ExecutionPolicy Bypass -File ...` 命令。这个设置只对本次命令生效，不会永久修改系统执行策略。

### 游戏中没有出现新威望

- 用记事本打开中文安装记录，确认威望已经列出。
- 确认运行的是依赖本地 `CMRE_Core_Triggers.SC2Mod` 的 CMRE 地图。
- 如果刚更新过 CMRE，请重新运行本仓库安装器。
- 先使用 `Maps\CMRE\TestMap.SC2Map` 验证，再测试其他地图。

### CMRE 地图提示缺少其他模组

这通常属于 CMRE 自身的外部依赖，而不是自制威望脚本错误。请查看 [CMRE 官方仓库的安装及外部依赖说明](https://github.com/WondersReady/CMRE_OpenSource#readme)。

### 如何恢复备份

优先运行卸载器。只有 CMRE 文件已经损坏或无法解析时，才手工从 `_CMRECustomPrestigesBackup` 恢复最近一次备份。
