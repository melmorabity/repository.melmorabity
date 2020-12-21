ADDON_ID = $(shell xmllint -xpath "string(/addon/@id)" addon.xml)
VERSION = $(shell xmllint -xpath "string(/addon/@version)" addon.xml)

ASSET_FILES = icon.png
ADDON_FILES = addon.xml $(ASSET_FILES)
ADDON_PACKAGE_FILE = $(ADDON_ID)-$(VERSION).zip

KODI_ADDON_DIR = $(HOME)/.kodi/addons
KODI_BRANCH = matrix


all: package


$(ADDON_PACKAGE_FILE): $(ADDON_FILES)
	ln -s . $(ADDON_ID)
	zip -FSr $@ $(foreach f,$^,$(ADDON_ID)/$(f))
	$(RM) $(ADDON_ID)


package: $(ADDON_PACKAGE_FILE)


install: $(ADDON_PACKAGE_FILE)
	unzip -o $< -d $(KODI_ADDON_DIR)


uninstall:
	$(RM) -r $(KODI_ADDON_DIR)/$(ADDON_ID)/


check: $(ADDON_PACKAGE_FILE)
	$(eval TEMP_DIR := $(shell mktemp -d -p /var/tmp))
	unzip -o $< -d $(TEMP_DIR)
	kodi-addon-checker --branch $(KODI_BRANCH) $(TEMP_DIR)
	$(RM) -r $(TEMP_DIR)


tag: check
	git tag $(VERSION)
	git push origin $(VERSION)


clean:
	$(RM) $(ADDON_PACKAGE_FILE)
	$(RM) $(shell find . -name "*~")


.PHONY: package install uninstall lint check tag clean
