#!/bin/sh

# function add to choosenCourse.txt and choosenTime.txt
addChoosen() {
    for i in $(awk -v pas=$1 '$1 == pas { print $2 }' courseList.txt)
    do
        courseName=$(awk -v pas=$1 '$1 == pas { print $4 }' courseList.txt)
        courseClass=$(awk -v pas=$1 '$1 == pas { print $3 }' courseList.txt)
       
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
if [ -e choosenCourse.txt ]
then
    currentChoosenTime=$( cat choosenTime.txt | awk '{ print $1 }' )
fi
tmpCourseList=$( cat courseList.txt )
for i in $currentChoosenTime
do
    firstChar=$( echo $i | cut -c1-1)
    secondChar=$( echo $i | cut -c2-2)
    tmpCourseList=$( echo "$tmpCourseList" | awk -v pas1="$firstChar[A-Z]*$secondChar" '$2~pas1 { next } { print }' )
done
# handle course for free time
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
# add choosen class to choosenCourse.txt
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
            addChoosen $i
        fi
    done
fi