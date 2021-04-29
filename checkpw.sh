#!/bin/bash

#Line 9: NR>1 removes first record from output, then if statement checks if the field containing the password has
#        8 or more characters AND contains a number AND contains a capital letter
#Line 10: Success message is printed if password contains all criteria
#Line 12: Failure message is printed if passwords does not contain all criteria
#Line 13: Data is read from the "usrpwords.txt" file

awk 'NR>1 {if ((length($2)>=8) && ($2~/[0-9]/) && ($2~/[A-Z]/))
                {print $2 " - meets password strength requirements"}
        else1
                {print $2 " - does NOT meet password strength requirements"}
        }' usrpwords.txt


exit 0