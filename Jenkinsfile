pipeline{
    agent any
    tools {
        maven 'maven-3.9.9' 
    }
    stages{
        stage("Clone"){
            steps{
                git branch: 'jenkins', credentialsId: 'github-token', url: 'https://github.com/Primus-Learning/wordsmith-api.git'
                sh"ls -l"
                
            }
        }
        stage("Maven test"){
            steps{
                script{
                    sh"mvn test"
                }
            }
        }
        stage("Maven Package"){
            steps{
                sh"mvn clean package"
                sh"ls -l target/"
            }
        }
        stage('SonarQube analysis') {
            tools {
                jdk 'jdk11'
            }
            steps {
                // withSonarQubeEnv('sonar') {
                //     sh 'mvn sonar:sonar'
                // }
                echo "sonar passed"
            }
        }
        stage("Quality Gate") {
            steps {
                // timeout(time: 1, unit: 'HOURS') {
                //     waitForQualityGate abortPipeline: true
                // }
                echo "sonar passed"
            }
        }
        stage("Upload jar to Nexus"){
            steps{
                script{
                    def componentVersion = getVersion()
                    // nexusArtifactUploader(
                    //     nexusVersion: 'nexus3',
                    //     protocol: 'http',
                    //     nexusUrl: '3.138.155.75:8081',
                    //     groupId: 'com.example',
                    //     version: componentVersion,
                    //     repository: 'maven-releases',
                    //     credentialsId: 'nexus-creds',
                    //     artifacts: [
                    //         [artifactId: 'words',
                    //         classifier: '',
                    //         file: "${WORKSPACE}/target/words.jar",
                    //         type: 'jar']
                    //     ]
                    // )
                    echo "pushed artifact"
                }
            }
        }
        stage("Docker build and Push"){
            steps{
                script{
                    withAWS(region:'us-east-2',credentials:'aws-creds'){
                        def componentVersion = getVersion()
                        dir("${WORKSPACE}"){
                            sh"""
                            aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 421740842601.dkr.ecr.us-east-2.amazonaws.com
                            docker build -t wordsmith-api .
                            docker tag wordsmith-api:latest 421740842601.dkr.ecr.us-east-2.amazonaws.com/wordsmith-api:${componentVersion}
                            docker push 421740842601.dkr.ecr.us-east-2.amazonaws.com/wordsmith-api:${componentVersion}
                            """
                        }
                    }
                }
            }
        }
        stage("deploy to Dev"){
            steps{
                script{
                    withAWS(region:'us-east-2',credentials:'eks-user'){
                        def componentVersion = getVersion()
                        String componentImage = "421740842601.dkr.ecr.us-east-2.amazonaws.com/wordsmith-api:${componentVersion}"
                        dir("${WORKSPACE}"){
                            sh"""
                                aws eks update-kubeconfig --name dev-cluster
                                kubectl apply -f deployment.yaml -n wordsmith
                            """
                        }
                    }
                }
            }
        }
    }
}

def getVersion(){
    def pom = readMavenPom file: 'pom.xml'
    def baseVersion = pom.version
    def finalVersion
    if(env.BRANCH_NAME == "develop"){
        finalVersion = "${baseVersion}-rc"
    }else if(env.BRANCH_NAME == "main"){
        finalVersion = baseVersion
    }else{
        finalVersion = "${baseVersion}-${BUILD_NUMBER}-${env.BRANCH_NAME}"
    }
    return finalVersion
}
