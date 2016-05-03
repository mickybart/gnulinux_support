LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

# -----------------------------------------------------------------
# Package creation for GNU/Linux with Hybris integration
#
# Provide:
#   /system
#     + static busybox for sh
#   root (boot ramdisk)
#   headers (at least for libhybris compilation)
#   boot.img (kernel + hyrbis ramdisk)

.PHONY: hybris
hybris: hybris-device hybris-linux

hybris-device: $(DEFAULT_GOAL) $(BUILT_RAMDISK_TARGET) $(PRODUCT_OUT)/utilities/busybox
	$(call pretty,"Creating headers")
	$(hide) rm -rf $(PRODUCT_OUT)/headers
	$(hide) ./hybris/packaging/extract-headers.sh $(TOP) $(PRODUCT_OUT)/headers $(shell (echo $(PLATFORM_VERSION) | tr '.' ' '))
	$(call pretty,"Creating package: $@.tgz")
	$(hide) cp -f $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/system/xbin/busybox-static
	$(hide) rm -f $(PRODUCT_OUT)/system/xbin/sh
	$(hide) ln -s busybox-static $(PRODUCT_OUT)/system/xbin/sh
	$(hide) rm -f $(PRODUCT_OUT)/$@.tgz
	$(hide) tar -czf $(PRODUCT_OUT)/$@.tgz $(PRODUCT_OUT)/system $(PRODUCT_OUT)/headers $(PRODUCT_OUT)/root
	$(call pretty,"Package created: $@.tgz")

hybris-linux: $(INSTALLED_BOOTIMAGE_TARGET)
	$(call pretty,"Creating package: $@.tgz")
	$(hide) rm -f $(PRODUCT_OUT)/$@.tgz
	$(hide) tar -czf $(PRODUCT_OUT)/$@.tgz $(INSTALLED_BOOTIMAGE_TARGET)
	$(call pretty,"Package created: $@.tgz")



