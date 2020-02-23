#!/bin/bash

. /etc/profile
WHO=`who am i|awk '{print $1"-"$5}'|sed 's/(//'|sed 's/)//'`
WORKDIR=/home/sysadm/adhoc_ansible
TMPFILE=/tmp/FUNCTION.tmp
HOST_FILE=/tmp/HOST_${WHO}.$$
#PREFIX=`ls $WORKDIR/parm | grep $FUNCTION | sed "s/$FUNCTION.parm//g"`
TASK_LIST=$WORKDIR/adhoc_ansible_task.list
JOB_OUTPUT=${WORKDIR}/logs/`basename $0`.out


usage () {

#        echo "Not enough arguments supplied"
        echo ""
        echo "`basename $0`" "-e <ENV> -t <TASK> -h <HOSTNAME> -o <OPTION> -f <HOST FILE NAME>"
        echo "where: "
        echo "ENV = NONPROD or PROD"
        echo "TASK = available task: `cat $TASK_LIST`"
        echo "HOSTNAME = target server name"
        echo "OPTION = additional parameter if any"
        echo "EXAMPLE = ./ansible.sh -e NONPROD -t iview -h <hostname> -o group=fode"
        echo "EXAMPLE = ./ansible.sh -e NONPROD -t iview -f <filename> -o group=fode"
        exit 8
}

clear

if [ X${1} = X ];then
usage
fi

#ENV=$1
#ROLE_NAME=$2
#HOST_NAME=$3



echo $HOST_NAME > $HOST_FILE

while getopts ":e:t:h:f:o:" var;do
case ${var} in
e)
ENV=${OPTARG}
;;
t)
ROLE_NAME=${OPTARG}
if [[  `cat $TASK_LIST|grep $ROLE_NAME |wc -l ` = 0 ]];then
        usage
fi

;;
h)
HOST_NAME=${OPTARG}
echo $HOST_NAME > $HOST_FILE
;;
o)
#OPTION+=("$OPTARG")
OPTION=("$OPTARG")
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                OPTION+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
;;
f)
cat $OPTARG > $HOST_FILE
;;
*)
usage
;;
esac
done
shift $((OPTIND-1))



for HOST in `cat $HOST_FILE`;do
        if [ `ping -c 1 -i 1 -W 1 $HOST |grep "100% packet loss"|wc -l ` != 0 ];then
        echo "ABORT: $HOST_NAME is not reachable, please check !"
        exit 16
        fi
done

###
#Choose ansible server
###

if [ $ENV = "NONPROD" ] ; then
        echo "wgqansiblepp"
        ANSIBLE_SERVER="ansiblepp"
elif [ $ENV = "PROD" ] ; then
        echo "wgqansibleprd"
        ANSIBLE_SERVER="ansibleprd"
else
        echo "Invalid ansible server selected, please input NONPROD or PROD"

        exit 8
fi


# Debug
#echo "      ansible-playbook /etc/ansible/projects/$ROLE_NAME/$ROLE_NAME.yml -i $HOST_FILE -e '"${OPTION[@]}"' "

#exit 8
# end of Debug



###
#copy the temp host file to ansible server
###




echo "temp host file $HOST_FILE created"
cat $HOST_FILE
echo "copy the $HOST_FILE to ansible server for ad-hoc run playbook"
scp -pr $HOST_FILE $ANSIBLE_SERVER:/tmp
rm -f $HOST_FILE
###
#Execute playbook
###
ssh $ANSIBLE_SERVER "echo $WHO run $ROLE_NAME  >> /var/log/ansible.log"
if [ X${OPTION} != X ];then
        echo "$ANSIBLE_SERVER run  ansible-playbook /etc/ansible/projects/$ROLE_NAME/$ROLE_NAME.yml -i $HOST_FILE -e '"${OPTION[@]}"' "

        ssh $ANSIBLE_SERVER "ansible-playbook /etc/ansible/projects/$ROLE_NAME/$ROLE_NAME.yml -i $HOST_FILE -e '"${OPTION[@]}"' "
else
        ssh $ANSIBLE_SERVER "ansible-playbook /etc/ansible/projects/$ROLE_NAME/$ROLE_NAME.yml -i $HOST_FILE "
fi
ssh $ANSIBLE_SERVER rm -f $HOST_FILE

