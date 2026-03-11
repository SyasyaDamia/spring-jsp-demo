pipeline {
    agent any

    tools {
        maven 'Maven-4.0.3' // Make sure this matches the name in Global Tool Configuration
    }
    
    environment {
        DEPLOY_PATH = "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\spring-jsp-demo\\deploy"
        WAR_NAME = 'spring-jsp-demo-0.0.1-SNAPSHOT.war'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SyasyaDamia/spring-jsp-demo.git'
            }
        }

        stage('Build') {
            steps {
                bat 'mvn clean install'
            }
        }

        stage('Deploy Application') {
            steps {
                bat '''
                copy /Y "target\\%WAR_NAME%" "%DEPLOY_PATH%\\%WAR_NAME%"
                echo Deployment completed
                '''
            }
        }
    }
}