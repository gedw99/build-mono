include help.mk

BIN_ROOT_NAME=.bin
BIN_ROOT=$(PWD)/$(BIN_ROOT_NAME)

export PATH:=$(BIN_ROOT):$(PATH)

## print
this-print:
	@echo ""
	@echo "build-mono"
	@echo "BIN_ROOT: $(BIN_ROOT)"
	@echo ""

include spok.mk

this: this-print this-dep this-src this-bin


this-dep: 
	
## src
this-src: spok-src


### bin

GORELEASER_BIN_NAME=goreleaser
GORELEASER_BIN_WHICH=$(shell command -v $(GORELEASER_BIN_NAME))
this-bin-dep:
	rm -rf $(BIN_ROOT)
	mkdir -p $(BIN_ROOT)
	@echo $(BIN_ROOT_NAME) >> .gitignore

ifeq ($(GORELEASER_BIN_WHICH), )
	@echo ""
	@echo "$(GORELEASER_BIN_NAME) dep check: failed"
	# https://github.com/goreleaser/goreleaser/releases/tag/v2.3.2
	go install github.com/goreleaser/goreleaser/v2@v2.3.2
else
	@echo ""
	@echo "$(GORELEASER_BIN_NAME) dep check: passed"
	@echo ""
endif

## bin
this-bin: this-bin-dep spok-bin

GH_BIN_NAME=gh
GH_BIN_WHICH=$(shell command -v $(GH_BIN_NAME))

GH_RUN_RELEASE_TAG=$(shell git rev-parse --short HEAD)
GH_RUN_RELEASE_TAG_LONG=$(shell git rev-parse HEAD)

this-release-print:
	@echo ""
	@echo "-- release"
	@echo "GH_RUN_RELEASE_TAG: $(GH_RUN_RELEASE_TAG)"
	@echo ""
this-release-dep:
ifeq ($(GH_BIN_WHICH), )
	@echo ""
	@echo "$(GH_BIN_NAME) dep check: failed"
	# https://github.com/cli/cli/releases/tag/v2.59.0
	go install github.com/cli/cli/v2/cmd/gh@v2.59.0
else
	@echo ""
	@echo "$(GH_BIN_NAME) dep check: passed"
	@echo ""
endif
	
this-release-del: this-release-dep
	#gh release delete -h
	$(GH_BIN_NAME) release delete $(GH_RUN_RELEASE_TAG) --yes

this-release-ls: this-release-dep
	$(GH_BIN_NAME) release list
## release
this-release: this-release-dep
	#gh release create -h
	$(GH_BIN_NAME) release create $(GH_RUN_RELEASE_TAG) --generate-notes
	#$(GH_BIN_NAME) release create $(GH_RUN_RELEASE_TAG) $(PWD)/.bin/spok
	
	#gh release upload -h
	$(GH_BIN_NAME) release upload $(GH_RUN_RELEASE_TAG) $(PWD)/.bin/spok --clobber

	@echo ""
	@echo "https://github.com/gedw99/build-mono/releases/tag/$(GH_RUN_RELEASE_TAG)"
	@echo ""



	

	
