#!/bin/sh

# INITIALIZE
if ! [ -e rawTimeTable.json ] || ! [ -e courseList.txt ] || ! [ -e addClass.txt ]
then
    ./downloadCourse.sh
fi
if ! [ -e option.txt ]
then
    echo "op1 off"  > option.txt
    echo "op2 off"  >> option.txt
fi

# MAIN
./createTable.sh > /dev/null 2>&1 | dialog --progressbox "Generating table..." 10 100
dialog --ok-label "Add Class" --extra-button --extra-label "Option" --help-button --help-label "Exit" --textbox table_final.txt 100 100
choosenOption=$?
case $choosenOption in
   0) ./add.sh;;
   3) 
        op1=$( awk '$1~"op1" { print $2 }' option.txt)
        op1_string="Show Classroom"
        if [ $op1 == "on" ]
        then
            op1_string="Hide Classroom"
        fi
        op2=$( awk '$1~"op2" { print $2 }' option.txt)
        op2_string="Show Extra Column"
        if [ $op2 == "on" ]
        then
            op2_string="Hide Extra Column"
        fi
        menuResult=$(dialog --stdout --menu "Option" 50 50 4 "op1" "$op1_string" "op2" "$op2_string" "op3" "Show Class for Free Time" "op4" "Search Course by Name" "op5" "Search Course by Time")
        menuOption=$?
        case $menuOption in
        0) case $menuResult in
            op1) 
                awk '$1~"op1" { if ($2=="off") $2="on"; else $2="off"; }1' option.txt  > tmp && mv tmp option.txt
                rm -f tmp
                ;;
            op2) 
                awk '$1~"op2" { if ($2=="off") $2="on"; else $2="off"; }1' option.txt  > tmp && mv tmp option.txt
                rm -f tmp
                ;;
            op3) 
                ./freeTime.sh
                ;;
            op4) 
                userInput=$( dialog --stdout --inputbox "Input course name to search" 10 100 )
                inputBoxOption=$?
                case $inputBoxOption in
                0)
                    tmpCourseList=$( awk -v pas1="$userInput" '$4~pas1 { print $1" "$2" "$3" "$4 }' courseList.txt )
                    ./findCourse.sh "$tmpCourseList"
                esac
                ;;
            op5) 
                userInput=$( dialog --stdout --inputbox "Input course time to search" 10 100 )
                inputBoxOption=$?
                case $inputBoxOption in
                0)
                    tmpCourseList=$( awk -v pas1="$userInput" '$2~pas1 { print $1" "$2" "$3" "$4 }' courseList.txt )
                    ./findCourse.sh "$tmpCourseList"
                esac
                ;;
           esac 
           ./timeTable.sh 
           ;;
        *) ./timeTable.sh ;;
        esac
    ;;
esac