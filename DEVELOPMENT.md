# Development

このドキュメントは、`clang-docker-image` の開発・テスト・リリース時に使用するメモです。

## Local Build

ローカルでDockerイメージをビルドする場合：

```sh
docker build \
  --build-arg CLANG_VERSION=23 \
  -t clang:local \
  .
```

ビルド後にClangを確認：

```sh
docker run --rm \
  clang:local \
  clang --version
```

Clang++を確認：

```sh
docker run --rm \
  clang:local \
  clang++ --version
```

Clangdを確認：

```sh
docker run --rm \
  clang:local \
  clangd --version
```

LLDBを確認：

```sh
docker run --rm \
  clang:local \
  lldb --version
```

LLDを確認：

```sh
docker run --rm \
  clang:local \
  lld --version
```

## Multi-platform Build

ローカルから `linux/amd64` と `linux/arm64` のイメージをビルドする場合：

```sh
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg CLANG_VERSION=23 \
  -t ghcr.io/higma-container/clang:local \
  .
```

レジストリへpushする場合は `--push` を追加します。

```sh
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg CLANG_VERSION=23 \
  -t ghcr.io/higma-container/clang:v23.0.0 \
  --push \
  .
```

## GitHub Actions

GitHub Actions のWorkflowは以下の2つに分かれています。

```text
.github/workflows/
├── test.yaml
└── release.yaml
```

### test.yaml

`main` ブランチへのpush、およびPull Requestで実行します。

```text
main / Pull Request
        │
        ├── amd64 build + test
        │
        └── arm64 build + test
```

GHCRへのpushは行いません。

各アーキテクチャのrunner上でイメージをビルドし、以下を確認します。

```sh
clang --version
clang++ --version
clangd --version
lldb --version
lld --version
```

さらに、以下のコマンドが存在することを確認します。

```sh
which clang
which clang++
which clangd
which lldb
which lld
```

テストではClangのメジャーバージョンが23であることも確認します。

## release.yaml

GitHub Releaseが `published` されたときに実行します。

```text
GitHub Release
      │
      ├── amd64 build → GHCR
      │
      └── arm64 build → GHCR
                    │
                    ↓
              Multi-platform
                 manifest
                    │
          ┌─────────┼─────────┐
          ↓         ↓         ↓
       v23.0.0      23      latest
```

例えば `v23.0.0` をリリースすると、

```text
ghcr.io/higma-container/clang:v23.0.0
ghcr.io/higma-container/clang:23
ghcr.io/higma-container/clang:latest
```

が作成されます。

各アーキテクチャの中間イメージとして、

```text
v23.0.0-amd64
v23.0.0-arm64
```

も作成されます。

最終的に `v23.0.0`、`23`、`latest` はすべて `linux/amd64` と `linux/arm64` の Multi-platform manifest になります。

## Image Tag Policy

リリースタグには以下の3種類があります。

### Version tag

```text
v23.0.0
```

特定のバージョンに完全に固定したい場合に使用します。

例えば：

```dockerfile
FROM ghcr.io/higma-container/clang:v23.0.0
```

CIや再現性が重要な環境では、この形式を推奨します。

### Major version tag

```text
23
```

Clang 23系の最新リリースを使用します。

例えば：

```dockerfile
FROM ghcr.io/higma-container/clang:23
```

Clang 23系の更新を取り込みたい場合に使用します。

### latest

```text
latest
```

最新のClangリリースを指します。

Clang 24などの新しいメジャーバージョンへ移行した場合、`latest` は新しいバージョンを指すようになります。

そのため、ビルド環境の再現性が必要なDockerfileでは `latest` の使用を避けることを推奨します。

## Build Cache

`test.yaml` と `release.yaml` ではGitHub ActionsのBuildKit cacheを共有しています。

amd64：

```yaml
cache-from: type=gha,scope=clang-amd64
cache-to: type=gha,mode=max,scope=clang-amd64
```

arm64：

```yaml
cache-from: type=gha,scope=clang-arm64
cache-to: type=gha,mode=max,scope=clang-arm64
```

そのため、mainへのpushで作成されたビルドキャッシュをRelease時にも利用できます。

```text
main push
   │
   ↓
test.yaml
   │
   ├── amd64 ──→ clang-amd64 cache
   │
   └── arm64 ──→ clang-arm64 cache
                         │
                         ↓
                    release.yaml
```

amd64とarm64ではキャッシュを分離しています。

Dockerfileの変更内容によってキャッシュの利用状況は変わります。

## GHCR Permissions

GitHub ActionsからGHCRへpushするため、Workflowでは以下の権限を使用します。

```yaml
permissions:
  contents: read
  packages: write
```

GHCRのPackage側でも、対象RepositoryからのActionsによるアクセスにWrite権限が必要になる場合があります。

Package settingsのActions accessから、

```text
higma-container/clang-docker-image
```

にWrite権限を設定します。

GHCRへのpush時に以下のようなエラーが発生した場合：

```text
denied: permission_denied: read_package
```

Package側のActions accessを確認します。

## Docker Image Repository

GHCRのイメージ：

```text
ghcr.io/higma-container/clang
```

GitHub Repository：

```text
higma-container/clang-docker-image
```

DockerfileにはRepositoryとの関連付けのため、以下のLABELを設定します。

```dockerfile
LABEL org.opencontainers.image.source="https://github.com/higma-container/clang-docker-image"
```

実際のRepository名が異なる場合は、DockerfileのLABELを実際のURLに合わせて変更してください。

## Release

リリース時はGitHubでReleaseを作成します。

例えば：

```text
Tag: v23.0.0
```

Releaseを `published` にすると `release.yaml` が実行されます。

WorkflowではReleaseのタグを使用して、以下のイメージを作成します。

```text
v23.0.0-amd64
v23.0.0-arm64
```

その後、Multi-platform manifestを作成します。

```text
v23.0.0
23
latest
```

### Release時の注意

Releaseを作成する前に、`main` ブランチのCIが成功していることを確認します。

特に以下を確認します。

* Dockerfileのビルドが成功している
* `linux/amd64` のテストが成功している
* `linux/arm64` のテストが成功している
* Clang 23がインストールされている
* Clangd / LLDB / LLDが正常に動作する

CIが失敗した場合は、Dockerfileなどを修正した上でWorkflowを再実行します。

ビルドに失敗しただけの場合は、成功するまで同じバージョンで再実行し、不要に次のバージョンへ上げないようにします。
