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
3. 备份即将修改的文件。
4. 合并威望数据和中英文文本。
5. 写入安装状态文件。

备份位于：

```text
<星际争霸 II 根目录>/Mods/CMRE/_CMRECustomPrestigesBackup
```

## 验证

推荐先用编辑器打开：

```text
Maps/CMRE/TestMap.SC2Map
```

进入指挥官选择界面，确认对应指挥官出现新的威望，然后依次测试其核心效果。

## 更新

下载或拉取新版本文件后，再次运行同一条安装命令。安装器是幂等的：已有条目会更新，不会重复添加。

如果先更新了 CMRE，也应重新运行安装器，因为 CMRE 更新可能覆盖自制内容。

## 卸载

在仓库目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Uninstall-CMRECustomPrestiges.ps1 -StarCraftIIPath "D:\StarCraft II"
```

卸载器只移除本仓库声明的自制条目和补丁节点，并在操作前生成新备份，不会直接用旧备份覆盖其他后续改动。

## 常见问题

### 游戏中没有出现新威望

- 确认启动的是依赖本地 `CMRE_Core_Triggers.SC2Mod` 的地图。
- 重新运行安装器，检查是否显示成功安装的模块数量。
- 如果刚更新过 CMRE，请重新安装本项目。

### PowerShell 阻止脚本运行

使用文档中的 `-ExecutionPolicy Bypass` 命令；它只对本次 PowerShell 进程生效。

### 如何恢复

优先运行卸载器。只有在 CMRE 文件已经损坏或无法解析时，才手动从 `_CMRECustomPrestigesBackup` 恢复最近一次备份。

