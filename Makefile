

BIN_ROOT_NAME=.bin
BIN_ROOT=$(PWD)/$(BIN_ROOT_NAME)

export PATH:=$(BIN_ROOT):$(PATH)

this-print:
	@echo "build-mono"

include spok.mk

this: this-dep this-src this-bin 

this-dep:
	
	@echo $(BIN_ROOT_NAME) >> .gitignore

	#brew install goreleaser/tap/goreleaser

this-src: spok-src

this-bin-del:
	rm -rf $(BIN_ROOT)
	mkdir -p $(BIN_ROOT)
this-bin: this-bin-del spok-bin
	
