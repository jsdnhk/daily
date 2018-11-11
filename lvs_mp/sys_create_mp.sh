#!/bin/bash
# Version 1.0

AWK=`which awk`
DF=`which df`
ECHO=`which echo`
GREP=`which grep`
TR=`which tr`
VGS=`which vgs`
LVS=`which lvs`
LS=`which ls`
ID=`which id`

########################
### Proceed if the script is run with mount point and size in GB ###
if [ $# -eq 6 ]
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
    VGNAME=$1
    LVNAME=$2
    SIZE=`$ECHO $3 | $TR -d [:alpha:]`
    NEWMP=$4
    OWNERUID=$5
    OWNERGID=$6

    MPCHECK=`$AWK '{print $2}' /etc/fstab | $GREP ^"$NEWMP"$`
    if [ ${#MPCHECK} -ne 0 ]
    then
        $ECHO -e "\nWarning! Mount Point Exists! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $DF -h
        $ECHO -e "\n------------------------\n"
        exit
    fi

    MPCHECK2=`mount | $AWK '{print $3}' | $GREP ^"$NEWMP"$`
    if [ ${#MPCHECK2} -ne 0 ]
    then
        $ECHO -e "\nWarning! Mount Point Exists! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $DF -h
        $ECHO -e "\n------------------------\n"
        exit
    fi

    VGCHECK=`$VGS | $AWK '{print $1}' | $GREP ^"$VGNAME"$`
    if [ ${#VGCHECK} -eq 0 ]
    then
        $ECHO -e "\nWarning! VG NOT Exists! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $DF -h
        $ECHO -e "\n------------------------\n"
        exit
    fi

    LVCHECK=`$LVS | $AWK '{print $1}' | $GREP ^"$LVNAME"$`
    if [ ${#LVCHECK} -ne 0 ]
    then
        $ECHO -e "\nWarning! LV Name Exists! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $DF -h
        $ECHO -e "\n------------------------\n"
        exit
    fi

    UIDCHECK=`$GREP ^$OWNERUID: /etc/passwd`
    if [ ${#UIDCHECK} -eq 0 ]
    then
        $ECHO -e "\nWarning! Mount Point Owner UID NOT Exists! Action aborted. \n"
        exit
    fi

    GIDCHECK=`$GREP ^$OWNERGID: /etc/group`
    if [ ${#GIDCHECK} -eq 0 ]
    then
        $ECHO -e "\nWarning! Mount Point Owner GID NOT Exists! Action aborted. \n"
        exit
    fi

    $ECHO -e "VG Name = [$VGNAME]"
    $ECHO -e "\nLV Name = [$LVNAME]"

### Check if there is available disk space to extend mount point ###
    VFREE=`$VGS --units g | $GREP -w "$VGNAME"| $AWK '{print $7}' | $TR -d [:alpha:]`

    $ECHO -e "\nVFree = [$VFREE G]"
    $ECHO -e "\nRequested Size = [$SIZE G]"

    COMPARE=`$ECHO "$VFREE > $SIZE" | bc`

### Disk space is NOT enough to extend mount point ###
    if [ $COMPARE -eq 0 ]
    then
        $ECHO -e "\nNot enough disk space in VG! Action aborted. \n"
        $ECHO -e "------------------------\n"
        $VGS --units g | $GREP -w "$VGNAME"
        $ECHO -e "\n------------------------\n"
        exit
    fi

### Disk space is enough to extend mount point ###
    $ECHO -e "\n### START MOUNT POINT CREATION PROCESS AT `date` ###\n"
    $ECHO -e "### OS Version is `cat /etc/redhat-release` ###\n"
    $ECHO -e "------------------------\n"

    case $REDHAT_VERSION in
      5 )
         /usr/sbin/lvcreate -L ${SIZE}G -n ${LVNAME} $VGNAME
         /sbin/mkfs.ext3 /dev/$VGNAME/$LVNAME
         /bin/mkdir -p $NEWMP
         /bin/mount /dev/$VGNAME/$LVNAME $NEWMP
         /bin/chown $OWNERUID:$OWNERGID $NEWMP
         $ECHO "/dev/$VGNAME/$LVNAME $NEWMP ext3 defaults 1 2" >> /etc/fstab
         ;;
      6 )
         /sbin/lvcreate -L ${SIZE}G -n ${LVNAME} $VGNAME
         /sbin/mkfs.ext4 /dev/$VGNAME/$LVNAME
         /bin/mkdir -p $NEWMP
         /bin/mount /dev/$VGNAME/$LVNAME $NEWMP
         /bin/chown $OWNERUID:$OWNERGID $NEWMP
         $ECHO "/dev/mapper/$VGNAME-$LVNAME $NEWMP ext4 defaults 1 2" >> /etc/fstab
         ;;
      7 )
         /usr/sbin/lvcreate -Wy --yes -L ${SIZE}G -n ${LVNAME} $VGNAME
         /usr/sbin/mkfs.xfs /dev/$VGNAME/$LVNAME
         /usr/bin/mkdir -p $NEWMP
         /usr/bin/mount /dev/$VGNAME/$LVNAME $NEWMP
         /usr/bin/chown $OWNERUID:$OWNERGID $NEWMP
         $ECHO "/dev/mapper/$VGNAME-$LVNAME $NEWMP xfs defaults 0 0" >> /etc/fstab
         ;;
      * )
         $ECHO -e "-----------------------------------------------------------------------\n"
         $ECHO -e "Error! Only Red Hat Enterprise Linux 5/6/7 are supported! Action aborted. \n"
         $ECHO -e "-----------------------------------------------------------------------\n"
         exit
         ;;
    esac

    $ECHO -e "-------------------------------------------\n"
    $ECHO -e "### Verify LV Size After Creation ###\n"
    $LVS | $GREP -w "$LVNAME"
    $ECHO -e "\n-------------------------------------------\n"
    $ECHO -e "### Verify Mount Point Size After Creation ###\n"
    $DF -Th $NEWMP
    $ECHO -e "\n-------------------------------------------\n"
    $LS -ld $NEWMP
    $ECHO -e "\n-------------------------------------------\n"
    $ECHO -e "### MOUNT POINT CREATION PROCESS COMPLETED AT `date` ###\n"

else
### Display the usage of the script if parameters are not given correctly ###
    $ECHO -e "Usage:\t$0 [VG Name] [LV Name] [Mount Point Size in GB] [Mount Point] [Mount Point Owner UID] Mount Point Owner GID]"
    $ECHO -e "\nExample:$0 vgdata Fdata 10 /home/data oracle oinstall"
    $ECHO -e "\nPlease verify the [VFree] got space enough for your request or not. "
    $ECHO -e "-----------------------------------------------------------------------\n"
    $VGS --units g
    $ECHO -e "\n-----------------------------------------------------------------------\n"
    exit
fi
