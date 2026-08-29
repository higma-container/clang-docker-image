# syntax=docker/dockerfile:1

ARG CLANG_VERSION=23

# ============================================================
# Clang stage
# ============================================================
FROM debian:trixie-slim AS clang

ARG CLANG_VERSION

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg; \
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
    rm -rf /var/lib/apt/lists/*

# ============================================================
# Example final stage
# ============================================================
FROM debian:trixie-slim

ARG CLANG_VERSION

LABEL \
    org.opencontainers.image.title="Clang" \
    org.opencontainers.image.description="LLVM/Clang ${CLANG_VERSION} development environment" \
    org.opencontainers.image.source="https://github.com/higma-container/clang-docker-image"

COPY --from=clang /usr/bin/clang-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/clang++-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/clangd-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/clang-format-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/clang-tidy-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/lld-${CLANG_VERSION} /usr/bin/
COPY --from=clang /usr/bin/lldb-${CLANG_VERSION} /usr/bin/

COPY --from=clang /usr/lib/llvm-${CLANG_VERSION} /usr/lib/llvm-${CLANG_VERSION}

ENV PATH="/usr/lib/llvm-${CLANG_VERSION}/bin:${PATH}"
