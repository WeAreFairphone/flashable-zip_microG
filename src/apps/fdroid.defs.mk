export REPO_URL     := https://f-droid.org/repo/
export REPO_GPG     := 37D2 C987 89D8 3119 4839 4E3E 41E7 044E 1DBA 2E89
export DOWNLOAD_URL := $(REPO_URL)/$(PACKAGE_ID)_$(VERSION_CODE).apk
export DOWNLOAD_SIG := $(DOWNLOAD_URL).asc


include ../common.defs.mk
