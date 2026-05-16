# Rockchip RK3566 based board - WXY OEC Turbo 4G
BOARD_NAME="WXY OEC Turbo 4G"
BOARD_VENDOR="rockchip"
BOOT_SOC="rk3566"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="hogge816"
INTRODUCED="2026"
BOOTCONFIG="rk3566_defconfig"
KERNEL_TARGET="current,edge"
FULL_DESKTOP="no"
BOOT_LOGO="no"
BOOT_FDT_FILE="rockchip/rk3566-wxy-oec-turbo-4g.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
SERIALCON="ttyS2"
# Use U-Boot with RK3566 board support
BOOTSOURCE='https://github.com/rockchip-linux/u-boot.git'
BOOTBRANCH='branch:next-dev'
BOOTPATCHDIR='legacy/u-boot-rockchip-rk3566'

# Skip problematic wireless drivers
KERNEL_DRIVERS_SKIP="rtw88 rtw88_8822be rtw88_8822ce rtw88_8822bu rtw88_8822cu"
