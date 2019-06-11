README := target/README.html
GEN_CMD := ./src/sh/generate_images.sh

# リリース
# ------------------------------------------------------------------------------

# 配布物zipを全部作成
.PHONY: all
all: \
	actor020 \
	actor021 \
	actor022 \
	actor023 \
	actor024 \
	actor027

# GitHubReleaseにリリース
.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

# 配布物作成
# ------------------------------------------------------------------------------

.PHONY: dist/actor001_019.zip
dist/actor001_019.zip:
	#./script/gen_tmp_with_no_diff.sh -a actor001 -x 57 -y 100 --scale-size 65 --panel-type rpg_maker_mv
	for i in `seq 19`; do ./script/zip_gened.sh actor`printf '%03d' $$i`; done 1>/dev/null

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

dist/actor025.zip:
	./script/zip_gened.sh actor`printf '%03d' 25` 1>/dev/null

dist/actor026.zip:
	./script/zip_gened.sh actor`printf '%03d' 26` 1>/dev/null

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

