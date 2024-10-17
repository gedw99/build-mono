

spok-print:
	@echo "spok"

spok-all: spok-src spok-bin

spok-src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

spok-bin:
	touch go.work
	go work use spok
	cd spok && goreleaser build --single-target --skip=before --snapshot --clean --output $(BIN_ROOT)/spok

spok-install:
	cp $(BIN_ROOT)/spok $(GOPATH)/bin/spok
spok-install-del:
	rm -rf $(GOPATH)/bin/spok

spok-run:
	spok
spok-run-vars:
	spok --vars
spok-run-fmt:
	spok --fmt