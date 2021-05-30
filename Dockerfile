FROM alpine:3.13 as builder

RUN apk update && \
    apk add \
        gcc \
        g++ \
        automake \
        autoconf \
        pkgconfig \
        python3-dev \
        cmake \
        ninja \
        libc-dev \
        binutils \
        zlib-static \
        zlib-dev \
        libstdc++ \
        git

RUN mkdir -p /deps
WORKDIR /deps
RUN git clone https://github.com/llvm/llvm-project/ && \
    cd llvm-project && \
    git checkout release/12.x && \
    mkdir llvm/build && \
    mkdir lld/build && \
    mkdir clang/build

# llvm
WORKDIR /deps/llvm-project/llvm/build
RUN cmake .. \
    -DCMAKE_INSTALL_PREFIX=/deps/local \
    -DCMAKE_PREFIX_PATH=/deps/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DZLIB_LIBRARY=/lib/libz.a \
    -DLLVM_ENABLE_ZLIB=FORCE_ON \
    -GNinja
RUN ninja install

# lld
WORKDIR /deps/llvm-project/lld/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -GNinja
RUN ninja install

# clang
WORKDIR /deps/llvm-project/clang/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -GNinja
RUN ninja install

FROM alpine:3.13
RUN apk update && \
    apk add \
        gcc \
        g++ \
        python3-dev \
        cmake \
        make \
        libc-dev \
        binutils \
        zlib-static \
        zlib-dev \
        libstdc++ \
        git \
        xz
COPY --from=builder /deps/local/lib /deps/local/lib
COPY --from=builder /deps/local/include /deps/local/include
COPY --from=builder /deps/local/bin/llvm-config /deps/local/bin/llvm-config
COPY build /deps/build

ENTRYPOINT ["/deps/build"]
