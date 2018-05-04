#!/bin/bash
# vim:set tw=0 nowrap:

set -eu

readonly CMD=tkimgutil
readonly ACTOR=$1

# 配布物作成前の中間画像の生成
generate () {
  local panel_type=$1
  local scale_size=$2
  local trim_x=$3
  local trim_y=$4
  source ./script/param/$1.sh
  local paste_params=( -r $FACETILE_IMAGE_ROW -c $FACETILE_IMAGE_COL --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT )

  $CMD generate --config target/$ACTOR/pattern.toml -d tmp/$ACTOR/generate/left |
    $CMD scale -s $scale_size -d tmp/$ACTOR/scale/$panel_type/left |
    $CMD trim -x $trim_x -y $trim_y --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT -d tmp/$ACTOR/trim/left |
    sort |
    $CMD paste ${paste_params[@]} -d tmp/$ACTOR/paste/$panel_type/left
  find tmp/$ACTOR/generate/left -type f          | $CMD flip -d tmp/$ACTOR/generate/right
  find tmp/$ACTOR/scale/$panel_type/left -type f | $CMD flip -d tmp/$ACTOR/scale/$panel_type/right
  find tmp/$ACTOR/trim/left -type f              | $CMD flip -d tmp/$ACTOR/trim/right |
    sort |
    $CMD paste ${paste_params[@]} -d tmp/$ACTOR/paste/$panel_type/right
}

generate_base_scale_size=44
generate_rela_scale_size=30
generate_trim_x=92
generate_trim_y=240

generate rpg_maker_mv $generate_base_scale_size $generate_trim_x $generate_trim_y
generate rpg_maker_vxace $generate_rela_scale_size $(( generate_trim_x * generate_rela_scale_size / generate_base_scale_size )) $(( generate_trim_y * generate_rela_scale_size / generate_base_scale_size ))

# 配布用の立ち絵の生成
find tmp/$ACTOR/generate/left -type f |
  $CMD scale -s 50 -d tmp/$ACTOR/scale/x50/left |
  $CMD flip -d tmp/$ACTOR/scale/x50/right

# 中間ファイルのうち必要なもののみコピーしてzip圧縮

mkdir -p dist/$ACTOR
cp target/README.md dist/$ACTOR/README.txt

for panel_type in rpg_maker_mv rpg_maker_vxace
do
  for direction in left right
  do
    find tmp/$ACTOR/paste/$panel_type/$direction -type f |
      sort |
      while read -r f
        do
          i=$((i+1))
          dist_dir="dist/$ACTOR/face/$panel_type/$direction"
          fn="${ACTOR}_${direction:0:1}_face`printf '%03d' $i`.png"
          mkdir -p $dist_dir
          cp "$f" "$dist_dir/$fn"
        done
  done
done

mkdir -p dist/$ACTOR/stand/left
mkdir -p dist/$ACTOR/stand/right
find tmp/$ACTOR/scale/x50/left -type f  | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/stand/left/${ACTOR}_l_stand`printf '%03d' $i`.png"; done
find tmp/$ACTOR/scale/x50/right -type f | sort | while read -r f; do i=$((i+1)); cp "$f" "dist/$ACTOR/stand/right/${ACTOR}_r_stand`printf '%03d' $i`.png"; done

cd dist/ && zip -r $ACTOR.zip $ACTOR/
