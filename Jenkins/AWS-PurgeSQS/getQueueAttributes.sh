#/bin/bash

cat purgeSQS/queues.txt | while read line
do
   echo 'QUEUE:' "$line" >> purgeSQS/output.txt
   aws sqs get-queue-attributes --queue-url "$line" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesDelayed >> purgeSQS/output.txt
done
