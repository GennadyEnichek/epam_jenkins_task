pipeline {

    agent any
   
    stages{
        stage("build"){
            steps{
                echo "Building the application"
            }
        }

        stage("test"){
            steps{
                echo "Testing the application"
            }
        }

        stage("docker build"){
            steps{
                echo "Create the image"
            }
        }

        stage("deploy"){
            steps{
                echo "Deploy the application"
            }
        }
    }
}