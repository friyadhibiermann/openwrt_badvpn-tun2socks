# Copyright (C) 2009 Ambroz Bizjak
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nss
PKG_VERSION_MAJOR:=3
PKG_VERSION_MINOR:=12
PKG_VERSION_PATCH:=4
PKG_VERSION:=$(PKG_VERSION_MAJOR).$(PKG_VERSION_MINOR).$(PKG_VERSION_PATCH)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_12_4_RTM/src/
PKG_MD5SUM:=1ee3ed9c1900079319bd1de51388d856

include $(INCLUDE_DIR)/package.mk

define Package/nss
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+nspr +libsqlite3 +zlib
	TITLE:=Network Security Services
endef

define Package/nss-utils
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+nss
	TITLE:=Network Security Services utilities
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	rm -rf $(PKG_BUILD_DIR)/mozilla/security/nss/cmd/shlibsign
	(cd $(PKG_BUILD_DIR)/mozilla/security && \
		gcc -o nsinstall coreconf/nsinstall/nsinstall.c coreconf/nsinstall/pathsub.c && \
		export BUILD_OPT=1 && \
		export NSS_USE_SYSTEM_SQLITE=1 && \
		export NSDISTMODE=copy && \
		export FREEBL_NO_DEPEND=1 && \
		export NSS_ENABLE_ECC=1 && \
		case $(ARCH) in *64*) export USE_64=1; esac && \
		make OS_TARGET=Linux OS_RELEASE=2.6 OS_TEST="$(ARCH)" CC="$(TARGET_CC) $(TARGET_CFLAGS) -L$(STAGING_DIR)/usr/lib -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/nspr" -C dbm && \
		make OS_TARGET=Linux OS_RELEASE=2.6 OS_TEST="$(ARCH)" CC="$(TARGET_CC) $(TARGET_CFLAGS) -L$(STAGING_DIR)/usr/lib -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/nspr" -C nss \
	);
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib
	$(CP) -r $(PKG_BUILD_DIR)/mozilla/dist/*/lib/*.so $(PKG_INSTALL_DIR)/usr/lib/
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib/pkgconfig
	$(CP) ./nss.pc $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/
	sed 's/<<VERSION>>/$(PKG_VERSION)/g' -i $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/nss.pc
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/nss
	$(CP) $(PKG_BUILD_DIR)/mozilla/dist/private/nss/*.h $(PKG_INSTALL_DIR)/usr/include/nss/
	$(CP) $(PKG_BUILD_DIR)/mozilla/dist/public/nss/*.h $(PKG_INSTALL_DIR)/usr/include/nss/
	mkdir -p $(PKG_INSTALL_DIR)/usr/bin
	for bin in $(PKG_BUILD_DIR)/mozilla/dist/*/bin/*; do \
		name=`basename "$$$$bin"`; \
		$(CP) "$$$$bin" $(PKG_INSTALL_DIR)/usr/bin/nss"$$$$name"; \
	done
endef

define Build/InstallDev
	mkdir -p $(1)/usr/
	$(CP) -r $(PKG_INSTALL_DIR)/usr/lib $(1)/usr/
	$(CP) -r $(PKG_INSTALL_DIR)/usr/include $(1)/usr/
endef

define Package/nss/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so $(1)/usr/lib/
endef

define Package/nss-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nss))
$(eval $(call BuildPackage,nss-utils))
