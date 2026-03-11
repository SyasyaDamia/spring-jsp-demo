pipeline {
    agent any
    
    tools {
        maven 'Maven-4.0.3'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = 'spring-jsp-demo'
        PORT = '9090'
        WAR_FILE = 'target/spring-jsp-demo-0.0.1-SNAPSHOT.war'
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
        
        stage('Package WAR') {
            steps {
                bat '''
                    echo ========================================
                    echo Packaging WAR file...
                    echo ========================================
                    mvn package -DskipTests
                    
                    echo ========================================
                    echo Checking WAR file...
                    echo ========================================
                    dir target\\*.war
                    
                    if not exist target\\*.war (
                        echo ❌ WAR file not created!
                        exit 1
                    )
                    
                    echo ✅ WAR file created successfully!
                '''
            }
        }
        
        stage('Deploy WAR') {
            steps {
                bat '''
                    @echo off
                    echo ========================================
                    echo Deploying WAR application...
                    echo ========================================
                    
                    :: Kill any existing Java process on port 9090
                    echo Stopping existing application...
                    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090 ^| findstr LISTENING') do (
                        echo Killing PID: %%a
                        taskkill /F /PID %%a 2>nul
                    )
                    
                    :: Get WAR file name
                    for %%f in (target\\*.war) do set WAR_FILE=%%f
                    echo Using WAR: %WAR_FILE%
                    
                    :: Run the WAR file (Spring Boot executable WAR)
                    echo Starting application from WAR...
                    start /B java -jar %WAR_FILE% --server.port=%PORT% > app.log 2>&1
                    
                    echo Waiting for application to start...
                    timeout /t 20 /nobreak
                    
                    :: Check if application is running
                    echo ========================================
                    echo Checking application status...
                    echo ========================================
                    
                    netstat -ano | findstr :9090 | findstr LISTENING
                    
                    if errorlevel 1 (
                        echo ❌ Application failed to start!
                        echo ========================================
                        echo Last 20 lines of log:
                        echo ========================================
                        powershell -Command "Get-Content app.log -Tail 20"
                        exit 1
                    ) else (
                        echo ✅ Application is running on port %PORT%!
                    )
                    
                    :: Test the application
                    echo ========================================
                    echo Testing application endpoints...
                    echo ========================================
                    
                    powershell -Command "try { $response = Invoke-WebRequest -Uri http://localhost:%PORT%/ -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ Home page is up!' } else { Write-Host '❌ Home page returned ' + $response.StatusCode } } catch { Write-Host '❌ Home page failed: ' + $_.Exception.Message }"
                    
                    powershell -Command "try { $response = Invoke-WebRequest -Uri http://localhost:%PORT%/health -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ Health check is up!' } else { Write-Host '❌ Health check returned ' + $response.StatusCode } } catch { Write-Host '❌ Health check failed: ' + $_.Exception.Message }"
                    
                    echo ========================================
                    echo ✅ Deployment completed!
                    echo ========================================
                    echo Access your application at: http://localhost:%PORT%/
                    echo ========================================
                '''
            }
        }
        
        stage('Verify WAR Contents') {
            steps {
                bat '''
                    echo ========================================
                    echo Verifying WAR file contents...
                    echo ========================================
                    
                    :: Create temp directory for inspection
                    mkdir war_temp 2>nul
                    cd war_temp
                    
                    :: Extract WAR file (if jar command available)
                    jar xf ..\\target\\*.war 2>nul || echo "jar command not available, skipping extraction"
                    
                    echo Checking for JSP files...
                    dir /s *.jsp 2>nul || echo "No JSP files found in WAR"
                    
                    cd ..
                    rmdir /s /q war_temp 2>nul
                '''
            }
        }
    }
    
    post {
        success {
            echo '========================================'
            echo '✅ WAR PIPELINE COMPLETED SUCCESSFULLY!'
            echo '========================================'
            echo "WAR file: target/spring-jsp-demo.war"
            echo "Application: http://localhost:${PORT}/"
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