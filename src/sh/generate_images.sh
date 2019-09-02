#!/bin/bash

################################################################################
##
## generate_images.sh は差分の画像を重ねて立ち絵の画像を生成する。
## 生成した画像を左右反転、トリミング、タイル状配置してZIP圧縮し、distディレクト
## リに配置する。
##
## 前提条件:
##   imgctl 自作のコマンド (https://github.com/jiro4989/imgctl)
##   zip    ZIP圧縮に必要
##
## 引数:
##   - resources/actorXXXのactorXXX
##
## 環境変数:
##   オプション引数解析を実装するのがめんどくさかったので環境変数を使うことにし
##   ている。
##
##   - ACTOR_NAME  resources/actorXXXのactorXXX
##   - X           トリミング位置
##   - Y           トリミング位置
##   - SCALE_SIZE  トリミングするときのスケールサイズ
##
## 使い方:
##   ACTOR_NAME=actor027 X=125 Y=215 SCALE_SIZE=50 ./src/sh/generate_images.sh
##
## 成果物:
##   dist/actorXXX.zip
##
## 中間生成物:
##   tmp/actorXXX/
##
################################################################################

set -eu

# 環境変数がセットされているかをチェック
: $ACTOR_NAME
: $X
: $Y
: $SCALE_SIZE

# コマンドの有無チェック
type imgctl >/dev/null 2>&1 || {
  echo -e "imgctlコマンドが存在しません。\nmake setup を実行してください。"
  exit 1
}

type zip >/dev/null 2>&1 || {
  echo -e "zipコマンドが存在しません。インストールしてください。"
  exit 1
}

readonly CONFIG_DIR=config/$ACTOR_NAME
readonly BASE_WIDTH=144
readonly BASE_HEIGHT=144
readonly TMP_DIR=tmp/$ACTOR_NAME

# ハッシュマップの宣言
declare -A VERSION_MAP
VERSION_MAP=(
  ["96"]=rpg_maker_vxace
  ["144"]=rpg_maker_mv
)

mkdir -p tmp/
rm -rf $TMP_DIR || true

# テンプレートの設定ファイルをconfigディレクトリにコピーして
# 置換用のテンプレート文字列を環境変数や変数で上書き置換。
#
# 置換後の設定ファイルを使用してimgctl allで画像を一括生成する。
for w in 144 96; do
  rm -rf $CONFIG_DIR
  mkdir $CONFIG_DIR
  # テンプレート設定ファイルの配置
  cp template/* $CONFIG_DIR/

  i=0
  scale_size=$((SCALE_SIZE*w/BASE_WIDTH))
  x=$((X*w/BASE_WIDTH))
  y=$((Y*w/BASE_WIDTH))
  version=${VERSION_MAP[$w]}
  for v in $CONFIG_DIR/*.json; do
    i=$((i+1))
    pattern_index=$(printf "%03d" $i)

    # 環境変数や変数でテンプレート文字列を上書き置換
    sed -i \
      -e 's@{{ACTOR_NAME}}@'$ACTOR_NAME'@g' \
      -e 's@{{X}}@'$x'@g' \
      -e 's@{{Y}}@'$y'@g' \
      -e 's@{{WIDTH}}@'$w'@g' \
      -e 's@{{HEIGHT}}@'$w'@g' \
      -e 's@{{SCALE_SIZE}}@'$scale_size'@g' \
      -e 's@{{PATTERN_INDEX}}@'"$pattern_index"'@g' \
      -e 's@{{VERSION}}@'"$version"'@g' \
      $v
    imgctl all $v >/dev/null
  done
done

# 配布用のディレクトリ構成に変更
readonly ACTOR_DIR=$TMP_DIR/$ACTOR_NAME
mkdir -p $ACTOR_DIR/stand
cp docs/LICENSE.html $ACTOR_DIR/
cp -r $TMP_DIR/generate $ACTOR_DIR/stand/left
cp -r $TMP_DIR/flip $ACTOR_DIR/stand/right
cp -r $TMP_DIR/face $ACTOR_DIR/

# ファイル名をactorXXX_l_face_001_001.png 形式に変更する
find $TMP_DIR -name '*.png' \
  | grep -E 'actor.../actor.../face' \
  | sed -E 's@(tmp)/(actor[0-9]+)/(actor[0-9]+)/(face)/([^/]+)/(.)([^/]+)/(.*\.png)@mv & \1/\2/\3/\4/\5/\6\7/\2_\6_\4_\8@ge' \
  >/dev/null

# ファイル名をactorXXX_l_stand_001_001.png 形式に変更する
find $TMP_DIR -name '*.png' \
  | grep -E 'actor.../actor.../stand' \
  | sed -E 's@(tmp)/(actor[0-9]+)/(actor[0-9]+)/(stand)/(.)([^/]+)/(.*\.png)@mv & \1/\2/\3/\4/\5\6/\2_\5_\4_\7@ge' \
  >/dev/null

(cd $TMP_DIR && zip -r $ACTOR_NAME{.zip,}) >/dev/null
mkdir -p dist
mv $ACTOR_DIR.zip dist/
