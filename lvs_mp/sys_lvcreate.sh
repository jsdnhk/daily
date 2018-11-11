#!/bin/bash 

JOB_NAME=${0##*/}
MAILLIST="linux@exch"
LOG="/tmp/${JOB_NAME}.log"
EXECUTOR=`/usr/bin/who am i |/bin/awk '{print $1}'`
# Version 1.0

#### Check Version #####
if [ `grep -c 'Red Hat Enterprise Linux AS release 4 (Nahant Update 8)' /etc/redhat-release` -eq 1 ]
then
   REDHAT_VERSION=4
fi

if [ `grep -c 'Red Hat Enterprise Linux Server release 5' /etc/redhat-release` -eq 1 ]
then
   REDHAT_VERSION=5
fi

if [ `grep -c 'Red Hat Enterprise Linux Server release 7' /etc/redhat-release` -eq 1 ]
then
   REDHAT_VERSION=7
fi

########################

if [ $# -eq 6 ];then
	VG_NAME="$1"
	LV_NAME="F${2}"
	SIZE="$3"
	MOUNTPT="$4"
	OWNER_ID="$5"
	GROUP_ID="$6"
else 
	/bin/echo -e '\nUsage: sys_lvcreate.sh <VG> <NEW LV> <MB SIZE> <MountPoint> <MountPoint OwnerID> <MountPoint GroupID> \n'
	/bin/echo "----------------------------------------------------------------------"
	/bin/echo " Please verify the [VFree] got space enough for your request or not. "
	/bin/echo -e "----------------------------------------------------------------------\n"
	/sbin/vgs |/bin/grep -w -v "vg00"
	/bin/echo -e "\n----------------------------------------------------------------------\n"
	exit
fi

if [ x"$VG_NAME" = x"vg00" ]
	then 
	/bin/echo "WARNING! Selected VG [$VG_NAME] is not available due to it is owned by System team!! Action aborted. "
	exit
fi
if [ `/sbin/vgs |/bin/grep -w -q "${VG_NAME}";echo $?` != 0 ];then
	/bin/echo -e "\nWarning! No such VG! Action aborted. \n"
	/bin/echo -e "Listed existing VGs:"
	/bin/echo -e "------------------------\n"
	/sbin/vgs |/bin/grep -w -v "vg00"
	/bin/echo -e "\n------------------------\n"
	exit
fi
if [ `cat /etc/passwd |/bin/awk -F":" '{print $1}' |/bin/grep -w -q "${OWNER_ID}"; echo $?` != 0 ];then
	/bin/echo -e "\nWarning!! Owner ID [$OWNER_ID] not exist in `hostname`! Action aborted. \n"
	exit
fi
if [ `cat /etc/group |/bin/awk -F":" '{print $1}' |/bin/grep -w -q "${GROUP_ID}"; echo $?` != 0 ];then
	/bin/echo -e "\nWarning!! Owner group ID [$GROUP_ID] not exist in `hostname`! Action aborted. \n"
	exit
fi
if [ `/sbin/lvs |/bin/awk '{print $1}' |/bin/grep -w -q "${LV_NAME}"; echo $?` = 0 ];then
     /bin/echo -e "\nWarning!! LV [$LV_NAME] already exist! Action aborted. \n"
     /bin/echo -e "Listed existing LV(s):"
     /bin/echo -e "------------------------\n"
     /sbin/lvs |/bin/grep -w -v "vg00"
     /bin/echo -e "\n------------------------\n"
     exit
fi

PARAMETER() {
      	/sbin/lvcreate $VG_NAME -n${LV_NAME} -L${SIZE}m |/usr/bin/tee -a $LOG
      	/sbin/mkfs.ext3 /dev/${VG_NAME}/${LV_NAME}
      	cp -p /etc/fstab /etc/fstab_`date +%d%m%y`
      	/bin/echo "/dev/${VG_NAME}/${LV_NAME}	$MOUNTPT	ext3	defaults	1 2" >> /etc/fstab
}

   case $REDHAT_VERSION in
    4|5|7 )
	/bin/echo -e "\n############ Create mountpoint ${MOUNTPT} in `hostname` at `date` ############/n" |/usr/bin/tee $LOG
	/bin/echo "=================================" |/usr/bin/tee -a $LOG
	/bin/echo "Action Summary: " |/usr/bin/tee -a $LOG
	/bin/echo "=================================\n" |/usr/bin/tee -a $LOG
	/bin/echo "VG name	=	${VG_NAME} " |/usr/bin/tee -a $LOG
	/bin/echo "LV name	=	${LV_NAME} " |/usr/bin/tee -a $LOG
	/bin/echo "LV size (MB)	=	${SIZE} " |/usr/bin/tee -a $LOG
	/bin/echo "Mountpt name	=	${MOUNTPT}" |/usr/bin/tee -a $LOG
	/bin/echo "Owner ID	=	${OWNER_ID}" |/usr/bin/tee -a $LOG
	/bin/echo "Group ID	=	${GROUP_ID}" |/usr/bin/tee -a $LOG
	/bin/echo "\n=================================\n" |/usr/bin/tee -a $LOG
	if [ -d ${MOUNTPT} ];then
		/bin/echo -e "\nWarning! $MOUNTPT is already existed as a directory." 
		/bin/echo -e "Continue may cause all subdirectory or files under $MOUNTPT being lost."
		/bin/echo "----------------------------------------------------------------------------------------------"
		/bin/echo -e "SUB-DIRECTORIES : \n"
		find ${MOUNTPT} -type d |/bin/grep -v "lost+found"
		/bin/echo -e "\nFILES : \n"
		find ${MOUNTPT} -type f |/bin/grep -v "lost+found"
		echo ""
		/bin/echo "-----------------------------------------------------------------------------------------------"
		/bin/echo -e "Input [Y] to continue"
		read ANS_O
		if [ x"$ANS_O" = x"Y" ];then
			PARAMETER
		else
			/bin/echo "\nAction aborted! \n"
			exit
		fi
	else
		PARAMETER
	fi
	;;
   * )
        echo " Not Support Version in Linux"
        exit 
        ;;
   esac 

/bin/echo -e "\n============================================================="
/bin/echo -e " Please input Mountpoint Ownership: (e.g inetsupp, unixupp)"
/bin/echo -e "============================================================="
read KEYIN
if [ x"$KEYIN" = x ];then
	/bin/echo -e "\nWarning!! Input nothing! Action aborted.\n"
	exit
else
	OWNERSHIP="$KEYIN"
fi
/bin/echo -e "\n============================================================"
/bin/echo -e " Please input Ownership email ID: (e.g. ir2sntrel, inetsupp)"
/bin/echo -e "============================================================"
read ANS_O
if [ x"$ANS_O" = x ];then
	/bin/echo -e "\nWarning!! Input nothing! Action aborted.\n"
	exit
else
	EMAIL="$ANS_O"
fi
echo "${MOUNTPT}:${OWNERSHIP}:${EMAIL}" >> /home/sysadm/scripts/lvreport/supp.list
/bin/echo -e "\nUpdated /home/sysadm/scripts/lvreport/supp.list at below:" |tee -a $LOG
/bin/echo -e "============================================================\n" |tee -a $LOG
tail -1 /home/sysadm/scripts/lvreport/supp.list |tee -a $LOG
/bin/echo -e "\n============================================================\n" |tee -a $LOG
/bin/mkdir -p ${MOUNTPT}
/bin/mount ${MOUNTPT}
/bin/chown ${OWNER_ID}:${GROUP_D} ${MOUNTPT} 
/bin/echo -e "\n===========================================" |tee -a $LOG
/bin/echo -e " Verify created LV and mount point " |tee -a $LOG
/bin/echo -e "===========================================\n" |tee -a $LOG
/bin/df -h ${MOUNTPT} |tee -a $LOG
ls -ld ${MOUNTPT} |tee -a $LOG
/bin/echo "" |tee -a $LOG
/bin/mailx -s "`hostname`: Mount point [$4] created at `date`... by $EXECUTOR" $MAILLIST < $LOG

