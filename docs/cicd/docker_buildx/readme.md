# [docker构建多架构镜像](https://www.zhaowenyu.com/docker-doc/best-practices/mult-arch-image.html#%E5%9F%BA%E4%BA%8E-manifest-%E7%9A%84%E6%96%B9%E5%BC%8F%E7%BB%84%E5%90%88%E5%A4%9A%E5%B9%B3%E5%8F%B0%E6%9E%B6%E6%9E%84%E9%95%9C%E5%83%8F)



https://github.com/docker/buildx#manual-download

- 创建构建器

```shell
# 创建构建器
docker buildx create --name=multiarch --driver docker-container --use --bootstrap --platform linux/amd64,linux/386,linux/riscv64,linux/arm/v7,linux/arm/v6,linux/s390x,linux/ppc64le,linux/arm64

# 查看构建器
docker buildx ls

#在镜像构建时如果没有通过 --builder 指定明确的构建器，那么 buildx 会使用默认的构建器。

# 默认构建器 builder 名称后以 * 标记，可以通过 docker buildx use 来切换默认的构建器
docker buildx use multiarch

# 通过 docker buildx inspect 来单独查看某一个指定的 builder 构建器的详细信息
docker buildx inspect multiarch

# 构建器在创建成功后状态是 Status: inactive， 需要通过 docker buildx inspect 添加 --bootstrap 参数来启动构建器后才能正常使用该构建器构建镜像。
# docker buildx inspect --bootstrap --builder multiarch

# 删除
docker buildx rm multiarch
```


- 修改Dockerfile

```shell
FROM  --platform=$TARGETPLATFORM golang AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
WORKDIR /gobuild
COPY  get-cpu-os.go  .
RUN go build get-cpu-os.go

FROM --platform=$TARGETPLATFORM golang
ARG TARGETPLATFORM
ARG BUILDPLATFORM
WORKDIR /gorun
COPY --from=builder /gobuild/get-cpu-os .
CMD ["./get-cpu-os"]
```

- 开始构建

```shell
# -t 指定镜像地址，需要指定正确的registry+repo:tag，因为构建完就要推送到远程仓库
# --push 推送到远程registry
docker buildx build --builder multiarch -t test:1 --platform linux/amd64,linux/arm64 --push .

# 等同于docker manifest inspect
docker buildx imagetools inspect <username>/<image>:latest
```

# 如果没有使用docker desktop，则需要手动启用qemu

https://github.com/multiarch/qemu-user-static#getting-started

```shell
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

或者参考docker官方文档：https://docs.docker.com/build/building/multi-platform/

```shell
 docker run --privileged --rm tonistiigi/binfmt --install all
```