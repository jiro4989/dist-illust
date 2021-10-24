GEN_CMD := ./src/sh/generate_images.sh
ARC_CMD := ./src/sh/archive.sh
THUMBNAIL_CMD := ./src/sh/generate_thumbnail.sh

.PHONY: help
help: ## ドキュメントのヘルプを表示する。
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

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
thumbnail: actors ## サムネイルを生成する
	$(THUMBNAIL_CMD)

.PHONY: actor001_019
actor001_019: ## actor001～019を生成する
	for i in `seq 19`; do $(ARC_CMD) actor`printf '%03d' $$i`; done

.PHONY: actor020
actor020: ## actor020を生成する
	ACTOR_NAME=$@ X=92 Y=240 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor021
actor021: ## actor021を生成する
	ACTOR_NAME=$@ X=32 Y=220 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor022
actor022: ## actor022を生成する
	ACTOR_NAME=$@ X=80 Y=125 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor023
actor023: ## actor023を生成する
	ACTOR_NAME=$@ X=62 Y=230 SCALE_SIZE=50 $(GEN_CMD)

.PHONY: actor024
actor024: ## actor024を生成する
	ACTOR_NAME=$@ X=73 Y=215 SCALE_SIZE=44 $(GEN_CMD)

.PHONY: actor025
actor025: ## actor025を生成する
	$(ARC_CMD) $@

.PHONY: actor026
actor026: ## actor026を生成する
	$(ARC_CMD) $@

.PHONY: actor027
actor027: ## actor027を生成する
	ACTOR_NAME=$@ X=125 Y=215 SCALE_SIZE=50 $(GEN_CMD)

.PHONY: actor028
actor028: ## actor028を生成する
	ACTOR_NAME=$@ X=240 Y=369 SCALE_SIZE=29 $(GEN_CMD)

.PHONY: actor029
actor029: ## actor029を生成する
	ACTOR_NAME=$@ X=174 Y=55 SCALE_SIZE=29 $(GEN_CMD)

.PHONY: actor030
actor030: ## actor030を生成する
	ACTOR_NAME=$@ X=278 Y=75 SCALE_SIZE=29 $(GEN_CMD)

.PHONY: actor031
actor031: ## actor031を生成する
	make actor031_032 ACTOR_NAME=$@

.PHONY: actor032
actor032: ## actor032を生成する
	make actor031_032 ACTOR_NAME=$@

.PHONY: actor031_032
actor031_032: ## actor031と032の共通処理
	X=178 Y=75 SCALE_SIZE=29 $(GEN_CMD)

################################################################################
#     環境整備
################################################################################

.PHONY: setup
setup: ## 依存ツールのDL
	GO111MODULE=off go get -u github.com/jiro4989/imgctl

.PHONY: clean
clean: ## 成果物や中間生成物の削除
	-rm -rf dist/*
	-rm -rf tmp/

.PHONY: clean-backupfiles
clean-backupfiles: ## kritaの不可視ファイルの削除
	find resources/ -name '*.png~' -exec rm {} \;

.PHONY: check-size
check-size: ## 画像サイズを確認する
	find tmp/actor{001..019} -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
	find tmp/actor*/actor* -name '*.png' -exec identify -format '%f: width = %w, height = %h\n' {} \;
