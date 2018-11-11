#!/bin/bash

JOB_NAME=${0##*/}
MAILLIST="linuxsupp@exch"
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

if [ `grep -c 'Red Hat Enterprise Linux Server release 6' /etc/redhat-release` -eq 1 ]
then
   REDHAT_VERSION=6
fi

########################

if [ $# -eq 3 ]
then  
   if [ $1 = vg00 ]
   then 
     echo " The VG00 own by System team !!"
     exit
   fi
   if [ `/sbin/vgs |/bin/grep -w -q "${1}";echo $?` != 0 ]
   then
     /bin/echo -e "\nWarning! No such VG! Action aborted. \n"
     /bin/echo -e "------------------------\n"
     /sbin/vgs |/bin/grep -w -v "vg00"
     /bin/echo -e "\n------------------------\n"
     exit
   fi
   if [ `/sbin/lvs |/bin/grep -w "${1}" |/bin/awk '{print $1}' |/bin/grep -w -q "F$2";echo $?` != 0 ]
   then
     /bin/echo -e "\nWarning! No such LV in VG [${1}]! Action aborted. \n"
     /bin/echo -e "Listed existing LV(s):"
     /bin/echo -e "------------------------\n"
     /sbin/lvs |/bin/grep -w -v "vg00"
     /bin/echo -e "\n------------------------\n"
     exit
   fi
   case $REDHAT_VERSION in
    4 )
	/bin/echo -e "\n### START MOUNTPOINT EXTENSION PROCESS AT `date` ###\n" |tee $LOG
       	/sbin/lvextend /dev/${1}/F${2} -L+${3}m |tee -a $LOG
       	/usr/sbin/ext2online /dev/${1}/F${2} |tee -a $LOG
        /bin/echo -e "\n===========================================" |tee -a $LOG
        /bin/echo -e " Verify extended LV and mount point " |tee -a $LOG
        /bin/echo -e "===========================================\n" |tee -a $LOG
        /bin/df -h |/bin/grep ${2} |tee -a $LOG
        /bin/echo "" |tee -a $LOG
	/bin/mailx -s "`hostname`: LV [$2] extended $3 more at `date`... by $EXECUTOR" $MAILLIST < $LOG
       ;;
    5|6 ) 
	/bin/echo -e "\n### START MOUNTPOINT EXTENSION PROCESS AT `date` ###\n" |tee $LOG
       	/sbin/lvextend /dev/${1}/F${2} -L+${3}m |tee -a $LOG
        /sbin/resize2fs /dev/${1}/F${2} | tee -a $LOG
        /bin/echo -e "\n===========================================" |tee -a $LOG
        /bin/echo -e " Verify extended LV and mount point " |tee -a $LOG
        /bin/echo -e "===========================================\n" |tee -a $LOG
        /bin/df -h |/bin/grep ${2} |tee -a $LOG
        /bin/echo "" |tee -a $LOG
	/bin/echo -e "\n$PWD/$JOB_NAME\n" |tee -a $LOG
	/bin/mailx -s "`hostname`: LV [$2] extended $3 more at `date`... by $EXECUTOR" $MAILLIST < $LOG
       ;;
    * )
       echo " Not Support Version in Linux"
       exit 
       ;;
   esac 

else 
   echo 'sys_lvextend <VG NAME> <LV NAME> <+MB SIZE>'
   /bin/echo -e "\nPlease verify the [VFree] got space enough for your request or not. "
   /bin/echo -e "-----------------------------------------------------------------------\n"
   /sbin/vgs |/bin/grep -w -v "vg00"
   /bin/echo -e "\n-----------------------------------------------------------------------\n"
   exit
fi
