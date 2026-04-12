# Rockchip RK3528 based board - Hinlink HT2 + x88pro13 combo
BOARD_NAME="RK3528 Fastyumjin"
BOARD_VENDOR="rockchip"
BOOT_SOC="rk3528"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="hogge816"
INTRODUCED="2026"
BOOTCONFIG="hinlink_rk3528_defconfig"
KERNEL_TARGET="current,edge"
FULL_DESKTOP="no"
BOOT_LOGO="no"
BOOT_FDT_FILE="rockchip/rk3528-fastyumjin.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
SERIALCON="ttyS2"
# Use Radxa U-Boot which has hinlink board support
BOOTSOURCE='https://github.com/radxa/u-boot.git'
BOOTBRANCH='branch:next-dev-v2024.10'
BOOTPATCHDIR='legacy/u-boot-radxa-rk35xx'
