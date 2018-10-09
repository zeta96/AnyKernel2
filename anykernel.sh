# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=AnyKernel2 Flasher for modded Xiaomi Santoni by @dencel007. All Credits: osm0sis and many other committers.
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=santoni
device.name2=Xiaomi
device.name3=Redmi 4X
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chown -R root:root $ramdisk/*;
chmod -R 750 $ramdisk/init.spectrum.rc


## AnyKernel install
dump_boot;

# begin ramdisk changes

# fstab.qcom
backup_file fstab.qcom;
if [ -f /fstab.qcom ]; then
insert_line fstab.qcom "data f2fs" before "data ext4" "/dev/block/bootdevice/by-name/userdata /data   f2fs   nosuid,nodev,noatime,inline_xattr,data_flush wait,check,encryptable=footer,formattable,length=-16384";
insert_line fstab.qcom "cache f2fs" after "data ext4" "/dev/block/bootdevice/by-name/cache    /cache  f2fs   nosuid,nodev,noatime,inline_xattr,flush_merge,data_flush wait,formattable,check";
fi;

## /system/vendor/etc/fstab.qcom
# SPECIAL TREATMENT for Encrypted Data Partitions in LOS and AEX Official builds
# Thanks to @osm0sis, @mostafaz for scripts and Usman Mughal for figuring this out

mount -o remount,rw /system;
mount -o remount,rw /vendor;
backup_file /system/vendor/etc/fstab.qcom;
if [ -f /system/vendor/etc/fstab.qcom ]; then
sed -i 's/encryptable=footer/encryptable=userdata/g' /system/vendor/etc/fstab.qcom;
patch_fstab /system/vendor/etc/fstab.qcom /data f2fs options "rw,nosuid,nodev,noatime" "nosuid,nodev,noatime,data_flush";
patch_fstab /system/vendor/etc/fstab.qcom /data ext4 options "rw,nosuid,nodev,noatime,noauto_da_alloc" "nosuid,nodev,noatime,noauto_da_alloc";
patch_fstab /system/vendor/etc/fstab.qcom /cache f2fs options "nosuid,nodev,noatime,inline_xattr" "nosuid,nodev,noatime,inline_xattr,flush_merge,data_flush";
patch_fstab /system/vendor/etc/fstab.qcom /data f2fs flags "wait,formattable,check,forceencrypt=footer,quota" "wait,check,encryptable=footer,formattable,length=-16384";
patch_fstab /system/vendor/etc/fstab.qcom /data ext4 flags "wait,formattable,check,forceencrypt=footer,quota" "wait,check,encryptable=footer,formattable,length=-16384";
fi;

# insert init.spectrum.rc in init.rc
insert_line init.rc "import /init.spectrum.rc" after "import /init.trace.rc" "import /init.spectrum.rc";

# end ramdisk changes

write_boot;

## end install
