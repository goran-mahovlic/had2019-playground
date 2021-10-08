# Project config
PROJ = bootloader

# Target config
BOARD ?= ulx3s-v20
#BOARD ?= ulx3s-v314
#BOARD ?= ulx3s-v317
DEVICE = 12k
PACKAGE = CABGA381
SPEEDGRADE = 6

# address in FLASH where user bitstream starts
# should match FLASHCHIP_INTERNAL dfu_zones[] in fw/usb_dfu.c
# and be larger than bootloader bitstream
USER_BITSTREAM_ADDR := 0x200000

PROJ_DEPS := usb misc

PROJ_RTL_SRCS := $(addprefix rtl/, \
	picorv32.v \
	qspi_master_wb.v \
	qspi_phy_ecp5.v \
	soc_bram.v \
	soc_bridge.v \
	soc_had_misc.v \
	sysmgr.v \
	esp32_passthru.v \
	i2c_bridge.v \
)
PROJ_SIM_SRCS := $(addprefix sim/, \
	spiflash.v \
)
PROJ_SIM_SRCS += rtl/top-ulx3s.v
PROJ_TESTBENCHES := \
	dfu_helper_tb \
	top_tb
PROJ_PREREQ = \
	$(BUILD_TMP)/boot.hex
PROJ_TOP_SRC := rtl/top-ulx3s.v
PROJ_TOP_MOD := top


#NEXTPNR_ARGS = --pre-pack data/clocks.py

# Include default rules
include ../../build/project-rules.mk

# Custom rules
fw/fw_dfu.hex: fw
	#cp fw/fw_dfu.hex-0x180000 fw/fw_dfu.hex
	cp fw/fw_dfu.hex-0x200000 fw/fw_dfu.hex
	#echo make -C fw fw_dfu.hex

$(BUILD_TMP)/boot.hex:
	$(ECPBRAM) -g $@ -s 2019 -w 32 -d 8192

$(BUILD_TMP)/$(PROJ).bit $(BUILD_TMP)/$(PROJ).svf: fw/fw_dfu.hex $(BUILD_TMP)/$(PROJ).config $(BUILD_TMP)/boot.hex fw/fw_dfu.hex
	$(ECPBRAM) -v -f $(BUILD_TMP)/boot.hex -t fw/fw_dfu.hex -i $(BUILD_TMP)/$(PROJ).config -o $(BUILD_TMP)/$(PROJ)-sw.config
	$(ECPPACK) \
		--spimode $(FLASH_MODE) --freq $(FLASH_FREQ) \
		--bootaddr $(USER_BITSTREAM_ADDR) \
		--compress \
		--input $(BUILD_TMP)/$(PROJ)-sw.config \
		--svf $(BUILD_TMP)/$(PROJ).svf --svf-rowsize 100000 \
		--bit $(BUILD_TMP)/$(PROJ).bit


$(BUILD_TMP)/multiboot.img: $(BUILD_TMP)/$(PROJ).bit
	ecpmulti                           --input $(BUILD_TMP)/$(PROJ).bit \
	  --address $(USER_BITSTREAM_ADDR) --input $(BUILD_TMP)/$(PROJ).bit \
	  --flashsize 128 \
	  --output $@

# to apply non-serdes bootloader bitstream to serdes 85F chip
# --input-idcode  0x81113043 \
# --output-idcode 0x81113043 \

# make multiboot image
multi: $(BUILD_TMP)/multiboot.img

# flash multiboot image with fujprog
flash: $(BUILD_TMP)/multiboot.img
	fujprog -j flash $<

# flash multiboot image with openFPGALoader
flash_ofl: $(BUILD_TMP)/multiboot.img
	openFPGALoader -b ulx3s --file-type bin -f $<

# DFU write (upgrade) bootloader bitstream and start it
# hold BTN1 and BTN2 and plug USB
dfu_bootloader: $(BUILD_TMP)/multiboot.img
	dd if=$< of=/tmp/multibot.img bs=2M count=1
	$(DFU_UTIL) -d 1d50:614a,1d50:614b -a 5 -D /tmp/multibot.img
	$(DFU_UTIL) -d 1d50:614a,1d50:614b -a 5 -e
	rm /tmp/multibot.img

# DFU write user bitstream and start it
# hold BTN1 and plug USB
dfu_user: $(BUILD_TMP)/blink.bit
	$(DFU_UTIL) -d 1d50:614a,1d50:614b -a 0 -R -D $<

# Always try to rebuild the hex file
.PHONY: fw
