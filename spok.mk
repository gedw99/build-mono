

print:

all: src bin 


src:
	rm -rf spok
	git clone https://github.com/FollowTheProcess/spok
	@echo spok >> .gitignore

bin:
	rm -rf $(BIN_ROOT)
	touch go.work
	go work use spok
	mkdir -p $(BIN_ROOT)
	cd spok && goreleaser build --single-target --skip=before --snapshot --clean --output $(BIN_ROOT)/spok

install:
	cp $(BIN_ROOT)/spok $(GOPATH)/bin/spok
install-del:
	rm -rf $(GOPATH)/bin/spok

run:
	spok
run-vars:
	spok --vars
run-fmt:
	spok --fmt