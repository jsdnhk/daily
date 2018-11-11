#!/bin/bash
USAGE () {
echo "ERROR: null input detected"
echo "script to check server status by:"
echo "detect server type by process found"	
echo "CPU and MEMROY utilization average by last few hours by server type"
echo "and 3pm-6pm peak hour in last working day (mon-fri)"
echo "and process count by assigned baseline"
echo " "
echo "`basename $0` server_name "
echo "where supported server_type are: docker tibco weblogic oracledb mongodb"
exit 8
}

if [ X${1} = X ];then
USAGE
else
SVR=$1
fi

#SERVER_TYPE=$2



# test ping server is available 
if [ `ping ${SVR} -c 2 -i 1 |grep ' 0% packet loss' |wc -l ` =  0 ];then
echo "ERROR: ${SVR} network is not stable"
echo "SERVER_PINGABLE=FALSE"
exit 16
else
echo "SERVER_PINGABLE=TRUE"
fi

#####################################################
# detect server type and capture all detected value # 
#####################################################



# check DOCKER server, first set SERVER_TYPE
CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR "which docker > /dev/null 2>&1 && /usr/bin/docker ps|grep -q 0.0.0.0 && echo DOCKER"`
SERVER_TYPE=$CHECK_SERVER_TYPE


# #######################################################################################################################################################
# check WEBLOGIC server , overwrite DOCKER result if weblogic deployment found
CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR "which docker > /dev/null 2>&1 && /usr/bin/docker ps|grep 0.0.0.0|grep -iEq 'wls|weblogic'  && echo WEBLOGIC_DOCKER"`
#CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR "ps -ef|grep oracle|grep -iEq 'wls|weblogic' && echo WEBLOGIC"`
if [ X`echo ${CHECK_SERVER_TYPE}|awk '{print $1}'` != X ];then
SERVER_TYPE=$CHECK_SERVER_TYPE
fi

#speical step to check nondocker weblogic or oracle appserver
if [ X`echo $SERVER_TYPE|awk '{print $1}'` = X ];then
	if [ `ssh -q -o "StrictHostKeyChecking no" $SVR "ps -ef|grep oracle|grep -iE 'weblogic|oc4j'|grep -v grep|wc -l" ` -gt 0 ];then
		SERVER_TYPE=ORACLE_APPSERVER
	fi
fi
# #######################################################################################################################################################

# #######################################################################################################################################################
# Below is dedicated Server type and no mixed use type assumed, put the most important or biggest impact in lower location in this session

# check Tibco App server
CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR ps -ef|grep tibco|grep -v grep|grep -qiE 'engine|hawkagent'  && echo TIBCO`
if [ X`echo ${CHECK_SERVER_TYPE}|awk '{print $1}'` != X ];then
SERVER_TYPE=$CHECK_SERVER_TYPE
fi


# check Mongo DB server
CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR ps -ef|grep -v grep|grep -q mongod && echo MONGODB`
if [ X`echo ${CHECK_SERVER_TYPE}|awk '{print $1}'` != X ];then
SERVER_TYPE=$CHECK_SERVER_TYPE
fi


# check oracle DB server, if any DB process found and will declare as DB server even other type of process found
CHECK_SERVER_TYPE=`ssh -q -o "StrictHostKeyChecking no" $SVR ps -ef|grep -v grep|grep oracle|grep -q pmon && echo ORACLEDB`
if [ X`echo ${CHECK_SERVER_TYPE}|awk '{print $1}'` != X ];then
SERVER_TYPE=$CHECK_SERVER_TYPE
fi


# End of dedicated Server type 
# #######################################################################################################################################################

# shaping server type value
if [[ X${SERVER_TYPE} = X || `echo $SERVER_TYPE |wc -w` -gt 1 ]];then
echo "INFO: Mulitple type of server process found: " ${SERVER_TYPE}
SERVER_TYPE=GENERIC
else
# take of blank space 
#SERVER_TYPE=`echo $SERVER_TYPE|awk '{print $1}'`
# set all to upper case
SERVER_TYPE=`echo $SERVER_TYPE | tr [a-z] [A-Z]`
#echo "SERVER_TYPE=$SERVER_TYPE"
fi

# end of detect server type
# #######################################################################################################################################################





###########################################
# get basic server hardware configuration #
###########################################

PHYMEM=`ssh -q -o "StrictHostKeyChecking no" ${SVR} free |grep Mem | awk '{print $2}'`
let PHYMEM_IN_GB=${PHYMEM}/1024/1024
TOTALCPU=`ssh -q -o "StrictHostKeyChecking no" ${SVR} " cat /proc/cpuinfo"|grep processor|wc -l`


#echo "SERVER Config"
#echo "============= "
echo "TOTAL_CPU=${TOTALCPU}"
echo "MEMORY_SIZE_IN_GB=${PHYMEM_IN_GB}"
echo "SERVER_TYPE=${SERVER_TYPE}"

####################
# Generic baseline #
####################
CPU_Q_LENGTH_BASELINE=8
LASTDAY_CPU_Q_LENGTH_BASELINE=10

#############################################
# set baseline for each defined Server type #
#############################################

case $SERVER_TYPE in 
DOCKER)
PROCESS_COUNT_BASELINE=30
CPU_UTIL_BASELINE=70
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=80
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME="docker-containerd.sock"
;;

TIBCO)
PROCESS_COUNT_BASELINE=300
CPU_UTIL_BASELINE=60
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=80
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME="engine|grep tibco"
;;

ORACLE_APPSERVER)
PROCESS_COUNT_BASELINE=20
CPU_UTIL_BASELINE=70
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=80
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME='weblogic.Name|grep -v AdminServer'
;;

WEBLOGIC_DOCKER)
PROCESS_COUNT_BASELINE=20
CPU_UTIL_BASELINE=60
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=80
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME='weblogic.Name|grep -v AdminServer'
;;

ORACLEDB)
PROCESS_COUNT_BASELINE=5
CPU_UTIL_BASELINE=70
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=70
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME=pmon
;;

MONGODB) 
PROCESS_COUNT_BASELINE=10
CPU_UTIL_BASELINE=60
LASTDAY_CPU_UTIL_BASELINE=60
MEM_UTIL_BASELINE=70
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME=mongod
;;

#*) USAGE ;;
*) echo "Server type is deteted as $SERVER_TYPE, will set as GENERIC server type and check non-root ID process"
PROCESS_COUNT_BASELINE=50
CPU_UTIL_BASELINE=70
LASTDAY_CPU_UTIL_BASELINE=70
MEM_UTIL_BASELINE=70
LASTDAY_MEM_UTIL_BASELINE=80
HOUR_AGO=4
PROCESS_NAME='-v root'
;;

esac 

#######################
# End of Set baseline #
#######################



tmpfile=/tmp/`basename $0`.tmp
cat /dev/null > $tmpfile

#######################################
# Set time window for collecting stat #
#######################################
CURRENT_TIME=`date +%H:00:00`
REFERENCE_TIME=`date +%H:00:00 -d "${HOUR_AGO} hours ago"`
# add reference to most closet working day peak time
PEAK_HOUR_START="15:00:00"
PEAK_HOUR_END="18:00:00"
########################################################
# Set time window for last working day peak hour 3-6pm #
########################################################
LASTDAY_REFERENCE_WEEKDAY=`date +%w -d "1 day ago "`
case ${LASTDAY_REFERENCE_WEEKDAY} in
0) LASTDAY_REFERENCE_DATE=`date +%d -d "2 day ago "`;;
1) LASTDAY_REFERENCE_DATE=`date +%d -d "3 day ago "`;;
*) LASTDAY_REFERENCE_DATE=`date +%d -d "1 day ago "`;;
esac 
#################################################################
# prevent single digit return by date command
#if [[ ${LASTDAY_REFERENCE_DATE} -lt 10 ]];then
#LASTDAY_REFERENCE_DATE="0"${LASTDAY_REFERENCE_DATE}
#fi
#################################################################

#echo "SAR file for use is /var/log/sa/sa${LASTDAY_REFERENCE_DATE}"
###############################################
# Check if last working day SAR file is exist #
###############################################
if [ `ssh -q -o "StrictHostKeyChecking no" ${SVR} "ls -l /var/log/sa/sa${LASTDAY_REFERENCE_DATE}"|wc -l ` = 0 ];then
echo "$SVR /var/log/sa/sa${LASTDAY_REFERENCE_DATE} file not found, please inform OS team to fix SAR issue, `basename $0` command abort !"
echo "previous Peak day stat will be skipped"
SKIP_LASTDAY=Y
else
SKIP_LASTDAY=N
fi



##########################################
# Check if SAR is setup in target server #
##########################################
if [ SAR_`ssh -q -o "StrictHostKeyChecking no" ${SVR} "which sar > /dev/null 2>&1 && echo COMMAND_IS_FOUND"` != SAR_COMMAND_IS_FOUND ];then
echo "SAR command not found, job abort !"
exit 8
fi

#####################
# collect statistic #
#####################
let PROCESS_COUNT=`ssh -q -o "StrictHostKeyChecking no"  ${SVR} "ps -ef|grep -v grep|grep ${PROCESS_NAME}"|wc -l`
let CPU_UTIL_IDLE=`ssh -q -o "StrictHostKeyChecking no" ${SVR} "sar -u -s ${REFERENCE_TIME}" |tail -1 |awk '{printf "%d", $8}'`
let CPU_UTIL=100-${CPU_UTIL_IDLE}
#let MEM_UTIL=`ssh -q -o  "StrictHostKeyChecking no" ${SVR} "sar -r -s ${REFERENCE_TIME} "|tail -1 |awk '{printf "%d", $4}'`
# get Memory utilization % by adding free and Cached with total installed memory as base
let MEM_UTIL=`ssh -q -o  "StrictHostKeyChecking no" ${SVR} "sar -r -s ${REFERENCE_TIME} "|tail -1 |awk '{sumfree+=$2+$6}{sum+=$2+$3} {printf "%.2d\n",100-(100*sumfree/sum)}'`
let TOTAL_APP=`ssh -q -o "StrictHostKeyChecking no" ${SVR} "ps -ef|grep -v grep|grep -w ${PROCESS_NAME}"|wc -l `
if [ $SKIP_LASTDAY != Y ];then
let LASTDAY_CPU_UTIL_IDLE=`ssh -q -o  "StrictHostKeyChecking no" ${SVR} "sar -u -f /var/log/sa/sa${LASTDAY_REFERENCE_DATE} -s ${PEAK_HOUR_START} -e ${PEAK_HOUR_END} "|tail -1 |awk '{printf "%d", $8}'`
let LASTDAY_CPU_UTIL=100-${LASTDAY_CPU_UTIL_IDLE}
let LASTDAY_MEM_UTIL=`ssh -q -o "StrictHostKeyChecking no" ${SVR} " sar -r -f /var/log/sa/sa${LASTDAY_REFERENCE_DATE} -s ${PEAK_HOUR_START} -e ${PEAK_HOUR_END} "|tail -1 |awk '{sumfree+=$2+$6}{sum+=$2+$3} {printf "%.2d\n",100-(100*sumfree/sum)}'`
fi

let CPU_Q_LENGTH=`ssh -q -o  "StrictHostKeyChecking no" ${SVR} "sar -q -s ${REFERENCE_TIME} |tail -1 "|awk '{print $2}'`
let LASTDAY_CPU_Q_LENGTH=`ssh -q -o  "StrictHostKeyChecking no" ${SVR} "sar -q -f /var/log/sa/sa${LASTDAY_REFERENCE_DATE} -s ${PEAK_HOUR_START} -e ${PEAK_HOUR_END} |tail -1 "| awk '{print $2}'`


##################################################################
# Function to compare input Variable name with Baseline variable # 
##################################################################
CHECK_BASENAME () {
#echo "$1 is $[${1}]"
#echo "${1}_BASELINE is $[${1}_BASELINE]"
if [  $[${1}] -le  $[${1}_BASELINE] ];then
echo "OK: ${1}=$[${1}], ${1}_BASELINE=$[${1}_BASELINE]"
echo "${1}=TRUE"
else
echo "ERROR: ${1}=$[${1}], ${1}_BASELINE=$[${1}_BASELINE]"
echo "${1}=FALSE"
fi
}
###################
# END of Function #
###################



CHECK_BASENAME PROCESS_COUNT
CHECK_BASENAME CPU_UTIL
CHECK_BASENAME MEM_UTIL
CHECK_BASENAME CPU_Q_LENGTH

if [ $SKIP_LASTDAY != Y ];then
CHECK_BASENAME LASTDAY_CPU_UTIL
CHECK_BASENAME LASTDAY_MEM_UTIL
CHECK_BASENAME LASTDAY_CPU_Q_LENGTH
fi



