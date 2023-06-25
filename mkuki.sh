#!/bin/sh
echo ">>> Generating UKI (generic)"
efi-mkuki -c /config/cmdline -o /output/abl.efi /output/linux/arch/x86_64/boot/bzImage /output/initramfs.zstd

for ucode_arch in amd-ucode intel-ucode; do
  echo ">>> Generating UKI (${ucode_arch})"
  efi-mkuki -c /config/cmdline -o /output/abl.${ucode_arch}.efi /output/linux/arch/x86_64/boot/bzImage /boot/${ucode_arch}.img /output/initramfs.zstd
done
