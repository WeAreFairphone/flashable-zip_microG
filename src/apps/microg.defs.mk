export REPO_URL     := https://microg.org/fdroid/repo
export REPO_GPG     := 0x7F979A66F3E08422
export DOWNLOAD_URL := $(REPO_URL)/$(PACKAGE_ID)-$(VERSION_CODE).apk
export DOWNLOAD_SIG := $(DOWNLOAD_URL).asc

include ../common.defs.mk
