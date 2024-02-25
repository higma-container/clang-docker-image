FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y curl gnupg \
    && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main" | tee /etc/apt/sources.list.d/llvm.list > /dev/nul \
    && apt-get update \
    && apt-get install -y clang-19 llvm-19 lld-19 lldb-19 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 1 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 1 \
    && update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-19 1 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-19 1 \
    && apt-get purge -y curl gnupg \
    && apt-get autoremove -y \
    && rm -fr /var/lib/apt/lists/*
