#
# Copyright (C) 2016 Michael Serpieri <mickybart@pygoscelis.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# -----------------------------------------------------------------
# env
HYBRIS_TARGET_ROOT_OUT := $(PRODUCT_OUT)/hybris-root
HYBRIS_BUSYBOX := $(PRODUCT_OUT)/utilities/busybox 
HYBRIS_RAMDISK_SRC := hybris/ramdisk/initramfs

ifeq ($(BOARD_HYBRIS_RAMDISK_INIT_PROFILE),)
  $(error No BOARD_HYBRIS_RAMDISK_INIT_PROFILE defined. You need to provide a custom file! See hybris/ramdisk/init.profile example)
endif

ifeq ($(BOARD_HYBRIS_RAMDISK_EXTRA_FILES),)
#Can be defined into BoardConfig.mk to add extra files into ramdisk
BOARD_HYBRIS_RAMDISK_EXTRA_FILES := 
endif

# -----------------------------------------------------------------
# the ramdisk
INTERNAL_RAMDISK_FILES := $(filter $(TARGET_ROOT_OUT)/%, \
        $(ALL_PREBUILT) \
        $(ALL_COPIED_HEADERS) \
        $(ALL_GENERATED_SOURCES) \
        $(ALL_DEFAULT_INSTALLED_MODULES)) \
	$(HYBRIS_BUSYBOX) \
	$(BOARD_HYBRIS_RAMDISK_INIT_PROFILE)

BUILT_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk.img

# We just build this directly to the install location.
INSTALLED_RAMDISK_TARGET := $(BUILT_RAMDISK_TARGET)

$(INSTALLED_RAMDISK_TARGET): $(MKBOOTFS) $(INTERNAL_RAMDISK_FILES) | $(MINIGZIP)
	$(call pretty,"Target hybris ram disk: $@")
	$(hide) rm -rf $(HYBRIS_TARGET_ROOT_OUT)
	$(hide) mkdir -p $(HYBRIS_TARGET_ROOT_OUT)
	$(hide) cp -a $(HYBRIS_RAMDISK_SRC)/* $(HYBRIS_TARGET_ROOT_OUT)/
	$(hide) cp -a $(HYBRIS_BUSYBOX) $(HYBRIS_TARGET_ROOT_OUT)/bin/
	$(hide) cp -a $(BOARD_HYBRIS_RAMDISK_INIT_PROFILE) $(HYBRIS_TARGET_ROOT_OUT)/init.profile
	$(hide) $(foreach item,$(BOARD_HYBRIS_RAMDISK_EXTRA_FILES), \
          [ "$(item)" != "" ] && cp -af $(item) $(HYBRIS_TARGET_ROOT_OUT)/;)
	$(hide) $(MKBOOTFS) $(HYBRIS_TARGET_ROOT_OUT) | $(MINIGZIP) > $@

