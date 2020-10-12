FROM alpine:3.12 as builder

RUN apk update && \
    apk add \
        gcc \
        g++ \
        automake \
        autoconf \
        pkgconfig \
        python2-dev \
        cmake \
        ninja \
        libc-dev \
        binutils \
        zlib-static \
        libstdc++

RUN mkdir -p /deps

# llvm
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-11.0.0.src.tar.xz
RUN tar xf llvm-11.0.0.src.tar.xz
RUN mkdir -p /deps/llvm-11.0.0.src/build
WORKDIR /deps/llvm-11.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="AVR" -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF -G Ninja
RUN ninja install

# lld
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/lld-11.0.0.src.tar.xz
RUN tar xf lld-11.0.0.src.tar.xz
RUN mkdir -p /deps/lld-11.0.0.src/build
WORKDIR /deps/lld-11.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -G Ninja
RUN ninja install

# clang
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-11.0.0.src.tar.xz
RUN tar xf clang-11.0.0.src.tar.xz
RUN mkdir -p /deps/clang-11.0.0.src/build
WORKDIR /deps/clang-11.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -G Ninja
RUN ninja install

FROM alpine:3.12
RUN apk update && \
    apk add \
        gcc \
        g++ \
        python2-dev \
        cmake \
        make \
        libc-dev \
        binutils \
        zlib-static \
        libstdc++ \
        git \
        xz
COPY --from=builder /deps/local/lib /deps/local/lib
COPY --from=builder /deps/local/include /deps/local/include
COPY --from=builder /deps/local/bin/llvm-config /deps/local/bin/llvm-config
COPY build /deps/build

ENTRYPOINT ["/deps/build"]
