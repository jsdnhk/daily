#!/bin/bash
########################
# Housekeep Utility    #
# Version 06L          #
# Released MAR 2018    #
########################

RemoveFile()
{
	FILE_NAME="$1"
	HANDLE_CATEGORIZED_SUBDIR="$2"
	HOUSEKEEP_SEC="$3"
	FORCE_REMOVE_SUBDIR="$4"
	HOUSEKEEP_LOG="$5"
	REMOVE_COUNTER="$6"
	BYPASS_COUNTER="$7"
	ERROR_COUNTER="$8"

	FILE=`ls -ld "$FILE_NAME"`
	FILE_MONTH=`echo "$FILE" | awk '{print $6}'`
	FILE_DAY=`echo "$FILE" | awk '{print $7}'`
	FILE_TIME=`echo "$FILE" | awk '{print $8}'`
	FILE_YR=`GetFileYr $FILE_TIME`
	FILE_HR=`GetFileHr $FILE_TIME`
	FILE_MI=`GetFileMi $FILE_TIME`
	FILE_MON=`MonToMM $FILE_MONTH`

	if [ "$HANDLE_CATEGORIZED_SUBDIR" = "Y" ]; then
		INDEX_FILE=`ls -ld "$FILE_NAME/index.file"`
		if [ -f "$INDEX_FILE" ]; then
			INDEX_FILE_MONTH=`echo $INDEX_FILE | awk '{print $6}'`
			INDEX_FILE_DAY=`echo $INDEX_FILE | awk '{print $7}'`
			INDEX_FILE_TIME=`echo $INDEX_FILE | awk '{print $8}'`
			INDEX_FILE_YR=`GetFileYr $INDEX_FILE_TIME`
			INDEX_FILE_HR=`GetFileHr $INDEX_FILE_TIME`
			INDEX_FILE_MI=`GetFileMi $INDEX_FILE_TIME`
			INDEX_FILE_MON=`MonToMM $INDEX_FILE_MONTH`
			
			INDEX_FILE_EXIST_TIME=`$LIB_DIR/timediff $INDEX_FILE_YR $INDEX_FILE_MON $INDEX_FILE_DAY $INDEX_FILE_HR $INDEX_FILE_MI 0 $SYS_YR $SYS_MON $SYS_DAY $SYS_HR $SYS_MIN 0`

			if (($INDEX_FILE_EXIST_TIME<0)); then
				INDEX_FILE_YR=$(($INDEX_FILE_YR-1))
				INDEX_FILE_EXIST_TIME=`$LIB_DIR/timediff $INDEX_FILE_YR $INDEX_FILE_MON $INDEX_FILE_DAY $INDEX_FILE_HR $INDEX_FILE_MI 0 $SYS_YR $SYS_MON $SYS_DAY $SYS_HR $SYS_MIN 0`
			fi
			
			FILE_YR=$INDEX_FILE_YR
			ILE_MONTH=$INDEX_FILE_MONTH
			FILE_DAY=$INDEX_FILE_DAY

			if (($INDEX_FILE_EXIST_TIME>$HOUSEKEEP_SEC)); then
				rm -R "$FILE_NAME"
				REMOVE_STATUS=$?
			else
				CURR_YR=`date +%Y`
				if (($INDEX_FILE_YR<$CURR_YR)); then
					rm -R "$FILE_NAME"
					REMOVE_STATUS=$?
				else
					REMOVE_STATUS=-1
				fi
			fi
		else
			REMOVE_STATUS=-1
		fi
	else
		if [ "$FORCE_REMOVE_SUBDIR" = "Y" ] && [ -d "$FILE_NAME" ]; then
			rm -R "$FILE_NAME"
			REMOVE_STATUS=$?
		else
			rm "$FILE_NAME"
			REMOVE_STATUS=$?
		fi
	fi

	case $REMOVE_STATUS in
	"0")
		echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Removed." >> $HOUSEKEEP_LOG
		REMOVE_COUNTER=$(($REMOVE_COUNTER+1))
		;;
	"-1")
		echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Bypassed." >> $HOUSEKEEP_LOG
		BYPASS_COUNTER=$(($BYPASS_COUNTER+1))
		;;
	*)
		echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Not removed." >> $HOUSEKEEP_LOG
		ERROR_COUNTER=$(($ERROR_COUNTER+1))
		;;
	esac
	RETURN_STRING=$REMOVE_COUNTER","$BYPASS_COUNTER","$ERROR_COUNTER
	echo $RETURN_STRING
}

CompressFile()
{
	FILE_NAME="$1"
	GZIP_ARCHIVE_UTIL="$2"
	COMPRESS_FILE_MOVE_TO="$3"
	HOUSEKEEP_LOG="$4"
	COMPRESS_COUNTER="$5"
	ERROR_COUNTER="$6"

	FILE=`ls -ld "$FILE_NAME"`
	FILE_MONTH=`echo $FILE | awk '{print $6}'`
	FILE_DAY=`echo $FILE | awk '{print $7}'`
	FILE_TIME=`echo $FILE | awk '{print $8}'`
	FILE_YR=`GetFileYr $FILE_TIME`
	FILE_HR=`GetFileHr $FILE_TIME`
	FILE_MI=`GetFileMi $FILE_TIME`
	FILE_MON=`MonToMM $FILE_MONTH`

	ARCHIVED_FILE_EXT=gz
	$GZIP_ARCHIVE_UTIL -f "$FILE_NAME"
	COMPRESS_STATUS=$?

	if (($COMPRESS_STATUS!=0)) && [ -n "$COMPRESS_ARCHIVE_UTIL" ]; then
		$COMPRESS_ARCHIVE_UTIL -f "$FILE_NAME"
		COMPRESS_STATUS=$?
		ARCHIVED_FILE_EXT="Z"
	fi

	case $COMPRESS_STATUS in
		"0")
			if [ -n "$COMPRESS_FILE_MOVE_TO" ]; then
				mv "$FILE_NAME.$ARCHIVED_FILE_EXT" "$COMPRESS_FILE_MOVE_TO/"
				echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Compressed and moved." >> $HOUSEKEEP_LOG
			else
				echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Compressed." >> $HOUSEKEEP_LOG
			fi
			COMPRESS_COUNTER=$(($COMPRESS_COUNTER+1))
			;;
		*)
			echo $FILE_DAY $FILE_MONTH $FILE_YR $FILE_NAME "... Not compressed." >> $HOUSEKEEP_LOG
			ERROR_COUNTER=$(($ERROR_COUNTER+1))
			;;
	esac
	RETURN_STRING=$COMPRESS_COUNTER","$ERROR_COUNTER
	echo $RETURN_STRING
}

LIB_DIR=/var/adm/library
#
# Include script libraries
#
. $LIB_DIR/mail.sl
. $LIB_DIR/calendar.sl
. $LIB_DIR/file.sl
. $LIB_DIR/path.sl
. $LIB_DIR/os.sl

MAIL_DOMAIN="exch.oocl.com"

SYSADM_HOME=`GetSysAdmHomePath`
SCRIPT_DIR=$SYSADM_HOME/housekeep
EVENT_LOG=$SCRIPT_DIR/daily_master.log
MASTER_EVENT_LOG=$SCRIPT_DIR/master.log
HOUSEKEEP_LOG=$SCRIPT_DIR/housekeep.log.dist
HOUSEKEEP_LOG_SUMMARY=$SCRIPT_DIR/housekeep.log.sum

LOCK_FILE=$SCRIPT_DIR/.lock
FIND_COMMAND_SCRIPT=$SCRIPT_DIR/find_command.sh
COUNTER_FILE=$SCRIPT_DIR/housekeep.count.dist
KEEP_FILE=$SCRIPT_DIR/housekeep.keep.dist
ERR_FILE=$SCRIPT_DIR/housekeep.err
MAIL_FILE=$SCRIPT_DIR/remove.notice.dist
WORK_LIST=$SCRIPT_DIR/work_list.txt.dist
WORK_LIST_NORMAL=$SCRIPT_DIR/work_list.txt.normal
WORK_LIST_SPECIAL=$SCRIPT_DIR/work_list.txt.spc
TMP_WORK_LIST=$SCRIPT_DIR/work_list.txt.dist.tmp
SORT_WORK_LIST=$SCRIPT_DIR/work_list.txt.dist.sort

HOSTNAME=`hostname`
HOUSEKEEP_START_TIME=`date +%Y%m%d%H%M%S`
HOUSEKEEP_START_YEAR=`echo $HOUSEKEEP_START_TIME | cut -c 1-4`
HOUSEKEEP_START_MONTH=`echo $HOUSEKEEP_START_TIME | cut -c 5-6`
HOUSEKEEP_START_DAY=`echo $HOUSEKEEP_START_TIME | cut -c 7-8`
HOUSEKEEP_START_HOUR=`echo $HOUSEKEEP_START_TIME | cut -c 9-10`
HOUSEKEEP_START_MIN=`echo $HOUSEKEEP_START_TIME | cut -c 11-12`
HOUSEKEEP_START_SEC=`echo $HOUSEKEEP_START_TIME | cut -c 13-14`

SYS_YR=`date +'%Y'`
SYS_MONTH=`date +'%b'`
SYS_MON=`date +'%m'`
SYS_DAY=`date +'%d'`
SYS_HR=`date +'%H'`
SYS_MIN=`date +'%M'`

OS=`GetOSName`

case $OS in
	"HP-UX")
		GZIP_ARCHIVE_UTIL=/usr/contrib/bin/gzip
		COMPRESS_ARCHIVE_UTIL=/usr/bin/compress
		GREP_PATH=/usr/bin
		;;
	"SunOS")
		GZIP_ARCHIVE_UTIL=/usr/bin/gzip
		COMPRESS_ARCHIVE_UTIL=/usr/bin/compress
		GREP_PATH=/usr/xpg4/bin
		;;
	"Linux")
		GZIP_ARCHIVE_UTIL=/bin/gzip
		COMPRESS_ARCHIVE_UTIL=""
		GREP_PATH=/bin
		;;
esac

cat /dev/null > $EVENT_LOG

#
# Disable filename generation - by executing `set -f` or `set -o noglob`
# Enable filename generation - by executing `set +f` or `set +o noglob`
#
set +f

if [ -f $LOCK_FILE ]; then
	echo `date`": Housekeep job failed to start due to running of previous instance." >> $MASTER_EVENT_LOG
	HOST=`hostname`
	MailxSendMail "Housekeeping job in $HOST long running, new instance failed to start" "unixsupp@exch.oocl.com" /dev/null
	exit 1
else
	echo `date`": Housekeep job started." >> $EVENT_LOG
fi

touch $LOCK_FILE

if [ -n "$1" ]; then
	if [ -f "$SCRIPT_DIR/$1" ]; then
		PARM_SET=$SCRIPT_DIR/$1
	else
		if [ -f "$1" ]; then
			PARM_SET=$1
		else
			echo `date`": Housekeep job failed to start due to missing master parm file [$1]." >> $MASTER_EVENT_LOG
			HOST=`hostname`
			MailxSendMail "Housekeeping job in $HOST failed to start due to invalid or missing master parm file [$1]" "unixsupp@exch.oocl.com" /dev/null
			exit 2
		fi
	fi
	PARM_FILELIST=`cat $PARM_SET`
else	
	PARM_NAME="parm_*"
	PARM_PATH="$SCRIPT_DIR/$PARM_NAME"
	PARM_SET=`find "$SCRIPT_DIR/" -path "$PARM_PATH*" -name "$PARM_NAME" -prune -type f`
	PARM_FILELIST=`echo $PARM_SET`
fi
set -f

TTL_TOTAL=0
PARMFILE_COUNT=0

cat /dev/null > $HOUSEKEEP_LOG
cat /dev/null > $HOUSEKEEP_LOG_SUMMARY
cat /dev/null > $KEEP_FILE
cat /dev/null > $ERR_FILE
echo $TTL_TOTAL > $COUNTER_FILE

for HOUSEKEEP_PARM in $PARM_FILELIST; do
	echo `date`": Running profile ["$HOUSEKEEP_PARM"] ..." >> $EVENT_LOG
	COMPRESS_FILE_MOVE_TO=""
	HANDLE_CATEGORIZED_SUBDIR=""
	FORCE_REMOVE_SUBDIR=""
	. $HOUSEKEEP_PARM

	if [ -z "$HANDLE_CATEGORIZED_SUBDIR" ]; then
		HANDLE_CATEGORIZED_SUBDIR="N"
	elif [ "$HANDLE_CATEGORIZED_SUBDIR" != "Y" ]; then
		HANDLE_CATEGORIZED_SUBDIR="N"
	fi
	if [ -z "$FORCE_REMOVE_SUBDIR" ]; then
		FORCE_REMOVE_SUBDIR="N"
	elif [ "$FORCE_REMOVE_SUBDIR" != "Y" ]; then
		FORCE_REMOVE_SUBDIR="N"
	fi

	REMOVE_COUNTER=0
	COMPRESS_COUNTER=0
	BYPASS_COUNTER=0
	ERROR_COUNTER=0
	IGNORE_COUNTER=0
	
	HOUSEKEEP_SEC=`DayToSec $HOUSEKEEP_DAYS`
	HOUSEKEEP_FILE_LIST_LINE_COUNT=`cat $HOUSEKEEP_FILE_LIST | wc -l`
	HOUSEKEEP_FILE_LIST_LINE_COUNTER=1

	while (($HOUSEKEEP_FILE_LIST_LINE_COUNTER<=$HOUSEKEEP_FILE_LIST_LINE_COUNT)); do
		FILE_LIST=`sed -n "$HOUSEKEEP_FILE_LIST_LINE_COUNTER p" $HOUSEKEEP_FILE_LIST`
		FILE_LIST=`echo "$FILE_LIST"`
		SEARCH_PATH=`dirname "$FILE_LIST"`
		FILE_PATTERN=`basename "$FILE_LIST"`
		WILDCARD_PATH=`echo "$SEARCH_PATH" | $GREP_PATH/grep -E "\*|\?|\[|\]"`
		FIXED_PATH=""

		if [ -n "$WILDCARD_PATH" ]; then
			LAST_WILDCARD_DIR=`echo "$WILDCARD_PATH" | cut -d "*" -f 1 | cut -d "?" -f 1 | cut -d "[" -f 1 | cut -d "]" -f 1`
			FIXED_PATH_DEPTH=`echo "$LAST_WILDCARD_DIR" | awk -F"/" '{print NF}'`
			N_FIXED_PATH_DEPTH=$(($FIXED_PATH_DEPTH-1))
			FIXED_PATH=`echo "$LAST_WILDCARD_DIR" | cut -d "/" -f 1-$N_FIXED_PATH_DEPTH`
		else
			FIXED_PATH="$SEARCH_PATH"
		fi
		
		if [ -z "$FIXED_PATH" ]; then
			FIXED_PATH="/"
		else
			FIXED_PATH="${FIXED_PATH}"
		fi
		
		LAST_CHAR_FIXED_PATH="${FIXED_PATH:${#FIXED_PATH}-1}"
		if [ "$HANDLE_CATEGORIZED_SUBDIR" = "Y" ] || [ "$FORCE_REMOVE_SUBDIR" = "Y" ]; then
			FIND_OPTION="-type d"		#directory
			if [ -n "$FIXED_PATH" ]; then
				if [ "${LAST_CHAR_FIXED_PATH}" = "/" ]; then
					FIXED_PATH="${FIXED_PATH:0:${#FIXED_PATH}-1}"
				else
					FIXED_PATH="${FIXED_PATH}"
				fi
			else
				FIXED_PATH="/"
			fi
		else
			FIND_OPTION="-type f"		#file
			if [ -n "$FIXED_PATH" ]; then
				if [ "${LAST_CHAR_FIXED_PATH}" != "/" ]; then
					echo "${FIXED_PATH}/"
				else
					echo "${FIXED_PATH}"
				fi
			else
				FIXED_PATH="/"
			fi
		fi

		if [ "$HANDLE_CATEGORIZED_SUBDIR" = "Y" ]; then
			DUMMY_HOUSEKEEP_DAYS=0
		else
			DUMMY_HOUSEKEEP_DAYS=$HOUSEKEEP_DAYS
		fi

		if (($DUMMY_HOUSEKEEP_DAYS!=999)) && (($DUMMY_HOUSEKEEP_DAYS>=0)); then
			if (($DUMMY_HOUSEKEEP_DAYS==0)); then
				if [ "$HANDLE_CATEGORIZED_SUBDIR" -eq "Y" ]; then
					FIND_PLUS="+"
				else
					FIND_PLUS=""
				fi
			else
				FIND_PLUS="+"
			fi

			cat /dev/null > $FIND_COMMAND_SCRIPT
			case $OS in
				"HP-UX")
					echo set -f >> $FIND_COMMAND_SCRIPT
					echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -mtime "$FIND_PLUS"$DUMMY_HOUSEKEEP_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
					;;
				"SunOS")
					echo set +f >> $FIND_COMMAND_SCRIPT
					echo mkdir -p $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
					echo chmod 500 $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
					echo cd $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
					echo rm -R $SCRIPT_DIR/working/* >> $FIND_COMMAND_SCRIPT
					echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -mtime "$FIND_PLUS"$DUMMY_HOUSEKEEP_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
					echo cd / >> $FIND_COMMAND_SCRIPT
					;;
				"Linux")
					echo set +f >> $FIND_COMMAND_SCRIPT
					echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -mtime "$FIND_PLUS"$DUMMY_HOUSEKEEP_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
					;;
			esac

			chmod 700 $FIND_COMMAND_SCRIPT
			$FIND_COMMAND_SCRIPT
			cat $WORK_LIST | grep -v " " > $WORK_LIST_NORMAL
			cat $WORK_LIST | grep " " > $WORK_LIST_SPECIAL
			WORK_LIST_SPECIAL_COUNT=`cat $WORK_LIST_SPECIAL | wc -l`
			WORK_LIST_SPECIAL_COUNTER=1

			while (($WORK_LIST_SPECIAL_COUNTER<=$WORK_LIST_SPECIAL_COUNT)); do
				FILE_NAME=`sed -n "$WORK_LIST_SPECIAL_COUNTER p" $WORK_LIST_SPECIAL`
				REMOVE_RETURN=`RemoveFile "$FILE_NAME" "$HANDLE_CATEGORIZED_SUBDIR" "$HOUSEKEEP_SEC" "$FORCE_REMOVE_SUBDIR" "$HOUSEKEEP_LOG" "$REMOVE_COUNTER" "$BYPASS_COUNTER" "$ERROR_COUNTER"`
				WORK_LIST_SPECIAL_COUNTER=$(($WORK_LIST_SPECIAL_COUNTER+1))
				REMOVE_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 1`
				BYPASS_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 2`
				ERROR_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 3`
			done

			for FILE_NAME in `cat $WORK_LIST_NORMAL`
			do
				REMOVE_RETURN=`RemoveFile "$FILE_NAME" "$HANDLE_CATEGORIZED_SUBDIR" "$HOUSEKEEP_SEC" "$FORCE_REMOVE_SUBDIR" "$HOUSEKEEP_LOG" "$REMOVE_COUNTER" "$BYPASS_COUNTER" "$ERROR_COUNTER"`
				REMOVE_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 1`
				BYPASS_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 2`
				ERROR_COUNTER=`echo $REMOVE_RETURN | cut -d , -f 3`
			done
		fi

		if (($COMPRESS_DAYS!=999)) && (($COMPRESS_DAYS>=0)); then
			if (($COMPRESS_DAYS==0)); then
				FIND_PLUS=""
			else
				FIND_PLUS="+"
			fi

			cat /dev/null > $FIND_COMMAND_SCRIPT
			case $OS in
			"HP-UX")
				echo set -f >> $FIND_COMMAND_SCRIPT
				echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -not -name '"'*.Z'"' -not -name '"'*.gz'"' -mtime "$FIND_PLUS"$COMPRESS_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
				;;
			"SunOS")
				echo set +f >> $FIND_COMMAND_SCRIPT
				echo mkdir -p $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
				echo chmod 500 $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
				echo cd $SCRIPT_DIR/working >> $FIND_COMMAND_SCRIPT
				echo rm -R $SCRIPT_DIR/working/* >> $FIND_COMMAND_SCRIPT
				echo cd / >> $FIND_COMMAND_SCRIPT
				echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -not -name '"'*.Z'"' -not -name '"'*.gz'"' -mtime "$FIND_PLUS"$COMPRESS_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
				;;
			"Linux")
				echo set +f >> $FIND_COMMAND_SCRIPT
				echo find '"'$FIXED_PATH'"' -path '"'$FILE_LIST'"' -prune -name '"'$FILE_PATTERN'"' -not -name '"'*.Z'"' -not -name '"'*.gz'"' -mtime "$FIND_PLUS"$COMPRESS_DAYS $FIND_OPTION ">" $WORK_LIST >> $FIND_COMMAND_SCRIPT
				;;
			esac

			chmod 700 $FIND_COMMAND_SCRIPT
			$FIND_COMMAND_SCRIPT
			cat $WORK_LIST | grep -v " " > $WORK_LIST_NORMAL
			cat $WORK_LIST | grep " " > $WORK_LIST_SPECIAL

			WORK_LIST_SPECIAL_COUNT=`cat $WORK_LIST_SPECIAL | wc -l`
			WORK_LIST_SPECIAL_COUNTER=1

			while (($WORK_LIST_SPECIAL_COUNTER<=$WORK_LIST_SPECIAL_COUNT)); do
				FILE_NAME=`sed -n "$WORK_LIST_SPECIAL_COUNTER p" $WORK_LIST_SPECIAL`
				COMPRESS_RETURN=`CompressFile "$FILE_NAME" "$GZIP_ARCHIVE_UTIL" "$COMPRESS_FILE_MOVE_TO" "$HOUSEKEEP_LOG" "$COMPRESS_COUNTER" "$ERROR_COUNTER"`
				WORK_LIST_SPECIAL_COUNTER=$(($WORK_LIST_SPECIAL_COUNTER+1))
				COMPRESS_COUNTER=`echo $COMPRESS_RETURN | cut -d , -f 1`
				ERROR_COUNTER=`echo $COMPRESS_RETURN | cut -d , -f 2`
			done

			for FILE_NAME in `cat $WORK_LIST_NORMAL`; do
				COMPRESS_RETURN=`CompressFile "$FILE_NAME" "$GZIP_ARCHIVE_UTIL" "$COMPRESS_FILE_MOVE_TO" "$HOUSEKEEP_LOG" "$COMPRESS_COUNTER" "$ERROR_COUNTER"`
				COMPRESS_COUNTER=`echo $COMPRESS_RETURN | cut -d , -f 1`
				ERROR_COUNTER=`echo $COMPRESS_RETURN | cut -d , -f 2`
			done
		fi
		HOUSEKEEP_FILE_LIST_LINE_COUNTER=$(($HOUSEKEEP_FILE_LIST_LINE_COUNTER+1))
	done

	STR_INDENT="  "
	PARMFILE_COUNT=$(($PARMFILE_COUNT+1))
	
	#the mail file content
	cat /dev/null > $MAIL_FILE
	if [ -n "$MAIL_TITLE" ]; then
		echo -e "Mail Title:\t${MAIL_TITLE}" >> $MAIL_FILE
		echo -e "${STR_INDENT}" >> $MAIL_FILE
		echo -e "${STR_INDENT}" >> $MAIL_FILE
	fi
	echo -e "Operating logkeeping rule $PARMFILE_COUNT," >> $MAIL_FILE
	echo -e "on the host [${HOSTNAME}] at $SYS_HR":"$SYS_MIN $SYS_DAY-$SYS_MONTH-$SYS_YR" >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}\tNo. of files compressed:\t" $COMPRESS_COUNTER >> $MAIL_FILE 
	echo -e "${STR_INDENT}\tNo. of files removed:\t" $REMOVE_COUNTER >> $MAIL_FILE 
	echo -e "${STR_INDENT}\tNo. of files cannot be compressed:\t" $BYPASS_COUNTER >> $MAIL_FILE 
	echo -e "${STR_INDENT}\tNo. of files encountered error:\t" $ERROR_COUNTER >> $MAIL_FILE 
	echo -e "${STR_INDENT}\tNo. of files bypassed:\t" $IGNORE_COUNTER >> $MAIL_FILE 
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}Please check" "[${HOSTNAME}:${HOUSEKEEP_LOG}]" "for details." >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}Execute the logkeeping action by the values of parm. file [$HOUSEKEEP_PARM]:" >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}\tFile pattern list file:\t" "[$HOUSEKEEP_FILE_LIST]" >> $MAIL_FILE
	echo -e "${STR_INDENT}\tCompress after:\t" "${COMPRESS_DAYS}days" >> $MAIL_FILE
	echo -e "${STR_INDENT}\tRemove after:\t" "${HOUSEKEEP_DAYS}days" >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}File pattern included inside the path file [$HOUSEKEEP_FILE_LIST]:" >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	sed "s/\//#\//" $HOUSEKEEP_FILE_LIST >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE
	echo -e "${STR_INDENT}" >> $MAIL_FILE

	TTL_COUNTER=$(($COMPRESS_COUNTER+$REMOVE_COUNTER+$ERROR_COUNTER))
	if (($TTL_COUNTER>0)); then
		cat $MAIL_FILE >> $KEEP_FILE
		TTL_TOTAL=$(($TTL_TOTAL+$TTL_COUNTER))
		if (($ERROR_COUNTER>0)); then
			cat $MAIL_FILE >> $ERR_FILE
		fi
	fi
	cat $MAIL_FILE >> $HOUSEKEEP_LOG_SUMMARY
done

echo $TTL_TOTAL > $COUNTER_FILE 
rm $LOCK_FILE
echo `date`": Housekeep job completed." >> $EVENT_LOG
cat $EVENT_LOG >> $MASTER_EVENT_LOG

if [ -f $SCRIPT_DIR/post_exec.sh ]; then
	HOUSEKEEP_END_TIME=`date +%Y%m%d%H%M%S`
	HOUSEKEEP_END_YEAR=`echo $HOUSEKEEP_END_TIME | cut -c 1-4`
	HOUSEKEEP_END_MONTH=`echo $HOUSEKEEP_END_TIME | cut -c 5-6`
	HOUSEKEEP_END_DAY=`echo $HOUSEKEEP_END_TIME | cut -c 7-8`
	HOUSEKEEP_END_HOUR=`echo $HOUSEKEEP_END_TIME | cut -c 9-10`
	HOUSEKEEP_END_MIN=`echo $HOUSEKEEP_END_TIME | cut -c 11-12`
	HOUSEKEEP_END_SEC=`echo $HOUSEKEEP_END_TIME | cut -c 13-14`
	COMMENCED_SEC=`$LIB_DIR/timediff $HOUSEKEEP_START_YEAR $HOUSEKEEP_START_MONTH $HOUSEKEEP_START_DAY $HOUSEKEEP_START_HOUR $HOUSEKEEP_START_MIN $HOUSEKEEP_START_SEC $HOUSEKEEP_END_YEAR $HOUSEKEEP_END_MONTH $HOUSEKEEP_END_DAY $HOUSEKEEP_END_HOUR $HOUSEKEEP_END_MIN $HOUSEKEEP_END_SEC`
	COMMENCED_MIN=$(($COMMENCED_SEC/60))
	FILE_PROCESSED=`cat $HOUSEKEEP_LOG | wc -l`
	$SCRIPT_DIR/post_exec.sh $COMMENCED_MIN $HOUSEKEEP_START_YEAR $HOUSEKEEP_START_MONTH $HOUSEKEEP_START_DAY $FILE_PROCESSED
fi


