/*
FILENAME: WAF_IP_Sets_Automation.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: Scheduled to check pull request merges to a bitbucket repo that hosts Ip sets for the WAF in AWS. Retrieves new iP set from bitbucket, and pushes it to AWS. Triggers upon merge.
*/
echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"


pipeline {

	agent {label 'generic'}
	environment {
		// if the terraform version becomes outdated, release link can be updated with a new version https://releases.hashicorp.com/terraform/
		TF_V = "https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip"
		AWS_ACCOUNT_NUMBER = "12345678910" //AWS Account # that hosts the WAF
		PROFILE = "WAF" //provider
	}

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 12, unit: 'HOURS')
		timestamps()
	}

	stages {

/////////////////////////////////////////////// STAGE 1 /////////////////////////////////////////////

		stage('INSTALL TERRAFORM') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 1 *INSTALL TERRAFORM*\n\n'

					sh '''
						set +x
						wget ${TF_V}
						unzip terraform_*
						sudo mv terraform /usr/local/bin/
						which terraform
						set -x
					'''

					echo '\n\nTERRAFORM VERSION:'
					sh 'terraform --version'

				}
			}
		}



/////////////////////////////////////////////// STAGE 2 /////////////////////////////////////////////

		stage('APPLY TERRAFORM') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 2 *APPLY TERRAFORM*\n\n'

					sh '''
						set +x
						cd ~
						mkdir -p .aws
						cd workspace/WAF_IP_Sets_Automation/AWS-WAF_IP_Sets/TERRAFORM
						ls -al
	   					creds=$(aws sts assume-role --role-arn=arn:aws:iam::${AWS_ACCOUNT_NUMBER}:role/WAF-IP-Sets-Automation-Role --role-session-name=block_iP_automation)
	   					sudo echo "[${PROFILE}]" > ~/.aws/credentials
	   					sudo echo "aws_access_key_id=$(echo $creds | cut -d '"' -f 6 )" >> ~/.aws/credentials
	   					sudo echo "aws_secret_access_key=$(echo $creds | cut -d '"' -f 10 )" >> ~/.aws/credentials
	   					sudo echo "aws_session_token=$(echo $creds | cut -d '"' -f 14 )" >> ~/.aws/credentials
   						set -x
   						echo -e "\n\n\n\n -- APPLYING TERRAFORM -- \n\n"
   						terraform init
   						terraform apply -auto-approve 
					'''

				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'Whether you like it or not, the job has finished.'
			cleanWs()
		}
	}
}