#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.

Lodetach ()
{
	DEVICE="${1}"
	ATTEMPT="${2:-1}"

	if [ "${ATTEMPT}" -gt 3 ]
	then
		Echo_error "Failed to detach loop device '${DEVICE}'."
		exit 1
	fi

	# Changes to block devices result in uevents which trigger rules which in
	# turn access the loop device (ex. udisks-part-id, blkid) which can cause
	# a race condition. We call 'udevadm settle' to help avoid this.
	if [ -x "$(which udevadm 2>/dev/null)" ]
	then
		${LB_ROOT_COMMAND} udevadm settle
	fi

	# Loop back devices aren't the most reliable when it comes to writes.
	# We sleep and sync for good measure - better than build failure.
	sync
	sleep 1

	${LB_ROOT_COMMAND} ${LB_LOSETUP} -d "${DEVICE}" || Lodetach "${DEVICE}" "$(expr ${ATTEMPT} + 1)"
}

Losetup ()
{
	DEVICE="${1}"
	FILE="${2}"
	PARTITION="${3:-1}"

	${LB_ROOT_COMMAND} ${LB_LOSETUP} --read-only "${DEVICE}" "${FILE}"
	FDISK_OUT="$(${LB_FDISK} -l -u ${DEVICE} 2>&1)"
	Lodetach "${DEVICE}"

	LOOPDEVICE="$(echo ${DEVICE}p${PARTITION})"

	if [ "${PARTITION}" = "0" ]
	then
		Echo_message "Mounting %s with offset 0" "${DEVICE}"

		${LB_ROOT_COMMAND} ${LB_LOSETUP} "${DEVICE}" "${FILE}"
	else
		SECTORS="$(echo "$FDISK_OUT" | sed -ne "s|^$LOOPDEVICE[ *]*\([0-9]*\).*|\1|p")"
		OFFSET="$(expr ${SECTORS} '*' 512)"

		Echo_message "Mounting %s with offset %s" "${DEVICE}" "${OFFSET}"

		${LB_ROOT_COMMAND} ${LB_LOSETUP} -o "${OFFSET}" "${DEVICE}" "${FILE}"
	fi
}

Calculate_partition_size ()
{
	ORIGINAL_SIZE="${1}"
	FILESYSTEM="${2}"

	case "${FILESYSTEM}" in
		ext2|ext3)
			PERCENT="5"
			;;
		*)
			PERCENT="3"
			;;
	esac

	echo $(expr ${ORIGINAL_SIZE} + ${ORIGINAL_SIZE} \* ${PERCENT} / 100 + 1)
}
