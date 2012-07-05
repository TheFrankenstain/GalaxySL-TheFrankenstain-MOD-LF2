#!/sbin/sh

########################################
#   SAMSUNG Fascinate EXT4 Formatter   #
########################################

# Copyright (C) 2011 Evan Borden (navenedrob)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.

########################################
#    LOCATION OF STANDARD COMMANDS     #
########################################

cmd_grep="/sbin/busybox grep"
cmd_touch="/sbin/busybox touch"
cmd_chmod="/sbin/busybox chmod"
cmd_chown="/sbin/busybox chown"
cmd_mkdir="/sbin/busybox mkdir"
cmd_rm="/sbin/busybox rm"
cmd_mount="/sbin/busybox mount"
cmd_umount="/sbin/busybox umount"
cmd_ln="/sbin/busybox ln"

########################################
#     LOCATION OF FORMAT UTILITIES     #
########################################

cmd_fsck=/tmp/e2fsck
cmd_mkfs=/tmp/mkfs.ext
cmd_tune2fs=/tmp/tune2fs

########################################
#           PARTITION SIZES            #
########################################

# /system      309MB
# /data          1GB
# /data/fota   190MB
# /dbdata      104MB # Note: /dbdata in CWMR
# /cache        30MB
# /preinstall  127MB

########################################
#      PARTITION BLOCK LOCATIONS       #
########################################

system_part=/dev/block/stl9
dbdata_part=/dev/block/stl10
cache_part=/dev/block/stl11
data_part=/dev/block/mmcblk0p3

########################################
#            EXT4 COMMANDS             #
########################################

# SYSTEM
system_fsck_cmd="$cmd_fsck -fy $system_part"
system_mkfs_cmd="$cmd_mkfs -O ^extent,^flex_bg,^uninit_bg,^has_journal,^large_file -L SYSTEM -b 4096 -m 0 -E stride=128,stripe-width=128 -F $system_part"
system_tune2fs_cmd="$cmd_tune2fs -c 100 -i 100d -m 0 -o journal_data_writeback $system_part"
system_fsck2_cmd="$cmd_fsck -Dfy $system_part"
system_mount_cmd="$cmd_mount -o noatime,barrier=0,data=writeback,nobh -t ext4 $system_part /system"

# DBDATA
dbdata_fsck_cmd="$cmd_fsck -fy $dbdata_part"
dbdata_mkfs_cmd="$cmd_mkfs -O ^extent,^flex_bg,^uninit_bg,^has_journal,^large_file -L DBDATA -b 4096 -m 0 -E stride=128,stripe-width=128 -F $dbdata_part"
dbdata_tune2fs_cmd="$cmd_tune2fs -c 100 -i 100d -m 0 -o journal_data_writeback $dbdata_part"
dbdata_fsck2_cmd="$cmd_fsck -Dfy $dbdata_part"
dbdata_mount_cmd="$cmd_mount -o noatime,barrier=0,data=writeback,nobh -t ext4 $dbdata_part /dbdata"

# CACHE
cache_fsck_cmd="$cmd_fsck -fy $cache_part"
cache_mkfs_cmd="$cmd_mkfs -O ^extent,^flex_bg,^uninit_bg,^has_journal,^large_file -L CACHE -b 4096 -m 0 -E stride=128,stripe-width=128 -F $cache_part"
cache_tune2fs_cmd="$cmd_tune2fs -c 100 -i 100d -m 0 -o journal_data_writeback $cache_part"
cache_fsck2_cmd="$cmd_fsck -Dfy $cache_part"
cache_mount_cmd="$cmd_mount -o noatime,barrier=0,data=writeback,nobh -t ext4 $cache_part /cache"

# DATA
data_fsck_cmd="$cmd_fsck -fy $data_part"
data_mkfs_cmd="$cmd_mkfs -O ^extent,^flex_bg,^uninit_bg,^has_journal,^large_file -L DATA -b 4096 -m 0 -E stride=128,stripe-width=128 -F $data_part"
data_tune2fs_cmd="$cmd_tune2fs -c 100 -i 100d -m 0 -o journal_data_writeback $data_part"
data_fsck2_cmd="$cmd_fsck -Dfy $data_part"
data_mount_cmd="$cmd_mount -o noatime,barrier=0,data=writeback,nobh -t ext4 $data_part /data"

########################################
#             SETUP DEVICE             #
########################################

setup_device()
{
# Format SYSTEM
# Check if exists and is mounted, unmount if
# necessary and format, then remount and create
# If not, create then do the same process
if [ -e /system ]
then
	if ( $cmd_mount | $cmd_grep $system_part )
	then
		$cmd_umount $system_part
		$system_fsck_cmd
		$system_mkfs_cmd
		$system_tune2fs_cmd
		$system_fsck2_cmd
		$cmd_rm -rf /system
		$cmd_mkdir /system
		$cmd_chown 0.0 /system
		$cmd_chmod 0755 /system
		$system_mount_cmd
		$cmd_mkdir /system/lost+found
		$cmd_chown 0.0 /system/lost+found
		$cmd_chmod 0755 /system/lost+found
		$cmd_umount $system_part
	else
		$system_fsck_cmd
		$system_mkfs_cmd
		$system_tune2fs_cmd
		$system_fsck2_cmd
		$cmd_rm -rf /system
		$cmd_mkdir /system
		$cmd_chown 0.0 /system
		$cmd_chmod 0755 /system
		$system_mount_cmd
		$cmd_mkdir /system/lost+found
		$cmd_chown 0.0 /system/lost+found
		$cmd_chmod 0755 /system/lost+found
		$cmd_umount $system_part
	fi
elif [ ! -e /system ]
then
	$system_fsck_cmd
	$system_mkfs_cmd
	$system_tune2fs_cmd
	$system_fsck2_cmd
	$cmd_mkdir /system
	$cmd_chown 0.0 /system
	$cmd_chmod 0755 /system
	$system_mount_cmd
	$cmd_mkdir /system/lost+found
	$cmd_chown 0.0 /system/lost+found
	$cmd_chmod 0755 /system/lost+found
	$cmd_umount $system_part
fi

# Format DBDATA
if [ -e /dbdata ]
then
	if ( $cmd_mount | $cmd_grep $dbdata_part )
	then
		$cmd_umount $dbdata_part
		$dbdata_fsck_cmd
		$dbdata_mkfs_cmd
		$dbdata_tune2fs_cmd
		$dbdata_fsck2_cmd
		$cmd_rm -rf /dbdata
		$cmd_mkdir /dbdata
		$cmd_chown 1000.1000 /dbdata
		$cmd_chmod 0771 /dbdata
		$dbdata_mount_cmd
		$cmd_mkdir /dbdata/databases
		$cmd_mkdir /dbdata/db-journal
		$cmd_mkdir /dbdata/lost+found
		$cmd_chown 1000.1000 /dbdata/databases
		$cmd_chown 1000.1000 /dbdata/db-journal
		$cmd_chown 0.0 /dbdata/lost+found
		$cmd_chmod 0777 /dbdata/databases
		$cmd_chmod 0777 /dbdata/db-journal
		$cmd_chmod 0755 /dbdata/lost+found
		# Create a symlink to masquerade /dbdata/system
		$cmd_ln -s /data/system /dbdata/system
		# Create a symlink to masquerade /dbdata/registered_services
		$cmd_ln -s /data/system/registered_services /dbdata/registered_services
		$cmd_umount $dbdata_part
	else
		$dbdata_fsck_cmd
		$dbdata_mkfs_cmd
		$dbdata_tune2fs_cmd
		$dbdata_fsck2_cmd
		$cmd_rm -rf /dbdata
		$cmd_mkdir /dbdata
		$cmd_chown 1000.1000 /dbdata
		$cmd_chmod 0771 /dbdata
		$dbdata_mount_cmd
		$cmd_mkdir /dbdata/databases
		$cmd_mkdir /dbdata/db-journal
		$cmd_mkdir /dbdata/lost+found
		$cmd_chown 1000.1000 /dbdata/databases
		$cmd_chown 1000.1000 /dbdata/db-journal
		$cmd_chown 0.0 /dbdata/lost+found
		$cmd_chmod 0777 /dbdata/databases
		$cmd_chmod 0777 /dbdata/db-journal
		$cmd_chmod 0755 /dbdata/lost+found
		# Create a symlink to masquerade /dbdata/system
		$cmd_ln -s /data/system /dbdata/system
		# Create a symlink to masquerade /dbdata/registered_services
		$cmd_ln -s /data/system/registered_services /dbdata/registered_services
		$cmd_umount $dbdata_part
	fi
elif [ ! -e /dbdata ]
then
	$dbdata_fsck_cmd
	$dbdata_mkfs_cmd
	$dbdata_tune2fs_cmd
	$dbdata_fsck2_cmd
	$cmd_rm -rf /dbdata
	$cmd_mkdir /dbdata
	$cmd_chown 1000.1000 /dbdata
	$cmd_chmod 0771 /dbdata
	$dbdata_mount_cmd
	$cmd_mkdir /dbdata/databases
	$cmd_mkdir /dbdata/db-journal
	$cmd_mkdir /dbdata/lost+found
	$cmd_chown 1000.1000 /dbdata/databases
	$cmd_chown 1000.1000 /dbdata/db-journal
	$cmd_chown 0.0 /dbdata/lost+found
	$cmd_chmod 0777 /dbdata/databases
	$cmd_chmod 0777 /dbdata/db-journal
	$cmd_chmod 0755 /dbdata/lost+found
	# Create a symlink to masquerade /dbdata/system
	$cmd_ln -s /data/system /dbdata/system
	# Create a symlink to masquerade /dbdata/registered_services
	$cmd_ln -s /data/system/registered_services /dbdata/registered_services
	$cmd_umount $dbdata_part
fi

# Format CACHE
if [ -e /cache ]
then
	if ( $cmd_mount | $cmd_grep $cache_part )
	then
		$cmd_umount $cache_part
		$cache_fsck_cmd
		$cache_mkfs_cmd
		$cache_tune2fs_cmd
		$cache_fsck2_cmd
		$cmd_rm -rf /cache
		$cmd_mkdir /cache
		$cmd_chown 1000.2001 /cache
		$cmd_chmod 0770 /cache
		$cache_mount_cmd
		$cmd_mkdir /cache/lost+found
		$cmd_chown 0.0 /cache/lost+found
		$cmd_chmod 0755 /cache/lost+found
	else
		$cache_fsck_cmd
		$cache_mkfs_cmd
		$cache_tune2fs_cmd
		$cache_fsck2_cmd
		$cmd_rm -rf /cache
		$cmd_mkdir /cache
		$cmd_chown 1000.2001 /cache
		$cmd_chmod 0770 /cache
		$cache_mount_cmd
		$cmd_mkdir /cache/lost+found
		$cmd_chown 0.0 /cache/lost+found
		$cmd_chmod 0755 /cache/lost+found
	fi
elif [ ! -e /cache ]
then
	$cache_fsck_cmd
	$cache_mkfs_cmd
	$cache_tune2fs_cmd
	$cache_fsck2_cmd
	$cmd_mkdir /cache
	$cmd_chown 1000.2001 /cache
	$cmd_chmod 0770 /cache
	$cache_mount_cmd
	$cmd_mkdir /cache/lost+found
	$cmd_chown 0.0 /cache/lost+found
	$cmd_chmod 0755 /cache/lost+found
fi

# Format DATA
if [ -e /data ]
then
	if ( $cmd_mount | $cmd_grep $data_part )
	then
		# Check to see if FOTA is mounted,
		# we have to unmount it before we
		# can unmount DATA
		if ( $cmd_mount | $cmd_grep $fota_part )
		then
			$cmd_umount $fota_part
		fi
		$cmd_umount $data_part
		$data_fsck_cmd
		$data_mkfs_cmd
		$data_tune2fs_cmd
		$data_fsck2_cmd
		$cmd_rm -rf /data
		$cmd_mkdir /data
		$cmd_chown 1000.1000 /data
		$cmd_chmod 0771 /data
		$data_mount_cmd
		$cmd_mkdir /data/app
		$cmd_mkdir /data/app-private
		$cmd_mkdir /data/backup
		$cmd_mkdir /data/cache
		$cmd_mkdir /data/data
		$cmd_mkdir /data/dalvik-cache
		$cmd_mkdir /data/dontpanic
		$cmd_mkdir /data/gps
		$cmd_mkdir /data/local
		$cmd_mkdir /data/local/tmp
		$cmd_mkdir /data/log
		$cmd_mkdir /data/lost+found
		$cmd_mkdir /data/misc
		$cmd_mkdir /data/misc/bluetooth
		$cmd_mkdir /data/misc/bluetoothd
		$cmd_mkdir /data/misc/dhcp
		$cmd_mkdir /data/misc/dhcpcd 
		$cmd_mkdir /data/misc/keystore
		$cmd_mkdir /data/misc/systemkeys
		$cmd_mkdir /data/misc/vpn
		$cmd_mkdir /data/misc/vpn/profiles
		$cmd_mkdir /data/misc/wifi
		$cmd_mkdir /data/misc/wifi/sockets
		$cmd_mkdir /data/property
		$cmd_mkdir /data/secure
		$cmd_mkdir /data/system
		$cmd_mkdir /data/system/dropbox
		$cmd_mkdir /data/system/registered_services
		$cmd_mkdir /data/system/sync
		$cmd_mkdir /data/system/throttle
		$cmd_mkdir /data/system/usagestats
		$cmd_mkdir /data/wifi
		$cmd_chown 1000.1000 /data/app
		$cmd_chown 1000.1000 /data/app-private
		$cmd_chown 1000.1000 /data/backup
		$cmd_chown 1000.2001 /data/cache
		$cmd_chown 1000.1000 /data/data
		$cmd_chown 1000.1000 /data/dalvik-cache
		$cmd_chown 0.1007 /data/dontpanic
		$cmd_chown 1021.1000 /data/gps
		$cmd_chown 2000.2000 /data/local
		$cmd_chown 2000.2000 /data/local/tmp
		$cmd_chown 1000.1000 /data/log
		$cmd_chown 0.0 /data/lost+found
		$cmd_chown 1000.9998 /data/misc
		$cmd_chown 1000.1000 /data/misc/bluetooth
		$cmd_chown 1002.1002 /data/misc/bluetoothd
		$cmd_chown 1014.1014 /data/misc/dhcp
		$cmd_chown 1014.1014 /data/misc/dhcpcd
		$cmd_chown 1017.1017 /data/misc/keystore
		$cmd_chown 1000.1000 /data/misc/systemkeys
		$cmd_chown 1000.1000 /data/misc/vpn
		$cmd_chown 1000.1000 /data/misc/vpn/profiles
		$cmd_chown 1010.1010 /data/misc/wifi
		$cmd_chown 1010.1010 /data/misc/wifi/sockets
		$cmd_chown 0.0 /data/property
		$cmd_chown 1000.1000 /data/secure
		$cmd_chown 1000.1000 /data/system
		$cmd_chown 1000.1000 /data/system/dropbox
		$cmd_chown 1000.1000 /data/system/registered_services
		$cmd_chown 1000.1000 /data/system/sync
		$cmd_chown 1000.1000 /data/system/throttle
		$cmd_chown 1000.1000 /data/system/usagestats
		$cmd_chown 1010.1010 /data/wifi
		$cmd_chmod 0771 /data/app
		$cmd_chmod 0771 /data/app-private
		$cmd_chmod 0700 /data/backup
		$cmd_chmod 0770 /data/cache
		$cmd_chmod 0771 /data/data
		$cmd_chmod 0771 /data/dalvik-cache
		$cmd_chmod 0750 /data/dontpanic
		$cmd_chmod 0771 /data/gps
		$cmd_chmod 0771 /data/local
		$cmd_chmod 0771 /data/local/tmp
		$cmd_chmod 0777 /data/log
		$cmd_chmod 0755 /data/lost+found
		$cmd_chmod 1771 /data/misc
		$cmd_chmod +t /data/misc
		$cmd_chmod 0770 /data/misc/bluetooth
		$cmd_chmod 0771 /data/misc/bluetoothd
		$cmd_chmod 0777 /data/misc/dhcp
		$cmd_chmod 0771 /data/misc/dhcpcd 
		$cmd_chmod 0700 /data/misc/keystore
		$cmd_chmod 0700 /data/misc/systemkeys
		$cmd_chmod 0770 /data/misc/vpn
		$cmd_chmod 0770 /data/misc/vpn/profiles
		$cmd_chmod 0777 /data/misc/wifi
		$cmd_chmod 0777 /data/misc/wifi/sockets
		$cmd_chmod 0700 /data/property
		$cmd_chmod 0700 /data/secure
		$cmd_chmod 0771 /data/system
		$cmd_chown 0700 /data/system/dropbox
		$cmd_chown 0771 /data/system/registered_services
		$cmd_chown 0700 /data/system/sync
		$cmd_chown 0700 /data/system/throttle
		$cmd_chown 0700 /data/system/usagestats
		$cmd_chmod 0777 /data/wifi
		$cmd_umount $data_part
	else
		$data_fsck_cmd
		$data_mkfs_cmd
		$data_tune2fs_cmd
		$data_fsck2_cmd
		$cmd_rm -rf /data
		$cmd_mkdir /data
		$cmd_chown 1000.1000 /data
		$cmd_chmod 0771 /data
		$data_mount_cmd
		$cmd_mkdir /data/app
		$cmd_mkdir /data/app-private
		$cmd_mkdir /data/backup
		$cmd_mkdir /data/cache
		$cmd_mkdir /data/data
		$cmd_mkdir /data/dalvik-cache
		$cmd_mkdir /data/dontpanic
		$cmd_mkdir /data/gps
		$cmd_mkdir /data/local
		$cmd_mkdir /data/local/tmp
		$cmd_mkdir /data/log
		$cmd_mkdir /data/lost+found
		$cmd_mkdir /data/misc
		$cmd_mkdir /data/misc/bluetooth
		$cmd_mkdir /data/misc/bluetoothd
		$cmd_mkdir /data/misc/dhcp
		$cmd_mkdir /data/misc/dhcpcd 
		$cmd_mkdir /data/misc/keystore
		$cmd_mkdir /data/misc/systemkeys
		$cmd_mkdir /data/misc/vpn
		$cmd_mkdir /data/misc/vpn/profiles
		$cmd_mkdir /data/misc/wifi
		$cmd_mkdir /data/misc/wifi/sockets
		$cmd_mkdir /data/property
		$cmd_mkdir /data/secure
		$cmd_mkdir /data/system
		$cmd_mkdir /data/system/dropbox
		$cmd_mkdir /data/system/registered_services
		$cmd_mkdir /data/system/sync
		$cmd_mkdir /data/system/throttle
		$cmd_mkdir /data/system/usagestats
		$cmd_mkdir /data/wifi
		$cmd_chown 1000.1000 /data/app
		$cmd_chown 1000.1000 /data/app-private
		$cmd_chown 1000.1000 /data/backup
		$cmd_chown 1000.2001 /data/cache
		$cmd_chown 1000.1000 /data/data
		$cmd_chown 1000.1000 /data/dalvik-cache
		$cmd_chown 0.1007 /data/dontpanic
		$cmd_chown 1021.1000 /data/gps
		$cmd_chown 2000.2000 /data/local
		$cmd_chown 2000.2000 /data/local/tmp
		$cmd_chown 1000.1000 /data/log
		$cmd_chown 0.0 /data/lost+found
		$cmd_chown 1000.9998 /data/misc
		$cmd_chown 1000.1000 /data/misc/bluetooth
		$cmd_chown 1002.1002 /data/misc/bluetoothd
		$cmd_chown 1014.1014 /data/misc/dhcp
		$cmd_chown 1014.1014 /data/misc/dhcpcd
		$cmd_chown 1017.1017 /data/misc/keystore
		$cmd_chown 1000.1000 /data/misc/systemkeys
		$cmd_chown 1000.1000 /data/misc/vpn
		$cmd_chown 1000.1000 /data/misc/vpn/profiles
		$cmd_chown 1010.1010 /data/misc/wifi
		$cmd_chown 1010.1010 /data/misc/wifi/sockets
		$cmd_chown 0.0 /data/property
		$cmd_chown 1000.1000 /data/secure
		$cmd_chown 1000.1000 /data/system
		$cmd_chown 1000.1000 /data/system/dropbox
		$cmd_chown 1000.1000 /data/system/registered_services
		$cmd_chown 1000.1000 /data/system/sync
		$cmd_chown 1000.1000 /data/system/throttle
		$cmd_chown 1000.1000 /data/system/usagestats
		$cmd_chown 1010.1010 /data/wifi
		$cmd_chmod 0771 /data/app
		$cmd_chmod 0771 /data/app-private
		$cmd_chmod 0700 /data/backup
		$cmd_chmod 0770 /data/cache
		$cmd_chmod 0771 /data/data
		$cmd_chmod 0771 /data/dalvik-cache
		$cmd_chmod 0750 /data/dontpanic
		$cmd_chmod 0771 /data/gps
		$cmd_chmod 0771 /data/local
		$cmd_chmod 0771 /data/local/tmp
		$cmd_chmod 0777 /data/log
		$cmd_chmod 0755 /data/lost+found
		$cmd_chmod 1771 /data/misc
		$cmd_chmod +t /data/misc
		$cmd_chmod 0770 /data/misc/bluetooth
		$cmd_chmod 0771 /data/misc/bluetoothd
		$cmd_chmod 0777 /data/misc/dhcp
		$cmd_chmod 0771 /data/misc/dhcpcd 
		$cmd_chmod 0700 /data/misc/keystore
		$cmd_chmod 0700 /data/misc/systemkeys
		$cmd_chmod 0770 /data/misc/vpn
		$cmd_chmod 0770 /data/misc/vpn/profiles
		$cmd_chmod 0777 /data/misc/wifi
		$cmd_chmod 0777 /data/misc/wifi/sockets
		$cmd_chmod 0700 /data/property
		$cmd_chmod 0700 /data/secure
		$cmd_chmod 0771 /data/system
		$cmd_chown 0700 /data/system/dropbox
		$cmd_chown 0771 /data/system/registered_services
		$cmd_chown 0700 /data/system/sync
		$cmd_chown 0700 /data/system/throttle
		$cmd_chown 0700 /data/system/usagestats
		$cmd_chmod 0777 /data/wifi
		$cmd_umount $data_part
	fi
elif [ ! -e /data ]
then
	$data_fsck_cmd
	$data_mkfs_cmd
	$data_tune2fs_cmd
	$data_fsck2_cmd
	$cmd_mkdir /data
	$cmd_chown 1000.1000 /data
	$cmd_chmod 0771 /data
	$data_mount_cmd
	$cmd_mkdir /data/app
	$cmd_mkdir /data/app-private
	$cmd_mkdir /data/backup
	$cmd_mkdir /data/cache
	$cmd_mkdir /data/data
	$cmd_mkdir /data/dalvik-cache
	$cmd_mkdir /data/dontpanic
	$cmd_mkdir /data/gps
	$cmd_mkdir /data/local
	$cmd_mkdir /data/local/tmp
	$cmd_mkdir /data/log
	$cmd_mkdir /data/lost+found
	$cmd_mkdir /data/misc
	$cmd_mkdir /data/misc/bluetooth
	$cmd_mkdir /data/misc/bluetoothd
	$cmd_mkdir /data/misc/dhcp
	$cmd_mkdir /data/misc/dhcpcd 
	$cmd_mkdir /data/misc/keystore
	$cmd_mkdir /data/misc/systemkeys
	$cmd_mkdir /data/misc/vpn
	$cmd_mkdir /data/misc/vpn/profiles
	$cmd_mkdir /data/misc/wifi
	$cmd_mkdir /data/misc/wifi/sockets
	$cmd_mkdir /data/property
	$cmd_mkdir /data/secure
	$cmd_mkdir /data/system
	$cmd_mkdir /data/system/dropbox
	$cmd_mkdir /data/system/registered_services
	$cmd_mkdir /data/system/sync
	$cmd_mkdir /data/system/throttle
	$cmd_mkdir /data/system/usagestats
	$cmd_mkdir /data/wifi
	$cmd_chown 1000.1000 /data/app
	$cmd_chown 1000.1000 /data/app-private
	$cmd_chown 1000.1000 /data/backup
	$cmd_chown 1000.2001 /data/cache
	$cmd_chown 1000.1000 /data/data
	$cmd_chown 1000.1000 /data/dalvik-cache
	$cmd_chown 0.1007 /data/dontpanic
	$cmd_chown 1021.1000 /data/gps
	$cmd_chown 2000.2000 /data/local
	$cmd_chown 2000.2000 /data/local/tmp
	$cmd_chown 1000.1000 /data/log
	$cmd_chown 0.0 /data/lost+found
	$cmd_chown 1000.9998 /data/misc
	$cmd_chown 1000.1000 /data/misc/bluetooth
	$cmd_chown 1002.1002 /data/misc/bluetoothd
	$cmd_chown 1014.1014 /data/misc/dhcp
	$cmd_chown 1014.1014 /data/misc/dhcpcd
	$cmd_chown 1017.1017 /data/misc/keystore
	$cmd_chown 1000.1000 /data/misc/systemkeys
	$cmd_chown 1000.1000 /data/misc/vpn
	$cmd_chown 1000.1000 /data/misc/vpn/profiles
	$cmd_chown 1010.1010 /data/misc/wifi
	$cmd_chown 1010.1010 /data/misc/wifi/sockets
	$cmd_chown 0.0 /data/property
	$cmd_chown 1000.1000 /data/secure
	$cmd_chown 1000.1000 /data/system
	$cmd_chown 1000.1000 /data/system/dropbox
	$cmd_chown 1000.1000 /data/system/registered_services
	$cmd_chown 1000.1000 /data/system/sync
	$cmd_chown 1000.1000 /data/system/throttle
	$cmd_chown 1000.1000 /data/system/usagestats
	$cmd_chown 1010.1010 /data/wifi
	$cmd_chmod 0771 /data/app
	$cmd_chmod 0771 /data/app-private
	$cmd_chmod 0700 /data/backup
	$cmd_chmod 0770 /data/cache
	$cmd_chmod 0771 /data/data
	$cmd_chmod 0771 /data/dalvik-cache
	$cmd_chmod 0750 /data/dontpanic
	$cmd_chmod 0771 /data/gps
	$cmd_chmod 0771 /data/local
	$cmd_chmod 0771 /data/local/tmp
	$cmd_chmod 0777 /data/log
	$cmd_chmod 0755 /data/lost+found
	$cmd_chmod 1771 /data/misc
	$cmd_chmod +t /data/misc
	$cmd_chmod 0770 /data/misc/bluetooth
	$cmd_chmod 0771 /data/misc/bluetoothd
	$cmd_chmod 0777 /data/misc/dhcp
	$cmd_chmod 0771 /data/misc/dhcpcd 
	$cmd_chmod 0700 /data/misc/keystore
	$cmd_chmod 0700 /data/misc/systemkeys
	$cmd_chmod 0770 /data/misc/vpn
	$cmd_chmod 0770 /data/misc/vpn/profiles
	$cmd_chmod 0777 /data/misc/wifi
	$cmd_chmod 0777 /data/misc/wifi/sockets
	$cmd_chmod 0700 /data/property
	$cmd_chmod 0700 /data/secure
	$cmd_chmod 0771 /data/system
	$cmd_chown 0700 /data/system/dropbox
	$cmd_chown 0771 /data/system/registered_services
	$cmd_chown 0700 /data/system/sync
	$cmd_chown 0700 /data/system/throttle
	$cmd_chown 0700 /data/system/usagestats
	$cmd_chmod 0777 /data/wifi
	$cmd_umount $data_part
fi

} > /dev/null 2>&1

########################################
#        DISABLE VOODOO LAGFIX         #
########################################

disable_lagfix()
{
if [ -e /sdcard/Voodoo ]
then
  $cmd_rm -rf /sdcard/Voodoo
  $cmd_mkdir /sdcard/Voodoo
  $cmd_touch /sdcard/Voodoo/disable-lagfix
else
  $cmd_mkdir /sdcard/Voodoo
  $cmd_touch /sdcard/Voodoo/disable-lagfix
fi
}

########################################
#             RUN SCRIPT               #
########################################

execute_script()
{
setup_device
disable_lagfix
}

execute_script
