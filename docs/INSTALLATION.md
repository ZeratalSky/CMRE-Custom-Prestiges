# CMRE 与自制威望安装教程

下面的步骤适用于 Windows 版《星际争霸 II》。正常安装只需要下载 ZIP、复制文件夹和双击 BAT。

## 准备

需要以下内容：

1. 已安装的《星际争霸 II》和星际争霸 II 编辑器。
2. [CMRE 核心仓库](https://github.com/WondersReady/CMRE_OpenSource)。
3. [CMRE 自制威望合集](https://github.com/ZeratalSky/CMRE-Custom-Prestiges)。
4. 可以正常登录的战网客户端。

游戏根目录是包含 `Mods`、`Maps` 和 `Support64` 等文件夹的 `StarCraft II` 目录。可以在战网客户端的游戏设置中查看安装位置。常见路径例如：

```text
C:\Program Files (x86)\StarCraft II
D:\Games\StarCraft II
D:\Game\StarCraft2CN\StarCraft II
```

后文使用 `D:\Game\StarCraft II` 作为示例，请换成自己的实际路径。

## 安装 CMRE 核心

1. 打开 [WondersReady/CMRE_OpenSource](https://github.com/WondersReady/CMRE_OpenSource)。
2. 点击 **Code → Download ZIP**。
3. 解压下载的文件。
4. 打开 `CMRE_OpenSource-main`，把其中的 `Mods` 和 `Maps` 复制到游戏根目录。
5. Windows 询问时选择合并同名文件夹。

复制后的主要目录如下：

```text
D:\Game\StarCraft II
├─ Mods
│  └─ CMRE
│     ├─ CMRE_Core_Base.SC2Mod
│     ├─ CMRE_Core_Mengsk.SC2Mod
│     ├─ CMRE_Core_Stetmann.SC2Mod
│     └─ CMRE_Core_Triggers.SC2Mod
└─ Maps
   └─ CMRE
      └─ Launcher.SC2Map
```

## 安装自制威望合集

1. 打开 [ZeratalSky/CMRE-Custom-Prestiges](https://github.com/ZeratalSky/CMRE-Custom-Prestiges)。
2. 点击 **Code → Download ZIP**。
3. 解压后得到 `CMRE-Custom-Prestiges-main`。
4. 把这个完整文件夹移动到游戏根目录的 `Mods` 中，使它与 `CMRE` 并列。

```text
D:\Game\StarCraft II\Mods
├─ CMRE
└─ CMRE-Custom-Prestiges-main
   ├─ 安装并启动CMRE.bat
   ├─ 首次准备CMRE依赖.bat
   ├─ 安装自制威望.bat
   ├─ 卸载自制威望.bat
   ├─ prestiges
   └─ scripts
```

## 首次启动

1. 登录战网客户端。
2. 确认游戏本体和编辑器已经关闭。
3. 双击 `Mods\CMRE-Custom-Prestiges-main\安装并启动CMRE.bat`。
4. 等待威望同步和依赖检查完成。

如果本机已经有完整依赖，脚本会直接打开本地 CMRE 启动器。

如果还缺少战网资源，脚本会打开星际争霸 II 编辑器：

1. 保留黑色安装窗口。
2. 等编辑器完成下载和地图加载。
3. 关闭编辑器。
4. 安装窗口会继续准备依赖并启动 CMRE。

仍有缺少项时，先在战网大厅完整进入一次 CMRE，等地图下载完毕后退出游戏，再双击 `首次准备CMRE依赖.bat`。

## 战网依赖

CMRE 的部分整合包、因子、官方威望和美术资源通过战网分发。工具会从玩家自己的 Battle.net 缓存中识别当前版本，并放到本地任务需要的位置：

```text
Mods\CM_ArtPack\CM_ArtPack_Base.SC2Mod
Mods\CM_ArtPack\Campaign_DecensoredPatch.SC2Mod
Mods\CM_ArtPack\CM_ArtPack_Imbalyc.SC2Mod
Mods\CMRE\CMRE_IntegrationPack_Standard.SC2Mod
Mods\CMRE\CMRE_MutatorsPack_CM.SC2Mod
Mods\CMRE\CMRE_PrestigePack_CM.SC2Mod
Mods\CM\CM_Core_Extra.SC2Mod
```

任务地图还会使用几个旧版核心路径。启动器会为这些路径建立本地兼容入口，并让它们指向已经安装的公开版 CMRE 核心，不会额外复制多份文件。

这些战网资源不会上传到 GitHub，也不会由本仓库重新分发。

## 进入游戏

本地启动器打开后：

1. 选择指挥官。
2. 选择威望。
3. 设置突变因子、难度和任务地图。
4. 点击准备就绪。

目前可以选择：

- 雷诺：全能游骑兵
- 阿塔尼斯：全能大主教

安装记录位于：

```text
D:\Game\StarCraft II\Mods\CMRE\CMRE_自制威望安装记录.txt
```

## 更新

更新 CMRE 时，重新下载核心仓库 ZIP，把新的 `Mods` 和 `Maps` 合并到游戏根目录，然后再次运行 `安装并启动CMRE.bat`。

更新本仓库时，重新下载 ZIP 并替换原来的自制威望文件夹。需要保留个人模块时，请先备份 `prestiges` 中自己的目录，再运行安装 BAT 完成同步。

## 停用与卸载

`prestiges` 是当前安装清单。

- 停用单个威望：把它的完整目录移到 `prestiges` 外，再运行 `安装自制威望.bat`。
- 重新启用：把目录移回原处，再运行安装 BAT。
- 卸载全部自制威望：双击 `卸载自制威望.bat`。

卸载器只处理本工具记录的增量数据和兼容入口。已经从玩家缓存准备的战网依赖会保留，避免影响其他本地 CM/CMRE 地图。

## 常见问题

### 找不到 CMRE 核心

确认以下目录存在：

```text
<游戏根目录>\Mods\CMRE\CMRE_Core_Triggers.SC2Mod
```

自制威望文件夹应直接位于 `<游戏根目录>\Mods`，不要放进 `Mods\CMRE`。

### 依赖仍不完整

登录战网客户端，从大厅进入一次 CMRE 并等待下载结束。退出游戏后，再运行 `首次准备CMRE依赖.bat`。

### 选择任务后没有进入本地任务

关闭游戏，重新运行 `安装并启动CMRE.bat`。不要直接打开 `CM_CoopMaps` 中的单张任务地图，应从 `Maps\CMRE\Launcher.SC2Map` 进入。

### 游戏没有启动

在战网客户端中对《星际争霸 II》执行“扫描和修复”，并确认 `Support64\SC2Switcher_x64.exe` 或 `Support\SC2Switcher.exe` 存在。

### 安全软件拦截 BAT

BAT 是文本文件，只会调用仓库中的脚本和游戏自带程序。可以先用记事本查看内容，并确认下载来源是本仓库。
