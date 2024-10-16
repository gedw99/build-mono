BIN_NAME=.bin
BIN_ROOT=$(PWD)/$(BIN_NAME)

export PATH:=$(BIN_ROOT):$(PATH)


print:

all: src bin 

dep:
	brew install goreleaser/tap/goreleaser

src:
	git clone https://github.com/gedw99/build-mono

bin:
	
install:
	cp $(BIN_ROOT)/spok $(GOPATH)/bin/spok
install-del:
	rm -rf $(GOPATH)/bin/spok
