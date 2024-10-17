SPOK_BIN_NAME=spok
SPOK_BIN_NATIVE=$(SPOK_BIN_NAME)_$(BASE_BIN_SUFFIX_NATIVE)


spok-print:
	@echo ""
	@echo "--spok"
	@echo "SPOK_BIN_NAME:     $(SPOK_BIN_NAME)"
	@echo "SPOK_BIN_NATIVE:   $(SPOK_BIN_NATIVE)"
	@echo ""

spok-all: spok-print spok-src spok-bin

spok-src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

spok-bin:
	touch go.work
	go work use spok
	cd spok && goreleaser build --single-target --skip=before --snapshot --clean --output $(BASE_BIN_ROOT)/$(SPOK_BIN_NATIVE)

spok-download:
	cd $(BASE_DEP_BIN_WGOT_RUN_PATH) && $(BASE_DEP_BIN_WGOT_NAME) -o $(SPOK_BIN_NATIVE) $(GH_RUN_RELEASE_URL)/$(SPOK_BIN_NATIVE)

spok-install:
	#cp $(BASE_BIN_ROOT)/spok $(GOPATH)/bin/spok
spok-install-del:
	#rm -rf $(GOPATH)/bin/spok

spok-run:
	$(SPOK_BIN_NATIVE)
spok-run-vars:
	$(SPOK_BIN_NATIVE) --vars
spok-run-fmt:
	$(SPOK_BIN_NATIVE) --fmt