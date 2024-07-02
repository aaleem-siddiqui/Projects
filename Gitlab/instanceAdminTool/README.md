# Instance Administration Tool
**JIRA:** [CDOP-411](https://www.atlassian.com/software/jira) <br />

## DESCRIPTION
This pipeline performs multiple operations relating to Instance administration:
- [Deleting a Instance](https://www.atlassian.com/software/confluence)
- [Listing all Instances in a cluster](https://www.atlassian.com/software/confluence)
- [Listing all users within an Instance](https://www.atlassian.com/software/confluence)
- [Creating an Instance](https://www.atlassian.com/software/confluence)

## USAGE
1. Navigate to the 'Run pipeline' page within this repository.
   - Build (on the left-hand side toolbar) > Pipelines > Run Pipeline
1. You will now enter the variables required for your operation:
   - For deleting a Instance:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **ROOT_INSTANCES:** Provide the names of the Instances that you would like to delete. (URL Prefix)
         - _Example: instance1,instance2,etc..._
   - For listing all Instances in a cluster:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
   - For listing all users within a Instance:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **ROOT_INSTANCES:** Provide the name of the Instance that you would like to list all users in.
   - For creating a Instance:
      - **CLUSTER_NAME:** Provide the name of the Kuberneties Cluster.
      - **ROOT_INSTANCES:** Provide the name of the Instance that you would like to create. (URL Prefix)
      - **USER_EMAIL:** Provide the e-mail address tied to the initial admin user. Example: aaleem@gmail.com"
      - **ACTIVATION_ID:** Provide the activation ID of the software LAC. Please remember to fill in the system ID field during the LAC creation
1. Once you've entered in these variables, you can hit the 'Run pipeline' button underneath the variables.
   - The pipeline should now trigger and you will see one stage: **InstanceAdminTool**
   - You may click on this stage to see it's status.
