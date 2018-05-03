#!/bin/bash

set -eu

readonly CMD=tkimgutil
readonly ACTOR=$1

# 配布物作成前の中間画像の生成
$CMD generate --config target/$ACTOR/pattern.toml -d tmp/$ACTOR/generate/left |
  $CMD scale -s 44 -d tmp/$ACTOR/scale/left |
  $CMD trim -x 58 -y 229 -d tmp/$ACTOR/trim/left |
  sort |
  $CMD paste -d tmp/$ACTOR/paste/left
find tmp/$ACTOR/generate/left -type f | $CMD flip -d tmp/$ACTOR/generate/right
find tmp/$ACTOR/scale/left -type f    | $CMD flip -d tmp/$ACTOR/scale/right
find tmp/$ACTOR/trim/left -type f     | $CMD flip -d tmp/$ACTOR/trim/right |
  sort |
  $CMD paste -d tmp/$ACTOR/paste/right

# 中間ファイルのうち必要なもののみコピーしてzip圧縮
mkdir -p dist/$ACTOR/face/left
mkdir -p dist/$ACTOR/face/right
mkdir -p dist/$ACTOR/stand/left
mkdir -p dist/$ACTOR/stand/right
cp target/README.md dist/$ACTOR/README.txt

find tmp/$ACTOR/paste/left -type f  | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/face/left/${ACTOR}_l_face`printf '%03d' $i`.png"; done
find tmp/$ACTOR/paste/right -type f | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/face/right/${ACTOR}_r_face`printf '%03d' $i`.png"; done
find tmp/$ACTOR/scale/left -type f  | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/stand/left/${ACTOR}_l_stand`printf '%03d' $i`.png"; done
find tmp/$ACTOR/scale/right -type f | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/stand/right/${ACTOR}_r_stand`printf '%03d' $i`.png"; done
cd dist/ && zip -r $ACTOR.zip $ACTOR/
