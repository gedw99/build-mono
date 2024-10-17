

spok-print:
	@echo ""
	@echo "spok"
	@echo ""

spok-all: spok-print spok-src spok-bin

spok-src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

spok-bin:
	touch go.work
	go work use spok
	cd spok && goreleaser build --single-target --skip=before --snapshot --clean --output $(BASE_BIN_ROOT)/spok_$(BASE_BIN_SUFFIX_NATIVE)

spok-install:
	cp $(BASE_BIN_ROOT)/spok $(GOPATH)/bin/spok
spok-install-del:
	rm -rf $(GOPATH)/bin/spok

spok-run:
	spok
spok-run-vars:
	spok --vars
spok-run-fmt:
	spok --fmt