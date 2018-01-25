# docker-zig

## usage

```
docker pull ziglang/zig:latest
```

The intended workflow is to run this image interactively, mounting the `pwd` to
persist any created artifacts to the host machine. Artifacts should be run from
within the image for consistency, but programs may work outside alright.

The following alias is useful for entering an interactive session.

```
alias zigi='docker run --rm -it -v "$(pwd)":/z zig bash'
```

If using a posix os, strongly consider using the following which will create
artifacts using the current users permissions.

```
alias zigi='docker run --rm -it -u "$UID:$(id -g)" -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v "$(pwd)":/z zig bash'
```

It is suggested to use two terminal sessions, one with the docker image compiling
the code, and the other with your editor of choice.

## update

```
# Branch can be master, or a tag i.e. 0.1.0
export ZIG_BRANCH=master
docker build -t ziglang/zig:$ZIG_BRANCH --build-arg ZIG_BRANCH=$ZIG_BRANCH .
docker push ziglang/zig:$ZIG_BRANCH
```
