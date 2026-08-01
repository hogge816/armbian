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
SERIALCON="ttyS2"
# Use U-Boot with RK3528 board support
BOOTSOURCE='https://github.com/rockchip-linux/u-boot.git'
BOOTBRANCH='branch:next-dev'
BOOTPATCHDIR='legacy/u-boot-rockchip-rk3528'

# Skip problematic wireless drivers
KERNEL_DRIVERS_SKIP="rtw88 rtw88_8822be rtw88_8822ce rtw88_8822bu rtw88_8822cu"

# The RK3399 Type-C compatibility patch is already partly upstream in 6.18.31
# and does not apply to this RK3528 board.
KERNEL_PATCHES_TO_SKIP="rk3399-usbc-phy-rockchip-naneng-Add-fallback-for-old-DTs.patch"

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

# The stock RK3528 U-Boot FIT uses a board-specific pre-relocation DTB.
# Replace only the FIT FDT after Armbian has generated the new U-Boot and ATF.
function post_uboot_custom_postprocess__fastyumjin_known_good_uboot_fdt() {
	local uboot_fdt="${SRC}/config/boards/rockchip-rk3528-fastyumjin/u-boot-h28k.dtb"
	local expected_sha256="db83a0738a78c82a0c5e5913509555359900fe2075497362dabc7ad2e4a3decc"
	local actual_sha256

	[[ -s "${uboot_fdt}" ]] ||
		exit_with_error "Missing known-good RK3528 U-Boot FDT: ${uboot_fdt}"
	actual_sha256="$(sha256sum "${uboot_fdt}" | cut -d' ' -f1)"
	[[ "${actual_sha256}" == "${expected_sha256}" ]] ||
		exit_with_error "Known-good RK3528 U-Boot FDT checksum mismatch: ${actual_sha256}"
	[[ -s u-boot.its && -s u-boot-nodtb.bin ]] ||
		exit_with_error "Cannot rebuild RK3528 U-Boot FIT: missing u-boot.its or u-boot-nodtb.bin"

	display_alert "${BOARD}" "Using known-good RK3528 U-Boot FDT (${actual_sha256})" "info"
	run_host_command_logged cp -f "${uboot_fdt}" u-boot.dtb
	run_host_command_logged sed -i 's/rk3528-evb/rk3528-hinlink-h28k/g' u-boot.its
	run_host_command_logged tools/mkimage -f u-boot.its -E u-boot.itb
}

# Use kernel patch series for rockchip64-6.18; includes DTS, rk3528 support patches
# KERNELPATCHDIR default: archive/rockchip64-${KERNEL_MAJOR_MINOR}
