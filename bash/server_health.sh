#!/bin/bash
date
echo "uptime:"
uptime
echo "Currently connected:"
w
echo "--------------------"
echo "Last logins:"
last -a | head -3
echo "--------------------"
echo "Disk and memory usage:"
df -h | xargs | awk '{print "Free/total disk: " $11 " / " $9}'
free -m | xargs | awk '{print "Free/total memory: " $17 " / " $8 " MB"}'
echo "--------------------"
start_log=$(head -1 /var/log/messages | cut -c 1-12)
oom=$(grep -ci kill /var/log/messages)
echo -n "OOM errors since $start_log :" $oom
echo ""
echo "--------------------"
echo "Utilization and the top 10 expensive processes:"
top -b | head -3
echo
# top -b | head -10 | tail -4
top -b | head -16 | tail -11
echo "--------------------"
echo "Open TCP ports:"
nmap -p -T4 127.0.0.1
echo "--------------------"
echo "Current connections:"
ss -s
echo "--------------------"
echo "vmstat:"
vmstat 1 5
echo "--------------------"
echo "processes:"
ps auxf
# ps -eo pid,user,ppid,cmd,%mem,%cpu --sort=-%cpu --width=400 | head -10
