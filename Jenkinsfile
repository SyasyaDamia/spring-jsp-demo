pipeline {
    agent any
    
    tools {
        maven 'Maven-4.0.3'  // Make sure this matches your Jenkins Maven name
        jdk 'JDK-17'         // Make sure this matches your Jenkins JDK name
    }
    
    environment {
        APP_NAME = 'spring-jsp-demo'
        PORT = '9090'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/SyasyaDamia/spring-jsp-demo.git'
            }
        }
        
        stage('Build') {
            steps {
                bat 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                bat 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                bat 'mvn package -DskipTests'
            }
        }
        
        stage('Deploy') {
            steps {
                bat '''
                    @echo off
                    echo Stopping existing application on port %PORT%...
                    
                    :: Find and kill process using port 9090
                    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090') do (
                        echo Killing process with PID: %%a
                        taskkill /F /PID %%a 2>nul || exit /b 0
                    )
                    
                    echo Starting application...
                    
                    :: Get the JAR file name
                    for %%f in (target\\*.jar) do set JAR_FILE=%%f
                    
                    echo Using JAR: %JAR_FILE%
                    
                    :: Start the application
                    start /B java -jar %JAR_FILE% --server.port=%PORT%
                    
                    echo Waiting for application to start...
                    timeout /t 20 /nobreak
                    
                    :: Test if application is running
                    curl -f http://localhost:%PORT%/ || exit /b 1
                    
                    echo Application started successfully on port %PORT%!
                '''
            }
        }
    }
    
    post {
        success {
            echo '========================================'
            echo '✅ PIPELINE COMPLETED SUCCESSFULLY!'
            echo '========================================'
            echo "Application is running on port ${PORT}"
            echo "Access it at: http://localhost:${PORT}"
            echo '========================================'
        }
        failure {
            echo '========================================'
            echo '❌ PIPELINE FAILED!'
            echo '========================================'
            echo 'Check the console output for errors'
            echo '========================================'
        }
    }
}