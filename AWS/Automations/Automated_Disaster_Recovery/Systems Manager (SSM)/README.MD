 ## -- Automated Disaster Recovery -- 

 This systems manager document fails over a service in AWS from us-east-1 to us-west-2 or vice versa. This document is written for multiple environments, but for simplification, only one environent is integrated. The full document template is provided in the "QA_DISASTER_RECOVERY.YAML" file.

 The individual python scripts that run in steps are within the "Automation Steps (Python)" folder. Note that there is no Step 13 within this folder, Step 13 is a step that requires an approval in order to proceed with the post-actions of the failover. This step can be seen in teh full document template. 