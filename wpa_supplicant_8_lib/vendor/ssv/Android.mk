#
# Copyright (C) 2008 The Android Open Source Project
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
LOCAL_PATH := $(call my-dir)

ifeq ($(WPA_SUPPLICANT_VERSION),VER_0_8_X)

ifneq ($(BOARD_WPA_SUPPLICANT_DRIVER),)
  CONFIG_DRIVER_$(BOARD_WPA_SUPPLICANT_DRIVER) := y
endif

WPA_SUPPL_DIR = external/wpa_supplicant_8
WPA_SRC_FILE :=

include $(WPA_SUPPL_DIR)/wpa_supplicant/android.config

WPA_SUPPL_DIR_INCLUDE = $(WPA_SUPPL_DIR)/src \
	$(WPA_SUPPL_DIR)/src/common \
	$(WPA_SUPPL_DIR)/src/drivers \
	$(WPA_SUPPL_DIR)/src/l2_packet \
	$(WPA_SUPPL_DIR)/src/utils \
	$(WPA_SUPPL_DIR)/src/wps \
	$(WPA_SUPPL_DIR)/wpa_supplicant

ifdef CONFIG_DRIVER_NL80211
WPA_SUPPL_DIR_INCLUDE += external/libnl/include
WPA_SRC_FILE += driver_cmd_nl80211.c
endif

ifdef CONFIG_DRIVER_WEXT
WPA_SRC_FILE += driver_cmd_wext.c
endif

ifeq ($(TARGET_ARCH),arm)
# To force sizeof(enum) = 4
L_CFLAGS += -mabi=aapcs-linux
endif

ifdef CONFIG_ANDROID_LOG
L_CFLAGS += -DCONFIG_ANDROID_LOG
endif

ifdef CONFIG_P2P
L_CFLAGS += -DCONFIG_P2P
endif

########################

include $(CLEAR_VARS)
LOCAL_MODULE := lib_driver_cmd_ssv
LOCAL_SHARED_LIBRARIES := libc libcutils
LOCAL_CFLAGS := $(L_CFLAGS)
#LOCAL_SRC_FILES := $(WPA_SRC_FILE)
LOCAL_C_INCLUDES := $(WPA_SUPPL_DIR_INCLUDE)
LOCAL_PROPRIETARY_MODULE := true

LOCAL_C_INCLUDES += hardware/aw/wlan/wpa_supplicant_8_lib/common
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

SCRIPT_PATH := hardware/aw/wlan/wpa_supplicant_8_lib/vendor
VENDOR_PATH := hardware/aw/wlan/wpa_supplicant_8_lib/vendor/ssv

ifdef CONFIG_DRIVER_NL80211
LOCAL_GENERATED_SOURCES := $(local-generated-sources-dir)/driver_cmd_nl80211.c
LOCAL_GENERATED_SOURCES += $(local-generated-sources-dir)/driver_cmd_nl80211.h
endif

ifdef CONFIG_DRIVER_WEXT
LOCAL_GENERATED_SOURCES += $(local-generated-sources-dir)/driver_cmd_wext.c
LOCAL_GENERATED_SOURCES += $(local-generated-sources-dir)/driver_cmd_wext.h
endif

$(LOCAL_GENERATED_SOURCES): $(SCRIPT_PATH)/auto-gen-source.sh $(VENDOR_PATH)
	@echo "Generator: $@"
	@./$< $^ ssv $@

include $(BUILD_STATIC_LIBRARY)

########################

endif