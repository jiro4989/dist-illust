CMD := tkimgutil
GEN_SCRIPT := script/gen_dist.sh
SRCS := $(shell find script -type f | grep .sh)
README := target/README.md

# リリース
# ------------------------------------------------------------------------------

# 配布物zipを全部作成
.PHONY: all
all: dist/actor019.zip dist/actor020.zip dist/actor024.zip

# GitHubReleaseにリリース
.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

# 配布物作成
# ------------------------------------------------------------------------------

dist/actor019.zip: $(SRCS) \
		$(shell find target/actor019/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) -a actor019 -x 62 -y 230 --scale-mv 50 --scale-vxace 30 1>/dev/null

dist/actor020.zip: $(SRCS) \
		$(shell find target/actor020/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) -a actor020 -x 92 -y 240 --scale-mv 44 --scale-vxace 30 1>/dev/null

dist/actor024.zip: $(SRCS) \
		$(shell find target/actor024/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) -a actor024 -x 75 -y 184 --scale-mv 42 --scale-vxace 30 1>/dev/null

# 環境整備
# ------------------------------------------------------------------------------

# 依存ツールのDL
.PHONY: setup
setup:
	chmod +x $(shell find script/ -type f -maxdepth 1)
	go get -u github.com/jiro4989/$(CMD)
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

# テンプレートディレクトリ構造の作成
.PHONY: dir
dir:
	if [ "$(DIRNAME)" = "" ]; then echo Require variable DIRNAME; exit 1; fi
	$(eval target_dir := target/$(DIRNAME))
	if [ -e "$(target_dir)" ]; then echo $(target_dir) has existed. Please delete one.; exit 1; fi
	cp -r target/actor020 "$(target_dir)"
	find "$(target_dir)" -type f | grep -v .toml | xargs rm
	sed -i 's@actor020@'"$(DIRNAME)"'@g' "$(target_dir)"/pattern/*.toml

# dist配下の成果物の画像ファイルを全部開く
.PHONY: open-all
open-all: all
	find dist/ -type f | grep .*face.*mv.*left.*001_001.png | xargs eog

