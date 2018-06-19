export REPO_URL     := https://microg.org/fdroid/repo
export DOWNLOAD_URL := $(REPO_URL)/$(PACKAGE_ID)-$(VERSION_CODE).apk


.PHONY: build

build: $(PACKAGE_NAME).apk
$(PACKAGE_NAME).apk: $(PACKAGE_ID)_$(VERSION_CODE).apk
	@cp $< $@

$(PACKAGE_ID)_$(VERSION_CODE).apk:
	@curl $(DOWNLOAD_URL) -o $@
