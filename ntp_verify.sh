#!/bin/bash

# commentblock.sh


if !(service ntp status grep "active" >> /dev/null)
then 
echo "NOTICE: ntp is not running"
service ntp start
fi

mapfile -d$'\n' -t strings < <(echo 'server 0.ua.pool.ntp.org iburst prefer
server 1.ua.pool.ntp.org iburst
server 2.ua.pool.ntp.org iburst
server 3.ua.pool.ntp.org iburst')

IFS=$'\n'
i=0
j=0
k=0

function check {
if [ "$j" -eq 0 ]; then 
echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:" 
echo "`ls -l --time-style=full-iso /etc/ntp.conf | awk '{print "+++ " $9 "  " $6 " " $7 " " $8}'`" 
let j=1
fi
#echo `cat /etc/ntp.conf | grep -in -E "$1"` | awk -F: '{print $1}'
echo "@@ +$2 @@"
echo "+"$1
}

count=0;
for var in $(cat /etc/ntp.conf | grep -in -E '^[[:blank:]]*pool')
do
countRows=`echo $var | awk -F: '{print $1}'`
rowsPool=`echo $var | awk -F'^[0-9]+:' '{print $2}'`
check "$rowsPool" "$countRows"
done

b=0
arrIndex=0;
for var in $(cat /etc/ntp.conf | grep -in -E '^[[:blank:]]*Server')
do
countRows=`echo $var | awk -F: '{print $1}'`
rows=`echo $var | awk -F'^[0-9]+:' '{print $2}'`
varNotSpace=`echo $rows | sed 's/\s\+$//'| sed 's/^\s\+//'`


is=1
isElse=0
for ((index = 0; index < ${#arr[*]}; index++ ))
do
if [ "$varNotSpace" = "${arr[$index]}" ] 2> /dev/null
then
is=0
fi
done

for ((index = 0; index < ${#strings[*]}; index++ ))
do
if [ "$varNotSpace" = "${strings[$index]}" ] 2> /dev/null
then
arr[arrIndex]=$varNotSpace
arrIndex=$(($arrIndex+1))
isElse=1
count=$(($count+1))
break
fi
done

if [ "$is" != "1" ] || [ "$isElse" != "1" ] 2> /dev/null
then
check "$rows" "$countRows"
else
let k=k+1
fi
let i=i+1
done


if [ "$j" -gt 0 ] || [ "$k" -ne 4 ]; then
sed -i "/^[[:blank:]]*pool/d" /etc/ntp.conf 
sed -i "/^[[:blank:]]*server/d" /etc/ntp.conf 
count=`cat /etc/ntp.conf |grep -n "# pool:" | awk -F: '{print $1}'`
if [ "$count" -gt 0 ] 2> /dev/null
then let count=count+1
else count=`cat /etc/ntp.conf | wc -l`
fi
sed -i "$count"i\ 'server 0.ua.pool.ntp.org iburst prefer\nserver 1.ua.pool.ntp.org iburst\nserver 2.ua.pool.ntp.org iburst\nserver 3.ua.pool.ntp.org iburst' /etc/ntp.conf 
service ntp restart
fi


#: << COMMENTBLOCK
#for var in "$(cat /etc/ntp.conf)"
#do 
#echo "$var"
#echo "qwe";
#done

#while read line
#do
#echo $line
#done < "/etc/ntp.conf"
#COMMENTBLOCK


