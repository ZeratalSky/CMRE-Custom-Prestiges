# 添加新威望

## 说明语言

仓库中面向使用者的威望介绍、安装步骤、更新记录和来源说明一律使用简体中文。对象 ID、清单字段、文件名及 `enUS.GameStrings.txt` 等游戏兼容内容可以保留英文。

## 目录约定

每个威望都是一个独立模块：

```text
prestiges/
  <commander-slug>/
    <prestige-slug>/
      prestige.json
      catalog/
        UpgradeData.xml
        UserData.xml
        ...
      locales/
        zhCN.GameStrings.txt
        enUS.GameStrings.txt
      SOURCES.md
```

安装器会自动扫描所有符合此结构的 `prestige.json`，所以不用修改脚本，也没有预设的威望槽位上限。

## 创建步骤

1. 复制 `templates/new-prestige`。
2. 将目录改为 `prestiges/<指挥官>/<威望>`。
3. 修改 `prestige.json` 中的 ID、版本、数据文件和所有权声明。
4. 在 `catalog` 中写增量 XML，根元素必须是 `<Catalog>`。
5. 在 `locales` 中添加 `键=文本` 格式的本地化内容。
6. 在 `SOURCES.md` 中记录 CMRE 依赖、公开网络页面及其他参考来源。
7. 运行安装器，再用 `Maps/CMRE/TestMap.SC2Map` 验证。

## ID 规则

建议所有自制对象使用唯一前缀：

```text
CMCP<Commander><Prestige><Object>
```

不要复用官方或 CMRE 已存在的对象 ID，除非该对象明确列在 `patchEntries` 中。

## prestige.json

- `catalog[].file`：要合并到 `Base.SC2Data/GameData` 的文件名。
- `catalog[].ownedEntries`：完全由该模块创建的顶层数据对象；卸载时会删除整个对象。
- `catalog[].patchEntries`：模块给现有对象增加的子节点；卸载时只删除片段中声明的子节点。
- `locales`：本地化源文件与目标区域。

同一个对象不能同时列在 `ownedEntries` 和 `patchEntries` 中。

## 扩展原则

- 一个威望只修改自己需要的数据。
- 负面效果和正面效果应逐条列在说明中。
- 对现有对象的补丁尽量使用明确的 `index`、`Id` 或 `id`，方便安装器安全更新和卸载。
- 不要把完整 CMRE 核心文件复制进仓库。
- 使用公开网络资料时保留页面标题、作者或站点、链接、访问日期和实际用途；“公开可访问”不代表可以不署名或不遵守许可。
