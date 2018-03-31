FROM ziglang/static-base:llvm6-1 as builder

# zig
ARG ZIG_BRANCH=master
RUN apk update && apk add git

WORKDIR /deps
ARG MAKE_JOBS=-j1
ARG CACHE_DATE=2018-03-30
RUN git clone --branch $ZIG_BRANCH --depth 1 https://github.com/zig-lang/zig
RUN mkdir -p /deps/zig/build
WORKDIR /deps/zig/build
# Install to /usr and mirror this on the copy
RUN cmake .. \
    -DZIG_STATIC=on                                                        \
    -DCMAKE_BUILD_TYPE=Release                                             \
    -DCMAKE_PREFIX_PATH=/deps/local                                        \
    -DCMAKE_INSTALL_PREFIX=/usr
RUN make $MAKE_JOBS install

FROM alpine:edge
COPY --from=builder /usr/bin/zig /usr/bin/zig
COPY --from=builder /usr/lib/zig /usr/lib/zig
WORKDIR /z

ENTRYPOINT ["zig"]
