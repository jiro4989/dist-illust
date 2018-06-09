#!/bin/bash

readonly THIS_SCRIPT_NAME=`basename $0`

function main() {
  for opt in "$@"
  do
    case "$opt" in
      '-h'|'--help' )
        usage
        exit 1
        ;;
      '-a'|'--actor' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        readonly ACTOR="$2"
        export ACTOR
        shift 2
        ;;
      '-x' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r x="$2"
        shift 2
        ;;
      '-y' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r y="$2"
        shift 2
        ;;
      '--scale-mv' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r scale_mv="$2"
        shift 2
        ;;
      '--scale-vxace' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r scale_vxace="$2"
        shift 2
        ;;
      -*)
        echo "$THIS_SCRIPT_NAME: Illegal option -- $1" 1>&2
        exit 1
        ;;
    esac
  done

  set -eu

  : $x $y $scale_mv $scale_vxace

  readonly CMD=tkimgutil
  export CMD

  readonly TMP_DIR=tmp/$ACTOR
  export TMP_DIR

  local -r GEN_SCRIPT="`dirname $0`/gen_tmp.sh"

  local pattern_index=0
  for ptn_type in normal option_red
  do
    local pattern_index=$((pattern_index+1))
    local pattern_dir=$TMP_DIR/$ptn_type

    # 中間画像ファイルの生成
    $GEN_SCRIPT \
      --pattern-type $ptn_type \
      --panel-type rpg_maker_mv \
      --scale-size $scale_mv \
      -x $x \
      -y $y
    local tmp_x=$(( x * scale_vxace / scale_mv ))
    local tmp_y=$(( y * scale_vxace / scale_mv ))
    $GEN_SCRIPT \
      --pattern-type $ptn_type \
      --panel-type rpg_maker_vxace \
      --scale-size $scale_vxace \
      -x $tmp_x \
      -y $tmp_y

    # 配布用の立ち絵の生成
    find $pattern_dir/generate/left -type f \
      | $CMD scale -s 50 -d $pattern_dir/scale/x50/left \
      | $CMD flip -d $pattern_dir/scale/x50/right

    # 中間ファイルのうち必要なもののみコピーしてzip圧縮
    mkdir -p dist/$ACTOR
    cp target/README.html dist/$ACTOR/

    for direction in left right
    do
      local tag=${direction:0:1}

      # 表情ファイルの生成
      for panel_type in rpg_maker_mv rpg_maker_vxace
      do
        find $pattern_dir/paste/$panel_type/$direction -type f \
          | sort \
          | while read -r f
            do
              local i=${i:-0}
              i=$((++i))
              local dist_dir="dist/$ACTOR/face/$panel_type/$direction"

              local num=`printf '%03d' $pattern_index`_`printf '%03d' $i`
              local fn="${ACTOR}_${tag}_face_$num.png"

              mkdir -p $dist_dir
              cp "$f" "$dist_dir/$fn"
            done
    done

    # 立ち絵の生成
    find $pattern_dir/scale/x50/$direction -type f \
      | sort \
      | while read -r f
        do
          local i=${i:-0}
          i=$((++i))
          local dist_dir=dist/$ACTOR/stand/$direction

          local num=`printf '%03d' $pattern_index`_`printf '%03d' $i`
          local fn=${ACTOR}_${tag}_stand_$num.png

          mkdir -p "$dist_dir"
          cp "$f" "$dist_dir/$fn"
        done
    done
  done

  ( cd dist/ && zip -r $ACTOR.zip $ACTOR/ )

  return 0
}

# usage は使い方ヘルプ関数です。
function usage() {
  cat << EOL 1>&2
  $THIS_SCRIPT_NAME は配布用zipを生成します。

  Globals:
  None

  Arguments:
  -h            ヘルプ
  -a, --actor   アクターファイル名
  -x            トリミングする座標x
  -y            トリミングする座標y
  --scale-mv    MV用の画像の拡縮(%)
  --scale-vxace VXACE用の画像の拡縮(%)

  Returns:
  None

EOL
  return 1
}

main "$@"
