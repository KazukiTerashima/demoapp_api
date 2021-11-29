# ベースイメージを指定する
# FROM ベースイメージ：タグ
FROM ruby:3.0.3-alpine

# Dockerfile内で使用する変数定義
# 今回はDocker-composeからappが代入される
ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git" 
ARG DEV_PACKAGES="build-base curl-dev"

# 環境変数を定義(Dockerfile、 コンテナから参照可能)
# Rails ENV["TZ"] => Asia/Tokyo
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# 作業ディレクトリを定義
WORKDIR ${HOME}

# ホスト側からコンテナ側へファイルコピー
COPY Gemfile* ./

    # apk: alpine Linux コマンド
    # apk update: パッケージの最新リストを取得
RUN apk update && \
    # apk upgrade: インストールパッケージを最新のものに
    apk upgrade && \
    # apk add: パッケージのインストール
    # --no-cache: パッケージをキャッシュしない(軽量化)
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    # --virtural <name>: <name>で仮装パッケージ化
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    # -j4(jobs4): Gemインストールの高速化 
    bundle install -j4 && \
    # パッケージの削除(軽量化)
    apk del build-dependencies

COPY . ./
