# 超级信号专家：来源与实现说明

- 依赖：CMRE 的 `CMRE_Core_Stetmann.SC2Mod`、`CMRE_Core_Triggers.SC2Mod` 与本机已有的官方合作任务数据。
- 基础设计：斯台特曼官方威望 1“信号专家”的艾星无敌、范围增大及禁用超级盖瑞规则。
- 护甲归零实现：复用官方合作任务数据中凯瑞根跳虫 `ZerglingArmorShredTarget` 的 `LifeArmorMultiplier=0` 数据方式，并使用独立对象将持续时间设为 45 秒。
- 敌方超载：沿用原版艾星超载的自动施法标志、目标选择方式和 `Abil/MechaOverloadStetmann` 共享充能链接。

本模块没有复制或重新分发外部美术资源，只引用玩家本地游戏与 CMRE 已提供的对象和素材路径。
