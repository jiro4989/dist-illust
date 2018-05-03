CMD := tkimgutil
GEN_SCRIPT := script/generate.sh
README := target/README.md

.PHONY: all
all: dist/actor020.zip

dist/actor020.zip: $(GEN_SCRIPT) $(shell find target/actor020 -type f | grep -E \.png$$) $(README) 
	./$(GEN_SCRIPT) actor020

.PHONY: setup
setup:
	go get -u github.com/jiro4989/$(CMD)
	go get -u github.com/tcnksm/ghr

.PHONY: clean
clean:
	-rm -rf tmp/

.PHONY: clean-backupfiles
clean-backupfiles:
	find target/ -type f | grep png~ | xargs rm
