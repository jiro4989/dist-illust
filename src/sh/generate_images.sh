#!/bin/bash

set -eu

## 環境変数
## readonly ACTOR_NAME=actor027
## readonly X=125
## readonly Y=215
## readonly SCALE_SIZE=50

readonly CONFIG_DIR=config/$ACTOR_NAME
readonly BASE_WIDTH=144
readonly BASE_HEIGHT=144
readonly TMP_DIR=tmp/$ACTOR_NAME

declare -A VERSION_MAP
VERSION_MAP=(
  ["96"]=rpg_maker_vxace
  ["144"]=rpg_maker_mv
)

mkdir -p tmp/
rm -rf $TMP_DIR || true

for w in 144 96; do
  rm -rf $CONFIG_DIR
  mkdir $CONFIG_DIR
  cp template/* $CONFIG_DIR/

  i=0
  scale_size=$((SCALE_SIZE*w/BASE_WIDTH))
  x=$((X*w/BASE_WIDTH))
  y=$((Y*w/BASE_WIDTH))
  version=${VERSION_MAP[$w]}
  for v in $CONFIG_DIR/*.json; do
    i=$((i+1))
    pattern_index=$(printf "%03d" $i)
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

readonly ACTOR_DIR=$TMP_DIR/$ACTOR_NAME
mkdir -p $ACTOR_DIR/stand
cp -r $TMP_DIR/generate $ACTOR_DIR/stand/left
cp -r $TMP_DIR/flip $ACTOR_DIR/stand/right
cp -r $TMP_DIR/face $ACTOR_DIR/
(cd $TMP_DIR && zip -r $ACTOR_NAME{.zip,}) >/dev/null
mv $ACTOR_DIR.zip dist/
