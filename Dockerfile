# syntax=docker/dockerfile:1

ARG CLANG_VERSION=23

FROM debian:trixie-slim

ARG CLANG_VERSION

LABEL \
    org.opencontainers.image.title="Clang" \
    org.opencontainers.image.description="LLVM/Clang ${CLANG_VERSION} development environment" \
    org.opencontainers.image.source="https://github.com/higma-container/clang-docker-image"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key -o /tmp/llvm-snapshot.gpg.key; \
    gpg --dearmor -o /etc/apt/keyrings/llvm.gpg /tmp/llvm-snapshot.gpg.key; \
    rm -f /tmp/llvm-snapshot.gpg.key; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] https://apt.llvm.org/trixie/ llvm-toolchain-trixie-${CLANG_VERSION} main" \
        > /etc/apt/sources.list.d/llvm.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        clang-${CLANG_VERSION} \
        clangd-${CLANG_VERSION} \
        clang-format-${CLANG_VERSION} \
        clang-tidy-${CLANG_VERSION} \
        llvm-${CLANG_VERSION} \
        lld-${CLANG_VERSION} \
        lldb-${CLANG_VERSION}; \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${CLANG_VERSION} 100; \
    update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${CLANG_VERSION} 100; \
    apt-get purge -y \
        curl \
        gnupg; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/llvm.list /etc/apt/keyrings/llvm.gpg

ENV PATH="/usr/lib/llvm-${CLANG_VERSION}/bin:${PATH}"

CMD ["/bin/bash"]
