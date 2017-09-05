FROM debian:sid

RUN apt-get update                                          \
        && apt-get install -y --no-install-recommends       \
                ca-certificates git cmake build-essential   \
                libclang-5.0-dev llvm-5.0-dev libllvm5.0    \
        && apt-get clean

# zig (plus patched lld)
WORKDIR /app
RUN git clone https://github.com/zig-lang/zig/
WORKDIR /app/zig/build
RUN cmake ..                                                                   \
        -DZIG_LIBC_LIB_DIR=$(dirname $(cc -print-file-name=crt1.o))            \
        -DZIG_LIBC_INCLUDE_DIR=$(echo -n | cc -E -x c - -v 2>&1 |              \
                                 grep -B1 "End of search list." |              \
                                 head -n1 | cut -c 2- | sed "s/ .*//")         \
        -DZIG_LIBC_STATIC_LIB_DIR=$(dirname $(cc -print-file-name=crtbegin.o))
RUN make
RUN make install

WORKDIR /z
CMD ["zig"]
