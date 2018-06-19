INC_PACKAGES := GmsCore GmsFrameworkProxy FakeStore
# TODO: minimal flavour
INC_PACKAGES += DroidGuardHelper MozillaNlpBackend NominatimNlpBackend

PACKAGES := $(foreach PACKAGE, $(INC_PACKAGES), apps/$(PACKAGE)/$(PACKAGE).apk)


.PHONY: build

%.apk:
	@cd $(*D) && $(MAKE) $(MFLAGS) $(*F).apk

%.xml:
	@cd $(*D) && $(MAKE) $(MFLAGS) $(*F).xml


build: $(PACKAGES)
	@echo $<
