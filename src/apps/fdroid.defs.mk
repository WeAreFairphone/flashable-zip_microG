export REPO_URL     := https://f-droid.org/repo/
export DOWNLOAD_URL := $(REPO_URL)/$(PACKAGE_ID)_$(VERSION_CODE).apk


.PHONY: build

all: $(PACKAGE_NAME).apk
$(PACKAGE_NAME).apk: $(PACKAGE_ID)_$(VERSION_CODE).apk
	@cp $< $@

$(PACKAGE_ID)_$(VERSION_CODE).apk:
	@curl $(DOWNLOAD_URL) -o $@
