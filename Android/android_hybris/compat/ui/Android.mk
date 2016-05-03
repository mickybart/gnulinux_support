LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	ui_compatibility_layer.cpp

LOCAL_MODULE:= libui_compat_layer
LOCAL_MODULE_TAGS := optional

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/../include \
	frameworks/native/include

LOCAL_SHARED_LIBRARIES := \
	libcutils \
	libutils \
	libbinder \
	libhardware \
	libui

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
