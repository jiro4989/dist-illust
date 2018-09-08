# dist-illust

画像の一括生成、管理用リポジトリ。

## 目的

画像の生成、管理のコストを抑えること。主に自分用。

今まで画像はDropboxやGoogleDriveで管理していたのですが、正直使い勝手悪いですしリ
リースもやりづらいですしバージョン管理もしづらいので、ソースファイルと差分画像だ
けGitHubで管理して、生成はmakeからやればよいのではと考えました。

## 使い方

- 初回セットアップ: `make setup`
- 生成 `make dist/actorXXX.zip`
- 全部一気に生成 `make all`
- GitHubReleaseにリリース `make release`
- ディレクトリ作成 `make dir DIRNAME=actorXXX`

## 成果物

下記のファイル構造のzipファイル。

    dist/actorXXX/
    |-- face
    |   |-- rpg_maker_mv
    |   |   |-- left
    |   |   `-- right
    |   `-- rpg_maker_vxace
    |       |-- left
    |       `-- right
    `-- stand
        |-- left
        `-- right

## Krita設定

| 設定       | 値          |
|------------|-------------|
| ペン       | lnk_gpen_25 |
| ペンサイズ | 10          |
| 画像サイズ | N x 1620 px |

