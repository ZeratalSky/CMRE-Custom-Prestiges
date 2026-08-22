# 安装、更新与卸载

## 准备工作

请先确认以下目录存在：

```text
<星际争霸 II 根目录>/Mods/CMRE/CMRE_Core_Triggers.SC2Mod
```

如果没有这个目录，请先正确安装 CMRE。

## 安装

下载仓库 ZIP 并解压，在解压目录打开 PowerShell，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Install-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\StarCraft II"
```

路径中含空格时必须保留双引号。安装器会：

1. 检查 CMRE 核心文件是否完整。
2. 自动发现仓库内的所有威望模块。
3. 对比上一次安装状态，自动卸载已从 `prestiges` 目录移除的威望。
4. 备份即将修改的文件。
5. 合并威望数据和中英文文本。
6. 保存卸载快照、机器状态文件和中文安装记录。

备份位于：

```text
<星际争霸 II 根目录>/Mods/CMRE/_CMRECustomPrestigesBackup
```

中文安装记录位于：

```text
<星际争霸 II 根目录>/Mods/CMRE/CMRE_自制威望安装记录.txt
```

它会列出当前实际安装的目录、中文名称、模块 ID 和版本。卸载快照位于 `CMRE_CustomPrestiges.installed`，请不要手工删除，否则已经移出仓库的模块可能无法被安全清理。

## 目录同步规则

`prestiges` 目录就是安装清单，不需要另外维护白名单：

- 目录中新出现的威望：自动安装。
- 目录中仍然存在的威望：自动检查并更新。
- 上次已安装、现在已从目录删除或移走的威望：自动卸载。
- 目录为空：自动卸载本工具以前安装的全部威望。

因此，想临时停用某个威望，可以把整个威望目录移到 `prestiges` 之外，再运行安装器；想恢复时移回来并再次运行安装器。

## 验证

推荐先用编辑器打开：

```text
Maps/CMRE/TestMap.SC2Map
```

进入指挥官选择界面，确认对应指挥官出现新的威望，然后依次测试其核心效果。

## 更新

下载或拉取新版本文件后，再次运行同一条安装命令。安装器是幂等的：已有条目会更新，不会重复添加，同时会清理目录中已经不存在的旧威望。

如果先更新了 CMRE，也应重新运行安装器，因为 CMRE 更新可能覆盖自制内容。

## 卸载

在仓库目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Uninstall-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\StarCraft II"
```

卸载器只移除本仓库声明的自制条目和补丁节点，并在操作前生成新备份，不会直接用旧备份覆盖其他后续改动。

通常不必单独运行卸载器：从 `prestiges` 目录移走某个威望后运行安装器，即可只卸载该威望。单独运行卸载器用于一次性卸载当前记录中的全部自制威望。

## 常见问题

### 游戏中没有出现新威望

- 确认启动的是依赖本地 `CMRE_Core_Triggers.SC2Mod` 的地图。
- 重新运行安装器，检查是否显示成功安装的模块数量。
- 如果刚更新过 CMRE，请重新安装本项目。

### PowerShell 阻止脚本运行

使用文档中的 `-ExecutionPolicy Bypass` 命令；它只对本次 PowerShell 进程生效。

### 如何恢复

优先运行卸载器。只有在 CMRE 文件已经损坏或无法解析时，才手动从 `_CMRECustomPrestigesBackup` 恢复最近一次备份。
