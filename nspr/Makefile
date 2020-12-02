# Copyright (C) 2009 Ambroz Bizjak
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nspr
PKG_VERSION_MAJOR:=4
PKG_VERSION_MINOR:=8
PKG_VERSION:=$(PKG_VERSION_MAJOR).$(PKG_VERSION_MINOR)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v$(PKG_VERSION)/src/
PKG_MD5SUM:=e0916a72bcc6c427551ea262183fdb26

include $(INCLUDE_DIR)/package.mk

define Package/nspr
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libpthread +libsqlite3
	TITLE:=Netscape Portable Runtime
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	$(CP) ./compile.sh $(PKG_BUILD_DIR)/mozilla/nsprpub/
	(cd $(PKG_BUILD_DIR)/mozilla/nsprpub && \
		CROSS=$(GNU_TARGET_NAME)- CFLAGS="$(TARGET_CFLAGS)" ./compile.sh \
	);
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/lib*.so* $(PKG_INSTALL_DIR)/usr/lib/
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib/pkgconfig
	$(CP) ./nspr.pc $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/
	sed 's/<<VERSION>>/$(PKG_VERSION).0/g' -i $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/nspr.pc
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/nspr
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/prcpucfg.h $(PKG_INSTALL_DIR)/usr/include/nspr/
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/pr/include/*.h $(PKG_INSTALL_DIR)/usr/include/nspr/
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/lib/ds/*.h $(PKG_INSTALL_DIR)/usr/include/nspr/
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/lib/libc/include/*.h $(PKG_INSTALL_DIR)/usr/include/nspr/
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/nspr/md
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/pr/include/md/*.cfg $(PKG_INSTALL_DIR)/usr/include/nspr/md/
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/nspr/obsolete
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/pr/include/obsolete/*.h $(PKG_INSTALL_DIR)/usr/include/nspr/obsolete/
	mkdir -p $(PKG_INSTALL_DIR)/usr/include/nspr/private
	$(CP) $(PKG_BUILD_DIR)/mozilla/nsprpub/pr/include/private/*.h $(PKG_INSTALL_DIR)/usr/include/nspr/private/
endef

define Build/InstallDev
	$(CP) -r $(PKG_INSTALL_DIR)/* $(1)/
endef

define Package/nspr/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,nspr))
