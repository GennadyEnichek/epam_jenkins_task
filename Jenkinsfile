pipeline {

    agent any
    
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
                sh"if $BRANCH_NAME == 'dev'; then rm src/logo.svg && mv src/logo1.svg src/logo.svg; fi"
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

        stage("deploy main"){
            when{
                expression{
                    env.BRANCH_NAME == "main"
                }
            }
            steps{
                echo "Deploy application to main environment"
                sshagent(credentials: ['my-ssh']){
                    sh '''
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} "docker image pull ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} 'if [[ $(docker ps -q | wc -l) -ne 0 ]]; then docker ps -q | xargs docker container rm -f; fi'                      
                        ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} "docker run -d -p ${MAIN_PORT}:80 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
                        ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} "docker image prune -a -f"
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
                    sh '''
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} "docker image pull ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
                    	ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} 'if [[ $(docker ps -q | wc -l) -ne 0 ]]; then docker ps -q | xargs docker container rm -f; fi'                       
                        ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} "docker run -d -p ${DEV_PORT}:80 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
                        ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} "docker image prune -a -f"
                    '''
                }
            }
        }
    }
}
