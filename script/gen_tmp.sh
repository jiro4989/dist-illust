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
      '--pattern-type' )
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$THIS_SCRIPT_NAME: options requires an argument -- $1" 1>&2
          exit 1
        fi
        local -r pattern_type="$2"
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

  : $CMD $ACTOR $TMP_DIR $pattern_type $panel_type $x $y $scale_size

  # パネルタイプごとの画像規格変数の取得
  source ./script/param/$panel_type.sh
  local -r paste_params=( -r $FACETILE_IMAGE_ROW -c $FACETILE_IMAGE_COL --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT )
  local -r pattern_dir=$TMP_DIR/$pattern_type

  # 左向き画像の生成
  $CMD generate --config target/$ACTOR/pattern/$pattern_type.toml -d $pattern_dir/generate/left \
    | $CMD scale -s $scale_size -d $pattern_dir/scale/$panel_type/left \
    | $CMD trim -x $x -y $y --width $FACETILE_IMAGE_WIDTH --height $FACETILE_IMAGE_HEIGHT -d $pattern_dir/trim/left \
    | sort \
    | $CMD paste ${paste_params[@]} -d $pattern_dir/paste/$panel_type/left

  # 右向き画像の生成
  find $pattern_dir/generate/left -type f          | $CMD flip -d $pattern_dir/generate/right
  find $pattern_dir/scale/$panel_type/left -type f | $CMD flip -d $pattern_dir/scale/$panel_type/right
  find $pattern_dir/trim/left -type f              | $CMD flip -d $pattern_dir/trim/right \
    | sort \
    | $CMD paste ${paste_params[@]} -d $pattern_dir/paste/$panel_type/right

  return 0
}

# usage は使い方ヘルプ関数です。
function usage() {
  cat << EOL 1>&2
$THIS_SCRIPT_NAME は配布用zipの途中に必要となる中間画像を生成します。

Globals:
  CMD            画像生成に使用するコマンド名
  ACTOR          生成するアクター名(拡張子なし)
  TMP_DIR        画像の出力先ディレクトリ

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
