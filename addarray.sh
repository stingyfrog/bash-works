#!/bin/bash


# Assigning an array of values to the variables
ass1=(12 18 20 10 12 16 15 19 8 11)
ass2=(22 29 30 20 18 24 25 26 29 30)

#Setting count variable to 1 (used in labelling each student number)
count=1

#Starting C-style loop, setting it to iterate 10 times
for ((i=0; i<=9; i++)) do
    echo "Student_$count Result: ${ass1[$i]} ${ass2[$i]}"       #Print the student's results to the terminal
    ((count++))                                                 #Increment count variable by 1
done

exit 0