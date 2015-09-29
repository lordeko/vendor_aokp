PRODUCT_BRAND ?= aokp

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/aokp/prebuilt/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/aokp/prebuilt/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/aokp/prebuilt/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

# Common overlay
PRODUCT_PACKAGE_OVERLAYS += vendor/aokp/overlay/common

# Common dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/aokp/overlay/dictionaries

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.error.receiver.system.apps=com.google.android.feedback \
    ro.com.google.locationfeatures=1 \
    ro.setupwizard.enterprise_mode=1 \
    ro.kernel.android.checkjni=0 \
    persist.sys.root_access=3

#SELinux
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/aokp/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/aokp/prebuilt/common/bin/50-aokp.sh:system/addon.d/50-aokp.sh \
    vendor/aokp/prebuilt/common/bin/blacklist:system/addon.d/blacklist \
    vendor/aokp/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/aokp/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/etc/init.d/00start:system/etc/init.d/00start \
    vendor/aokp/prebuilt/common/etc/init.d/01sysctl:system/etc/init.d/01sysctl \
    vendor/aokp/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf \
    vendor/aokp/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/etc/init.local.rc:root/init.aokp.rc \

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/aokp/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/aokp/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Installer
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/bin/persist.sh:install/bin/persist.sh \
    vendor/aokp/prebuilt/common/etc/persist.conf:system/etc/persist.conf

PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/lib/libmicrobes_jni.so:system/lib/libmicrobes_jni.so \
    vendor/aokp/prebuilt/common/etc/resolv.conf:system/etc/resolv.conf

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

PRODUCT_COPY_FILES += \
    vendor/aokp/configs/permissions/com.aokp.android.xml:system/etc/permissions/com.aokp.android.xml

# T-Mobile theme engine
include vendor/aokp/configs/themes_common.mk

# Required AOKP packages
PRODUCT_PACKAGES += \
    BluetoothExt \
    CellBroadcastReceiver \
    Development \
    LatinIME \
    LatinImeDictionaryPack \
    libemoji \
    mGerrit \
    Microbes \
    Stk \
    SwagPapers

# Optional AOKP packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji \
    Terminal

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    CMWallpapers \
    CMFileManager \
    Eleven \
    LockClock \
    CMSettingsProvider

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/aokp/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

PRODUCT_PACKAGE_OVERLAYS += vendor/aokp/overlay/common

PRODUCT_VERSION_MAJOR = 12
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# Version information used on all builds
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_VERSION_TAGS=release-keys USER=android-build BUILD_UTC_DATE=$(shell date +"%s")

DATE = $(shell vendor/aokp/tools/getdate)
AOKP_BRANCH=mm

ifneq ($(AOKP_BUILDTYPE),)
    # AOKP_BUILD=<goo version int>/<build string>
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.goo.developerid=aokp \
        ro.goo.rom=aokp \
        ro.goo.version=$(shell echo $(AOKP_BUILDTYPE) | cut -d/ -f1)

    AOKP_VERSION=$(TARGET_PRODUCT)_$(AOKP_BRANCH)_$(shell echo $(AOKP_BUILDTYPE) | cut -d/ -f2)
else
    ifneq ($(AOKP_NIGHTLY),)
        # AOKP_NIGHTLY=true
        AOKP_VERSION=$(TARGET_PRODUCT)_$(AOKP_BRANCH)_nightly_$(DATE)
    else
        AOKP_VERSION=$(TARGET_PRODUCT)_$(AOKP_BRANCH)_unofficial_$(DATE)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.aokp.version=$(AOKP_VERSION) \
    ro.aokp.branch=$(AOKP_BRANCH) \
    ro.aokp.device=$(AOKP_DEVICE) \
    ro.aokp.releasetype=$(CM_BUILDTYPE) \
    ro.modversion=$(AOKP_VERSION) \
    ro.aokp.display.version=$(AOKP_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

ifndef CM_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  CM_PLATFORM_SDK_VERSION := 3
endif

# Camera shutter sound property
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.camera-sound=1

ifndef CM_PLATFORM_REV
  # For internal SDK revisions that are hotfixed/patched
  # Reset after each CM_PLATFORM_SDK_VERSION release
  # If you are doing a release and this is NOT 0, you are almost certainly doing it wrong
  CM_PLATFORM_REV := 0
endif

# Include CM audio files
include vendor/carbon/config/cm_audio.mk

# Audio
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)

# CyanogenMod Platform Internal
PRODUCT_PROPERTY_OVERRIDES += \
  ro.aokp.build.version.plat.rev=$(CM_PLATFORM_REV)

# common boot animation
PRODUCT_COPY_FILES += \
    vendor/aokp/prebuilt/bootanimation/bootanimation-kiernan.zip:system/media/bootanimation-alt.zip
