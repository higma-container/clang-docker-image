# Clang Docker Image

Clang 23 がインストールされた Debian ベースの Docker イメージです。

Clang / LLVM を利用する CI や C/C++ のビルド環境、開発環境などで使用できます。

## Tools Version

* Clang 23
* Clangd 23
* Clang-format 23
* Clang-tidy 23
* LLVM 23
* LLD 23
* LLDB 23

## Supported Platforms

以下のプラットフォームに対応しています。

* `linux/amd64`
* `linux/arm64`

Docker が実行環境に応じて適切なイメージを自動的に選択します。

## Usage

### Pull

最新バージョンを取得する場合：

```sh
docker pull ghcr.io/higma-container/clang:latest
```

Clang 23 系を指定する場合：

```sh
docker pull ghcr.io/higma-container/clang:23
```

特定のバージョンを指定する場合：

```sh
docker pull ghcr.io/higma-container/clang:v23.0.0
```

`23` タグを使用すると Clang 23 系の最新リリースを利用できます。

特定のリリースを完全に固定したい場合は `v23.0.0` のようなバージョンタグを使用してください。

### Check Versions

Clang：

```sh
docker run --rm \
  ghcr.io/higma-container/clang:23 \
  clang --version
```

Clang++：

```sh
docker run --rm \
  ghcr.io/higma-container/clang:23 \
  clang++ --version
```

Clangd：

```sh
docker run --rm \
  ghcr.io/higma-container/clang:23 \
  clangd --version
```

LLDB：

```sh
docker run --rm \
  ghcr.io/higma-container/clang:23 \
  lldb --version
```

LLD：

```sh
docker run --rm \
  ghcr.io/higma-container/clang:23 \
  lld --version
```

## Using as a Base Image

このイメージは、他のDockerイメージのベースイメージとして使用できます。

例えば、Clang 23を使用するC++ビルド環境：

```dockerfile
FROM ghcr.io/higma-container/clang:23

WORKDIR /workspace

COPY . .

RUN clang++ -std=c++23 -O2 \
    -o app \
    main.cpp
```

特定のClangバージョンに完全に固定する場合：

```dockerfile
FROM ghcr.io/higma-container/clang:v23.0.0
```

## Available Tools

主要なコマンド：

```text
clang
clang++
clangd
clang-format
clang-tidy
lld
lldb
```

バージョン付きの実体もインストールされています。

```text
clang-23
clang++-23
clangd-23
clang-format-23
clang-tidy-23
lld-23
lldb-23
```

`clang`、`clang++` などのデフォルトコマンドは Clang 23 を使用するように設定されています。

## CI / Release

GitHub Actions を使用して Docker イメージをビルドしています。

`main` ブランチへの push および Pull Request では、以下のテストを実行します。

* `linux/amd64` のビルド
* `linux/arm64` のビルド
* Clang 23 の起動確認
* Clangd 23 の起動確認
* LLDB 23 の起動確認
* LLD 23 の起動確認
* 各実行ファイルのPATH確認

GitHub Releaseを `published` にすると、`linux/amd64` と `linux/arm64` のイメージをビルドし、GHCRへpushします。

リリース時には Multi-platform manifest が作成されるため、利用者はアーキテクチャを意識せずにイメージを取得できます。

例えば `v23.0.0` をリリースした場合：

```sh
docker pull ghcr.io/higma-container/clang:v23.0.0
```

Clang 23 系の最新リリースを利用する場合：

```sh
docker pull ghcr.io/higma-container/clang:23
```

最新リリースを利用する場合：

```sh
docker pull ghcr.io/higma-container/clang:latest
```

## Image Tags

リリース時には以下のタグが作成されます。

```text
v23.0.0
23
latest
```

例えば `v23.0.0` をリリースした場合：

```text
ghcr.io/higma-container/clang:v23.0.0
ghcr.io/higma-container/clang:23
ghcr.io/higma-container/clang:latest
```

それぞれの用途は以下の通りです。

| Tag       | 用途            |
| --------- | ------------- |
| `v23.0.0` | 特定バージョンに完全固定  |
| `23`      | Clang 23 系を使用 |
| `latest`  | 最新リリースを使用     |

他のDockerfileから利用する場合は、再現性を重視するならバージョンタグを使用することを推奨します。

```dockerfile
FROM ghcr.io/higma-container/clang:v23.0.0
```

Clang 23系の更新を自動的に取り込みたい場合は：

```dockerfile
FROM ghcr.io/higma-container/clang:23
```

## Repository

* GitHub: `higma-container/clang-docker-image`
* Container Registry: `ghcr.io/higma-container/clang`
