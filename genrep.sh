#!/bin/bash

#grep returns 5 lines after the term "Attack"
#sed removes all unwanted data (e.g. html coding such as <td>)
#sed then removes all whitespace
#awk prints the column headers, then adds all the values of each month together 
#it then formats the sum of the values to correspond with each criteria

grep -w -A 5 'Attack' attacks.html | sed 's/<[^>]\+>/ /g; s/^ *//g; s/[[:space:]]*$//' | awk 'BEGIN {printf "Attack"; printf "               Instances(Q3) \n"}
    NR>1{sum=($2+$3+$4); printf "%-20s %-20s \n", $1, sum }'

exit 0