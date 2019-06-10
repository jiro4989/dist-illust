#!/bin/bash

set -eu

readonly ACTOR_NAME=actor027
readonly CONFIG_DIR=config/$ACTOR_NAME

readonly X=125
readonly Y=215
readonly BASE_WIDTH=144
readonly BASE_HEIGHT=144
readonly SCALE_SIZE=50

rm -rf tmp/$ACTOR_NAME

for w in 144 96; do
  rm -rf $CONFIG_DIR
  mkdir $CONFIG_DIR
  cp template/* $CONFIG_DIR/

  i=0
  scale_size=$((SCALE_SIZE*w/BASE_WIDTH))
  x=$((X*w/BASE_WIDTH))
  y=$((Y*w/BASE_WIDTH))
  for v in $CONFIG_DIR/*.json; do
    i=$((i+1))
    pattern_index=$(printf "%03d" $i)
    sed -i -e 's@{{ACTOR_NAME}}@'$ACTOR_NAME'@g' \
      -e 's@{{X}}@'$x'@g' \
      -e 's@{{Y}}@'$y'@g' \
      -e 's@{{WIDTH}}@'$w'@g' \
      -e 's@{{HEIGHT}}@'$w'@g' \
      -e 's@{{SCALE_SIZE}}@'$scale_size'@g' \
      -e 's@{{PATTERN_INDEX}}@'"$pattern_index"'@g' \
      $v
    imgctl all $v
  done
done
