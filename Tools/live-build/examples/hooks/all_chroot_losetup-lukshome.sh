#!/bin/sh

# This hook was based and adapted from:
# http://lists.debian.org/debian-live/2009/04/msg00186.html
# ---------------------------------------------------------
#
#
# NOTE 1: this was not tested with persistent boot option,
# but it seems logic that persistent and lukshome can't
# coexist as boot options (because of snapshots and others), so lukshome
# won't be executed if any persistent option is given on boot.
#
# NOTE 2: if using an USB key, it will eventualy end up failing someday.
# You should backup the encrypted disk image file itself (luks-home.img) to
# prevent loosing your data.
#
# This hook will create 3 files:
#
# /usr/local/sbin/create-lukshome-file.sh
#	script to create an disk file image (luks-home.img) with a
#	LUKS encrypted ext2 filesystem inside to be placed in a
#	partition labeled lukshome.
#
# /usr/local/sbin/lukshome.sh
#	detects a partition with lukshome label, updates fstab and crypttab so
#	the encrypted file is mounted later in a loopback device (/dev/loopX).
#	It also changes /etc/init.d/umountfs so the encrypted home is correctly
#	umounted.
#
# /usr/share/initramfs-tools/scripts/live-bottom/13live_luks_home
#	a live-boot hook to execute lukshome.sh script
#	in initrd.
#
#
# HOWTO lukshome
# --------------
#
# First build your live system with this hook inside config/chroot_local-hooks/.
# If you have an existing live-build build directory with a previous live
# build, you might have to run
#
#	lh_clean
#	lh_clean --stage
#
# to make sure this hook is included in the live system. Then (re)build your
# live system.
#
#	lh_build
#
# After booting your (re)built live system, setup the encrypted losetup
# filesystem to be used as /home using the instructions present in the
# create-lukshome-file.sh script.
#
# Reboot and now use the "lukshome" boot option to mount the encrypted /home,
# like when using "persistent" boot option with a home-rw file in some partition.
#


# install needed packages (in case apt recommends are off)
# make sure that cryptsetup is installed
echo "I: checking for cryptsetup."
if [ ! -x /sbin/cryptsetup ]
then
	echo "I: installing cryptsetup."
	DEBIAN_FRONTEND="dialog" apt-get install --yes --force-yes -y cryptsetup
fi


echo "I: to see how to use lukshome hook run create-lukshome-file.sh as root."
echo "I: creating script /usr/local/sbin/create-lukshome-file.sh"
cat > /usr/local/sbin/create-lukshome-file.sh << 'EOF'
#!/bin/sh

# This script will create an encrypted filesystem in a file to
# be used as /home in a live system built with Debian Live Helper with
# this hook in config/chroot_local-hooks/.
#
# The lukshome boot option will do the following:
#	- search for a partition with label 'lukshome'
#	  (btw, you can't use the live system partition itself)
#	- mount the partition as /luks-home in the live system
#	- open /luks-home/luks-home.img file as a loopback device (/dev/loop)
#	- open the loopback device with cryptsetup
#	- mount the encrypted filesystem as /home
#
# This script will only create the luks-home.img file. Next are details of how
# to use this script.
#
# CAUTION! THIS CAN WIPE YOUR DATA, backup first!
# Be sure to understand what you will do, or you can end up
# wiping disks or partitions you don't want to!
#
# Login as root:
#	$ sudo -i
#
# Create a mountpoint (don't use /mnt, it will be used by this script):
#	# mkdir /media/target
#
# !!! ***  Skip the next line if you don't want to wipe a partition  *** !!!
# !!! * Just change the partition label to 'lukshome' (without quotes) * !!!
# Create an ext2 filesystem in a partition with 'lukshome' label:
#	# mkfs.ext2 -L lukshome /dev/the_partition_to_be_used
#
# Mount the partition and cd into it:
#	# mount /dev/the_partition_to_be_used /media/target
#	# cd /media/target
#
# Create the encrypted file:
#	# create-lukshome-file.sh
#
# The script is located in /usr/local/sbin/, so it's in root $PATH.
# It will copy the directories in /home/* into the file.
# Now return to $HOME to be able to umount the target partition:
#	# cd
#
# Umount the target partition:
#	# umount /media/target
#
# Reboot and use the "lukshome" boot option to mount the encrypted /home,
# like in using "persistent" boot option with a home-rw file in some partition.
#
# To use another partition label use the following boot options:
#	lukshome lukspart=partition_label
#
# If you want to use another filename instead of luks-home.img, rename (mv)
# the file and use the following boot options:
#	lukshome luksfile=filename
#
# Both boot options can be used at the same time, but always with lukshome:
#	lukshome lukspart=partition_label luksfile=filename
#
# By default, if just the lukshome boot option is used, the script will
# search for a partition labeled 'lukshome' and a file named 'luks-home.img'.
#
# Press Shift-PgUp/Shift-PgDn to scrool the instructions on the screen.


# check if root/sudo
if [ "${USER}" != "root" ]
then
	echo " ** Please run this script as root or with sudo."
	exit 1
fi

# check if /mnt is available and empty
mount | grep "/mnt" > /dev/null
MNT_IS_MOUNTED=${?}
if [ "${MNT_IS_MOUNTED}" == 0 ]
then
	echo "** ERROR: /mnt is mounted at the moment. Please umount it to use this script."
	exit 1
fi
if [ "$(ls -A /mnt)" ]
then
	echo "** ERROR: /mnt is not empty. An empty /mnt is needed to use this script."
	exit 1
fi

# check if /dev/mapper/luks-home is available
if [ -f /dev/mapper/luks-home ]
then
	echo "** ERROR: /dev/mapper/luks-home is being used at the moment. Please run «cryptsetup remove luks-home» to use this script."
	exit 1
fi


# show instructions
echo ""
echo "** Instructions to use create-lukshome-file.sh (this script):"
sed -n '2,64p' /usr/local/sbin/create-lukshome-file.sh | sed 's/^.//'
echo ""


# proceed?
echo "** Do you want to proceed with this script? (y/N)"
read CONFIRM

case "${CONFIRM}" in
	y*|Y*)
		echo ""
	;;
	*)
		exit 0
	;;
esac


# create file
echo ""
echo "** Please type the size of the file disk image."
echo "Size of the file in MB: "
read FILE_SIZE

echo ""
echo "** Creating file luks-home.img."
echo "** Filling file image with /dev/urandom output. It will take some time."
echo "(Edit this script to use /dev/random. It's known to be more secure but "
echo "it will take a *very* long time to complete."
dd if=/dev/urandom of=luks-home.img bs=1M count=${FILE_SIZE}
# To use /dev/random comment the line above and uncomment the next line
#dd if=/dev/random of=luks-home.img ibs=128 obs=128 count=$((8192*${FILE_SIZE}))
# You might have to increase kernel entropy by moving the mouse, typing keyboard,
# make the computer read the disk or use network connections.
echo "** Done."
echo ""

# losetup
FREE_LOSETUP=$(losetup -f)
echo "** Using ${FREE_LOSETUP} to open luks-home.img"
losetup ${FREE_LOSETUP} ./luks-home.img
echo "** Done."
echo ""

# cryptsetup
echo "** Running cryptsetup."
echo ""
echo "** luksFormat"
cryptsetup luksFormat ${FREE_LOSETUP}
EXIT_CODE=${?}
if [ "${EXIT_CODE}" != 0 ]
then
	echo "** ERROR: Error while trying to format disk file image."
	losetup -d ${FREE_LOSETUP}
	exit 1
fi
echo ""

echo "** luksOpen"
cryptsetup luksOpen ${FREE_LOSETUP} luks-home
EXIT_CODE=${?}
if [ "${EXIT_CODE}" != 0 ]
then
	echo "** ERROR: Error while trying to open LUKS file image."
	losetup -d ${FREE_LOSETUP}
	exit 1
fi
echo ""

# format encrypted filesystem
echo "** Now formating /dev/mapper/luks-home"
mkfs.ext2 /dev/mapper/luks-home
EXIT_CODE=${?}
if [ "${EXIT_CODE}" != 0 ]
then
	echo "** ERROR: Error while trying to format LUKS file."
	cryptsetup remove luks-home
	losetup -d ${FREE_LOSETUP}
	exit 1
fi
echo ""

# mount in /mnt
echo "** Now mounting luks-home.img in /mnt"
mount /dev/mapper/luks-home /mnt
EXIT_CODE=${?}
if [ "${EXIT_CODE}" != 0 ]
then
	echo "** ERROR: Error while trying to mount LUKS file in /mnt."
	umount /mnt
	cryptsetup remove luks-home
	losetup -d ${FREE_LOSETUP}
	exit 1
fi
echo ""

# copy files
HOME_DIR="/home/*"

echo "** Copying ${HOME_DIR}."
cp -rav ${HOME_DIR} /mnt
EXIT_CODE=${?}
if [ "${EXIT_CODE}" != 0 ]
then
	echo "** ERROR: Error while trying to copy files to /mnt."
	umount /mnt
	cryptsetup remove luks-home
	losetup -d ${FREE_LOSETUP}
	exit 1
fi
echo "** Done."
echo ""

echo "** All done."
echo "** Closing losetup, cryptsetup and mounted /mnt."
# umount and close
umount /mnt
cryptsetup remove luks-home
losetup -d ${FREE_LOSETUP}
echo "** The disk file image luks-home.img is done and ready. Move it into a partition"
echo "** with 'lukshome' as label and reboot with lukshome boot option to use it."
echo ""

EOF

chmod 0755 /usr/local/sbin/create-lukshome-file.sh



echo "I: creating script /usr/local/sbin/lukshome.sh"
cat > /usr/local/sbin/lukshome.sh << 'EOF'
#!/bin/sh

# this script is to be executed by a hook in live-boot. It searches
# for a partition with 'lukshome' label, mounts it as /luks-home, then opens an
# encrypted disk image file called luks-home.img as a loopback device, opens it
# with cryptsetup and finally mounts the present filesystem as /home.
# It also changes /etc/init.d/umountfs to umount the lukshome partition
#  (/luks-home) and clear the loopback device on shutdown.

# functions taken from live-helpers
. /usr/share/initramfs-tools/scripts/live-helpers

# set default values
LUKSPART="lukshome"
LUKSFILE="luks-home.img"

# get boot option lukshome - adapted from live-helpers
for ARGUMENT in $(cat /proc/cmdline)
do
	case "${ARGUMENT}" in
		lukshome)
			LUKSHOME=1
			;;
		luksfile=*)
			LUKSFILE="${ARGUMENT#luksfile=}"
			LUKSHOME=1
			;;
		lukspart=*)
			LUKSPART="${ARGUMENT#lukspart=}"
			LUKSHOME=1
			;;

	esac
done

CRYPTHOME=$(/sbin/blkid -L ${LUKSPART})

# if no partition found, exit
if [ -z "${CRYPTHOME}" ]
then
	echo "Could not find any partition with ${LUKSPART} label. "
	echo "Proceeding with no encrypted /home."
	exit 0
fi

# mount partition where file container is
echo "Mounting /luks-home with ${CRYPTHOME}."
mkdir -p /luks-home
mount -t $(get_fstype "${CRYPTHOME}") "${CRYPTHOME}" /luks-home

# mount losetup encrypted file
FREE_LOOP="$(/sbin/losetup -f)"
echo "Opening file /luks-home/${LUKSFILE} in ${FREE_LOOP}."

if [ -f /luks-home/"${LUKSFILE}" ]
then
	/sbin/losetup ${FREE_LOOP} /luks-home/"${LUKSFILE}"

	echo "Adding ${FREE_LOOP} home to /etc/crypttab and setting it as /home in /etc/fstab."

	# update crypttab
	echo "home	${FREE_LOOP}	none	luks,check,timeout" >> /etc/crypttab

	# update fstab
	echo "/dev/mapper/home	/home	ext2	defaults,noatime	0	0" >> /etc/fstab
else
	echo "Did not found any file named ${LUKSFILE} in ${CRYPTHOME}!"
	echo "Proceeding with no encrypted /home."
	sleep 2
	umount -r /luks-home
	exit 0
fi

# changes to /etc/init.d/umountfs to make /luks-home being umounted on shutdown
sed -i 's/[\t]do_stop/CHANGE_HERE/' /etc/init.d/umountfs
sed -i 's|CHANGE_HERE|	\
	# added by lukshome hook -  umount \/luks-home to prevent busy device on shutdown \
	LOOP_LUKSHOME=$(losetup -a \| grep luks-home \|cut -c 1-10) \
	if [ -n ${LOOP_LUKSHOME} ] \
	then \
		umount -r -d \/home \
		cryptsetup remove home \
		losetup -d ${LOOP_LUKSHOME} \
		umount -r \/luks-home \
	fi \
\
	do_stop \
|' /etc/init.d/umountfs

EOF

chmod 0755 /usr/local/sbin/lukshome.sh



# scripts/live-bottom/13live_luks_home, right after 12fstab
echo "I: creating /usr/share/initramfs-tools/scripts/live-bottom/13live_luks_home"

cat > /usr/share/initramfs-tools/scripts/live-bottom/13live_luks_home << 'EOF'
#!/bin/sh

#set -e

# initramfs-tools header

PREREQ=""

prereqs()
{
	echo "${PREREQ}"
}

case "${1}" in
	prereqs)
		prereqs
		exit 0
		;;
esac

. /scripts/live-functions

# live-boot hook to use an disk image file with encrypted filesystem as /home.

log_begin_msg "Executing losetup-lukshome"

# get boot option lukshome - adapted from live-helpers
for ARGUMENT in $(cat /proc/cmdline)
do
	case "${ARGUMENT}" in
		lukshome)
			LUKSHOME=1
			;;
		luksfile=*)
			LUKSFILE="${ARGUMENT#luksfile=}"
			LUKSHOME=1
			;;
		lukspart=*)
			LUKSPART="${ARGUMENT#lukspart=}"
			LUKSHOME=1
			;;

	esac
done

# don't use persistent* and lukshome
if [ -n "${PERSISTENT}" ] && [  -n "${LUKSHOME}" ]
then
	echo "You should not use persistent and lukshome at the same time."
	echo "Skipping lukshome. Persistent medium, if any, will be used instead."
	log_end_msg
	exit 0
fi

# if no lukshome boot option, exit
if [ -z "${LUKSHOME}" ]
then
	log_end_msg
	exit 0
fi

log_begin_msg "Executing lukshome.sh script."

mount -o bind /sys /root/sys
mount -o bind /proc /root/proc
mount -o bind /dev /root/dev

# lukshome.sh detects lukshome partition and file location, mounts it
# and opens the file and then updates fstab and crypttab to use it as /home.
chroot /root /usr/local/sbin/lukshome.sh

umount /root/sys
umount /root/proc
umount /root/dev

# delete the lukshome.sh script, not needed anymore
# rm -f /root/usr/local/sbin/lukshome.sh

log_end_msg

EOF

chmod 0755 /usr/share/initramfs-tools/scripts/live-bottom/13live_luks_home



echo "I: update-initramfs to include 13live_luks_home."
# if you already have installed the update-initramfs.sh hook, you can remove
# this.

for KERNEL in /boot/vmlinuz-*
do
	VERSION="$(basename ${KERNEL} | sed -e 's|vmlinuz-||')"

	update-initramfs -k ${VERSION} -t -u
done
