FROM ubuntu:16.04
WORKDIR /app
RUN echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated git build-essential llvm-4.0 llvm-4.0-dev libclang-4.0-dev libclang-common-4.0-dev libclang1-4.0  liblld-4.0-dev liblld-4.0 cmake
RUN git clone https://github.com/zig-lang/zig/
RUN mkdir /app/zig/build
WORKDIR /app/zig/build
RUN cmake .. -DZIG_LIBC_LIB_DIR=$(dirname $(cc -print-file-name=crt1.o)) -DZIG_LIBC_INCLUDE_DIR=$(echo -n | cc -E -x c - -v 2>&1 | grep -B1 "End of search list." | head -n1 | cut -c 2- | sed "s/ .*//") -DZIG_LIBC_STATIC_LIB_DIR=$(dirname $(cc -print-file-name=crtbegin.o))
RUN make
RUN make install
CMD ["zig"]
