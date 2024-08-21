pipeline{
    agent any
    tools {
        maven 'maven-3.9.9' 
    }
    stages{
        stage("Clone"){
            steps{
                git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/Primus-Learning/wordsmith-api.git'
                sh"ls -l"
            }
        }
        stage("Maven test"){
            steps{
                sh"mvn test"
            }
        }
        stage("Maven Package"){
            steps{
                sh"mvn clean package"
                sh"ls -l target/"
            }
        }
    }
}
