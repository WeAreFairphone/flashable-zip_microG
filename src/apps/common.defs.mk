export GPG_KEYSERVER := pgp.mit.edu

.PHONY: all

all: $(PACKAGE_NAME).apk
$(PACKAGE_NAME).apk: $(PACKAGE_ID)_$(VERSION_CODE).apk
	@cp $< $@

$(PACKAGE_ID)_$(VERSION_CODE).apk: $(PACKAGE_ID)_$(VERSION_CODE).apk.asc
	@curl $(DOWNLOAD_URL) -o $@
	@gpg --quiet --list-key "$(REPO_GPG)" \
	  || gpg --quiet --keyserver $(GPG_KEYSERVER) --recv-keys "$(REPO_GPG)"
	@gpg --verify $< $@ || rm -f $@ $<

$(PACKAGE_ID)_$(VERSION_CODE).apk.asc:
	@curl $(DOWNLOAD_SIG) -o $@
