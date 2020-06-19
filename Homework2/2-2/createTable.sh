#!/bin/sh

parseCouseName() {
  oriClassName=$1
  tmpClassName=$oriClassName
  fileNameIndex=$2
  for ii in 1 2 3 4
  do
    if [ "$tmpClassName" == "." ] && [ "$(echo ${#tmpClassName})" -eq 1 ];
    then
      toPrint="."
    elif [ "$(echo ${#tmpClassName})" -gt 13 ]
    then
      toPrint=$(echo "$tmpClassName" | cut -c1-13)
      tmpClassName=$(echo "$tmpClassName" | cut -c14-)
    else
      toPrint="$tmpClassName"
      tmpClassName="."
    fi
    printf '|%-13s\n' $toPrint >> tmp"$2".txt
  done
}

# main function here
rm -f tmp0.txt
timing='1 2 3 4 5 6 7'
timemark='M N A B C D X E F G H Y I J K L'

showExtra=$( awk '$1~"op2" { print $2 }' option.txt)
if [ $showExtra == "off" ]
then
  timing='1 2 3 4 5'
  timemark='A B C D E F G H I J K'
fi

echo "x" >> tmp0.txt
for x in $timemark
do
  printf '%-s\n' $x >> tmp0.txt
  printf '%-s\n' "." >> tmp0.txt
  printf '%-s\n' "." >> tmp0.txt
  printf '%-s\n' "." >> tmp0.txt
  printf '%-s\n' "=" >> tmp0.txt
done
column -t tmp0.txt

for j in $timing
do
  rm -f tmp"$j".txt
  dayName=$j
  case $dayName in
            1) dayName="Mon" ;;
            2) dayName="Tue" ;;
            3) dayName="Wed" ;;
            4) dayName="Thu" ;;
            5) dayName="Fri" ;;
            6) dayName="Sat" ;;
            7) dayName="Sun" ;;
  esac
showClassroom=$( awk '$1~"op1" { print $2 }' option.txt)
if [ $showClassroom == "off" ]
then
  showClassroom="3"
else
  showClassroom="2"
fi
  printf '.%-13s\n' $dayName >> tmp"$j".txt
  for x in $timemark
  do
    classesName="."
    findMatch=""
    findMatch=$(awk '{ print $1 }' choosenTime.txt | grep -h "$j$x")
    if [ "$findMatch" != "" ]
    then
      classesName=$(grep -h "$j$x" choosenTime.txt | awk -v pas=$showClassroom '{ print $pas }')
    fi
    parseCouseName $classesName $j
    printf "==============\n" >> tmp"$j".txt
  done
  column -t tmp"$j".txt
done
if [ $showExtra == "off" ]
then
  paste tmp0.txt tmp1.txt tmp2.txt tmp3.txt tmp4.txt tmp5.txt > table_final.txt
else
  paste tmp0.txt tmp1.txt tmp2.txt tmp3.txt tmp4.txt tmp5.txt tmp6.txt tmp7.txt > table_final.txt
fi
for j in 0 1 2 3 4 5 6 7
do
  if [ -e tmp"$j".txt ]
  then
    rm -f tmp"$j".txt
  fi
done