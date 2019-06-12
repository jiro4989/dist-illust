README := target/README.html
GEN_CMD := ./src/sh/generate_images.sh
ARC_CMD := ./src/sh/archive.sh

# リリース
# ------------------------------------------------------------------------------

# 配布物zipを全部作成
.PHONY: all
all: \
	clean \
	actor001_019 \
	actor020 \
	actor021 \
	actor022 \
	actor023 \
	actor024 \
	actor025 \
	actor026 \
	actor027

# GitHubReleaseにリリース
.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

# 配布物作成
# ------------------------------------------------------------------------------

.PHONY: actor001_019
actor001_019:
	for i in `seq 19`; do $(ARC_CMD) actor`printf '%03d' $$i`; done

.PHONY: actor020
actor020:
	ACTOR_NAME=$@ X=92 Y=240 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor021
actor021:
	ACTOR_NAME=$@ X=32 Y=220 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor022
actor022:
	ACTOR_NAME=$@ X=80 Y=125 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor023
actor023:
	ACTOR_NAME=$@ X=62 Y=230 SCALE_SIZE=50 $(GEN_CMD)

.PHONY: actor024
actor024:
	ACTOR_NAME=$@ X=73 Y=215 SCALE_SIZE=44 $(GEN_CMD)

actor025:
	$(ARC_CMD) $@

actor026:
	$(ARC_CMD) $@

.PHONY: actor027
actor027:
	ACTOR_NAME=$@ X=125 Y=215 SCALE_SIZE=50 $(GEN_CMD)

# 環境整備
# ------------------------------------------------------------------------------

# 依存ツールのDL
.PHONY: setup
setup:
	go get -u github.com/jiro4989/imgctl
	go get -u github.com/tcnksm/ghr

# 成果物や中間生成物の削除
.PHONY: clean
clean:
	-rm -rf dist/*
	-rm -rf tmp/

# kritaの不可視ファイルの削除
.PHONY: clean-backupfiles
clean-backupfiles:
	find target/ -type f | grep png~ | xargs rm

# 画像サイズを確認する
.PHONY: check-size
check-size:
	find tmp/actor{001..019} -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
	find tmp/actor*/actor* -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
