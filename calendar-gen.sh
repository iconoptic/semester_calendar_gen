#!/bin/bash

year=2023
index=0
#Month range
m1=8
m2=12
semLen=16	#8 weeks in summer; 16 otherwise
months=()
weekOne=21	#date (Monday)
semBreak=14	#Week to move for sem break

incrementWeek() {
	weekOne=$((weekOne+7))
	monthlen="$(cal -m 1 $j $year | tail -2 | grep -E -o "[0-9]{2}" | tail -1)"
	if [[ $weekOne -gt $monthlen ]]; then
			j=$((j+1))
			weekOne=$((weekOne-monthlen))
	fi
}

for i in `seq $m1 $m2`; do
		month=$(cal -m 1 $i $year | head -1 | sed 's/    //g')
		months+=( $month )
done

for i in `seq $m1 $m2`; do
		month=$(cal -m 1 $i $year | head -1 | sed 's/    //g')
		months+=( $month )
		cal -m 1 $i $year
done | sed '/^.*202[[:digit:]].*$/d;s/.....$//g;/              /d;s/^/| /g;s/[[:alnum:]] /&| /g;s/   /&|/g;s/|   |/|    |/g;s/|   |/|    |/g' \
| while read line; do
		if [ "$(echo $line | grep -E '^\| Mo' | wc -l)" == "1" ]; then
				if [ "$index" != "0" ]; then echo; fi
				echo "${months[$index]} ${months[$((index+1))]}"
				index=$((index+2))
				echo "$line"
				for i in `seq 1 5`; do echo -n "|----"; done
				echo "|"
		else
				echo "$line"
		fi
done > cal.md

sed -i 's/Mo/Monday\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/g;s/Tu/Tuesday\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/g;s/We/Wednesday\&nbsp\;\&nbsp\;\&nbsp\;/g;s/Th/Thursday\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/g;s/Fr/Friday\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/g' cal.md

j=$m1
for i in `seq 1 $semLen`; do
		if [[ $i -lt $semBreak ]]; then
			sed -i "0,/^|[[:space:]]\{1,2\}$weekOne |/ {s//| $weekOne   Week $i |/}" cal.md
			incrementWeek
		else
			incrementWeek
			sed -i "0,/^|[[:space:]]\{1,2\}$weekOne |/ {s//| $weekOne   Week $i |/}" cal.md
		fi
done

cat cal.md | while read line; do
	if [ "$(echo $line | grep -E "$year" | wc -l)" -eq "1" ]; then
			sed -i "s/$line/&\n/g" cal.md
	fi
done

cat cal.md

pandoc cal.md -f gfm -o Calendar.docx

