pipeline {

    agent any
   
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
                    docker.build("nodemain:v1.0")
                }
            }
        }

        stage("deploy"){
            steps{
                echo "Deploy the application"
            }
        }
    }
}