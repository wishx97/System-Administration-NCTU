#!/bin/sh

# curl from site
curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > rawTimeTable.json
# extract course name field in json file and replace space with "."
grep -o '"cos_ename":"[^"]*"' rawTimeTable.json | grep -o '"[^"]*"$' | sed 's/"//g' | sed 's/[[:blank:]]/./g' > cos_ename.txt
# extract time and classroom
grep -o '"cos_time":"[^"]*"' rawTimeTable.json | grep -o '"[^"]*"$' | sed 's/"//g' > cos_time_place.txt
sed -e 's/-[^$,]*//g' cos_time_place.txt >  cos_time.txt
sed 's/[^$,]*-//g' cos_time_place.txt | sed 's/^\s*$/NULL/g' >  cos_place.txt
# generate index for course list
seq 111 > index.txt
# make a copy for courseList
paste -d'-' cos_time.txt cos_place.txt cos_ename.txt > addClass.txt
# remove duplicate
awk '/.Education/ { print }' addClass.txt > test.txt
sed '/^$/d' addClass.txt | awk '!a[$1]++' | sed 's/.*.Education.*//' > test2.txt
cat test2.txt test.txt | sed '/^$/d' > addClass.txt
sed -e 's/-/ /g' addClass.txt > courseListTmp.txt
paste -d' ' index.txt courseListTmp.txt > courseList.txt
# remove unnecessary file
rm -f test.txt
rm -f test2.txt
rm -f courseListTmp.txt
rm -f index.txt
rm -f cos_ename.txt
rm -f cos_time.txt
rm -f cos_place.txt
rm -f cos_time_place.txt