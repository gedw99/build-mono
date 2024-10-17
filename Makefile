include help.mk

BASE_SHELL_OS_NAME := $(shell uname -s | tr A-Z a-z)
BASE_SHELL_OS_ARCH := $(shell uname -m | tr A-Z a-z)

# os
BASE_OS_NAME := $(shell go env GOOS)
BASE_OS_ARCH := $(shell go env GOARCH)

BASE_GITROOT=$(shell git rev-parse --show-toplevel)

# constants for bin targets
BASE_BIN_SUFFIX_DARWIN_AMD64=bin_darwin_amd64
BASE_BIN_SUFFIX_DARWIN_ARM64=bin_darwin_arm64
BASE_BIN_SUFFIX_LINUX_AMD64=bin_linux_amd64
BASE_BIN_SUFFIX_LINUX_ARM64=bin_linux_arm64
BASE_BIN_SUFFIX_WINDOWS_AMD64=bin_windows_amd64.exe
BASE_BIN_SUFFIX_WINDOWS_ARM64=bin_windows_arm64.exe
BASE_BIN_SUFFIX_WASM=bin_js_wasm

# used for naming all binaries suffix.
BASE_BIN_SUFFIX_NATIVE=bin_$(BASE_OS_NAME)_$(BASE_OS_ARCH)
ifeq ($(BASE_OS_NAME),windows)
	BASE_BIN_SUFFIX_NATIVE=bin_$(BASE_OS_NAME)_$(BASE_OS_ARCH).exe
endif

BASE_BIN_ROOT_NAME=.bin
BASE_BIN_ROOT=$(PWD)/$(BASE_BIN_ROOT_NAME)

export PATH:=$(BASE_BIN_ROOT):$(PATH)

## print
this-print:
	@echo ""
	@echo "build-mono"
	@echo ""
	@echo "BASE_OS_NAME: $(BASE_OS_NAME)"
	@echo "BASE_OS_ARCH: $(BASE_OS_ARCH)"
	@echo ""
	@echo "BASE_GITROOT: $(BASE_GITROOT)"
	@echo ""
	@echo "BASE_BIN_SUFFIX_NATIVE: $(BASE_BIN_SUFFIX_NATIVE)"
	@echo ""
	@echo "BASE_BIN_ROOT: $(BASE_BIN_ROOT)"
	@echo ""

include spok.mk

this: this-print this-dep this-src this-bin


this-dep: 
	
## src

this-src-print: this-src-dep
	@echo ""
	@echo "--src "
	@echo ""
this-src-dep:
	@echo ""
	@echo "no deps needed. git is assumed. "
	@echo ""
## src
this-src: this-src-print this-src-dep spok-src


### bin

this-bin-print: this-bin-dep
	@echo ""
	@echo "-- bin "
	@echo "GORELEASER_BIN_NAME:           $(GORELEASER_BIN_NAME)"
	@echo "GORELEASER_BIN_WHICH:          $(GORELEASER_BIN_WHICH)"
	@echo ""

GORELEASER_BIN_NAME=goreleaser
ifeq ($(BASE_OS_NAME),windows)
	GORELEASER_BIN_NAME=gh.exe
endif
GORELEASER_BIN_WHICH=$(shell command -v $(GORELEASER_BIN_NAME))
this-bin-dep:
	@echo ""
	@echo "-- bin "
	@echo ""
	rm -rf $(BASE_BIN_ROOT)
	mkdir -p $(BASE_BIN_ROOT)
	@echo $(BASE_BIN_ROOT_NAME) >> .gitignore

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
this-bin: this-bin-print this-bin-dep spok-bin


### release 

GH_BIN_NAME=gh
ifeq ($(BASE_OS_NAME),windows)
	GH_BIN_NAME=gh.exe
endif
GH_BIN_VERSION=v2.59.0
GH_BIN_WHICH=$(shell command -v $(GH_BIN_NAME))

# We use this for now. Later distinguish between a PR and a TAG. We still upload to same place, so its EASY !
GH_RUN_RELEASE_TAG=$(shell git rev-parse --short HEAD)

GH_RUN_RELEASE_TAG_LONG=$(shell git rev-parse HEAD)
GH_RUN_RELEASE_TAG_OTHER=$(shell git describe --tags)
GH_RUN_RELEASE_URL=$(shell git config --get remote.origin.url)/releases/tag/$(GH_RUN_RELEASE_TAG)
GH_RUN_RELEASE_URL_DOWNLOAD=
# https://github.com/gedw99/build-mono/releases/download/360a6ef/spok_bin_darwin_arm64


this-release-print:
	@echo ""
	@echo "-- release"
	@echo "GH_BIN_NAME:                $(GH_BIN_NAME)"
	@echo "GH_BIN_VERSION:             $(GH_BIN_VERSION)"
	@echo "GH_BIN_WHICH:               $(GH_BIN_WHICH)"
	@echo ""
	@echo "GH_RUN_RELEASE_TAG:         $(GH_RUN_RELEASE_TAG)"
	@echo "GH_RUN_RELEASE_TAG_LONG:    $(GH_RUN_RELEASE_TAG_LONG)"
	@echo "GH_RUN_RELEASE_TAG_OTHER:   $(GH_RUN_RELEASE_TAG_OTHER)"
	@echo "GH_RUN_RELEASE_URL:         $(GH_RUN_RELEASE_URL)"
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

this-release-h: this-release-dep
	gh release -h
	#gh release create -h
	#gh release upload -h
this-release-tag:
	@echo ""
	@echo "tags ?"
	git fetch --force --tags
	git tag -l
	git tag --force $(GH_RUN_RELEASE_TAG)  -m "PR Release version $(GH_RUN_RELEASE_TAG)"
	#git push --tags
	git push --force --tags
	git tag -l
## release
this-release: this-release-dep 
	@echo ""
	@echo "-- release"
	@echo ""
	@echo ""
	#$(GH_BIN_NAME) release create $(GH_RUN_RELEASE_TAG) --generate-notes
	#$(GH_BIN_NAME) release upload $(GH_RUN_RELEASE_TAG) $(PWD)/.bin/* --clobber
	$(GH_BIN_NAME) release upload $(GH_RUN_RELEASE_TAG) $(PWD)/.bin/*

	@echo ""
	@echo "here it is:"
	@echo "GH_RUN_RELEASE_URL: $(GH_RUN_RELEASE_URL)"
	@echo ""



### download

BASE_DEP_BIN_WGOT_NAME=wgot
BASE_DEP_BIN_WGOT_VERSION=v0.7.0
ifeq ($(BASE_OS_NAME),windows)
	BASE_DEP_BIN_WGOT_NAME=wgot.exe
endif
BASE_DEP_BIN_WGOT_WHICH=$(shell command -v $(BASE_DEP_BIN_WGOT_NAME))

BASE_DEP_BIN_WGOT_RUN_NAME=.bin_download
BASE_DEP_BIN_WGOT_RUN_PATH=$(PWD)/$(BASE_DEP_BIN_WGOT_RUN_NAME)

this-download-print:
	@echo ""
	@echo "- download"
	@echo "BASE_DEP_BIN_WGOT_NAME:      $(BASE_DEP_BIN_WGOT_NAME)"
	@echo "BASE_DEP_BIN_WGOT_VERSION:   $(BASE_DEP_BIN_WGOT_VERSION)"
	@echo "BASE_DEP_BIN_WGOT_WHICH:     $(BASE_DEP_BIN_WGOT_WHICH)"
	@echo ""
	@echo "BASE_DEP_BIN_WGOT_RUN_PATH:  $(BASE_DEP_BIN_WGOT_RUN_PATH)"
	@echo ""

this-download-dep:
ifeq ($(BASE_DEP_BIN_WGOT_WHICH), )
	@echo ""
	@echo " $(BASE_DEP_BIN_WGOT_NAME) check: failed"
	# https://github.com/bitrise-io/got
	#go install github.com/bitrise-io/got/cmd/got@latest
	go install github.com/bitrise-io/got/cmd/wgot@latest
else
	@echo ""
	@echo "$(BASE_DEP_BIN_WGOT_NAME) check: passed"
endif
	rm -rf $(BASE_DEP_BIN_WGOT_RUN_PATH)
	mkdir -p $(BASE_DEP_BIN_WGOT_RUN_PATH)
	@echo $(BASE_DEP_BIN_WGOT_RUN_NAME) >> .gitignore

## download
this-download: this-download-dep spok-download
	$(BASE_DEP_BIN_WGOT_NAME) -o $(BASE_DEP_BIN_WGOT_RUN_PATH)/$(SPOK_BIN_NATIVE) $(GH_RUN_RELEASE_URL)/$(SPOK_BIN_NATIVE)

	


	
