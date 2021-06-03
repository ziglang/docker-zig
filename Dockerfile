FROM alpine:3.13 as builder

RUN apk update && \
    apk add \
        curl \
        xz

RUN mkdir -p /deps
WORKDIR /deps
RUN curl https://ziglang.org/deps/zig+llvm+lld+clang-aarch64-linux-musl-0.8.0-dev.2723+d1f60a63b.tar.xz  -O && \
    tar xf zig+llvm+lld+clang-aarch64-linux-musl-0.8.0-dev.2723+d1f60a63b.tar.xz && \
    mv zig+llvm+lld+clang-aarch64-linux-musl-0.8.0-dev.2723+d1f60a63b/ local/
    
FROM alpine:3.13
RUN apk --no-cache add \
    libc-dev \
    xz \
    samurai \
    git \
    cmake
COPY --from=builder /deps/local/ /deps/local/
