#!/bin/sh

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
                    ./findCourse.sh "$2"
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

# main function here
tmpCourseList=$( echo "$1" )
if [ "$tmpCourseList" == "" ]
then
    dialog --msgbox "No result" 10 100
else
    # handle course from input
    echo "$tmpCourseList" | awk '{ print $1 }' > tmp1
    echo "$tmpCourseList" | awk '{ print $2" "$3" "$4 }' | sed 's/[[:blank:]]/./g' > tmp2
    paste -d' ' tmp1 tmp2 > tmp_final
    while read line;
    do
        tmp="$line off "
        classMenu=$classMenu$tmp
    done < tmp_final
    # handle choosen course
    cat choosenCourse.txt | awk '{ print $1 }' > tmp1
    cat choosenCourse.txt | awk '{ print $2" "$3" "$4 }' | sed 's/[[:blank:]]/./g' > tmp2
    paste -d' ' tmp1 tmp2 > tmp_final
    while read line;
    do
        tmp="$line on "
        classMenu=$classMenu$tmp
    done < tmp_final
    rm -f tmp1
    rm -f tmp2
    rm -f tmp_final
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
                checkConflict "$i" "$1"
                rm -f tmp.txt
                rm -f tmp2.txt
            fi
        done
    fi
fi