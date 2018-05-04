CMD := tkimgutil
GEN_SCRIPT := script/generate.sh
README := target/README.md

.PHONY: all
all: dist/actor020.zip

.PHONY: release
release: all
	ghr `date +%Y%m%d-%H%M%S` dist/

dist/actor020.zip: $(GEN_SCRIPT) \
		$(shell find target/actor020/ -type f | grep -E "\.(png|toml)$$") \
		$(README) 
	./$(GEN_SCRIPT) actor020

.PHONY: setup
setup:
	chmod +x $(GEN_SCRIPT)
	go get -u github.com/jiro4989/$(CMD)
	go get -u github.com/tcnksm/ghr

.PHONY: clean
clean:
	-rm -rf dist/*
	-rm -rf tmp/

.PHONY: clean-backupfiles
clean-backupfiles:
	find target/ -type f | grep png~ | xargs rm
