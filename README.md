# CMRE 自制威望合集

这是一个面向《星际争霸 II》CMRE 合作模式复刻项目的模块化自制威望仓库。

本仓库面向使用者的介绍、安装说明、更新记录、来源说明和威望制作教程统一使用简体中文。代码标识、文件名以及 `enUS` 游戏文本属于程序兼容内容，不属于英文说明文档。

当前包含：

- 雷诺：**全能游骑兵**

## 设计目标

- 每个威望使用独立目录，避免不同威望的数据混在一起。
- `prestiges` 目录是唯一安装清单；安装器自动发现其中的 `prestige.json`，未来新增威望没有固定数量上限。
- 重复运行安装器会安装新增模块、更新保留模块，并自动卸载已经从 `prestiges` 目录移除的模块。
- CMRE 目录中自动保存中文安装记录和卸载快照，即使模块目录已经删除，也能精确清理旧威望。
- 安装和卸载前自动备份将要修改的 CMRE 文件。
- 不覆盖原版三个威望；自制威望会作为额外选项加入。

## 新手安装概览

1. 从 [CMRE 核心仓库](https://github.com/WondersReady/CMRE_OpenSource) 点击 **Code → Download ZIP** 下载 CMRE。
2. 解压 CMRE，把其中的 `Mods` 和 `Maps` 复制到《星际争霸 II》根目录并合并；不要复制外层 `CMRE_OpenSource-main` 文件夹。
3. 从本仓库点击 **Code → Download ZIP**，解压到桌面或 `D:\SC2Mods` 等方便的位置。
4. 在本仓库解压目录打开 PowerShell，运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\StarCraft II"
```

把 `D:\StarCraft II` 改成自己的《星际争霸 II》根目录。安装完成后进入 CMRE 的指挥官选择界面，雷诺会出现第 4 个威望。

想停用某个自制威望，只需删除或移走它在 `prestiges` 下的目录，然后再次运行安装器。安装记录位于 `Mods/CMRE/CMRE_自制威望安装记录.txt`。

第一次安装或不熟悉 GitHub 时，请阅读包含目录示例和故障排查的 [从零开始完整安装教程](docs/INSTALLATION.md)。想继续制作新威望，请看 [添加新威望](docs/ADDING_PRESTIGES.md)。

## 兼容性说明

本项目是 **CMRE 的增量扩展，必须先安装 CMRE**，不能脱离 CMRE 单独运行。安装器需要以下目录版核心模组：

```text
Mods/CMRE/CMRE_Core_Triggers.SC2Mod
```

CMRE 更新可能改变数据结构。更新 CMRE 后建议重新运行安装器，并在测试地图中验证自制威望。

## 来源与致谢

- [WondersReady/CMRE_OpenSource](https://github.com/WondersReady/CMRE_OpenSource) 是本项目依赖的 CMRE 核心模组与地图仓库；感谢 CMRE 作者和贡献者。本仓库不包含或重新发布完整 CMRE，只保存自制增量数据。
- 部分威望的机制资料、设计参考或说明可能整理自公开网络页面。每个模块应在自己的 `SOURCES.md` 中注明具体来源与用途。
- 网络公开不等于放弃著作权。原始项目、网页内容、游戏素材及名称的权利归各自权利人所有。
- 当前雷诺模块的具体来源说明见 [`prestiges/raynor/all-in-raiders/SOURCES.md`](prestiges/raynor/all-in-raiders/SOURCES.md)。

## 当前威望

### 雷诺：全能游骑兵

优势：

- 获得雷诺三个原版威望的全部正面效果。
- 不禁用矿骡、不取消机械单位折扣，也不增加单位矿物消耗。
- 休伯利安号保留原版 5 分钟首次解锁，召唤后永久存在，每秒恢复 6 点生命。
- 高级定点防御无人机每 60 秒恢复 1 次使用次数，最多储存 9999 次，实际等同无上限。

劣势：无。

## 声明

这是非官方玩家项目，需要用户自行拥有《星际争霸 II》以及可用的 CMRE 本地文件。本仓库只保存自制增量数据和安装工具，不打包完整 CMRE。请尊重 CMRE 作者、公开资料作者以及暴雪娱乐的相关权利。
