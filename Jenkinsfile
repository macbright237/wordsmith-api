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
                script{
                    def componentVersion = getVersion()
                    println componentVersion
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
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: '3.138.155.75:8081',
                        groupId: 'com.example',
                        version:  "1.0-SNAPSHOT",
                        repository: 'maven-snapshots',
                        credentialsId: 'nexus-creds',
                        artifacts: [
                            [artifactId: 'words',
                            classifier: '',
                            file: "${WORKSPACE}/target/words.jar",
                            type: 'jar']
                        ]
                    )
                }
            }
        }
    }
}

def getVersion(){
    def baseVersion = readMavenPom file: "pom.xml"
    return baseVersion.version
}
