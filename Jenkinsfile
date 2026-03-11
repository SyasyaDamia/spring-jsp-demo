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
                    
                    if not exist target\\*.war (
                        echo ❌ WAR file not created!
                        exit /b 1
                    )
                    
                    echo ✅ WAR file created successfully!
                    dir target\\*.war
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
                    
                    :: Get WAR file name
                    set WAR_FILE=
                    for %%f in (target\\*.war) do set WAR_FILE=%%f
                    
                    echo Using WAR: %WAR_FILE%
                    echo Current directory: %CD%
                    
                    :: Create a PowerShell script that runs completely detached
                    (
                        echo `$logFile = "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\spring-jsp-demo\\app.log"
                        echo `$warFile = "%WAR_FILE%"
                        echo `$port = %PORT%
                        echo.
                        echo # Function to start the app
                        echo function Start-App {
                        echo     try {
                        echo         `$process = Start-Process -FilePath "java" -ArgumentList "-jar `$warFile --server.port=`$port" -NoNewWindow -PassThru -RedirectStandardOutput `$logFile -RedirectStandardError `$logFile
                        echo         `$process.Id ^| Out-File -FilePath "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\spring-jsp-demo\\app.pid"
                        echo         return `$process
                        echo     } catch {
                        echo         `$_.Exception.Message ^| Out-File -FilePath "C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\spring-jsp-demo\\error.log"
                        echo     }
                        echo }
                        echo.
                        echo # Start the app
                        echo Start-App
                    ) > "%TEMP%\\start_app.ps1"
                    
                    :: Execute the PowerShell script in a completely detached way
                    echo Starting application from WAR...
                    start /B powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%TEMP%\\start_app.ps1"
                    
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
                        
                        :: Save PID to file
                        echo %%a > app.pid
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
                        if exist error.log (
                            echo ========================================
                            echo Error log:
                            echo ========================================
                            type error.log
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
                    
                    echo ========================================
                    echo ✅ Deployment completed!
                    echo ========================================
                    echo Application URL: http://localhost:%PORT%/
                    echo Application is running DETACHED from Jenkins
                    echo Process ID: !FOUND!
                    echo ========================================
                    
                    :: Clean up temp files
                    del "%TEMP%\\start_app.ps1" 2>nul
                '''
            }
        }
        
        stage('Verify Persistence') {
            steps {
                bat '''
                    @echo off
                    echo ========================================
                    echo Verifying application persistence...
                    echo ========================================
                    
                    timeout /t 5 /nobreak
                    
                    :: Check if app is still running
                    netstat -ano | findstr :9090 | findstr LISTENING
                    if errorlevel 1 (
                        echo ❌ Application stopped after deployment!
                        
                        :: Check if we have a saved PID
                        if exist app.pid (
                            set /p PID=<app.pid
                            echo Checking PID !PID!...
                            tasklist /fi "PID eq !PID!" | findstr java
                        )
                        
                        exit /b 1
                    ) else (
                        echo ✅ Application is still running!
                        
                        :: Show process details
                        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090 ^| findstr LISTENING') do (
                            echo Process ID: %%a
                            echo.
                            echo Process details:
                            tasklist /fi "PID eq %%a"
                        )
                    )
                    
                    echo ========================================
                    echo ✅ Persistence verified
                    echo ========================================
                '''
            }
        }
        
        stage('Create Manual Scripts') {
            steps {
                bat '''
                    @echo off
                    echo ========================================
                    echo Creating manual management scripts...
                    echo ========================================
                    
                    :: Get WAR file
                    for %%f in (target\\*.war) do set WAR_FILE=%%f
                    
                    :: Create start script
                    (
                        echo @echo off
                        echo echo Starting Spring Boot application...
                        echo cd /d "%CD%"
                        echo start /B java -jar %WAR_FILE% --server.port=%PORT%
                        echo echo Application started on port %PORT%!
                        echo echo Check with: netstat -ano ^| findstr :%PORT%
                        echo pause
                    ) > start_app.bat
                    
                    :: Create stop script
                    (
                        echo @echo off
                        echo echo Stopping Spring Boot application on port %PORT%...
                        echo for /f "tokens=5" %%%%a in ('netstat -ano ^^^| findstr :%PORT% ^^^| findstr LISTENING') do (
                        echo     echo Killing PID: %%%%a
                        echo     taskkill /F /PID %%%%a
                        echo )
                        echo echo Application stopped!
                        echo pause
                    ) > stop_app.bat
                    
                    :: Create status script
                    (
                        echo @echo off
                        echo echo Checking application status on port %PORT%...
                        echo echo.
                        echo netstat -ano ^| findstr :%PORT% ^| findstr LISTENING
                        echo if errorlevel 1 (
                        echo     echo Application is NOT running
                        echo ) else (
                        echo     echo Application IS running
                        echo )
                        echo pause
                    ) > status_app.bat
                    
                    :: Create README
                    (
                        echo ========================================
                        echo SPRING BOOT APPLICATION MANAGEMENT
                        echo ========================================
                        echo.
                        echo Application URL: http://localhost:%PORT%/
                        echo.
                        echo Commands:
                        echo ---------
                        echo start_app.bat  - Start the application
                        echo stop_app.bat   - Stop the application
                        echo status_app.bat - Check if application is running
                        echo.
                        echo Manual commands:
                        echo ----------------
                        echo Check if running: netstat -ano ^| findstr :%PORT%
                        echo Kill process:    taskkill /F /PID [PID]
                        echo View logs:       type app.log
                        echo.
                        echo Current Status:
                        echo ----------------
                    ) > README.txt
                    
                    :: Append current status to README
                    netstat -ano | findstr :%PORT% | findstr LISTENING >> README.txt
                    
                    echo ✅ Management scripts created:
                    echo    - start_app.bat
                    echo    - stop_app.bat
                    echo    - status_app.bat
                    echo    - README.txt
                    echo ========================================
                '''
            }
        }
    }
    
    post {
        success {
            echo '========================================'
            echo '✅ PIPELINE COMPLETED SUCCESSFULLY!'
            echo '========================================'
            echo "Application: http://localhost:${PORT}/"
            echo ""
            echo "MANAGEMENT SCRIPTS CREATED:"
            echo "  start_app.bat   - Start the app"
            echo "  stop_app.bat    - Stop the app"
            echo "  status_app.bat  - Check app status"
            echo ""
            echo "To check if app is running now:"
            echo "  netstat -ano | findstr :${PORT}"
            echo ""
            echo "The application is running DETACHED from Jenkins"
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
            // Clean up temp files but leave app running
            bat 'del /f /q "%TEMP%\\start_app.ps1" 2>nul || exit 0'
        }
    }
}