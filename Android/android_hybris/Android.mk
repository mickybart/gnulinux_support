ifeq ($(GNULINUX_SUPPORT),true)
#include $(all-subdir-makefiles)
MY_LOCAL_PATH := $(call my-dir)

include $(MY_LOCAL_PATH)/libhybris/compat/surface_flinger/Android.mk
include $(MY_LOCAL_PATH)/libhybris/compat/ui/Android.mk

endif
