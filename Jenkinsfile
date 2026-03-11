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
                    
                    :: Create a startup script instead of using start /B
                    echo Creating startup script...
                    (
                        echo @echo off
                        echo cd /d %CD%
                        echo java -jar %WAR_FILE% --server.port=%PORT% ^> app.log 2^>^&1
                    ) > start_app.bat
                    
                    echo Starting application from WAR...
                    
                    :: Use PowerShell to start the process in background
                    powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c start_app.bat' -WindowStyle Hidden -PassThru"
                    
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
                        echo Application log:
                        echo ========================================
                        type app.log
                        exit 1
                    ) else (
                        echo ✅ Application is running on port %PORT%!
                    )
                    
                    :: Test the application
                    echo ========================================
                    echo Testing application endpoints...
                    echo ========================================
                    
                    timeout /t 5 /nobreak
                    
                    powershell -Command "$attempts=0; while($attempts -lt 3) { try { $response = Invoke-WebRequest -Uri http://localhost:%PORT%/ -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ Home page is up!'; exit 0 } } catch { Write-Host 'Attempt ' + ($attempts+1) + ' failed, retrying...'; $attempts++; Start-Sleep -Seconds 3 } } Write-Host '❌ Application failed to respond'; exit 1"
                    
                    echo ========================================
                    echo ✅ Deployment completed!
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