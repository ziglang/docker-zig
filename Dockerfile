FROM debian:sid

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        cmake \
        build-essential \
        zlib1g-dev \
        python \
        wget \
        xz-utils \
        libquadmath0 \
    && \
    mkdir -p /deps && \
    cd /deps && \
    wget http://releases.llvm.org/5.0.0/llvm-5.0.0.src.tar.xz && \
    tar xf llvm-5.0.0.src.tar.xz && \
    mkdir -p /deps/llvm-5.0.0.src/build && \
    cd /deps/llvm-5.0.0.src/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/deps/local -DCMAKE_PREFIX_PATH=/deps/local -DCMAKE_BUILD_TYPE=Release && \
    make install && \
    cd /deps && \
    wget http://releases.llvm.org/5.0.0/cfe-5.0.0.src.tar.xz && \
    tar xf cfe-5.0.0.src.tar.xz && \
    mkdir -p /deps/cfe-5.0.0.src/build && \
    cd /deps/cfe-5.0.0.src/build && \
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
    wget -O "$HOME/.zig.bash_completion" https://raw.githubusercontent.com/tiehuis/zig-compiler-completions/master/completions/zig.bash-completion && \
    echo "source $HOME/.zig.bash_completion" >> "$HOME/.bashrc" && \
    cd / && \
    rm -rf /deps && \
    apt-get remove -y ca-certificates git cmake build-essential zlib1g-dev python xz-utils wget && \
    apt-get autoremove -y && \
    apt-get clean

WORKDIR /z

CMD ["zig"]
