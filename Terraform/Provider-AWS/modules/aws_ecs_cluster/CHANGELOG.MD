
## **Release notes**

*  **v1.0.0**
    *  module for AWS ECS cluster
    *  initial
*  **v1.1.0**
    *  module updated to use terraform aws provider v4.5
    *  Capacity providers moved under aws_ecs_cluster_capacity_providers resource
*  **v1.1.1**
    *  Removed default capacity provider strategy
*  **v1.2.0**
    *  Added dynamic scaling policies
    *  cleaned up tags
    *  removed protect from scale-in so clusters can properly scale
    *  fixed on-demand capacity var in mixed instance policy
    *  fixed priority of instance type
*  **v1.3.0**
    *  added config to update default EC2 launch template
    *  removal of FW cloud defender installation from userdata
*  **v1.3.1**
    *  added tags for volumes used by instances in ASG