# Rockchip RK3528A based board - hk28A
BOARD_NAME="OEC Turbo 4G"
BOARD_VENDOR="rockchip"
BOOT_SOC="rk3568"
BOARDFAMILY="rockchip64"
BOARD_MAINTAINER="hogge816"
INTRODUCED="2026"
BOOTCONFIG="rk3568_defconfig"
KERNEL_TARGET="vendor,current"
FULL_DESKTOP="no"
BOOT_LOGO="no"
BOOT_FDT_FILE="rockchip/rk3568-wxy-oec-turbo-4g.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
SERIALCON="ttyS2"
# Use U-Boot with RK3568 board support
BOOTSOURCE='https://github.com/rockchip-linux/u-boot.git'
BOOTBRANCH='branch:next-dev-v2024.10'
BOOTPATCHDIR='legacy/u-boot-rockchip-rk3568'

# Skip problematic wireless drivers
KERNEL_DRIVERS_SKIP="rtw88 rtw88_8822be rtw88_8822ce rtw88_8822bu rtw88_8822cu"

# Skip kernel driver patches to avoid RTW88 compatibility issues
KERNELPATCHDIR=""
