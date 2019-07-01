# dist-illust

[![Build Status](https://travis-ci.org/jiro4989/dist-illust.svg?branch=master)](https://travis-ci.org/jiro4989/dist-illust)

画像の一括生成、管理用リポジトリ。

## 目的

画像の生成、管理のコストを抑えること。主に自分用。

## できること

`resources`配下の差分画像を順に重ねていくことで、
立ち絵画像を自動生成し配布用のファイル構成にパッケージングすること。

昔に書いたイラストはすでに元になる画像ソースが残っていないことや
ソースの画像のサイズが小さかったりして自動生成に使えないものがある。
自動生成できないもの(001〜019と025, 026)はすでに配布用に生成済みのもののみをリポジトリで管理している。

## 前提条件

以下のツールが必要である。

- [imgctl](https://github.com/jiro4989/imgctl) 自作の画像生成用のツール
- zip 配布用にzip圧縮するためのコマンド
- ghr GitHubReleaseにリリースするためのコマンド

## 使い方

- 依存ツールのインストール: `make setup`
- 生成 `make actorXXX`
- 全部生成 `make all`
- GitHubReleaseにリリース `make release`

## 成果物

distディレクトリ配下に圧縮ファイルが生成される。

# メモ

## Krita設定

| 設定       | 値          |
|------------|-------------|
| ペン       | lnk_gpen_25 |
| ペンサイズ | 10          |
| 画像サイズ | N x 1620 px |

