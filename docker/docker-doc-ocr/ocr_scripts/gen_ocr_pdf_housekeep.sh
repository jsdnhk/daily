#!/usr/bin/env bash

readonly THRESHOLD_DAYS=${DAYS_TO_CLEAR_DOCS}
readonly TARGET_DIR=${OCR_DIR}

if [ $THRESHOLD_DAYS -ge 1 ]; then
    echo "The file housekeep on the dir[${TARGET_DIR}] over [${THRESHOLD_DAYS}] day(s),"
    echo "the following file(s) will be removed:"
    find ${TARGET_DIR} -type f -mtime +${THRESHOLD_DAYS}
    find ${TARGET_DIR} -type f -mtime +${THRESHOLD_DAYS} -delete
    find ${TARGET_DIR} -type d -empty -delete
else
    echo "The threshold day(s) are [${THRESHOLD_DAYS}], will not run housekeeping."
fi