#!/bin/bash

set -eu

readonly CROP_WIDTH=144
readonly CROP_HEIGHT=144
readonly THUMBNAIL_DIR=tmp/thumbnail
readonly THUMBNAIL_ROW=2
readonly THUMBNAIL_COL=5
readonly THUMBNAIL_FILE_NAME_FORMAT="thumbnail_%03d.png"
readonly OUT_DIR=gh-pages

# コマンドの有無チェック
type imgctl >/dev/null 2>&1 || {
  echo -e "imgctlコマンドが存在しません。\nmake setup を実行してください。"
  exit 1
}

mkdir -p $THUMBNAIL_DIR

find tmp -name '*face_001_001.png' \
  | grep -v thumbnail \
  | grep -v -e vxace -e left \
  | xargs imgctl crop \
        -x 0 -y 0 \
        -W $CROP_WIDTH -H $CROP_HEIGHT \
        -d $THUMBNAIL_DIR \
  | sort \
  | xargs imgctl paste \
      -r $THUMBNAIL_ROW -c $THUMBNAIL_COL \
      -W $CROP_WIDTH -H $CROP_HEIGHT \
      -f $THUMBNAIL_FILE_NAME_FORMAT \
      -d $OUT_DIR
