# Rockchip RK3528A based board - hk28A
BOARD_NAME="Fastyumjin-3528A"
BOARD_VENDOR="rockchip"
BOOT_SOC="rk3528"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="hogge816"
INTRODUCED="2026"
BOOTCONFIG="rk3528_defconfig"
KERNEL_TARGET="vendor,current,edge"
FULL_DESKTOP="no"
BOOT_LOGO="no"
BOOT_FDT_FILE="rockchip/rk3528-fastyumjin.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="ext4"
SERIALCON="ttyS0:1500000"
# Use U-Boot with RK3528 board support
BOOTSOURCE='https://github.com/rockchip-linux/u-boot.git'
BOOTBRANCH='branch:next-dev'
BOOTPATCHDIR='legacy/u-boot-rockchip-rk3528'

# Skip problematic wireless drivers
KERNEL_DRIVERS_SKIP="rtw88 rtw88_8822be rtw88_8822ce rtw88_8822bu rtw88_8822cu"

# The RK3399 Type-C/DWC3 compatibility series is not applicable to this
# RK3528 board. Skip the complete dependent series, not just its base patch.
KERNEL_PATCHES_TO_SKIP="rk3399-usbc-phy-rockchip-naneng-Add-fallback-for-old-DTs.patch rk3399-usbc-usb-dwc3-Track-the-power-state-of-usb3_generic_phy.patch rk3399-usbc-usb-dwc3-Extend-reset-quirk-support-to-include-role-.patch"

# RK3528 debug UART is UART0. Select the existing ttyS0 bootscript after the
# rockchip64 family has installed its default ttyS2 script.
function post_family_config__fastyumjin_mainline_console() {
	declare -g BOOTSCRIPT="boot-rockchip64-ttyS0.cmd:boot.cmd"
	declare -g SERIALCON="ttyS0:1500000"
	# The vendor clock/reset ABI is incompatible with the 6.18 SoC bindings.
	# Keep vendor builds on their vendor DTS; select the port only for 6.18.
	if [[ "${KERNEL_MAJOR_MINOR}" == "6.18" && "${BRANCH}" == "current" ]]; then
		declare -g BOOT_FDT_FILE="rockchip/rk3528-hinlink-ht2.dtb"
	fi
}

# The old Rockchip FIT generator reads bl31.elf from the U-Boot worktree.
# Armbian passes BL31 as a make variable, so stage it explicitly before make.
function pre_config_uboot_target__fastyumjin_stage_bl31() {
	local bl31="${RKBIN_DIR}/${BL31_BLOB}"

	[[ -s "${bl31}" ]] ||
		exit_with_error "Missing RK3528 BL31 blob: ${bl31}"
	run_host_command_logged cp -f "${bl31}" bl31.elf
	display_alert "${BOARD}" "Staged RK3528 BL31 for FIT generation: ${BL31_BLOB}" "info"
}

# The board's known-good 6.1.99 firmware uses a vendor RKNS idblock.
# Keep the new kernel/U-Boot FIT, but reuse that proven first-stage loader.
function post_uboot_custom_postprocess__fastyumjin_known_good_idbloader() {
	local idbloader="${SRC}/config/boards/rockchip-rk3528-fastyumjin/idbloader.img"
	local expected_sha256="ee4ea8d45f9ae9c70dc9ea0c8d3f3acc93063f9d078902940c811ce670672af3"
	local actual_sha256

	[[ -s "${idbloader}" ]] ||
		exit_with_error "Missing known-good RK3528 idbloader: ${idbloader}"
	actual_sha256="$(sha256sum "${idbloader}" | cut -d' ' -f1)"
	[[ "${actual_sha256}" == "${expected_sha256}" ]] ||
		exit_with_error "Known-good RK3528 idbloader checksum mismatch: ${actual_sha256}"

	display_alert "${BOARD}" "Using known-good RK3528 vendor idbloader (${actual_sha256})" "info"
	run_host_command_logged cp -f "${idbloader}" idbloader.img
}

# Keep the complete pre-Linux payload read from the working HT2 eMMC. Linux
# Image, initrd, DTB and rootfs remain independently replaceable on the image.
function post_uboot_custom_postprocess__fastyumjin_known_good_fit() {
	local fit="${SRC}/config/boards/rockchip-rk3528-fastyumjin/u-boot-h28k.itb"
	local expected_sha256="135b99eb7f1072984c9f028d13db536e1e4e41104bf81f6f50080313c087769c"
	local expected_size="1322808"
	local actual_sha256 actual_size

	[[ -s "${fit}" ]] ||
		exit_with_error "Missing known-good RK3528 U-Boot FIT: ${fit}"
	actual_sha256="$(sha256sum "${fit}" | cut -d' ' -f1)"
	actual_size="$(stat -c '%s' "${fit}")"
	[[ "${actual_sha256}" == "${expected_sha256}" ]] ||
		exit_with_error "Known-good RK3528 FIT checksum mismatch: ${actual_sha256}"
	[[ "${actual_size}" == "${expected_size}" ]] ||
		exit_with_error "Known-good RK3528 FIT size mismatch: ${actual_size}"
	dumpimage -l "${fit}" | grep -q 'Description:  rk3528-hinlink-h28k' ||
		exit_with_error "Known-good RK3528 FIT has an unexpected configuration"

	display_alert "${BOARD}" "Using complete known-good RK3528 vendor FIT (${actual_sha256})" "info"
	run_host_command_logged cp -f "${fit}" u-boot.itb
}

# Use kernel patch series for rockchip64-6.18; includes DTS, rk3528 support patches
# KERNELPATCHDIR default: archive/rockchip64-${KERNEL_MAJOR_MINOR}
