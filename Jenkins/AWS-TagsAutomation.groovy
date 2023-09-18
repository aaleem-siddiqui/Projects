/*
FILENAME: AWS-TagsAutomation.groovy
CREATOR: AALEEM SIDDIQUI
DESCRIPTION: Scheduled to check pull request merges to a bitbucket repo that hosts service control policies for tags in AWS. Retrieves new policy from bitbucket, and pushes it to AWS. Triggers upon merge.
*/

echo "\n                 ,~\n                 |\\\n                /| \\\n        ~^~ ^~ /_|__\\~^~ ~^~\n       ~^~^ ~ '======' ~^ ~^~\n"

import groovy.json.*

pipeline {

	agent {label 'generic_Agent_Label'}

	environment {
        REPO = "[REPO_NAME_HERE]"
        BRANCH = "any"
        SERVICE123_POLICYID = "p-123"
        SERVICE456_POLICYID = "p-456"
        SERVICE789_POLICYID = "p-789"
        CREATE_POLICIES_ONLY = "no" // change to "yes" if testing policy creation
    }

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 3, unit: 'HOURS')
		timestamps()
	}

	stages {
/////////////////////////////////////////////// STAGE 1 /////////////////////////////////////////////
		stage('CLONE PROP FILES FROM BITBUCKET') {
			steps {
				script {
					//cloning tags repo to jenkins node
					checkout([$class: 'Git',
                    	branches: [[name: "${BRANCH}"]],
                    	doGenerateSubmoduleConfigurations: false,
                    	extensions: [[$class: 'WipeWorkspace']],
                    	submoduleCfg: [],
                    	userRemoteConfigs: [[credentialsId: 'Stored_Jenkins_Credentials',
                                        	name: 'origin',
                                        	url: "https://admin@bit.generic.com/repo/${REPO}.git"]]
        			])

        			// making workspace dir
        			sh 'mkdir SERVICE123-TaggingPolicy SERVICE456-TaggingPolicy SERVICE789-TaggingPolicy tagPolicies'

        			// copying relavent jsons from tags repo
        			sh 'cp -av tags/service123/* SERVICE123-TaggingPolicy/'
        			sh 'cp -av tags/service456/* SERVICE456-TaggingPolicy/'
        			sh 'cp -av tags/service789/* SERVICE789-TaggingPolicy/'

        			// removing extra space at the end of files since they are considering windows files
        			sh 'sed -i -e "s/\r//g" SERVICE123-TaggingPolicy/* SERVICE456-TaggingPolicy/* SERVICE789-TaggingPolicy/*'
		
				}
			}
		}

/////////////////////////////////////////////// STAGE 2 /////////////////////////////////////////////

		stage('CREATE POLICIES') {
			steps {
				script {

					def directoryName = ["SERVICE123-TaggingPolicy","SERVICE456-TaggingPolicy","SERVICE789-TaggingPolicy"]
					def policyName = ["SERVICE123","SERVICE456","SERVICE789"]

					for (int i = 0; i < directoryName.size(); i++) {
						sh( 
							script: "touch tagPolicies/${policyName[i]}.json; \
							echo \"{\n  \\\"tags\\\": {\" > tagPolicies/${policyName[i]}.json; \
							echo \"\$(cat ${directoryName[i]}/*environment.json),\n\$(cat ${directoryName[i]}/*_services.json),\" >> tagPolicies/${policyName[i]}.json; \
							echo \"\$(cat ${directoryName[i]}/*applications.json),\n\$(cat ${directoryName[i]}/*_services.json),\" >> tagPolicies/${policyName[i]}.json; \
							echo \"\$(cat ${directoryName[i]}/*components.json),\n\$(cat ${directoryName[i]}/*_services.json),\" >> tagPolicies/${policyName[i]}.json; \
							echo \"\$(cat ${directoryName[i]}/*microservices.json),\n\$(cat ${directoryName[i]}/*_services.json)\n  }\n}\" >> tagPolicies/${policyName[i]}.json; \
							echo \"\$(cat tagPolicies/${policyName[i]}.json)\" ",
							returnStdout: true
						)
					}

				}
			}
		}

/////////////////////////////////////////////// STAGE 3 /////////////////////////////////////////////

		stage('PUSH TO AWS') {
			steps {
				script {

					if (CREATE_POLICIES_ONLY == 'yes') { // create policies only, they are uploaded to the AWS s3 bucket here: arn:aws:s3:::tag-policies
						sh '''
	        				set +x
	        				creds=$(aws sts assume-role --role-arn=arn:aws:iam::account#:role/tag-Role --role-session-name=checkTagPolicy); \
	                   		export AWS_ACCESS_KEY_ID=$(echo $creds | cut -d '"' -f 6 ); \
	                    	export AWS_SECRET_ACCESS_KEY=$(echo $creds | cut -d '"' -f 10 ); \
	                    	export AWS_SESSION_TOKEN=$(echo $creds | cut -d '"' -f 14 );
	                    	set -x
	                    	ls -al tagPolicies/
	                    	cd tagPolicies/
	                    	aws s3 cp SERVICE123.json s3://tag-policies
	                    	aws s3 cp SERVICE456.json s3://tag-policies
	                    	aws s3 cp SERVICE789.json s3://tag-policies
	                    	exit
	                    EOF
	                    ''' 
					}
					else { // push newly created policy to AWS 
						sh '''
	        				set +x
	        				creds=$(aws sts assume-role --role-arn=arn:aws:iam::account#:role/tag-Role --role-session-name=updateTagPolicy); \
	                   		export AWS_ACCESS_KEY_ID=$(echo $creds | cut -d '"' -f 6 ); \
	                    	export AWS_SECRET_ACCESS_KEY=$(echo $creds | cut -d '"' -f 10 ); \
	                    	export AWS_SESSION_TOKEN=$(echo $creds | cut -d '"' -f 14 );
	                    	set -x
	                    	ls -al tagPolicies/
	                    	aws organizations update-policy --policy-id=${SERVICE123_POLICYID} --content="$(cat tagPolicies/SERVICE123.json)" --description="Last Updated: $(date '+%Y-%m-%d %H-%M-%S')"
	                    	aws organizations update-policy --policy-id=${SERVICE456_POLICYID} --content="$(cat tagPolicies/SERVICE456.json)" --description="Last Updated: $(date '+%Y-%m-%d %H-%M-%S')"
	                    	aws organizations update-policy --policy-id=${SERVICE789_POLICYID} --content="$(cat tagPolicies/SERVICE789.json)" --description="Last Updated: $(date '+%Y-%m-%d %H-%M-%S')"
	                    	exit
	                    EOF
	                    ''' 
					}
				}
			}
		}
	}

/////////////////////////////////////////////// Post Actions /////////////////////////////////////////////
	post {
		always {
			echo 'One way or another, I have finished'
			cleanWs()
		}
	}
}
