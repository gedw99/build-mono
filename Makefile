include help.mk

BASE_SHELL_OS_NAME := $(shell uname -s | tr A-Z a-z)
BASE_SHELL_OS_ARCH := $(shell uname -m | tr A-Z a-z)

# os
BASE_OS_NAME := $(shell go env GOOS)
BASE_OS_ARCH := $(shell go env GOARCH)

# ci
BASE_CI_GITHUB=$(GITHUB_ACTIONS)

# git
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
	@echo "BASE_OS_NAME:           $(BASE_OS_NAME)"
	@echo "BASE_OS_ARCH:           $(BASE_OS_ARCH)"
	@echo ""
	@echo "BASE_CI_GITHUB:         $(BASE_CI_GITHUB)"
	@echo ""
	@echo "BASE_GITROOT:           $(BASE_GITROOT)"
	@echo ""
	@echo "BASE_BIN_SUFFIX_NATIVE: $(BASE_BIN_SUFFIX_NATIVE)"
	@echo ""
	@echo "BASE_BIN_ROOT:          $(BASE_BIN_ROOT)"
	@echo ""

include spok.mk

this: this-print this-dep this-src this-bin


WHICH_BIN_NAME=go-which
WHICH_BIN_TEMP_NAME=which
ifeq ($(BASE_OS_NAME),windows)
ifeq ($(BASE_CI_GITHUB), )
	WHICH_BIN_NAME=go-which.exe
	WHICH_BIN_TEMP_NAME=which.exe
endif
endif
WHICH_BIN_WHICH=$(shell command -v $(WHICH_BIN_NAME))
this-dep-print:
	@echo ""
	@echo "-- dep"
	@echo ""
	@echo "GH_BIN_WHICH: $(GH_BIN_WHICH)"
this-dep-del:
	rm -rf $(WHICH_BIN_WHICH)
this-dep:
	# MUST do this FIRST thing, because the other things need it.
ifeq ($(WHICH_BIN_WHICH), )
	@echo ""
	@echo "$(WHICH_BIN_NAME) dep check: failed"
	# https://github.com/hairyhenderson/go-which/releases/tag/v0.2.0
	go install github.com/hairyhenderson/go-which/cmd/which@v0.2.0
	mv $(GOPATH)/bin/$(WHICH_BIN_TEMP_NAME) $(GOPATH)/bin/$(WHICH_BIN_NAME)
else
	@echo ""
	@echo "$(WHICH_BIN_NAME) dep check: passed"
	@echo ""
endif

	#$(WHICH_BIN_NAME) -h 
	#$(WHICH_BIN_NAME) -a which

	# Later: https://github.com/scottlepp/go-duck
	# Use which, and i realise it wil give me the equivalent of PATH searching cross platform.


	
## src

this-src-print: this-src-dep
	@echo ""
	@echo "--src "
	@echo ""
this-src-dep:
	@echo ""
	@echo "--src-dep "
	@echo "no deps needed. git is assumed. "
	@echo ""
## src
this-src: this-src-print this-src-dep spok-src


### bin

this-bin-print: this-bin-dep
	@echo ""
	@echo "-- bin "
	@echo ""

this-bin-dep:
	@echo ""
	@echo "-- bin-dep "
	@echo ""
	rm -rf $(BASE_BIN_ROOT)
	mkdir -p $(BASE_BIN_ROOT)
	@echo $(BASE_BIN_ROOT_NAME) >> .gitignore


## bin
this-bin: this-bin-print this-bin-dep spok-bin



### release 

GH_BIN_NAME=gh
ifeq ($(BASE_OS_NAME),windows)
ifeq ($(BASE_CI_GITHUB), )
	GH_BIN_NAME=gh.exe
endif
endif
GH_BIN_VERSION=v2.59.0
GH_BIN_WHICH=$(shell $(WHICH_BIN_NAME) $(GH_BIN_NAME))

# We use this for now. Later distinguish between a PR and a TAG. We still upload to same place, so its EASY !
GH_RUN_RELEASE_TAG=$(shell git rev-parse --short HEAD)

GH_RUN_RELEASE_TAG_LONG=$(shell git rev-parse HEAD)
GH_RUN_RELEASE_TAG_OTHER=$(shell git describe --tags)
GH_RUN_RELEASE_URL=$(shell git config --get remote.origin.url)/releases/tag/$(GH_RUN_RELEASE_TAG)
GH_RUN_RELEASE_URL_DOWNLOAD=
# https://github.com/gedw99/build-mono/releases/download/360a6ef/spok_bin_darwin_arm64


this-release-print: this-release-dep
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
	
this-release-dep: this-dep
	
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
this-release: this-release-print this-release-dep 
	@echo ""
	@echo "-- release"
	@echo ""
	@echo ""
	$(GH_BIN_NAME) release create $(GH_RUN_RELEASE_TAG) --generate-notes
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
BASE_DEP_BIN_WGOT_WHICH=$(shell $(WHICH_BIN_NAME) $(BASE_DEP_BIN_WGOT_NAME))

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

this-download-dep: this-dep
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

	


	
