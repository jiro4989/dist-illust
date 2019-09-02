#!/bin/bash

################################################################################
##
## archive.sh はすでに生成ずみの配布物をZIP圧縮してdistディレクトリに配置する。
##
## 前提条件:
##   zip    ZIP圧縮に必要
##
## 引数:
##   - resources/actorXXXのactorXXX
##
## 環境変数:
##   なし
##
## 使い方:
##   ./src/sh/archive.sh actor001
##
## 成果物:
##   dist/actorXXX.zip
##
## 中間生成物:
##   tmp/actorXXX/
##
################################################################################

set -eu

# 引数が指定されているかをチェック
: $1

# コマンドの有無チェック
type zip >/dev/null 2>&1 || {
  echo -e "zipコマンドが存在しません。インストールしてください。"
  exit 1
}

readonly ACTOR_NAME=$1

mkdir -p tmp/
rm -rf tmp/$ACTOR_NAME || true
cp -r resources/$ACTOR_NAME tmp/
cp docs/LICENSE.html tmp/$ACTOR_NAME/

( cd tmp && zip -r $ACTOR_NAME{.zip,} ) >/dev/null

mkdir -p dist
mv tmp/$ACTOR_NAME.zip dist/
