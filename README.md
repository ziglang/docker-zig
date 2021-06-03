# docker-zig

This docker image is solely for the purpose of creating the image that runs for
[Zig's Drone CI script](https://github.com/ziglang/zig/tree/master/ci/drone).

**Zig makes Docker irrelevant.** You probably do not need a Docker image to
build your Zig application, and you definitely do not need this one.

## Usage

First, decide whether to bump the base alpine image version. Next:

```
docker build -t ziglang/static-base:llvm12-$(uname -m)-1 .
docker push ziglang/static-base:llvm12-$(uname -m)-1
```
