pipeline {
    agent any
    
    tools {
        maven 'Maven-4.0.3'  // Configure this in Jenkins
        jdk 'JDK-17'         // Configure this in Jenkins
    }
    
    environment {
        // Application properties
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
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                    # Stop existing application if running
                    pkill -f ${APP_NAME} || true
                    
                    # Run the application
                    nohup java -jar target/*.jar --server.port=${PORT} > app.log 2>&1 &
                    
                    # Wait for application to start
                    sleep 20
                    
                    # Check if application is running
                    curl -f http://localhost:${PORT}/ || exit 1
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Application is running on port ${PORT}"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}