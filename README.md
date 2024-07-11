一团的 Rime 配置
================

这是一团的 Rime 配置。[Rime](https://rime.im/) 是一个跨平台的输入法框架，支持多种输入方案。本配置包含了一些自定义的输入方案，使用一个 Powershell [脚本](./rimectl.ps1) 管理。本配置使用了以下开源项目：

* [雾凇拼音](https://github.com/iDvel/rime-ice): 简中拼音字库。GPL v3 许可。
* [白霜词库](https://github.com/gaboolic/rime-frost): 基于雾凇的词频库。GPL v3 许可。
* [墨奇音形](https://github.com/gaboolic/rime-shuangpin-fuzhuma): 带辅码的双拼方案。MIT 协议。
* [RIME 输入法辅助码插件](https://github.com/HowcanoeWang/rime-lua-aux-code): 为（非墨奇的）纯双拼方案增加辅助码。MIT 协议。

除此之外，本配置还包含了一些自定义的输入方案：

* [指尖拼音](./10d_ice.schema.yaml): 使用十指并击的拼音预编码。方案可见 [独立 repo](https://github.com/EtaoinWu/10dpy).
