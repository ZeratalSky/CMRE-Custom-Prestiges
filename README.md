# CMRE 自制威望合集

这是一个面向《星际争霸 II》CMRE 合作模式复刻项目的模块化自制威望仓库。当前包含雷诺威望“全能游骑兵”，以后可以继续在 `prestiges` 目录中加入其他指挥官和威望。

## 直接开始

1. 从 [CMRE 核心仓库](https://github.com/WondersReady/CMRE_OpenSource) 点击 **Code → Download ZIP**。
2. 解压 CMRE，把其中的 `Mods` 和 `Maps` 复制到《星际争霸 II》根目录并合并。
3. 从本仓库点击 **Code → Download ZIP**，解压后把整个 `CMRE-Custom-Prestiges-main` 文件夹放进游戏的 `Mods` 文件夹。
4. 保持战网客户端已登录、游戏本体未启动，双击 `安装并启动CMRE.bat`。
5. 首次运行如果本机缓存尚不完整，工具会打开星际争霸 II 编辑器取得战网依赖。地图加载完成后关闭编辑器，脚本会继续准备文件并启动本地 CMRE。

正确位置示例：

```text
D:\StarCraft II\Mods\CMRE-Custom-Prestiges-main\安装并启动CMRE.bat
```

普通玩家不需要打开 PowerShell，也不需要输入游戏路径。BAT 会根据自身位置识别游戏目录，并在路径错误时停止。

完整的下载、目录示例、首次依赖准备和故障处理请看 [从零开始完整安装教程](docs/INSTALLATION.md)。

## 一键启动会做什么

- 扫描 `prestiges` 中的全部 `prestige.json`，安装新增威望并更新已有威望。
- 自动卸载以前安装过、但已从 `prestiges` 移除的威望。
- 备份即将修改的 CMRE 文件，保存安装状态和中文记录。
- 从玩家自己的战网缓存中识别本地任务所需的 CM 资源，并复制到 CMRE 要求的位置。
- 为公开版 CMRE 的新目录与任务地图使用的旧目录建立兼容入口。
- 修正公开版 CMRE 的本地地图路径与切图分支。
- 使用游戏自带的 `SC2Switcher` 打开本地 `Maps\CMRE\Launcher.SC2Map`。

进入启动器后可以选择指挥官、自制威望、突变因子和具体合作地图。雷诺会出现额外威望“全能游骑兵”。

如果只想同步威望而暂时不启动游戏，双击 `安装自制威望.bat`。如果只想提前准备任务依赖，双击 `首次准备CMRE依赖.bat`。

## 战网依赖说明

CMRE 的公开 GitHub 仓库只包含核心模组与地图；整合包、因子包、官方威望包和部分美术包通过战网发布。本工具不会把这些非仓库资源上传或重新分发，只会在玩家已经登录战网并由游戏或编辑器下载后，从玩家自己的 Battle.net 缓存中识别它们。

目前本地任务链会检查：

```text
Mods\CM_ArtPack\CM_ArtPack_Base.SC2Mod
Mods\CM_ArtPack\Campaign_DecensoredPatch.SC2Mod
Mods\CM_ArtPack\CM_ArtPack_Imbalyc.SC2Mod
Mods\CMRE\CMRE_IntegrationPack_Standard.SC2Mod
Mods\CMRE\CMRE_MutatorsPack_CM.SC2Mod
Mods\CMRE\CMRE_PrestigePack_CM.SC2Mod
Mods\CM\CM_Core_Extra.SC2Mod
```

这些必须是真实的 `.SC2Mod` 文件。空文件夹或空占位包虽然可能让编辑器不再弹出“文件不存在”，但进入任务后会造成黑屏、紫色方块和大量素材缺失；安装器会拒绝这种占位方式。

本机缓存不完整时，双击安装与启动 BAT 会尝试打开编辑器准备依赖。如果仍提示缺少文件，请先在战网大厅完整进入一次 CMRE，等待下载完成后关闭游戏，再重新运行 BAT。

## 威望目录就是安装清单

`prestiges` 是唯一安装清单，不需要另外维护白名单：

- 放入新的完整威望目录后再次运行安装器，即可安装或更新。
- 把某个威望目录移到 `prestiges` 之外，再次运行安装器，即可自动卸载。
- `prestiges` 为空时，会卸载本工具以前安装的全部威望。
- 中文安装记录位于 `Mods\CMRE\CMRE_自制威望安装记录.txt`。

安装、卸载和运行环境都有独立状态记录。卸载器只清理本工具记录的自制数据与兼容入口，不会删除从玩家战网缓存准备的外部依赖文件。

## 当前威望

### 雷诺：全能游骑兵

优势：

- 获得雷诺三个原版威望的全部正面效果。
- 不禁用矿骡、不取消机械单位折扣，也不增加单位矿物消耗。
- 休伯利安号保留原版 5 分钟首次解锁，召唤后永久存在，每秒恢复 6 点生命。
- 高级定点防御无人机每 60 秒恢复 1 次使用次数，最多储存 9999 次，实际等同无上限。

劣势：无。

## 后续添加威望

每个威望使用独立目录和清单，未来新增数量不写死。开发说明与模板见 [添加新威望](docs/ADDING_PRESTIGES.md) 和 `templates/new-prestige`。

## 兼容性

本项目是 CMRE 的增量扩展，必须先安装 CMRE，不能脱离 CMRE 单独运行。CMRE 或战网发布依赖更新后，文件结构与缓存版本可能变化；更新 CMRE 后请重新运行 `安装并启动CMRE.bat`。安装器若无法确认当前缓存版本会停止并显示缺少项，不会用空占位包继续启动。

## 来源与致谢

- [WondersReady/CMRE_OpenSource](https://github.com/WondersReady/CMRE_OpenSource) 是本项目依赖的 CMRE 核心模组与地图仓库；感谢 CMRE 作者和贡献者。本仓库不包含或重新发布完整 CMRE。
- 部分威望机制资料、设计参考或说明整理自公开网络页面；每个模块应在自己的 `SOURCES.md` 中注明具体来源和用途。
- 网络公开不等于放弃著作权。原始项目、网页内容、游戏素材及名称的权利归各自权利人所有。
- 当前雷诺模块的具体来源说明见 [`prestiges/raynor/all-in-raiders/SOURCES.md`](prestiges/raynor/all-in-raiders/SOURCES.md)。

## 声明

这是非官方玩家项目，需要用户自行拥有《星际争霸 II》以及可用的 CMRE 文件。本仓库只保存自制增量数据和安装工具，不打包完整 CMRE、战网缓存或第三方游戏资源。
