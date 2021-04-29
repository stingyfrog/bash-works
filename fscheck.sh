#!/bin/bash

#Start of function
getprop() {         
    wordCount=$(wc -w $1 | cut -d " " -f1)                          #Returns word count of the file
    dateTime=$(stat -c %y $1 | cut -d"." -f1)                       #Returns the date and time the file was last modified
    fileSize=$(ls -l --block-size=K| grep $1 | grep -o '[0-9]K')    #Returns the file size of the file in kilobytes

    echo "The file $1 contains $wordCount words and is $fileSize in size and was last modified $dateTime"   #Prints message with data of the file to the terminal
}
#End of function

read -p "Enter filename: " filename     #Prompts user to enter the filename to be analysed
getprop $filename                       #Calls function and passes filename to it

exit 0he