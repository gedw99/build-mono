include help.mk

BIN_ROOT_NAME=.bin
BIN_ROOT=$(PWD)/$(BIN_ROOT_NAME)

export PATH:=$(BIN_ROOT):$(PATH)

## print
this-print:
	@echo "build-mono"
	@echo "BIN_ROOT: $(BIN_ROOT)"

include spok.mk

this: this-print this-dep this-src this-bin

this-dep: 
	
## src
this-src: spok-src

this-bin-dep:
	rm -rf $(BIN_ROOT)
	mkdir -p $(BIN_ROOT)
	@echo $(BIN_ROOT_NAME) >> .gitignore
	go install github.com/goreleaser/goreleaser/v2@latest
## bin
this-bin: this-bin-dep spok-bin

this-release-dep:
	go install github.com/cli/cli/v2/cmd/gh@latest
## release
this-release:
	release upload 001 $(PWD)/.bin/* --clobber

	

	
