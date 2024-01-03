# Cloud Software Initial Signup
**JIRA:** [OPS-261](https://www.google.com/) <br />
**CREATED BY:** AALEEM SIDDIQUI

## DESCRIPTION
Often times the initial welcome e-mail for a user to login to their instance is lost, this pipeline generates that link with a new token. 

## LINKS
[How to use the Automation](https://www.google.com/) <br />
[Backend Documentation](https://www.google.com/)

## USAGE
1. Navigate to the 'Run pipeline' page within this repository.
   - Build (on the left-hand side toolbar) > Pipelines > Run Pipeline
1. You will now enter the variables required for this pipeline. 
   - **CLIENT_EMAIL:** Provide the e-mail address of the user.
   - **INSTANCE:** Provide the name of the Tenant. 
   - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
1. Once you've entered in these variables, you can hit the 'Run pipeline' button underneath the variables.
   - The pipeline should now trigger and you will see one stage: **generateInvitationLink**
   - You may click on this stage to see it's status. If the script is successful, it will provide the link at the end that you will be able to send to the client.