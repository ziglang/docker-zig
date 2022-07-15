FROM alpine:3.13 as builder

RUN apk update && \
    apk add \
        curl \
        xz

ARG ZIGVER
RUN mkdir -p /deps
WORKDIR /deps
RUN curl https://ziglang.org/deps/zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER.tar.xz  -O && \
    tar xf zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER.tar.xz && \
    mv zig+llvm+lld+clang-$(uname -m)-linux-musl-$ZIGVER/ local/
    
FROM alpine:3.13
RUN apk --no-cache add \
    libc-dev \
    xz \
    samurai \
    git \
    cmake
COPY --from=builder /deps/local/ /deps/local/
ENV PATH $PATH:/deps/local/bin
