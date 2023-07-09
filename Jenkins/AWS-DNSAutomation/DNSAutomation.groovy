/*
FILENAME: DNSAutomation.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: Scheduled to check pull request merges to a bitbucket repo that hosts DNS records in terraform managed zones. Retrieves added/removed/modified records from bitbucket, and pushes changes to AWS. Triggers upon merge.
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"
@Library('generic_automation_libraries') _


pipeline {

	agent {label 'generic_Agent_Label'}
	environment {
		// if the terraform version becomes outdated, release link can be updated with a new version https://releases.hashicorp.com/terraform/
		TF_V = "https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip"
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

		stage('GET CHANGES FROM PULL REQUEST') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 2 *GET CHANGES FROM PULL REQUEST*\n\n'

					sh '''
						set +x
						diff1=$(git show --merges -1 | grep 'Merge:' | cut -d ' ' -f 2 )
						diff2=$(git show --merges -1 | grep 'Merge:' | cut -d ' ' -f 3 )
						modified_records=$(git diff --name-only $diff1..$diff2 | grep 'records.tf')
						echo $modified_records > modified_records.txt
						sed -i 's/records.tf//g' modified_records.txt
						cat modified_records.txt | tr ' ' '\n' > tf_paths.txt
						set -x
					'''

					echo '\n\nTERRAFORM WILL BE APPLIED TO THE FOLLOWING DIRECTORIES:'
					sh 'cat tf_paths.txt'
				}
			}
		}

/////////////////////////////////////////////// STAGE 3 /////////////////////////////////////////////

		stage('APPLY TERRAFORM') {
			steps {
				script {
					echo '\n\nCOMMENCING STAGE 3 *APPLY TERRAFORM*\n\n'

					sh '''
						set +x
						cd ~
						mkdir -p .aws
						cd workspace/DNSAutomation
						chmod +x DNSAutomation/apply_tf.sh
						set -x
						./DNSAutomation/apply_tf.sh
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		success {
			echo 'victory mi amigo'
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		failure {
			echo 'Job failed... that sucks.'
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
		aborted {
			echo '... why would you do that'
		}
	}
}