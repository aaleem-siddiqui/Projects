#!/bin/bash -xe
cat << EOF >> /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER_NAME}
ECS_BACKEND_HOST=

# See Amazon ECS Container Agent Configuration here:
#   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html

# Log level written to the stdout
ECS_LOGLEVEL=info

# Whether to exit for ECS agent updates when they are requested
ECS_UPDATES_ENABLED=false

# Remove Docker container, data, logs for stopped ECS Task
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=3h

# Interval between container graceful stop and force kill
ECS_CONTAINER_STOP_TIMEOUT=30s

# Interval between image cleanup cycles
ECS_IMAGE_CLEANUP_INTERVAL=30m

# Minimum interval between image pull and cleanup
ECS_IMAGE_MINIMUM_CLEANUP_AGE=1h

EOF

# Install Latest Kernel Headers
sudo yum install -y kernel-devel-$(uname -r)

# Install AWS CLI
sudo yum install -y awscli

# Install jq
sudo yum install -y jq

# Install security software
mkdir -p /opt/cb-psc-install
cd /opt/cb-psc-install
curl -L -o ${security_software_SENSOR_KIT} https://s3.amazonaws.com/packages-other/linux/security_software/${security_software_SENSOR_KIT}
tar xzvf ${security_software_SENSOR_KIT}
/opt/cb-psc-install/install.sh ${security_software_CODE}
systemctl enable ssagentd
systemctl start ssagentd

# Install FW Cloud Defender
#FW_USER=$(aws secretsmanager get-secret-value --secret-id ${FW_DEFENDER_SECRET_ARN} --version-stage AWSCURRENT --query SecretString --region ${ECS_REGION} --output text | jq -r .FW_user)
#FW_PASS=$(aws secretsmanager get-secret-value --secret-id ${FW_DEFENDER_SECRET_ARN} --version-stage AWSCURRENT --query SecretString --region ${ECS_REGION} --output text | jq -r .FW_pass)
#FW_TOKEN=$(curl -sSLk -d '{ "username": "'"$${FW_USER}"'", "password": "'"$${FW_PASS}"'" }' -H 'content-type: application/json' "${FW_CONSOLEAUTH}" | awk -F\" '{print $4}')
#curl -sSLk -H "authorization: Bearer $${FW_TOKEN}" -X POST "https://us-east1.cloud.example.com/api/v1/scripts/defender.sh" | bash -s -- -c "us-east1.cloud.example.com" -d "none" --install-host
