# HinLink HT2 / Rockchip RK3528A.
#
# This target inherits the RK3528 boot implementation that is known to boot
# the audit host, then pins the complete pre-Linux FIT to the audited copy.
# The Linux-stage DTB remains the HT2/RK3528A Fastyumjin DTS.
source "${SRC}/config/boards/rockchip-rk3528-fastyumjin.csc"

BOARD_NAME="HinLink HT2"
BOARD_VENDOR="hinlink"
BOARD_MAINTAINER="hoochiwetech"
INTRODUCED="2024"
KERNEL_TARGET="current"
FULL_DESKTOP="no"
BOOT_LOGO="no"
BOOT_FDT_FILE="rockchip/rk3528-fastyumjin.dtb"
SERIALCON="ttyS0:1500000"

# The shared RK3528 default points at a generic v1.07 USB loader. HT2 uses
# the v1.09 4-bit PCB loader verified against the audited eMMC DDR blob.
HT2_ROCKUSB_BLOB="rk3528_spl_loader_v1.09.105.bin"
HT2_ROCKUSB_BLOB_SHA256="d69a569e7474d9d5d8942bafc881c3158dd161fdce45447857ae860cd239067f"

function post_family_config__ht2_use_v109_rockusb() {
	declare -g ROCKUSB_BLOB="board-local/${HT2_ROCKUSB_BLOB}"
	declare -g ROCKUSB_BLOB_PATH="${SRC}/config/boards/hinlink-ht2/${HT2_ROCKUSB_BLOB}"
	declare -g ROCKUSB_BLOB_SHA256="${HT2_ROCKUSB_BLOB_SHA256}"
}

# These values are the reference chain read from the running HT2 eMMC.
HT2_KNOWN_GOOD_IDBLOADER_SHA256="ee4ea8d45f9ae9c70dc9ea0c8d3f3acc93063f9d078902940c811ce670672af3"
HT2_KNOWN_GOOD_FIT_SHA256="135b99eb7f1072984c9f028d13db536e1e4e41104bf81f6f50080313c087769c"
HT2_KNOWN_GOOD_FIT_SIZE="1322808"
HT2_KNOWN_GOOD_UBOOT_FDT_SHA256="db83a0738a78c82a0c5e5913509555359900fe2075497362dabc7ad2e4a3decc"

# Replace the newly generated FIT only after the inherited Fastyumjin hooks
# have completed. This preserves the audited DDR/ATF/U-Boot combination while
# allowing the Linux kernel and root filesystem to move to 6.18.
function post_uboot_custom_postprocess__ht2_preserve_audited_fit() {
	local idbloader="${SRC}/config/boards/hinlink-ht2/idbloader.img"
	local fit="${SRC}/config/boards/hinlink-ht2/u-boot-h28k.itb"
	local idbloader_sha256 fit_sha256 fit_size fit_fdt fit_fdt_sha256
	local fit_totalsize_hex fit_data_offset_hex fit_data_size_hex fit_data_base
	local fit_header_size fit_data_offset fit_data_size

	[[ -s "${idbloader}" ]] ||
		exit_with_error "Missing audited HT2 idbloader: ${idbloader}"
	[[ -s "${fit}" ]] ||
		exit_with_error "Missing audited HT2 U-Boot FIT: ${fit}"

	idbloader_sha256="$(sha256sum "${idbloader}" | cut -d' ' -f1)"
	fit_sha256="$(sha256sum "${fit}" | cut -d' ' -f1)"
	fit_size="$(stat -c '%s' "${fit}")"
	[[ "${idbloader_sha256}" == "${HT2_KNOWN_GOOD_IDBLOADER_SHA256}" ]] ||
		exit_with_error "Audited HT2 idbloader checksum mismatch: ${idbloader_sha256}"
	[[ "${fit_sha256}" == "${HT2_KNOWN_GOOD_FIT_SHA256}" ]] ||
		exit_with_error "Audited HT2 FIT checksum mismatch: ${fit_sha256}"
	[[ "${fit_size}" == "${HT2_KNOWN_GOOD_FIT_SIZE}" ]] ||
		exit_with_error "Audited HT2 FIT size mismatch: ${fit_size}"

	if ! dumpimage -l "${fit}" | grep -q 'Description:  rk3528-hinlink-h28k'; then
		exit_with_error "Audited HT2 FIT has an unexpected configuration description"
	fi

	fit_totalsize_hex="$(od -An -tx1 -N4 -j4 "${fit}" | tr -d '[:space:]')"
	fit_data_offset_hex="$(fdtget -t x "${fit}" /images/fdt data-offset)"
	fit_data_size_hex="$(fdtget -t x "${fit}" /images/fdt data-size)"
	fit_header_size=$((16#${fit_totalsize_hex}))
	fit_data_offset=$((16#${fit_data_offset_hex}))
	fit_data_size=$((16#${fit_data_size_hex}))
	fit_data_base=$(( ((fit_header_size + 2047) / 2048) * 2048 ))
	fit_fdt="$(mktemp)"
	run_host_command_logged dd if="${fit}" of="${fit_fdt}" bs=1 skip=$((fit_data_base + fit_data_offset)) count="${fit_data_size}" iflag=fullblock status=none
	fit_fdt_sha256="$(sha256sum "${fit_fdt}" | cut -d' ' -f1)"
	rm -f "${fit_fdt}"
	[[ "${fit_fdt_sha256}" == "${HT2_KNOWN_GOOD_UBOOT_FDT_SHA256}" ]] ||
		exit_with_error "Audited HT2 U-Boot FDT checksum mismatch: ${fit_fdt_sha256}"

	display_alert "${BOARD}" "Installing audited RK3528 FIT (${fit_sha256})" "info"
	run_host_command_logged cp -f "${idbloader}" idbloader.img
	run_host_command_logged cp -f "${fit}" u-boot.itb
}
