
GORELEASER_BIN_NAME=goreleaser
ifeq ($(BASE_OS_NAME),windows)
	GORELEASER_BIN_NAME=gh.exe
endif
GORELEASER_BIN_WHICH=$(shell command -v $(GORELEASER_BIN_NAME))

goreleaser-print: this-bin-dep
	@echo ""
	@echo "-- bin "
	@echo "GORELEASER_BIN_NAME:           $(GORELEASER_BIN_NAME)"
	@echo "GORELEASER_BIN_WHICH:          $(GORELEASER_BIN_WHICH)"
	@echo ""
goreleaser-dep-del:
	rm -f $(GORELEASER_BIN_WHICH)
goreleaser-dep:
	@echo ""
	@echo "-- bin dep "
	@echo ""
	rm -rf $(BASE_BIN_ROOT)
	mkdir -p $(BASE_BIN_ROOT)
	@echo $(BASE_BIN_ROOT_NAME) >> .gitignore

ifeq ($(GITHUB_ACTIONS), )
	@echo ""
	@echo " NOT inside github "

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
else
	@echo ""
	@echo " Inside github "
	@echo ""
endif