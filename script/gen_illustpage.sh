#!/bin/bash

set -eu

find dist/ -name *r_stand_001_001.png -exec cp {} img/stand/ \;
find dist/ -name *face_001_001.png | grep -v -e vxace -e _l_ | xargs cp -t img/face/

paste -d " " \
    <(find img/stand/ -type f | sort) \
    <(find img/face/ -type f | sort) \
  | sed -r \
    -e 's@([^ ]+) (.*)$@<div class="actor-block"><div><img src="\1" height="400"></div><div><img src="\2"></div></div>@g' \
    -e 's@(src="dist/)(actor[0-9]+)(/stand.*</div>)(</div>)$@\1\2\3<label>\2</label>\4@g' \
  | cat \
    <(echo '<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width"><title> 次郎の配布イラスト一覧</title><style>body { font-size: 20px; background-color: #fafbfc; } .actor-block { display: inline-block; text-align: center; border: 2px solid #aaa; margin: 4px; background-color: white; }</style></head><body><h1>次郎の配布イラスト一覧</h1><h2><a href="https://github.com/jiro4989/dist-illust/releases">ダウンロード</a></h2><hr>') \
    - \
    <(echo '<hr><h2><a href="https://github.com/jiro4989/dist-illust/releases">ダウンロード</a></h2><small>&copy; '"$(date +%Y)"' 次郎 <a href="https://twitter.com/jiro_saburomaru">@jiro_saburomaru</a></small></body></html>') > index.html
