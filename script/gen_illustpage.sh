#!/bin/bash
# vim:tw=0:

set -eu

readonly BLOG="https://jiro4989.github.io/"
readonly DOWNLOAD="https://github.com/jiro4989/dist-illust/releases"
readonly TERMS_OF_USE="https://jiro4989.github.io/dist-illust/target/README.html"

readonly CSS_BODY="body { font-size: 20px; background-color: #fafbfc; }"
readonly CSS_ACTORBLOCK=".actor-block { display: inline-block; text-align: center; border: 2px solid #aaa; margin: 4px; background-color: white; }"
readonly CSS_LINK=".link { font-size: 28px; }"

find dist/ -name *r_stand_001_001.png -exec cp {} img/stand/ \;
find dist/ -name *face_001_001.png | grep -v -e vxace -e _l_ | xargs cp -t img/face/

spanlink() {
  local url=$1
  local text=$2
  printf '<span class="link"><a href="'"$url"'">'"$text"'</a></span>'
}

spanlinks() {
  for l in \
    "$(spanlink $BLOG "ブログ")" \
    "$(spanlink $DOWNLOAD "ダウンロード")" \
    "$(spanlink $TERMS_OF_USE "利用規約")"
  do
    printf "$l"
    printf " "
  done
}

styletag() {
  printf "<style>"
  for css in "$CSS_BODY" "$CSS_ACTORBLOCK" "$CSS_LINK"
  do
    printf "$css "
  done
  printf "</style>"
}

paste -d " " \
    <(find img/stand/ -type f | sort) \
    <(find img/face/ -type f | sort) \
  | sed -r \
    -e 's@([^ ]+) (.*)$@<div class="actor-block"><div><img src="\1" height="400"></div><div><img src="\2"></div></div>@g' \
    -e 's@(src="img/stand/)(actor[0-9]+)(.*</div>)(</div>)$@\1\2\3<label>\2</label>\4@g' \
  | cat \
    <(echo '<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width"><title> 次郎の配布イラスト一覧</title>'$(styletag)'</head><body><h1>次郎の配布イラスト一覧</h1>'"$(spanlinks)"'<hr>') \
    - \
    <(echo '<hr>'"$(spanlinks)"'<br><br><small>&copy; '"$(date +%Y)"' 次郎 <a href="https://twitter.com/jiro_saburomaru">@jiro_saburomaru</a></small></body></html>') > index.html
