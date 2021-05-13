#!/bin/bash

operatorReal() {
    local opChoice
    while true; do
        read -p $'\nPlease enter the operator you wish to use.\n=)equal to\n!=)not equal to\n>)greater than\n<)less than\n' opChoice
        if [[ $opChoice == "=" || $opChoice == "!=" || $opChoice == ">" || $opChoice == "<" ]] ; then
            echo "($opChoice) has been selected." > /dev/stderr
            break
        else
            echo $'Invalid input.\nPlease enter an operator.' > /dev/stderr
        fi 
    done
    echo $opChoice
}

searchTermFunc() {
    local searchTerm
    if [[ $1 == "byte" || $1 == "packet" ]]; then
        read -p $'\nPlease enter your search-term: ' searchTerm
        echo $searchTerm
    else
        read -p $'\nPlease enter your search-term: ' searchTerm
        serchTerm="/$searchTerm/"
        echo $searchTerm
    fi
}

testfunc() {
local dirChoice
local path
while true; do
        read -p $'Would you like to export results to a custom directory?\n 1 for YES\n 2 for NO\n' dirChoice
        if [[ $dirChoice == 1 ]]; then
            read -p $'Enter a path to save results to: \n' path
            [ -d $path ] || mkdir -p $path
            break
        elif [[ $dirChoice == 2 ]]; then
            path='.'
            break
        else
            echo $'Please input either a 1 or a 2.\n'
        fi
    done
    echo $path
}

selection=2
filename='serv_acc_log_03042020.csv'
filename2='serv_acc_log_*.csv'
columnNo1=7
columnNo2=9
packetTotal=0
byteTotal=0

if [[ $selection == 2 ]]; then
    let index=1
    while [[ $index < 3 ]]; do
        read -p "please input category: " category
        declare cat$index=$category

        if [[ $category == "byte" || $category == "packet" ]]; then
            if [[ $category == "byte" ]]; then
                byteTotal=1
            elif [[ $category == "packet" ]]; then
                packetTotal=1
                echo "packet total = 1"
            fi

            opChoice=$(operatorReal)
            declare op$index=$opChoice
        else
            declare op$index="~"
        fi
        
        declare search$index=$(searchTermFunc $category)
        ((index++))
    done

    grep 'suspicious' $filename2 > temp.csv 

    path=$(testfunc) 

    awk 'BEGIN {IGNORECASE=0; FS=","; totalPackets=0; totalBytes=0; printf "START OF SEARCH\nPROTOCOL   SRC_IP          SRC_PORT   DEST_IP       DEST_PORT   PACKETS    BYTES\n\n"}
    NR>1 { if (($'"$columnNo1 $op1 $search1"') && ($'"$columnNo2 $op2 $search2"'))
            { 
                totalPackets=totalPackets+$8
                totalBytes=totalBytes+$9
                printf "%-10s %-15s %-10s %-13s %-11s %-10s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }
        }
       END { if ( '"$packetTotal"'==1 )
                { print "Total amount of packets is", totalPackets; printf "\nEND OF SEARCH" } 
             else if ( '"$byteTotal"'==1 )
                { print "Total amount of bytes is", totalBytes; printf "\nEND OF SEARCH" }
             else
                { printf "END OF SEARCH"}
            }
    ' temp.csv > $path/results.csv
fi

exit 0