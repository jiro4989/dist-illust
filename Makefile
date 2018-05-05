CMD := tkimgutil
GEN_SCRIPT := script/gen_dist.sh
SRCS := $(shell find script -type f | grep .sh)
README := target/README.md

.PHONY: all
all: dist/actor020.zip

.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

dist/actor020.zip: $(SRCS) \
		$(shell find target/actor020/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) -a actor020 -x 92 -y 240 --scale-mv 44 --scale-vxace 30

.PHONY: setup
setup:
	chmod +x $(shell find script/ -type f -maxdepth 1)
	go get -u github.com/jiro4989/$(CMD)
	go get -u github.com/tcnksm/ghr

.PHONY: clean
clean:
	-rm -rf dist/*
	-rm -rf tmp/

.PHONY: clean-backupfiles
clean-backupfiles:
	find target/ -type f | grep png~ | xargs rm
