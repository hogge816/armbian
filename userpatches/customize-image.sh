#!/bin/bash
set -e
BOOTDTB_DIR="${SDCARD}/boot/dtb/rockchip"
mkdir -p "$BOOTDTB_DIR"
# Build-time dtb fanout: keep h28k as source if present, otherwise use whatever exists
if [[ -f "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" ]]; then
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb"
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" "$BOOTDTB_DIR/rk3528-x88pro13.dtb"
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" "$BOOTDTB_DIR/fastyumjin.dtb"
elif [[ -f "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" ]]; then
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" || true
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" "$BOOTDTB_DIR/rk3528-x88pro13.dtb" || true
  cp -f "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" "$BOOTDTB_DIR/fastyumjin.dtb" || true
elif [[ -f "$BOOTDTB_DIR/rk3528-x88pro13.dtb" ]]; then
  cp -f "$BOOTDTB_DIR/rk3528-x88pro13.dtb" "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" || true
  cp -f "$BOOTDTB_DIR/rk3528-x88pro13.dtb" "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" || true
  cp -f "$BOOTDTB_DIR/rk3528-x88pro13.dtb" "$BOOTDTB_DIR/fastyumjin.dtb" || true
elif [[ -f "$BOOTDTB_DIR/fastyumjin.dtb" ]]; then
  cp -f "$BOOTDTB_DIR/fastyumjin.dtb" "$BOOTDTB_DIR/rk3528-hinlink-h28k.dtb" || true
  cp -f "$BOOTDTB_DIR/fastyumjin.dtb" "$BOOTDTB_DIR/rk3528-hinlink-ht2.dtb" || true
  cp -f "$BOOTDTB_DIR/fastyumjin.dtb" "$BOOTDTB_DIR/rk3528-x88pro13.dtb" || true
fi
ls -la "$BOOTDTB_DIR" | sed -n '1,120p'
