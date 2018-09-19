# docker-zig

The goal of this docker image is to build a fully static Zig Linux x86_64
executable, which can then be used on any Linux system (or inside any
docker container).

After building zig and running the test suite, it produces
`zig-linux-x86_64-X.Y.Z-commitsha.tar.xz` which contains:

 * `/langref.html` (generated documentation)
 * `/zig` (statically linked executable)
 * `/lib` (installed zig std lib and c headers)

Therefore, this docker image is used to produce this artifact, and
not intended to be used directly.

## Usage

In this example:

 * `-j1` is a number of make jobs. Set to the number of cores you want to use.
 * `7d66908f294eed1138802c060185721a2e265f3b` is the Zig git revision to
   build, test, and package.

```
docker run --rm -it --mount type=bind,source="$(pwd)",target=/z ziglang/static-base:llvm7-1 -j1 7d66908f294eed1138802c060185721a2e265f3b
```

### Updating the base image

This only needs to be done if we need to tweak the build environment, or if
we update the LLVM or Clang dependencies.

```
docker build -t ziglang/static-base:llvm7-1 .
docker push ziglang/static-base:llvm7-1
```
