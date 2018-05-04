#!/bin/bash
# vim:set tw=0 nowrap:

set -eu

readonly CMD=tkimgutil
readonly ACTOR=$1
readonly TMP_DIR=tmp/$ACTOR

# 配布物作成前の中間画像の生成
generate () {
  local panel_type=$1
  local pattern_type=$2
  local scale_size=$3
  local trim_x=$4
  local trim_y=$5
  source ./script/param/$1.sh
  local paste_params=( -r $FACETILE_IMAGE_ROW -c $FACETILE_IMAGE_COL --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT )

  $CMD generate --config target/$ACTOR/pattern/$pattern_type.toml -d $pattern_dir/generate/left |
    $CMD scale -s $scale_size -d $pattern_dir/scale/$panel_type/left |
    $CMD trim -x $trim_x -y $trim_y --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT -d $pattern_dir/trim/left |
    sort |
    $CMD paste ${paste_params[@]} -d $pattern_dir/paste/$panel_type/left

  find $pattern_dir/generate/left -type f          | $CMD flip -d $pattern_dir/generate/right
  find $pattern_dir/scale/$panel_type/left -type f | $CMD flip -d $pattern_dir/scale/$panel_type/right
  find $pattern_dir/trim/left -type f              | $CMD flip -d $pattern_dir/trim/right |
    sort |
    $CMD paste ${paste_params[@]} -d $pattern_dir/paste/$panel_type/right
}

gen_base_scale_size=44
gen_rela_scale_size=30
gen_trim_x=92
gen_trim_y=240

pattern_index=0
for ptn_type in normal option_red
do
  pattern_index=$((pattern_index+1))
  pattern_dir=$TMP_DIR/$ptn_type

  generate rpg_maker_mv $ptn_type $gen_base_scale_size $gen_trim_x $gen_trim_y
  x=$(( gen_trim_x * gen_rela_scale_size / gen_base_scale_size ))
  y=$(( gen_trim_y * gen_rela_scale_size / gen_base_scale_size ))
  generate rpg_maker_vxace $ptn_type $gen_rela_scale_size $x $y

  # 配布用の立ち絵の生成
  find $pattern_dir/generate/left -type f |
    $CMD scale -s 50 -d $pattern_dir/scale/x50/left |
    $CMD flip -d $pattern_dir/scale/x50/right

  # 中間ファイルのうち必要なもののみコピーしてzip圧縮
  mkdir -p dist/$ACTOR
  cp target/README.md dist/$ACTOR/README.txt

  for direction in left right
  do
    tag=${direction:0:1}

    # 表情ファイルの生成
    for panel_type in rpg_maker_mv rpg_maker_vxace
    do
      find $pattern_dir/paste/$panel_type/$direction -type f |
        sort |
        while read -r f
        do
          i=$((i+1))
          dist_dir="dist/$ACTOR/face/$panel_type/$direction"

          num=`printf '%03d' $pattern_index`_`printf '%03d' $i`
          fn="${ACTOR}_${tag}_face_$num.png"

          mkdir -p $dist_dir
          cp "$f" "$dist_dir/$fn"
        done
    done

    # 立ち絵の生成
    find $pattern_dir/scale/x50/$direction -type f |
      sort |
      while read -r f
      do
        i=$((i+1))
        dist_dir=dist/$ACTOR/stand/$direction

        num=`printf '%03d' $pattern_index`_`printf '%03d' $i`
        fn=${ACTOR}_${tag}_stand_$num.png

        mkdir -p "$dist_dir"
        cp "$f" "$dist_dir/$fn"
      done
  done
done

( cd dist/ && zip -r $ACTOR.zip $ACTOR/ )
