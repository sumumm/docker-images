# Docker in Docker (DinD) 实践

## 一、Docker in Docker

### 1. 简介

Docker in Docker（DinD）是一种在 Docker 容器内部运行 Docker 守护进程的技术。本章节将带你深入了解 DinD 的概念、使用场景和实际应用。

随着容器化技术在 CI/CD 流水线和云原生开发中的广泛应用，开发团队面临着一个核心挑战：

如何在已经容器化的环境中安全地执行 Docker 操作，比如在运行于容器中的 Jenkins 或 GitLab CI 中构建和推送 Docker 镜像，或者为开发者提供隔离的 Docker 环境而不影响宿主机。

为了解决这个"容器中的容器"问题，社区发展出了两种主要技术路线：DinD（Docker in Docker）通过在容器内运行完整的 Docker 守护进程实现真正的隔离，适合需要完全独立环境的场景；而 DooD（Docker outside of Docker）则通过挂载宿主机的 Docker socket 来复用宿主机的 Docker 环境，在保持简单性的同时牺牲了部分隔离性。

### 2. DinD vs DooD

| 特性 | DinD | DooD |
| :--: | ---- | ---- |
| Docker Daemon | 容器内独立运行 | 使用宿主机的 |
| 隔离性 | 完全隔离 | 共享宿主机环境 |
| 特权要求 | 需要 `--privileged` | 只需挂载 socket |
| 缺点 | dind 由于需要 `--privileged` 参数来启动容器，因为无法被直接应用在 ci 或者 云端开发环境的场景中，比如，可以在容器内挂载宿主机根目录开访问宿主机的所有文件，这个时候就很容易造成安全问题。 | dood 由于是直接挂载宿主机的 socket 文件，因此，dood 容器可以访问宿主机的所有容器，这在多用户环境下是不安全的，用户可以看到其他用户的容器，甚至可以删除其他用户的容器。 |

### 3. 使用场景

<table>
  <tbody>
    <tr>
      <td align="left"><b>持续集成/持续部署（云原生构建）</b></td>
      <td align="left">- CI 控制器（如 Jenkins、GitLab CI）运行在容器中<br>- 为每个构建任务提供独立的 Docker 环境</td>
    </tr>
    <tr>
      <td align="left"><b>开发/测试环境隔离（云原生开发）</b></td>
      <td align="left">- 开发人员可以在容器内部进行 Docker 操作<br>- 不影响本地主机环境</td>
    </tr>
  </tbody>
</table>

## 二、思考

思考一下，CNB 的 docker 方案是哪一种呢？复刻一下？
