# 新威望模板

本模板生成的介绍、安装说明和来源说明应全部使用简体中文。对象 ID、文件名以及 `enUS.GameStrings.txt` 属于程序兼容内容，可以保留英文。

将本目录复制到：

```text
prestiges/<commander-slug>/<prestige-slug>
```

然后：

1. 修改 `prestige.json`。
2. 在 `catalog` 中添加需要的数据片段文件。
3. 在 `locales` 中添加中英文文本。
4. 确保每个数据对象在清单中被声明为 `ownedEntries` 或 `patchEntries`。
5. 运行安装器并使用 CMRE 测试地图验证。
