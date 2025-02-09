FROM debian:bookworm

ARG CLANG_VERSION=19

RUN apt-get update \
    && apt-get install -y curl gnupg \
    && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-${CLANG_VERSION} main" | tee /etc/apt/sources.list.d/llvm.list > /dev/nul \
    && apt-get update \
    && apt-get install -y clang-${CLANG_VERSION} llvm-${CLANG_VERSION} lld-${CLANG_VERSION} lldb-${CLANG_VERSION} clangd-${CLANG_VERSION} \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 1 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} 1 \
    && update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${CLANG_VERSION} 1 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${CLANG_VERSION} 1 \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${CLANG_VERSION} 1 \
    && apt-get purge -y curl gnupg \
    && apt-get autoremove -y \
    && rm -fr /var/lib/apt/lists/*
