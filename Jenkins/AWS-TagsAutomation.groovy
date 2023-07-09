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
    }

	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 3, unit: 'HOURS')
		timestamps()
	}

	stages {
/////////////////////////////////////////////// STAGE 1 /////////////////////////////////////////////
		stage('PUSH TO AWS') {
			steps {
				script {
					//cloning repo to jenkins node
					checkout([$class: 'Git',
                    	branches: [[name: "BRANCH"]],
                    	doGenerateSubmoduleConfigurations: false,
                    	extensions: [[$class: 'WipeWorkspace']],
                    	submoduleCfg: [],
                    	userRemoteConfigs: [[credentialsId: 'Stored_Jenkins_Credentials',
                                        	name: 'origin',
                                        	url: "https://admin@bit.generic.com/repo/${REPO}.git"]]
        			])

        			// making workspace dir, copying relavent jsons from repo, removing extra space at the end of files since they are considering windows files
        			sh 'mkdir TagServiceControlPolicy'
        			sh 'cp -av repo/* TagServiceControlPolicy/'
        			sh 'sed -i -e "s/\r//g" TagServiceControlPolicy/*'

        			// creating new policy file 
        			sh 'touch TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'echo "{\n   \\"tags\\": {" > TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'echo "$(cat TagServiceControlPolicy/*environment.json),\n$(cat TagServiceControlPolicy/*_services.json)," >> TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'echo "$(cat TagServiceControlPolicy/*applications.json),\n$(cat TagServiceControlPolicy/*_services.json)," >> TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'echo "$(cat TagServiceControlPolicy/*components.json),\n$(cat TagServiceControlPolicy/*_services.json)," >> TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'echo "$(cat TagServiceControlPolicy/*microservices.json),\n$(cat TagServiceControlPolicy/*_services.json)\n  }\n}" >> TagServiceControlPolicy/EnforceTag-genericCompanyName.json'
        			sh 'cat TagServiceControlPolicy/EnforceTag-genericCompanyName.json'

                    // push newly created policy to AWS
        			sh '''
        				set +x
        				creds=$(aws sts assume-role --role-arn=arn:aws:iam::account#:role/tag-Role --role-session-name=genericRoleName); \
                   		export AWS_ACCESS_KEY_ID=$(echo $creds | cut -d '"' -f 6 ); \
                    	export AWS_SECRET_ACCESS_KEY=$(echo $creds | cut -d '"' -f 10 ); \
                    	export AWS_SESSION_TOKEN=$(echo $creds | cut -d '"' -f 14 );
                    	set -x
                    	aws organizations update-policy --policy-id=genericPolicyID --content="$(cat TagServiceControlPolicy/EnforceTag-genericCompanyName.json)"
                    	exit
                    EOF
                    '''  			
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
