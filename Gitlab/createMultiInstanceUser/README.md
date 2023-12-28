# Multi Instance User Creation
**JIRA:** [OPS-284](https://www.google.com/) <br />
**CREATED BY:** AALEEM SIDDIQUI

## DESCRIPTION
This pipeline converts a normal user to a multi-Instance user as well as adding new Instances to an already multi-Instance user.

## LINKS
[How to use the Automation](https://www.google.com/) <br />
[Backend Documentation](https://www.google.com/)

## USAGE
*YOU WILL BE REQUIRED TO ENTER THE FULL LIST OF INSTANCE NAMES THAT THE USER IS ASSOCIATED WITH BEFORE RUNNING THE PIPELINE. IF YOU ARE MISSING A INSTANCE NAME THAT THE USER CURRENTLY HAS ACCESS TO, THEY WILL LOSE THAT ACCESS DURING PATCHING!* <br />

1. Navigate to the 'Run pipeline' page within this repository.
   - Build (on the left-hand side toolbar) > Pipelines > Run Pipeline
1. You will now enter the variables required for this pipeline. 
   - **EXISTING_INSTANCES:** Provide the names of the existing Instances that the user is associated with.
   - **NEW_INSTANCES:** Provide the name of the new Instance that you would like to add this user to. 
   - **USER_EMAIL:** Provide the users e-mail.
   - **GROUP_ASSIGNMENT:** Provide the level of permissions that you would like to give the user in the new Instance.
   - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
1. Once you've entered in these variables, you can hit the 'Run pipeline' button underneath the variables.
   - The pipeline should now trigger and you will see one stage: **createMultiInstanceUser**
   - You may click on this stage to see it's status.
