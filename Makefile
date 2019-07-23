GEN_CMD := ./src/sh/generate_images.sh
ARC_CMD := ./src/sh/archive.sh
THUMBNAIL_CMD := ./src/sh/generate_thumbnail.sh

################################################################################
#     画像・配布物生成
################################################################################

.PHONY: all
all: thumbnail

# 配布物zipを全部作成
.PHONY: actors
actors: \
	clean \
	actor001_019
	for task in `ls resources/ | sed 's/actor//g' | awk '20<=$$1'`; do \
		make actor$$task; \
	done

.PHONY: thumbnail
thumbnail: acotrs
	$(THUMBNAIL_CMD)

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

.PHONY: actor025
actor025:
	$(ARC_CMD) $@

.PHONY: actor026
actor026:
	$(ARC_CMD) $@

.PHONY: actor027
actor027:
	ACTOR_NAME=$@ X=125 Y=215 SCALE_SIZE=50 $(GEN_CMD)

################################################################################
#     環境整備
################################################################################

# 依存ツールのDL
.PHONY: setup
setup:
	GO111MODULE=off go get -u github.com/jiro4989/imgctl

# 成果物や中間生成物の削除
.PHONY: clean
clean:
	-rm -rf dist/*
	-rm -rf tmp/

# kritaの不可視ファイルの削除
.PHONY: clean-backupfiles
clean-backupfiles:
	find resources/ -name '*.png~' -exec rm {} \;

# 画像サイズを確認する
.PHONY: check-size
check-size:
	find tmp/actor{001..019} -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
	find tmp/actor*/actor* -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
