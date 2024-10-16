

BIN_ROOT_NAME=.bin
BIN_ROOT=$(PWD)/$(BIN_ROOT_NAME)

export PATH:=$(BIN_ROOT):$(PATH)

this-print:
	@echo "build-mono"

include spok.mk

this: this-dep this-src this-bin 

this-dep:
	mkdir -p $(BIN_ROOT)
	@echo $(BIN_ROOT_NAME) >> .gitignore

	#brew install goreleaser/tap/goreleaser

this-src: spok-src


this-bin: spok-bin
	
install:
	cp $(BIN_ROOT)/spok $(GOPATH)/bin/spok
install-del:
	rm -rf $(GOPATH)/bin/spok
