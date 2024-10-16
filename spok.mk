

spok-print:
	@echo "spok"

spok-all: spok-src spok-bin 


spok-src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

spok-bin:
	rm -rf $(BIN_ROOT)
	touch go.work
	go work use spok
	mkdir -p $(BIN_ROOT)
	cd spok && goreleaser build --single-target --skip=before --snapshot --clean --output $(BIN_ROOT)/spok

spok-run:
	spok
spok-run-vars:
	spok --vars
spok-run-fmt:
	spok --fmt