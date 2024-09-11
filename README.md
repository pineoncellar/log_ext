# log_ext

适用于 Dice!的额外日志操作指令 lua 插件

> 使用《署名—非商业性使用—相同方式共享 4.0 协议国际版》（CC BY-NC-SA 4.0）进行授权。
> https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.zh-Hans

---

### 一.基本信息

> - **作者：** 地窖上的松
> - **联系方式：**QQ: 602380092
> - **文件版本：**v1.5
> - **更新日期：**2024/9/11
> - **关键词：**`.log list` `.log get` `.log del` `.log stat`

---

### 二.介绍

在原有的`.log`指令之上添加了四种日志操作指令。

效果展示

![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2023-10-06/1696566139-94271-qq20231006122124.png)
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2023-10-06/1696566129-157250-atr94m6moj-25mq6rsm.png)
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2023-10-06/1696566171-859033-image.png)

---

### 三.使用方法

> **`.log get`指令基于 ob11 的 api，使用前需要先配置好 http 通信** > **gocq 框架**配置方法参考 [此帖第一章](https://forum.kokona.tech/d/1569-kuo-zhan-han-shu-gocqde-apidiao-yong)。
> **LLOneBot 框架**配置方法参考下方第四节内容。
> 如果你听不懂，也可以往下看第四五节的内容。

下载，解压，将两个lua文件扔进扔进 plugin 文件夹。

随后，手动打开`log_get`文件，修改第 8 行的端口值为你开启的 http 端口，并`.system load`

---

### 四.LLOneBot 框架配置 http 通信端口

打开 QQNT 的设置界面，在 LLOneBot 一栏中将**启用 http 服务**打开。
下方的 http 服务监听端口即是服务启用的端口，可以在一定范围内修改为自己希望的数字。
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-04-21/1713708845-691292-image.png)
保存，随后别忘了重启 QQ。

然后修改`log_get`文件中的第 8 行为对应的端口即可。
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-04-21/1713708419-54636-image.png)

> 很简单对吧 ;)

---

### 五.go-cqhttp 框架使用指令配置 http 连接（不推荐）

> 如果你已经按照 [此帖第一章](https://forum.kokona.tech/d/1569-kuo-zhan-han-shu-gocqde-apidiao-yong) 配置好了 http 连接，请跳过此章节。
> 当然，如果你是 LLOneBot 框架，请略过此节。

手动打开`log_ext.lua`文件，将第 27 行最前面的`--`去掉。
就像这样：
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-04-21/1713708626-594558-image.png)

然后，system load 一下，再然后对骰娘发送指令`.log http init`
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2023-10-06/1696567402-3889-e9oh-at-h58bvl7gfiic7v3.png)
骰娘将会自动写入 http 连接配置，并将端口发送给你，像这里便是使用了 26194 端口。
需要关掉骰娘程序，重新启动 gocq 以启用。
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2023-10-06/1696567690-666051-m-at-uq951mzvlidy-at-vfhqgp.png)
当 gocq 启动时出现这一行字，即说明 http 连接启用成功。

> 最后，别忘了修改`log_get.lua`文件内第 8 行的 http 端口为对应的值。

---

### 六.自定义回执

手动修改`log_ext`文件第 8 到第 18 行，还有`log_get`文件第 10 到第 14 行.
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-04-21/1713708744-606579-image.png)
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-04-21/1713708771-675962-image.png)

> `log_ext`文件默认使用**GBK 编码**，`log_get`文件默认使用**utf-8 编码**。这是因为`log_ext`文件需要与 dice 所用的编码保持一致，而`log_get`文件需要与系统编码保持一致。
> **若系统编码不为 GBK 且骰娘路径中带有中文字符很可能导致`.log list`指令读不出群聊 log 列表**

---

### 七.修改 log 空参时的帮助词条

建议对骰娘发送下面这条指令：

```
.helpdoc log 跑团日志记录.log
`.log new 日志名` 新开日志并开始记录
`.log on` 继续记录
`.log off` 暂停记录
`.log end` 完成记录并发送日志文件
`.log list` 查看本群日志列表
`.log get 日志名` 手动取日志
`.log del 日志名` 删除日志，此操作不可逆
`.log stat` 查看当前窗口日志状态
日志名须作为文件名合法，省略则使用创建时间戳。上传有失败风险，届时请.send 七海千秋后台索取
由于后台程序原因，长期开启log存在丢失风险，建议开团时再启用log或者定期检查log开启情况。
```

如此，在骰娘收到`.log`指令时将会返回帮助：
![image](https://dice-forum.s3.ap-northeast-1.amazonaws.com/2024-09-11/1726014534-637743-qq20240911-082828.png)
