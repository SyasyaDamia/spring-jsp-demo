pipeline {
    agent any

    tools {
        maven 'Maven-4.0.3' 
    }
    
    environment {
        DEPLOY_PATH = "C:\\springbootprojects\\spring-jsp-demo\\target"
        WAR_NAME = 'jenkinsDemo.war'
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
		        :: First, check if WAR exists in Jenkins workspace
		        if exist "target\\%WAR_NAME%" (
		            copy /Y "target\\%WAR_NAME%" "C:\\springbootprojects\\spring-jsp-demo\\target\\%WAR_NAME%"
		            echo Copied from Jenkins workspace to local project
		        ) else (
		            echo WAR not found in Jenkins workspace!
		            echo Please build the project first in Jenkins
		            dir target\\
		            exit /b 1
		        )
		        echo Deployment completed
		        '''
		    }
		}
    }
}