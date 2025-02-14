pipeline {

    agent any
    
    environment{
    	DOCKER_HUB_REPO = "genadijsjeniceks/"
        IMAGE_TAG = "V1.0"
        REMOTE_MAIN_HOST = "192.168.56.20"
        REMOTE_MAIN_HOST_USER = "vagrant"        
        REMOTE_DEV_HOST = "192.168.56.20"
        REMOTE_DEV_HOST_USER = "vagrant"
        MAIN_PORT = "3000"
        ENV_PORT = "3001"
    }
   
    stages{
        stage("build"){
            steps{
                echo "Building the application"
                nodejs("my-nodejs"){
                    sh'npm install'
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
                        ssh -o StrictHostKeyChecking=no ${REMOTE_MAIN_HOST_USER}@${REMOTE_MAIN_HOST} "docker run -d --expose ${MAIN_PORT} -p ${MAIN_PORT}:3000 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
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
                        ssh -o StrictHostKeyChecking=no ${REMOTE_DEV_HOST_USER}@${REMOTE_DEV_HOST} "docker run -d --expose ${ENV_PORT} -p ${ENV_PORT}:3000 ${DOCKER_HUB_REPO}node${BRANCH_NAME}:${IMAGE_TAG}"
                    '''
                }
            }
        }
    }
}
