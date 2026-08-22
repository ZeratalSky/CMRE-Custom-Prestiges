# 从零开始安装 CMRE 与自制威望

这份教程写给不熟悉 GitHub 或《星际争霸 II》模组目录的玩家。请按顺序完成，不要跳过 CMRE 的安装。

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

把整个 `CMRE-Custom-Prestiges-main` 文件夹移动到《星际争霸 II》根目录下的 `Mods` 文件夹中。BAT 安装器会根据这个位置自动识别游戏路径，因此不要放到桌面、下载目录或 `Mods` 的更深层子目录。

```text
D:\Game\StarCraft II\Mods\CMRE-Custom-Prestiges-main
```

它应当与 `CMRE` 文件夹并列。不要把它放进 `Mods\CMRE`，也不要单独移动 BAT、`scripts` 或 `prestiges`。正确结构如下：

```text
D:\Game\StarCraft II
└─ Mods
   ├─ CMRE
   │  └─ CMRE_Core_Triggers.SC2Mod
   └─ CMRE-Custom-Prestiges-main
      ├─ 安装自制威望.bat
      ├─ 安装并启动CMRE.bat
      ├─ 卸载自制威望.bat
      ├─ scripts
      │  ├─ Install-CMRECustomPrestiges.ps1
      │  └─ Uninstall-CMRECustomPrestiges.ps1
      ├─ prestiges
      │  └─ raynor
      │     └─ all-in-raiders
      ├─ docs
      └─ README.md
```

## 六、安装并启动 CMRE

1. 打开解压后的 `CMRE-Custom-Prestiges-main` 文件夹。
2. 双击 `安装并启动CMRE.bat`。
3. 等待黑色窗口完成检查和安装，不要在执行过程中关闭窗口。
4. 看到绿色的安装信息以及“自制威望已经与 prestiges 目录同步完成”后，工具会自动打开本地 CMRE 启动器。
5. 在 CMRE 启动器里选择指挥官、威望、突变因子和具体合作地图，然后开始游戏。

不需要手工输入游戏路径。BAT 会检查自己的父目录是否为 `Mods`，再检查同级的 `CMRE\CMRE_Core_Triggers.SC2Mod`；任一位置不正确都会停止，不会向猜测的路径写入数据。

BAT 内部会调用仓库自带的 PowerShell 核心脚本，但普通玩家不需要打开 PowerShell，也不需要复制命令。启动阶段使用游戏自带的 `Support64\SC2Switcher_x64.exe`（旧安装会自动改用 32 位版本）加载 `Maps\CMRE\Launcher.SC2Map`，不会进入战网大厅发布版。

安装器会自动完成以下工作：

1. 检查 CMRE 核心目录。
2. 扫描 `prestiges` 目录中的全部威望。
3. 自动卸载以前装过、但现在已经从目录移除的威望。
4. 备份即将修改的 CMRE 文件。
5. 安装或更新当前目录中的威望数据与文本。
6. 保存卸载快照和中文安装记录。
7. 使用本地 CMRE 启动器地图进入游戏。

看到“CMRE 已与目录保持一致”即表示脚本执行完成。

如果只想安装或更新威望，不想立即打开游戏，可以双击 `安装自制威望.bat`。如果要在编辑器中检查测试地图，可以双击 `打开本地CMRE测试地图.bat`。

联合启动器会检查 CMRE 完全本地运行常用的 `CM_ArtPack` 和 `CM_Core_Extra`。缺少时只会显示提示并继续启动；如果随后出现依赖错误，请按 CMRE 核心仓库的外部依赖说明补齐文件。

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

`安装并启动CMRE.bat` 会直接使用 CMRE 启动地图检查指挥官选择界面；也可以手工在编辑器中打开测试地图：

```text
D:\Game\StarCraft II\Maps\CMRE\Launcher.SC2Map
D:\Game\StarCraft II\Maps\CMRE\TestMap.SC2Map
```

当前版本中，雷诺应出现第 4 个威望“全能游骑兵”。

## 八、增加、停用或恢复威望

`prestiges` 目录就是安装清单，不需要编辑额外的白名单：

- 新威望目录放入 `prestiges/<指挥官>/<威望>` 后，再双击 `安装自制威望.bat`，即可安装。
- 想停用某个威望，把它的整个目录移到 `prestiges` 之外，再双击安装 BAT，即可自动卸载。
- 想恢复威望，把目录移回原位并再次双击安装 BAT。
- `prestiges` 目录为空时，双击安装 BAT 会卸载本工具以前安装的全部威望。

不要只删除目录中的某一个 XML 文件；应移动或删除完整的威望目录。

## 九、更新 CMRE 或本仓库

### 更新 CMRE

重新从 CMRE 仓库下载最新版，把新的 `Mods` 和 `Maps` 合并到游戏根目录。CMRE 更新可能覆盖自制数据，所以更新 CMRE 后必须再次双击 `安装自制威望.bat`。

### 更新本仓库

不熟悉 Git 时，最简单的方法是重新点击 **Code → Download ZIP** 下载最新版。解压后把新文件夹放回游戏的 `Mods` 文件夹，保留需要启用的 `prestiges` 目录，再双击安装 BAT。

安装器可以重复运行：已有内容会更新，不会重复添加；已经不在目录中的旧威望会自动清理。

## 十、卸载

### 只卸载一个威望

把对应威望目录移出 `prestiges`，然后再次双击 `安装自制威望.bat`。

### 卸载本工具记录的全部自制威望

双击仓库根目录中的 `卸载自制威望.bat`。

卸载器只移除本仓库声明的自制条目和补丁节点，并在操作前备份，不会直接使用旧备份覆盖 CMRE 的其他后续改动。

## 十一、常见问题

### 提示“找不到 CMRE_Core_Triggers.SC2Mod”

- 检查 `CMRE-Custom-Prestiges-main` 是否直接位于游戏的 `Mods` 文件夹中。
- 检查是否错误地形成了 `Mods\CMRE_OpenSource-main\Mods\CMRE` 这样的多层目录。
- 正确路径必须是 `<游戏根目录>\Mods\CMRE\CMRE_Core_Triggers.SC2Mod`。

### 双击 BAT 后窗口提示路径错误

不要单独复制 BAT。确认完整仓库文件夹直接位于 `<游戏根目录>\Mods`，并且 CMRE 位于同一个 `Mods` 下的 `CMRE` 文件夹中。

### 同步成功，但游戏没有启动

- 检查游戏目录中是否存在 `Support64\SC2Switcher_x64.exe` 或 `Support\SC2Switcher.exe`。
- 在战网客户端中对《星际争霸 II》执行“扫描和修复”，然后再次双击 `安装并启动CMRE.bat`。
- 如果安全软件拦截游戏自带的启动程序，请确认目标文件位于自己的《星际争霸 II》安装目录。

### Windows 安全软件拦截 BAT

BAT 是可以用记事本查看的文本文件，内部只调用仓库中的 PowerShell 安装脚本。如果安全软件拦截，请先核对文件来自本仓库，再根据系统提示选择允许；不要从第三方网盘下载别人重新打包的 EXE。

### 游戏中没有出现新威望

- 用记事本打开中文安装记录，确认威望已经列出。
- 确认运行的是依赖本地 `CMRE_Core_Triggers.SC2Mod` 的 CMRE 地图。
- 如果刚更新过 CMRE，请重新运行本仓库安装器。
- 先使用 `Maps\CMRE\TestMap.SC2Map` 验证，再测试其他地图。

### CMRE 地图提示缺少其他模组

这通常属于 CMRE 自身的外部依赖，而不是自制威望脚本错误。请查看 [CMRE 官方仓库的安装及外部依赖说明](https://github.com/WondersReady/CMRE_OpenSource#readme)。

### 如何恢复备份

优先运行卸载器。只有 CMRE 文件已经损坏或无法解析时，才手工从 `_CMRECustomPrestigesBackup` 恢复最近一次备份。
