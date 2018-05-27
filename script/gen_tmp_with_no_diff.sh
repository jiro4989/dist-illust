#!/bin/bash

readonly THIS_SCRIPT_NAME=`basename $0`
readonly CMD=tkimgutil

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
        local -r actor="$2"
        shift 2
        ;;
      '--panel-type' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r panel_type="$2"
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
      '-s'|'--scale-size' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r scale_size="$2"
        shift 2
        ;;
      -*)
        echo "$THIS_SCRIPT_NAME: Illegal option -- $1" 1>&2
        exit 1
        ;;
    esac
  done

  set -eu

  : $actor $panel_type $x $y $scale_size

  local -r tmp_dir=tmp/$actor
  source ./script/param/$panel_type.sh
  local -r paste_params=( -r $FACETILE_IMAGE_ROW -c $FACETILE_IMAGE_COL --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT )

  # TODO: パネル画像で通常のとオプションのがまじってる
  # find target/$actor/stand/right/ -type f | sort | sed -r 's@_[0-9]+.png@@g' | sort | uniq

  # 左右の立ち絵の作成
  mkdir -p ./$tmp_dir/right/stand
  cp target/$actor/stand/right/* ./$tmp_dir/right/stand/
  find ./$tmp_dir/right/stand/ -type f \
    | $CMD flip -d ./$tmp_dir/left/stand

  # 左右のスケールファイル
  find ./$tmp_dir/right/stand/ -type f \
    | $CMD scale -s $scale_size -d $tmp_dir/right/scale/$panel_type \
    | $CMD flip -d ./$tmp_dir/left/scale/$panel_type

  # 左右のトリミング画像の生成
  find ./$tmp_dir/right/scale/$panel_type -type f \
    | $CMD trim -x $x -y $y \
      --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT \
      -d ./$tmp_dir/right/trim/$panel_type \
    | $CMD flip -d $tmp_dir/left/trim/$panel_type

  # 左右の貼り付け済み画像の生成
  for direction in right left
  do
    find $tmp_dir/$direction/trim/$panel_type -type f \
      | sort \
      | $CMD paste ${paste_params[@]} -d $tmp_dir/$direction/paste/$panel_type
  done | xargs eog

}

# usage は使い方ヘルプ関数です。
function usage() {
  cat << EOL 1>&2
$THIS_SCRIPT_NAME は配布用zipの途中に必要となる中間画像を生成します。

Globals:
  None

Arguments:
  -h             ヘルプ
  --pattern-type 画像組み合わせtomlファイル名(拡張子なし)
  --panel-type   画像パネルタイプ(mv, vxaceなどの)
  -x             トリミングする座標x
  -y             トリミングする座標y
  --scale-size   画像パネルタイプ縮尺(%)

Returns:
  None

EOL
return 1
}

main "$@"
