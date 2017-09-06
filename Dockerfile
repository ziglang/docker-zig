FROM debian:sid

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        cmake \
        build-essential \
        zlib1g-dev \
        python \
        libquadmath0 \
    && \
    mkdir -p /deps && \
    cd /deps && \
    git clone --depth 1 --branch release_50 https://github.com/llvm-project/llvm-project-20170507 llvm-project && \
    mkdir -p /deps/llvm-project/llvm/build && \
    cd /deps/llvm-project/llvm/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release && \
    make install && \
    mkdir -p /deps/llvm-project/clang/build && \
    cd /deps/llvm-project/clang/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release && \
    make install && \
    cd /deps && \
    git clone --depth 1 https://github.com/zig-lang/zig/ && \
    mkdir -p /deps/zig/build && \
    cd /deps/zig/build && \
    cmake .. \
        -DZIG_LIBC_LIB_DIR=$(dirname $(cc -print-file-name=crt1.o))            \
        -DZIG_LIBC_INCLUDE_DIR=$(echo -n | cc -E -x c - -v 2>&1 |              \
                                 grep -B1 "End of search list." |              \
                                 head -n1 | cut -c 2- | sed "s/ .*//")         \
        -DZIG_LIBC_STATIC_LIB_DIR=$(dirname $(cc -print-file-name=crtbegin.o)) \
        -DCMAKE_PREFIX_PATH=/deps/local                                        \
    && \
    make install && \
    cd / && \
    rm -rf /deps && \
    apt-get remove -y ca-certificates git cmake build-essential zlib1g-dev python && \
    apt-get autoremove -y && \
    apt-get clean

WORKDIR /z

CMD ["zig"]
