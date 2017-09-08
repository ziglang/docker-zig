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

It is suggest to use two terminal sessions, one with the docker image compiling
the code, and the other with your editor of choice.

## update

```
docker build -t zig .
ZIG_VERSION=0.0.0-$(git ls-remote https://github.com/zig-lang/zig | head -n 1 | sed 's/\tHEAD//')

docker tag zig ziglang/zig:$ZIG_VERSION
docker tag zig ziglang/zig:latest

docker push ziglang/zig:$ZIG_VERSION
docker push ziglang/zig:latest
```
