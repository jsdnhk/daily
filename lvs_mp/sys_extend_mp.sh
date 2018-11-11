#!/bin/bash
# Version 1.0

AWK=`which awk`
DF=`which df`
ECHO=`which echo`
GREP=`which grep`
TR=`which tr`
VGS=`which vgs`
LVS=`which lvs`

########################
### Proceed if the script is run with mount point and extend size in GB ###
if [ $# -eq 2 ]
then
### Check OS Version ####
    if [ `$GREP -c 'Red Hat Enterprise Linux Server release 5' /etc/redhat-release` -eq 1 ]
    then
        REDHAT_VERSION=5
    elif [ `$GREP -c 'Red Hat Enterprise Linux Server release 6' /etc/redhat-release` -eq 1 ]
    then
        REDHAT_VERSION=6
    elif [ `$GREP -c 'Red Hat Enterprise Linux Server release 7' /etc/redhat-release` -eq 1 ]
    then
        REDHAT_VERSION=7
    else
        $ECHO -e "-----------------------------------------------------------------------\n"
        $ECHO -e "Error! Only Red Hat Enterprise Linux 5/6/7 are supported! Action aborted. \n"
        $ECHO -e "-----------------------------------------------------------------------\n"
        exit
    fi

### Check if mount point exists ###
    MP=`$AWK '{print $2}' /etc/fstab | $GREP ^"${1}"$`
    if [ ${#MP} -eq 0 ]
    then
        $ECHO -e "\nWarning! No such Mount Point! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $DF -h
        $ECHO -e "\n------------------------\n"
        exit
    fi

    $ECHO -e "------------------------\n"
    $ECHO -e "Mount Point [$MP] exists!!!\n"
    $DF -Th $1
    $ECHO -e "\n------------------------\n"

    VGNAME=`$DF -h $1 | $GREP "/dev" | $AWK -F '[/-]' '{print $4}'`
    LVNAME=`$DF -h $1 | $GREP "/dev" | $AWK '{print $1}'| $AWK -F '[/-]' '{print $5}'`
    $ECHO -e "VG Name = [$VGNAME]"
    $ECHO -e "\nLV Name = [$LVNAME]"

### Check if there is available disk space to extend mount point ###
    SIZE=`$ECHO "$2" | $TR -d [:alpha:]`
    VFREE=`$VGS --units g | $GREP -w "$VGNAME"| $AWK '{print $7}' | $TR -d [:alpha:]`

    $ECHO -e "\nVFree = [$VFREE G]"
    $ECHO -e "\nExtend Size = [$SIZE G]"

    COMPARE=`$ECHO "$VFREE > $SIZE" | bc`

    if [ $COMPARE -eq 0 ]
    then
### Disk space is NOT enough to extend mount point ###
        $ECHO -e "\nNot enough disk space in VG! Please input VM resources request form to extend VM storage first. \n"
        $ECHO -e "------------------------\n"
        $VGS --units g | $GREP -w "$VGNAME"
        $ECHO -e "\n------------------------\n"
        exit
    fi

### Disk space is enough to extend mount point ###
    $ECHO -e "\n### START MOUNT POINT EXTENSION PROCESS AT `date` ###\n"
    $ECHO -e "### OS Version is `cat /etc/redhat-release` ###\n"
    $ECHO -e "------------------------\n"
    $ECHO -e "### LV Size Before Extension ###\n"
    $LVS --units g | $GREP -w "$LVNAME"
    $ECHO -e "\n------------------------\n"
    $ECHO -e "### Mount Point Size Before Extension ###\n"
    $DF -Th $1
    $ECHO -e "\n------------------------\n"

    case $REDHAT_VERSION in
      5 )
         FSTYPE=`$DF -Th | $GREP "${1}"$ | $AWK '{print $1}'`
         $ECHO -e "FS Type = [$FSTYPE]\n"
         /usr/sbin/lvextend -L +${SIZE}G /dev/$VGNAME/$LVNAME
         /sbin/resize2fs /dev/$VGNAME/$LVNAME
         ;;
      6 ) 
         FSTYPE=`$DF -Th | $GREP "${1}"$ | $AWK '{print $1}'`
         $ECHO -e "FS Type = [$FSTYPE]\n"
         /sbin/lvextend -L +${SIZE}G /dev/$VGNAME/$LVNAME
         /sbin/resize2fs /dev/$VGNAME/$LVNAME
         ;;
      7 )
         FSTYPE=`$DF -Th | $GREP "${1}"$ | $AWK '{print $2}'`
         $ECHO -e "FS Type = [$FSTYPE]\n"
         /usr/sbin/lvextend -L +${SIZE}G /dev/$VGNAME/$LVNAME

         if [ "$FSTYPE" == "xfs" ]
         then
             /usr/sbin/xfs_growfs /dev/$VGNAME/$LVNAME
         elif [ "$FSTYPE" == "ext3" ] || [ "$FSTYPE" == "ext4" ]
         then
             /usr/sbin/resize2fs /dev/$VGNAME/$LVNAME
         else
             $ECHO -e "-----------------------------------------------------------------------\n"
             $ECHO -e "Error! Only EXT 3/4 or XFS are supported! Action aborted. \n"
             $ECHO -e "-----------------------------------------------------------------------\n"
             exit
         fi

         ;;
      * )
         $ECHO -e "-----------------------------------------------------------------------\n"
         $ECHO -e "Error! Only Red Hat Enterprise Linux 5/6/7 are supported! Action aborted. \n"
         $ECHO -e "-----------------------------------------------------------------------\n"
         exit 
         ;;
    esac 

    $ECHO -e "-------------------------------------------\n"
    $ECHO -e "### Verify LV Size After Extension ###\n"
    $LVS --units g | $GREP -w "$LVNAME"
    $ECHO -e "\n-------------------------------------------\n"
    $ECHO -e "### Verify Mount Point Size After Extension ###\n"
    $DF -Th $1
    $ECHO -e "\n-------------------------------------------\n"
    $ECHO -e "### MOUNT POINT EXTENSION PROCESS COMPLETED AT `date` ###\n"

else 
### Display the usage of the script if parameters are not given correctly ###
    $ECHO -e "Usage:\t$0 [Mount Point] [Extend Size in GB]"
    $ECHO -e "\nExample:$0 /data 3G"
    $ECHO -e "\nPlease verify the [VFree] got space enough for your request or not. "
    $ECHO -e "-----------------------------------------------------------------------\n"
    $VGS --units g
    $ECHO -e "\n-----------------------------------------------------------------------\n"
    exit
fi
