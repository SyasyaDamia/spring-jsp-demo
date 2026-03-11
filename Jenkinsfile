pipeline {
    agent any
    
    tools {
        maven 'Maven-4.0.3'
        jdk 'JDK-17'
    }
    
    environment {
        APP_NAME = 'spring-jsp-demo'
        PORT = '9090'
        WORKSPACE_DIR = "${WORKSPACE}"
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
                        exit /b 1
                    )
                    
                    echo ✅ WAR file created successfully!
                '''
            }
        }
        
        stage('Deploy WAR') {
            steps {
                bat '''
                    @echo off
                    setlocal enabledelayedexpansion
                    
                    echo ========================================
                    echo Deploying WAR application (detached)...
                    echo ========================================
                    
                    :: Kill any existing Java process on port 9090
                    echo Stopping existing application...
                    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090 ^| findstr LISTENING') do (
                        echo Killing PID: %%a
                        taskkill /F /PID %%a 2>nul
                    )
                    
                    :: Also kill any Java processes from our app
                    for /f "tokens=2" %%a in ('tasklist ^| findstr java ^| findstr spring-jsp-demo') do (
                        echo Killing Java process: %%a
                        taskkill /F /PID %%a 2>nul
                    )
                    
                    :: Get WAR file name
                    set WAR_FILE=
                    for %%f in (target\\*.war) do set WAR_FILE=%%f
                    
                    if "!WAR_FILE!"=="" (
                        echo ❌ No WAR file found!
                        exit /b 1
                    )
                    
                    echo Using WAR: %WAR_FILE%
                    echo Current directory: %CD%
                    
                    :: Create a standalone VBS launcher that runs independently
                    (
                        echo Set WshShell = CreateObject("WScript.Shell"^)
                        echo cmd = "cmd /c cd /d " ^& WshShell.CurrentDirectory ^& " && java -jar %WAR_FILE% --server.port=%PORT% > app.log 2>&1"
                        echo WshShell.Run cmd, 0, False
                    ) > "%TEMP%\\launch_app_%PORT%.vbs"
                    
                    :: Start the app completely detached
                    echo Starting application from WAR...
                    start /B wscript.exe "%TEMP%\\launch_app_%PORT%.vbs"
                    
                    :: Wait for application to start
                    echo Waiting for application to start...
                    timeout /t 20 /nobreak
                    
                    :: Check if application is running
                    echo ========================================
                    echo Checking application status...
                    echo ========================================
                    
                    set FOUND=
                    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%PORT% ^| findstr LISTENING') do (
                        set FOUND=%%a
                        echo ✅ Application is running on port %PORT%!
                        echo Process ID: %%a
                    )
                    
                    if "!FOUND!"=="" (
                        echo ❌ Application failed to start!
                        echo ========================================
                        echo Application log:
                        echo ========================================
                        if exist app.log (
                            type app.log
                        ) else (
                            echo app.log not found
                        )
                        exit /b 1
                    )
                    
                    :: Test the application
                    echo ========================================
                    echo Testing application endpoints...
                    echo ========================================
                    
                    timeout /t 5 /nobreak
                    
                    powershell -Command "$attempts=0; while($attempts -lt 3) { try { $response = Invoke-WebRequest -Uri http://localhost:%PORT%/ -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ Home page is up!' -ForegroundColor Green; exit 0 } } catch { $attempts++; Write-Host 'Attempt ' + $attempts + ' failed, retrying...'; Start-Sleep -Seconds 3 } } Write-Host '❌ Application failed to respond' -ForegroundColor Red; exit 1"
                    
                    if errorlevel 1 (
                        echo ❌ Application test failed!
                        exit /b 1
                    )
                    
                    :: Test health endpoint
                    powershell -Command "try { $response = Invoke-WebRequest -Uri http://localhost:%PORT%/health -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ Health check is up!' -ForegroundColor Green } else { Write-Host '⚠️ Health check returned ' + $response.StatusCode } } catch { Write-Host '⚠️ Health check not available' }"
                    
                    echo ========================================
                    echo ✅ Deployment completed!
                    echo ========================================
                    echo Application URL: http://localhost:%PORT%/
                    echo Application is running DETACHED from Jenkins
                    echo It will continue running after this job ends
                    echo ========================================
                    
                    :: Clean up temp file but keep app running
                    del "%TEMP%\\launch_app_%PORT%.vbs" 2>nul
                '''
            }
        }
        
        stage('Verify Deployment Persists') {
            steps {
                bat '''
                    @echo off
                    echo ========================================
                    echo Verifying application is still running...
                    echo ========================================
                    
                    timeout /t 5 /nobreak
                    
                    netstat -ano | findstr :9090 | findstr LISTENING
                    if errorlevel 1 (
                        echo ❌ Application stopped after deployment!
                        exit /b 1
                    ) else (
                        echo ✅ Application is still running!
                    )
                    
                    :: Get process details
                    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090 ^| findstr LISTENING') do (
                        echo Process ID: %%a
                        tasklist /fi "PID eq %%a"
                    )
                    
                    echo ========================================
                    echo ✅ Verification complete - app is persistent
                    echo ========================================
                '''
            }
        }
        
        stage('Create Startup Script') {
            steps {
                bat '''
                    @echo off
                    echo ========================================
                    echo Creating manual startup script...
                    echo ========================================
                    
                    :: Get WAR file
                    for %%f in (target\\*.war) do set WAR_FILE=%%f
                    
                    :: Create a batch file to manually start the app
                    (
                        echo @echo off
                        echo echo Starting Spring Boot application...
                        echo cd /d "%CD%"
                        echo java -jar %WAR_FILE% --server.port=%PORT%
                        echo pause
                    ) > start_app.bat
                    
                    :: Create a README with instructions
                    (
                        echo ========================================
                        echo SPRING BOOT APPLICATION - MANUAL START
                        echo ========================================
                        echo.
                        echo Your application has been deployed by Jenkins
                        echo and is running at: http://localhost:%PORT%/
                        echo.
                        echo If the application stops, you can restart it manually:
                        echo 1. Open Command Prompt
                        echo 2. cd %CD%
                        echo 3. run: start_app.bat
                        echo.
                        echo To stop the application:
                        echo 1. Find the PID: netstat -ano ^| findstr :%PORT%
                        echo 2. Kill it: taskkill /F /PID [PID_NUMBER]
                        echo.
                        echo Or use: taskkill /F /IM java.exe
                        echo ========================================
                    ) > README.txt
                    
                    echo ✅ Startup script created: start_app.bat
                    echo ✅ Instructions created: README.txt
                '''
            }
        }
    }
    
    post {
        success {
            echo '========================================'
            echo '✅ WAR PIPELINE COMPLETED SUCCESSFULLY!'
            echo '========================================'
            echo "WAR file: target/spring-jsp-demo-0.0.1-SNAPSHOT.war"
            echo "Application: http://localhost:${PORT}/"
            echo ""
            echo "IMPORTANT: The application is running DETACHED from Jenkins"
            echo "It will continue running even after this job ends"
            echo ""
            echo "To stop the application manually:"
            echo "1. netstat -ano | findstr :${PORT}"
            echo "2. taskkill /F /PID [PID_NUMBER]"
            echo ""
            echo "Or use: taskkill /F /IM java.exe"
            echo "========================================"
        }
        failure {
            echo '========================================'
            echo '❌ PIPELINE FAILED!'
            echo '========================================'
            echo 'Check the console output for errors'
            echo '========================================'
        }
        always {
            echo '========================================'
            echo 'Pipeline execution completed'
            echo '========================================'
        }
    }
}