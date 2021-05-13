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
    if [[ $1 == "BYTES" || $1 == "PACKETS" ]]; then
        read -p $'\nPlease enter your search-term: ' searchTerm
        echo $searchTerm
    else
        read -p $'\nPlease enter your search-term: ' searchTerm
        searchTerm="/$searchTerm/"
        echo $searchTerm
    fi
}

choosePath() {
    local dirChoice
    local path
    while true; do
        read -p $'Would you like to export results to a custom directory?\n 1 for YES\n 2 for NO\n ' dirChoice
        if [[ $dirChoice == 1 ]]; then
            read -p $'Enter a path to save results to: \n' path
            [ -d $path ] || mkdir -p $path
            break
        elif [[ $dirChoice == 2 ]]; then
            path='.'
            break
        else
            echo $'Please input either a 1 or a 2.\n' > /dev/stderr
        fi
    done
    echo $path
}

criteriaNum() {
    local number=0
    case $1 in
        "PROTOCOL") number=3;;
        "SRC_IP") number=4;;
        "SRC_PORT") number=5;;
        "DEST_IP") number=6;;
        "DEST_PORT") number=7;;
        "PACKETS") number=8;;
        "BYTES") number=9;;
    esac
    echo $number
}

criteriaChoice() {
    local choice
    while true; do
        read -p $'\nPlease input your critera choice:\nThe criteria are:\nSRC_IP       SRC_PORT       DEST_IP       DEST_PORT\nPROTOCOL     PACKETS        BYTES\n' choice 
        if [[ "$choice" =~ ^(SRC_IP|SRC_PORT|DEST_IP|DEST_PORT|PROTOCOL|PACKETS|BYTES)$ ]]; then
            echo "$choice has been chosen." > /dev/stderr
            break
        else
            echo 'Please ensure choice is valid (make sure to write everything in capital letters!)' > /dev/stderr
        fi
    done
    echo $choice
}

exitFunc() {
    while true; do
        read p $'\n Would you like to perform another search?\n 1 for YES\n 2 for NO\n ' searchAgain
        if [[ searchAgain == 1 ]]; then
            return 1
            break
        elif [[ searchAgain == 2 ]]; then
            echo 'Thank you for using the access log searcher.' > /dev/stderr
            return 0
            break
        else
            echo $'Please enter a valid input.' > /dev/stderr
        fi
    done
}
    

while true; do
    packetTotal=0
    byteTotal=0

    echo $'Welcome to the access log searcher.\n'
    read -p $'\nPlease select the amount of criteria you wish to search: \n (1) \n (2) \n (3)\n' selection
    read -p 'Please enter "1" to search within a certain file, or "2" to search all files.' fileAmount

    while true; do
        if [[ $fileAmount == 1 ]]; then
            while true; do
                read -p 'Please enter the name of the file you wish to search in: ' filename
                if [ -f "$filename" ]; then
                    echo "$filename selected."
                    grep 'suspicious' $filename > temp.csv
                    break
                else
                    echo $'File not found. \nPlease enter filename correctly (search is case-sensitive, and make sure to include ".csv" at the end).'
                fi
            done
            break
        elif [[ $fileAmount == 2 ]]; then
            grep -E 'suspicious' serv_acc_log_*.csv > temp.csv
            break
        else
            echo $'\nPlease use a valid input (1 or 2).'
        fi
    done



    if [[ $selection == 1 ]]; then

        #while true; do
        #    read -p $'\nPlease input your critera choice:\nThe criteria are:\nSRC_IP       SRC_PORT       DEST_IP       DEST_PORT\nPROTOCOL     PACKETS        BYTES' choice 
        #    if criteriaCheck $choice ; then
        #        echo 'Please ensure choice is valid (make sure to write everything in capital letters!)'
        #    else
        #        echo "$choice has been chosen."
        #        break
        #    fi
        #done

        

        read -p $'\nPlease enter your search-term: ' searchTerm
            awk 'BEGIN {IGNORECASE=0; FS=","; totalPackets=0; totalBytes=0; printf "START OF SEARCH\nPROTOCOL   SRC_IP          SRC_PORT   DEST_IP       DEST_PORT   PACKETS    BYTES\n\n"}
        NR>1 { if ($'"$columnNo1 $op1 $search1"')
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



    elif [[ $selection == 2 ]]; then
        let index=1
        while [[ $index < 3 ]]; do
            criteria=$(criteriaChoice)

            if [[ $criteria == "BYTES" || $criteria == "PACKETS" ]]; then
                if [[ $criteria == "BYTES" ]]; then
                    byteTotal=1
                elif [[ $criteria == "PACKET" ]]; then
                    packetTotal=1
                fi

                opChoice=$(operatorReal)
                declare op$index=$opChoice
            else
                declare op$index="~"
            fi
            
            declare search$index=$(searchTermFunc $category)
            declare columnNo$index=$(criteriaNum $criteria)
            ((index++))
        done

        path=$(choosePath) 

        awk 'BEGIN {IGNORECASE=0; FS=","; totalPackets=0; totalBytes=0; printf "START OF SEARCH\nPROTOCOL   SRC_IP          SRC_PORT   DEST_IP       DEST_PORT   PACKETS    BYTES"}
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
        echo "Successfully exported to $path/results.csv"

        if $(exitFunc) ; then
            break
        else
            echo $'Restarting...\n\n\n'
        fi
    fi

done


exit 0