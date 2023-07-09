#/bin/bash

cat purgeSQS/queues.txt | while read line
do
   aws sqs purge-queue --queue-url "$line"
done