CMD := tkimgutil
GEN_SCRIPT := script/gen_dist.sh
SRCS := $(shell find script -type f | grep .sh)
README := target/README.md

# 配布物zipを全部作成
.PHONY: all
all: dist/actor020.zip

# GitHubReleaseにリリース
.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

# 配布物作成
dist/actor020.zip: $(SRCS) \
		$(shell find target/actor020/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) -a actor020 -x 92 -y 240 --scale-mv 44 --scale-vxace 30 1>/dev/null

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
