FROM alpine:edge as builder

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
        zlib-dev \
        libstdc++

RUN mkdir -p /deps
ARG MAKE_JOBS=-j1

# xml2
WORKDIR /deps
RUN wget ftp://ftp.xmlsoft.org/libxml2/libxml2-2.9.7.tar.gz
RUN tar xf libxml2-2.9.7.tar.gz
WORKDIR /deps/libxml2-2.9.7
RUN autoreconf
RUN ./configure --without-python --disable-shared --prefix=/deps/local
RUN make $MAKE_JOBS install

# llvm
WORKDIR /deps
RUN wget http://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz
RUN tar xf llvm-6.0.0.src.tar.xz
WORKDIR /deps/llvm-6.0.0.src/
COPY llvm-fix-libxml2-dep.patch ./
RUN patch -p0 -i llvm-fix-libxml2-dep.patch
RUN mkdir -p /deps/llvm-6.0.0.src/build
WORKDIR /deps/llvm-6.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly
RUN make $MAKE_JOBS install

# clang
WORKDIR /deps
RUN wget http://releases.llvm.org/6.0.0/cfe-6.0.0.src.tar.xz
RUN tar xf cfe-6.0.0.src.tar.xz
RUN mkdir -p /deps/cfe-6.0.0.src/build
WORKDIR /deps/cfe-6.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release
RUN make $MAKE_JOBS install

# zig
ARG ZIG_BRANCH=master

WORKDIR /deps
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
