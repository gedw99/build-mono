SPOK_BIN_NAME=spok
SPOK_BIN_NATIVE=$(SPOK_BIN_NAME)_$(BASE_BIN_SUFFIX_NATIVE)

SPOK_LD_VERSION=1
SPOK_LD_COMMIT=1
SPOK_LD_DATE=1

SPOK_LD=-X 'github.com/FollowTheProcess/spok/cli/cmd.version=$(SPOK_LD_VERSION)' -X 'github.com/FollowTheProcess/spok/cli/cmd.commit=$(SPOK_LD_COMMIT)' -X 'github.com/FollowTheProcess/spok/cli/cmd.buildDate=$(SPOK_LD_DATE)'


spok-print:
	@echo ""
	@echo "--spok"
	@echo "SPOK_BIN_NAME:     $(SPOK_BIN_NAME)"
	@echo "SPOK_BIN_NATIVE:   $(SPOK_BIN_NATIVE)"
	@echo "SPOK_LD:           $(SPOK_LD)"
	@echo ""

spok-all: spok-print spok-src spok-bin

spok-src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

spok-bin:
	touch go.work
	go work use spok

	cd spok && go build -ldflags="$(SPOK_LD)" -o $(BASE_BIN_ROOT)/$(SPOK_BIN_NATIVE) ./cmd/spok

spok-download:
	$(BASE_DEP_BIN_WGOT_NAME) -o $(BASE_DEP_BIN_WGOT_RUN_PATH)/$(SPOK_BIN_NATIVE) $(GH_RUN_RELEASE_URL)/$(SPOK_BIN_NATIVE)
	#cd $(BASE_DEP_BIN_WGOT_RUN_PATH) && $(BASE_DEP_BIN_WGOT_NAME) -o $(SPOK_BIN_NATIVE) $(GH_RUN_RELEASE_URL)/$(SPOK_BIN_NATIVE)

spok-install:
	#cp $(BASE_BIN_ROOT)/spok $(GOPATH)/bin/spok
spok-install-del:
	#rm -rf $(GOPATH)/bin/spok

spok-run:
	$(SPOK_BIN_NATIVE) -h

spok-run-version:
	$(SPOK_BIN_NATIVE) --version
spok-run-vars:
	$(SPOK_BIN_NATIVE) --vars
spok-run-fmt:
	$(SPOK_BIN_NATIVE) --fmt