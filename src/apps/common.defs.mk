export GPG_KEYSERVER := pgp.mit.edu

export PACKAGE    := $(PACKAGE_NAME).apk
export SOURCE_APK := $(PACKAGE_ID)_$(VERSION_CODE).apk
export SOURCE_SIG := $(SOURCE_APK).asc


.PHONY: all

all: $(PACKAGE)
$(PACKAGE): $(SOURCE_APK)
	@cp $< $@

$(SOURCE_APK): $(SOURCE_SIG)
	@gpg --quiet --list-key "$(REPO_GPG)" \
	  || gpg --quiet --keyserver $(GPG_KEYSERVER) --recv-keys "$(REPO_GPG)"
	@curl $(DOWNLOAD_URL) -o $@
	@gpg --verify $< $@ \
	  || rm -f $@ $<

$(SOURCE_SIG):
	@curl $(DOWNLOAD_SIG) -o $@
