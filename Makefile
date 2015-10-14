PACKAGE_NAME=rcue
VERSION=2.4.1
MILESTONE=master
ifneq ($(MILESTONE),)
SUFFIX:=_$(MILESTONE)
endif
PACKAGE_VERSION=$(VERSION)$(SUFFIX)
PACKAGE_RPM_VERSION=$(VERSION)
# for milestones
PACKAGE_RPM_RELEASE=0.0.$(MILESTONE)
# for releases
# PACKAGE_RPM_RELEASE=1
ABI=2

PREFIX=/usr/local
DATAROOT_DIR=$(PREFIX)/share
PKG_DATA_DIR=$(DATAROOT_DIR)/$(PACKAGE_NAME)
RESOURCES_DIR=$(DATAROOT_DIR)/rcue$(ABI)/resources

.SUFFIXES:
.SUFFIXES: .in

all:	rcue.spec
	rm -fr build
	mkdir -p build/components
	cp -r dist/* build
	cp -r components/* build/components/
	mv build/components/patternfly/dist/fonts build
	mv build/components/patternfly/dist/js build
	mv build/components/patternfly/components/* build/components/
	rm -rf build/components/patternfly
	sed -i "s#../../components/patternfly/components#../components#g" \
		build/css/rcue*.css \
		$(NULL)
	sed -i "s#../../components/patternfly/dist/fonts#../fonts#g" \
		build/css/rcue*.css \
		$(NULL)

clean:
	rm -rf build

install:	all
	install -d -m 0755 "$(DESTDIR)$(RESOURCES_DIR)"
	cp -r build/* "$(DESTDIR)$(RESOURCES_DIR)"
	find "$(DESTDIR)$(RESOURCES_DIR)" -type d -exec chmod 0755 {} +
	find "$(DESTDIR)$(RESOURCES_DIR)" -type f -exec chmod 0644 {} +

.PHONY:	rcue.spec.in
dist:	rcue.spec
	TMP="$$(mktemp -d)" && mkdir "$${TMP}/$(PACKAGE_NAME)-$(PACKAGE_VERSION)" && \
		git ls-files | \
		tar --files-from /proc/self/fd/0 -c rcue.spec | \
		tar -C "$${TMP}/$(PACKAGE_NAME)-$(PACKAGE_VERSION)" -x && \
		tar -C "$${TMP}" -czf "$(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz" "$(PACKAGE_NAME)-$(PACKAGE_VERSION)"; \
		rm -fr "$${TMP}"

.in:
	sed \
		-e 's/@PACKAGE_NAME@/$(PACKAGE_NAME)/g' \
		-e 's/@PACKAGE_VERSION@/$(PACKAGE_VERSION)/g' \
		-e 's/@PACKAGE_RPM_VERSION@/$(PACKAGE_RPM_VERSION)/g' \
		-e 's/@PACKAGE_RPM_RELEASE@/$(PACKAGE_RPM_RELEASE)/g' \
		$< > $@
