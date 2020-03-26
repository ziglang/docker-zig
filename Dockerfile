FROM alpine:3.11 as builder

RUN apk update && \
    apk add \
        gcc \
        g++ \
        automake \
        autoconf \
        pkgconfig \
        python2-dev \
        cmake \
        make \
        libc-dev \
        binutils \
        zlib-static \
        libstdc++

RUN mkdir -p /deps
ARG MAKE_JOBS=-j1

# llvm
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/llvm-10.0.0.src.tar.xz
RUN tar xf llvm-10.0.0.src.tar.xz
RUN mkdir -p /deps/llvm-10.0.0.src/build
WORKDIR /deps/llvm-10.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="AVR" -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_TERMINFO=OFF
RUN make $MAKE_JOBS install

# lld
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/lld-10.0.0.src.tar.xz
RUN tar xf lld-10.0.0.src.tar.xz
RUN mkdir -p /deps/lld-10.0.0.src/build
WORKDIR /deps/lld-10.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release
RUN make $MAKE_JOBS install

# clang
WORKDIR /deps
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/clang-10.0.0.src.tar.xz
RUN tar xf clang-10.0.0.src.tar.xz
RUN mkdir -p /deps/clang-10.0.0.src/build
WORKDIR /deps/clang-10.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release
RUN make $MAKE_JOBS install

FROM alpine:3.11
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
