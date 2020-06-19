#!/bin/sh

# function check time conflict
checkConflict() {
    for i in $(awk -v pas=$1 '$1 == pas { print $2 }' courseList.txt)
    do
        courseName=$(awk -v pas=$1 '$1 == pas { print $4 }' courseList.txt)
        courseClass=$(awk -v pas=$1 '$1 == pas { print $3 }' courseList.txt)
        # decompose time
        timee=""
        for j in $(echo "$i" | sed -e 's/\(.\)/\1 /g')
        do
        case $j in
            # check if conflict with current choosenCourse.txt list
            ''|*[!0-9]*)
                ans_conflict=""
                t1=""
                t1=$(awk '{ print $1 }' tmp2.txt | grep -h "$j")
                if [ "$t1" != "" ]
                then
                    ans_conflict=$(grep -h "$t1" tmp2.txt | awk '{ print $2 }')
                fi
                if [ "$ans_conflict" != "" ]
                then
                    dialog --msgbox "Collision: $timee$j\n$ans_conflict and $courseName" 10 100
                    rm -f tmp.txt
                    rm -f tmp2.txt
                    sh ./add.sh
                    exit 0
                fi
            ;;
            *)  
                timee="$j"
                cat choosenCourse.txt > tmp.txt
                awk '{ print $2" "$4 }' tmp.txt | grep -h "$j" | sed -e "s/.*$j//g" | sed -e "s/[[:digit:]][^ ]* / /g" > tmp2.txt
            ;;
        esac
        done
        # combine time and courseName
        timee=""
        for j in $(echo "$i" | sed -e 's/\(.\)/\1 /g')
        do
        case $j in
            ''|*[!0-9]*)
                echo "$timee$j $courseClass $courseName" >> choosenTime.txt
            ;;
            *)  
                timee="$j"
            ;;
        esac
        done
    done
    # processed selected course and update file
    awk NR=="$1" courseList.txt >> choosenCourse.txt
}

###
# Main body of script starts here
###
classMenu=""
tmp=""
i=1
# check selected class and display in dialog
while read line;
do
 tmp="$i $line off "
 if [ -e choosenCourse.txt ]
 then
    for j in $(awk '{ print $1 }' choosenCourse.txt)
    do
    if [ $j == $i ];
    then
        tmp="$i $line on "
        break
    fi
    done
 fi
 classMenu=$classMenu$tmp
 i=$(($i+1))
done < addClass.txt
result=$(dialog --stdout --buildlist "Add Class" 300 300 120 $classMenu )
if [ $? == 0 ]
then
    for i in $result
    do
        zen=""
        if [ -e choosenCourse.txt ]
        then
            zen=$(awk -v pas=$i '$1 ==  pas {print "yes"}' choosenCourse.txt)
        fi
        if [ "$zen" != "yes" ];
        then
            checkConflict $i
            rm -f tmp.txt
            rm -f tmp2.txt
        fi
    done
fi
./timeTable.sh