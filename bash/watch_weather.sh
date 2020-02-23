#!/usr/bin/env bash

set -eu

function print_weather() {
  CITIES=$1
  LANGUAGE="zh-TW"
  FORMAT='"%l:+%c+%t+%h+%w+%p+%o+%m"'
  UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36"

  curl -s \
  -H "Accept-Language: $LANGUAGE" \
  -H "User-Agent: $UA" \
  "wttr.in/{${CITIES}}?format=${FORMAT}"
}


dt=`date '+%Y/%m/%d %H:%M:%S'`
echo "Current Datetime: $dt"
echo -e "Weather report: \n---\n"
# python3 simpletest.py;
# echo -e "\n---\n"
TZ=Asia/Hong_Kong date
print_weather "HongKong,TaiPei,BeiJing"
echo ""
TZ=America/Los_Angeles date
print_weather "LosAngeles"
echo ""
TZ=Brazil/East date
print_weather "SaoPaulo"
echo ""
TZ=Asia/Calcutta date
print_weather "NewDelhi"
echo -e "\n---\n"
