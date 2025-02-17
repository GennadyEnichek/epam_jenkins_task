pipeline {

    agent{
        label "default"
    }
    
    environment{
    	DOCKER_HUB_REPO = "genadijsjeniceks/"
        IMAGE_TAG = "v2.0.0"
        REMOTE_MAIN_HOST = "192.168.56.20"
        REMOTE_MAIN_HOST_USER = "vagrant"        
        REMOTE_DEV_HOST = "192.168.56.20"
        REMOTE_DEV_HOST_USER = "vagrant"
        MAIN_PORT = "3000"
        DEV_PORT = "3001"
    }
   
    stages{
        stage("build"){
            steps{
                echo "Building the application"
                sh '''
                    if [[ $BRANCH_NAME == "dev" ]]
                        then rm -f src/logo.svg && mv src/logo1.svg src/logo.svg
                    fi
                '''
                nodejs("my-nodejs"){
                    sh'npm ci --cache /var/jenkins_home/.npm --prefer-offline'
                    sh'npm run build'
                    sh'ls -al'
                }
            }
        }

        stage("test"){
            steps{
                echo "Testing the application"
                nodejs("my-nodejs"){
                    sh'npm test'
                }
            }
        }
        
        stage("dockerfile check"){
            steps{
            	echo "Check Dockerfile with hadolint"
            	sh'''
            	    if ./hadolint -- version
            	        then ./hadolint Dockerfile
		        else curl -o hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
		    	chmod +x hadolint
		    	./hadolint Dockerfile
            	    fi
            	'''
            }
        }

        stage("docker build"){
            steps{
                echo "Create the image"
                script{
                    docker.build("${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}")
                    docker.withRegistry("https://registry.hub.docker.com", "docker-hab-cred"){
                    	docker.image("${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}").push()
                    }
                }
                sh'docker images'
            }
        }
        
        stage("vulnerability check"){
            agent{
                label "agent1"
            }
            steps{
                echo "Docker image vulnerability check"
                sh"trivy image --exit-code 0 --severity HIGH,MEDIUM,LOW --no-progress ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
            }
        }

        stage("deploy main"){
            when{
                expression{
                    env.BRANCH_NAME == "main"
                }
            }
            steps{
                echo "Deploy application to main environment"
                sshagent(credentials: ['my-ssh']){
                    sh '''#!/bin/bash
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} \\
                    	"docker image pull ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG} && \\
                    	bash -c 'if [[ $(docker ps -q -a | wc -l) -ne 0 ]]; then docker ps -a -q | xargs docker container rm -f; fi' && \\                     
                        docker run -d -p ${MAIN_PORT}:80 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG} && \\
                        docker image prune -a -f"
                    '''
                }
            }
        }
        
        stage("deploy dev"){
            when{
                expression{
                    env.BRANCH_NAME == "dev"
                }
            }
            steps{
                echo "Deploy application to dev environment"
                sshagent(credentials: ['my-ssh']){
                    sh '''#!/bin/bash
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} \\
                    	"docker image pull ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG} && \\
                    	bash -c 'if [[ $(docker ps -a -q | wc -l) -ne 0 ]]; then docker ps -a -q | xargs docker container rm -f; fi' && \\                       
                        docker run -d -p ${DEV_PORT}:80 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG} && \\
                        docker image prune -a -f"
                    '''
                }
            }
        }
    }
}
