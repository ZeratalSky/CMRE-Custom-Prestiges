# CMRE 自制威望合集

这是一个面向《星际争霸 II》CMRE 合作模式复刻项目的模块化自制威望仓库。

当前包含：

- 雷诺：**全能游骑兵**

## 设计目标

- 每个威望使用独立目录，避免不同威望的数据混在一起。
- 安装器自动发现 `prestiges/<指挥官>/<威望>/prestige.json`，未来新增威望没有固定数量上限。
- 重复运行安装器即可安装新模块或更新已有模块。
- 安装和卸载前自动备份将要修改的 CMRE 文件。
- 不覆盖原版三个威望；自制威望会作为额外选项加入。

## 快速安装

1. 安装并确认 CMRE 可以正常运行。
2. 下载本仓库 ZIP 并解压。
3. 在 PowerShell 中运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\StarCraft II"
```

把 `D:\StarCraft II` 改成自己的《星际争霸 II》根目录。安装完成后进入 CMRE 的指挥官选择界面，雷诺会出现第 4 个威望。

完整说明见 [安装、更新与卸载](docs/INSTALLATION.md)。想继续制作新威望，请看 [添加新威望](docs/ADDING_PRESTIGES.md)。

## 兼容性说明

本项目是 **CMRE 的增量扩展，必须先安装 CMRE**，不能脱离 CMRE 单独运行。安装器需要以下目录版核心模组：

```text
Mods/CMRE/CMRE_Core_Triggers.SC2Mod
```

CMRE 更新可能改变数据结构。更新 CMRE 后建议重新运行安装器，并在测试地图中验证自制威望。

## 来源与致谢

- CMRE 是本项目的必要依赖；本仓库不包含或重新发布完整 CMRE，只保存自制增量数据。
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
