# docker-zig

## usage

```
docker pull tiehuis/zig:latest
```

The intended workflow is to run this image interactively, mounting the `pwd` to
persist any created artifacts to the host machine. Artifacts should be run from
within the image for consistency, but programs may work outside alright.

The following alias is useful for entering an interactive session.

```
alias zigi='docker run --rm -it -v "$(pwd)":/z zig bash'
```

It is suggest to use two terminal sessions, one with the docker image compiling
the code, and the other with your editor of choice.

## update

```
docker build -t zig .
ZIG_VERSION=0.0.0-$(git ls-remote https://github.com/zig-lang/zig | sed 's/\tHEAD//')
docker tag zig tiehuis/zig:$ZIG_VERSION
docker push tiehuis/zig:$ZIG_VERSION
```
