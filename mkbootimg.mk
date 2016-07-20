LOCAL_PATH := $(call my-dir)

## Build and run dtbtool
INSTALLED_DTIMAGE_TARGET := $(LOCAL_PATH)/dt.img

ifneq ($(TARGET_KERNEL_ARCH),)
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
else
KERNEL_ARCH := $(TARGET_ARCH)
endif
## Overload bootimg generation: Same as the original, + --dt arg
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_DTIMAGE_TARGET)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) \
	--second_offset $(BOARD_SECOND_OFFSET) --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) \
	  --dt $(INSTALLED_DTIMAGE_TARGET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
	   --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

## Overload recoveryimg generation: Same as the original, + --dt arg
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) \
	--second_offset $(BOARD_SECOND_OFFSET) --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) \
	  --dt $(INSTALLED_DTIMAGE_TARGET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
	   --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}

	