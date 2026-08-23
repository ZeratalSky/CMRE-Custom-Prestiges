# 从零开始安装 CMRE 与自制威望

这份教程写给不熟悉 GitHub、模组目录或 PowerShell 的玩家。普通安装只需要下载 ZIP、复制文件夹和双击 BAT，不需要输入命令。

## 一、需要准备什么

1. Windows 版《星际争霸 II》。
2. 星际争霸 II 编辑器；如果没有，请在战网客户端中安装或扫描修复。
3. [CMRE 核心仓库](https://github.com/WondersReady/CMRE_OpenSource)中的核心模组与地图。
4. [本自制威望仓库](https://github.com/ZeratalSky/CMRE-Custom-Prestiges)。
5. 首次准备依赖时，战网客户端需要保持登录；游戏本体应当关闭。

公开仓库只提供 CMRE 核心。任务所需的整合包、因子包、官方威望包和部分美术包会由游戏/编辑器从战网取得。本工具只读取玩家自己的 Battle.net 缓存，不在 GitHub 中重新分发这些资源。

## 二、找到游戏根目录

根目录是游戏实际安装所在的 `StarCraft II` 文件夹，不是“文档”中的录像或账号文件夹。常见示例：

```text
C:\Program Files (x86)\StarCraft II
D:\Games\StarCraft II
D:\Game\StarCraft2CN\StarCraft II
```

不知道位置时，在战网客户端中打开《星际争霸 II》的设置，查看安装位置或选择“在资源管理器中显示”。

后文用 `D:\Game\StarCraft II` 作为示例，请换成自己的真实路径。

## 三、下载并安装 CMRE 核心

1. 打开 [WondersReady/CMRE_OpenSource](https://github.com/WondersReady/CMRE_OpenSource)。
2. 点击绿色 **Code** 按钮。
3. 点击 **Download ZIP**。
4. 下载完成后右键 ZIP，选择“全部解压”。
5. 打开解压得到的 `CMRE_OpenSource-main`。
6. 把其中的 `Mods` 和 `Maps` 两个文件夹复制到《星际争霸 II》根目录。
7. Windows 询问时选择合并同名文件夹。

正确关系：

```text
CMRE_OpenSource-main\Mods  ──复制──>  D:\Game\StarCraft II\Mods
CMRE_OpenSource-main\Maps  ──复制──>  D:\Game\StarCraft II\Maps
```

不要把整个 `CMRE_OpenSource-main` 直接塞进 `Mods`。安装后至少应有：

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
      ├─ Rand
      ├─ Prot
      ├─ Terr
      └─ Zerg
```

`Mods\CMRE`、`Maps\CMRE` 和 `Maps\CM_CoopMaps` 都不能随意改名。

## 四、下载本自制威望合集

1. 打开 [ZeratalSky/CMRE-Custom-Prestiges](https://github.com/ZeratalSky/CMRE-Custom-Prestiges)。
2. 点击绿色 **Code → Download ZIP**。
3. 解压后得到类似 `CMRE-Custom-Prestiges-main` 的文件夹。
4. 把这个完整文件夹移动到游戏根目录下的 `Mods` 中。

正确位置：

```text
D:\Game\StarCraft II\Mods\CMRE-Custom-Prestiges-main
```

它应当与 `CMRE` 并列，不要放进 `Mods\CMRE`，也不要只复制 BAT。正确结构示例：

```text
D:\Game\StarCraft II\Mods
├─ CMRE
│  └─ CMRE_Core_Triggers.SC2Mod
└─ CMRE-Custom-Prestiges-main
   ├─ 安装并启动CMRE.bat
   ├─ 首次准备CMRE依赖.bat
   ├─ 安装自制威望.bat
   ├─ 卸载自制威望.bat
   ├─ scripts
   ├─ prestiges
   ├─ templates
   └─ README.md
```

## 五、首次安装并启动

1. 登录战网客户端。
2. 确认《星际争霸 II》游戏本体没有运行。
3. 打开 `Mods\CMRE-Custom-Prestiges-main`。
4. 双击 `安装并启动CMRE.bat`。
5. 黑色窗口会先同步威望，再检查本地任务依赖。

如果依赖已经存在，工具会直接完成准备并打开本地 CMRE。

如果缓存尚不完整，工具会打开星际争霸 II 编辑器：

1. 不要关闭黑色安装窗口。
2. 等编辑器完成下载并打开任务地图。
3. 如果编辑器弹出“Dependency file could not be found”，选择“否”。
4. 关闭编辑器。
5. 安装窗口会继续扫描缓存、准备依赖并启动 CMRE。

如果第一次没有准备完整，可以先在战网游戏大厅进入一次 CMRE，等待所有内容下载完成，然后退出游戏，再双击 `首次准备CMRE依赖.bat` 或 `安装并启动CMRE.bat`。

## 六、本地依赖会放到哪里

脚本会从玩家自己的 Battle.net 缓存中识别与当前已验证版本匹配的真实文件，并放到 CMRE/任务地图要求的位置：

```text
Mods\CM_ArtPack\CM_ArtPack_Base.SC2Mod
Mods\CM_ArtPack\Campaign_DecensoredPatch.SC2Mod
Mods\CM_ArtPack\CM_ArtPack_Imbalyc.SC2Mod
Mods\CMRE\CMRE_IntegrationPack_Standard.SC2Mod
Mods\CMRE\CMRE_MutatorsPack_CM.SC2Mod
Mods\CMRE\CMRE_PrestigePack_CM.SC2Mod
Mods\CM\CM_Core_Extra.SC2Mod
```

同时会为任务地图使用的旧核心路径建立三个本地兼容入口，它们指向已经安装的公开版 CMRE 核心：

```text
Mods\CM\CM_Core_Base.SC2Mod      → Mods\CMRE\CMRE_Core_Base.SC2Mod
Mods\CM\CM_Core_Mengsk.SC2Mod    → Mods\CMRE\CMRE_Core_Mengsk.SC2Mod
Mods\CM\CM_Core_Stetmann.SC2Mod  → Mods\CMRE\CMRE_Core_Stetmann.SC2Mod
```

这些入口不会复制三份核心内容。脚本还会备份并修正 CMRE 的本地任务路径和切图分支，使登录着战网客户端时仍然使用本地任务地图。

严禁用空文件夹或空 `.SC2Mod` 占位。占位包会造成任务中黑屏、紫色方块、UI 丢失或只有计时器正常。脚本检测到文件夹占位时会停止。

## 七、进入 CMRE 后怎么做

本地启动器打开后：

1. 选择指挥官。
2. 选择威望；雷诺应出现“全能游骑兵”。
3. 选择突变因子、难度和任务地图。
4. 点击“准备就绪”。

首次切图可能比以后慢，因为游戏需要读取较多本地依赖。正常情况应当能看到完整的任务加载画面、地形、单位、头像和 UI，而不是回到未登录界面或出现黑屏占位块。

## 八、如何确认安装成功

中文安装记录：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_自制威望安装记录.txt
```

威望数据备份：

```text
D:\Game\StarCraft II\Mods\CMRE\_CMRECustomPrestigesBackup
```

本地运行环境记录：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_CustomPrestiges.runtime.json
```

当前版本中，雷诺选择页应出现额外威望“全能游骑兵”，并能从该选择页正常进入具体合作任务。

## 九、增加或停用威望

`prestiges` 就是安装清单：

- 新威望放入 `prestiges/<指挥官>/<威望>` 后，重新运行安装 BAT。
- 停用某个威望时，把它的完整目录移到 `prestiges` 之外，再运行安装 BAT。
- 恢复时把目录移回原位。
- 不要只删除目录中的某一个 XML。

未来制作新威望请看 [添加新威望](ADDING_PRESTIGES.md)。

## 十、更新

### 更新 CMRE

重新下载 CMRE 最新 ZIP，把新的 `Mods` 和 `Maps` 合并到游戏根目录。更新可能覆盖威望数据或切图脚本，因此更新后必须再次双击 `安装并启动CMRE.bat`。

### 更新本仓库

重新点击 **Code → Download ZIP**，把新版完整文件夹放回游戏的 `Mods` 中。保留自己需要的 `prestiges` 内容，再次运行 BAT。不要只更新其中一个脚本。

如果 CMRE 或战网依赖发布了新版本，而脚本无法确认缓存文件，它会列出缺少项并停止；请先进入一次战网大厅版 CMRE。仍无法识别时，应等待本仓库更新依赖指纹，不要自行创建空占位包。

## 十一、卸载

### 只停用一个威望

把对应目录移出 `prestiges`，再双击 `安装自制威望.bat`。

### 卸载本工具记录的全部自制威望

双击 `卸载自制威望.bat`。卸载器会：

- 移除本工具记录的自制威望数据；
- 恢复本工具备份的 CMRE 切图脚本；
- 移除本工具创建的三个旧路径兼容入口；
- 保留已经从玩家战网缓存准备的真实外部依赖文件。

保留外部依赖是为了避免影响其他本地 CM/CMRE 地图，也避免下次重新复制大文件。

## 十二、常见问题

### 提示找不到 `CMRE_Core_Triggers.SC2Mod`

- 确认完整仓库文件夹直接位于游戏的 `Mods` 中。
- 确认 CMRE 正确路径为 `<游戏根目录>\Mods\CMRE\CMRE_Core_Triggers.SC2Mod`。
- 检查是否形成了 `Mods\CMRE_OpenSource-main\Mods\CMRE` 这样的多层目录。

### 缓存中仍缺少依赖

1. 登录战网客户端。
2. 在大厅中完整进入一次 CMRE，等待下载完成。
3. 退出游戏，保留战网客户端登录。
4. 重新双击 `首次准备CMRE依赖.bat`。

脚本不会从第三方网盘下载依赖，也不会上传这些文件到 GitHub。

### 进入任务后黑屏、紫色方块，只有计时器正常

这表示因子包、官方威望包或美术包不是真实完整文件。删除自己创建的空文件夹/空占位 `.SC2Mod`，再运行首次依赖准备 BAT。真实的 `CMRE_MutatorsPack_CM.SC2Mod` 和 `CMRE_PrestigePack_CM.SC2Mod` 都是文件，不是空目录。

### 选择任务后回到未登录界面

这表示本地切图修正没有生效，或 CMRE 更新覆盖了它。关闭游戏，重新运行 `安装并启动CMRE.bat`。

### 加载的是旧 CM，而且没有自制威望

不要直接双击某个 `CM_CoopMaps` 任务地图。直接启动任务会走地图自己的旧依赖链。必须从本仓库启动的本地 `Maps\CMRE\Launcher.SC2Map` 选择“全能游骑兵”，再由启动器切入任务。

### 游戏没有启动

- 检查 `Support64\SC2Switcher_x64.exe` 或 `Support\SC2Switcher.exe` 是否存在。
- 在战网客户端中对游戏执行“扫描和修复”。
- 确认游戏本体已经完全退出，再运行 BAT。

### 安全软件拦截 BAT

BAT 是可用记事本查看的文本文件，只调用仓库内的 PowerShell 脚本和游戏自带程序。请确认文件来自本仓库，不要使用第三方重新打包的 EXE。
