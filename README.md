# FRP Docker

使用 [FRP 官方发布包](https://github.com/fatedier/frp)构建客户端和服务端镜像，发布到阿里云容器镜像服务北京地域。

| 用途 | 镜像 |
| --- | --- |
| 客户端 | `registry.cn-beijing.aliyuncs.com/witter/frp:frpc` |
| 服务端 | `registry.cn-beijing.aliyuncs.com/witter/frp:frps` |

自动检测 FRP 官方最新正式版，无需填写版本号，支持 `linux/amd64` 和 `linux/arm64`。构建时校验官方 SHA256；镜像不包含部署配置或认证 token。

## 上游许可证

FRP 使用 [Apache License 2.0](https://github.com/fatedier/frp/blob/dev/LICENSE)。构建时将上游许可证保存在镜像的 `/usr/share/licenses/frp/LICENSE`。
