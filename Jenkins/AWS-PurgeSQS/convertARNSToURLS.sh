#/bin/bash

cat purgeSQS/arns.txt | while read line
do
   echo "$line" | awk '{print"https://sqs."$4".amazonaws.com/"$5"/"$6}' FS=: >> purgeSQS/queues.txt
done
