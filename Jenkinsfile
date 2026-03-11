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
        powershell '''
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Deploying WAR application..." -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            
            # Kill any existing Java process on port 9090
            Write-Host "Stopping existing application..." -ForegroundColor Yellow
            try {
                $connections = Get-NetTCPConnection -LocalPort 9090 -ErrorAction SilentlyContinue
                foreach ($conn in $connections) {
                    Write-Host "Killing PID: $($conn.OwningProcess)"
                    Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
                }
            } catch {
                Write-Host "No existing processes found"
            }
            
            # Get WAR file
            $warFile = Get-ChildItem -Path "target\\*.war" | Select-Object -First 1
            if (-not $warFile) {
                Write-Host "❌ No WAR file found!" -ForegroundColor Red
                exit 1
            }
            Write-Host "Using WAR: $($warFile.FullName)" -ForegroundColor Green
            
            # Create a simple batch file to run the app (more reliable)
            $batchContent = @"
@echo off
cd /d "$env:WORKSPACE"
java -jar "$($warFile.FullName)" --server.port=$env:PORT > app.log 2>&1
"@
            $batchPath = "$env:WORKSPACE\\run_app.bat"
            $batchContent | Out-File -FilePath $batchPath -Encoding ASCII -Force
            
            # Start the application using WScript (silent)
            $vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "$batchPath", 0, False
"@
            $vbsPath = "$env:WORKSPACE\\launch.vbs"
            $vbsContent | Out-File -FilePath $vbsPath -Encoding ASCII -Force
            
            Write-Host "Starting application from WAR..." -ForegroundColor Yellow
            cscript //nologo "$vbsPath"
            
            Write-Host "Waiting for application to start..." -ForegroundColor Yellow
            Start-Sleep -Seconds 20
            
            # Check if application is running
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Checking application status..." -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            
            $portCheck = Get-NetTCPConnection -LocalPort $env:PORT -ErrorAction SilentlyContinue
            if (-not $portCheck) {
                Write-Host "❌ Application failed to start!" -ForegroundColor Red
                Write-Host "========================================" -ForegroundColor Red
                Write-Host "Application log:" -ForegroundColor Red
                Write-Host "========================================" -ForegroundColor Red
                
                if (Test-Path "$env:WORKSPACE\\app.log") {
                    Get-Content "$env:WORKSPACE\\app.log" -Tail 50
                } else {
                    Write-Host "Log file not found"
                }
                
                # Check Java processes
                Write-Host "`nJava processes running:" -ForegroundColor Yellow
                Get-Process -Name "java" -ErrorAction SilentlyContinue | Format-Table Id, ProcessName, CPU
                
                exit 1
            } else {
                Write-Host "✅ Application is running on port $env:PORT!" -ForegroundColor Green
                Write-Host "Process ID: $($portCheck.OwningProcess)" -ForegroundColor Green
            }
            
            # Test the application
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Testing application endpoints..." -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            
            Start-Sleep -Seconds 5
            
            $attempts = 0
            $maxAttempts = 3
            while ($attempts -lt $maxAttempts) {
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:$env:PORT/" -UseBasicParsing -TimeoutSec 5
                    if ($response.StatusCode -eq 200) {
                        Write-Host "✅ Home page is up!" -ForegroundColor Green
                        break
                    }
                } catch {
                    $attempts++
                    Write-Host "Attempt $attempts of $maxAttempts failed, retrying..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 3
                }
            }
            
            if ($attempts -eq $maxAttempts) {
                Write-Host "❌ Application failed to respond" -ForegroundColor Red
                exit 1
            }
            
            # Test health endpoint
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:$env:PORT/health" -UseBasicParsing -TimeoutSec 5
                if ($response.StatusCode -eq 200) {
                    Write-Host "✅ Health check is up!" -ForegroundColor Green
                }
            } catch {
                Write-Host "⚠️ Health check not available (this is OK if not implemented)" -ForegroundColor Yellow
            }
            
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "✅ Deployment completed!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Application URL: http://localhost:$env:PORT/" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Cyan
            
            # Clean up temporary files
            Remove-Item "$env:WORKSPACE\\run_app.bat" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:WORKSPACE\\launch.vbs" -Force -ErrorAction SilentlyContinue
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
        
        stage('Cleanup') {
		    steps {
		        powershell '''
		            Write-Host "Cleaning up..." -ForegroundColor Yellow
		            # Remove temporary files
		            Remove-Item "$env:WORKSPACE\\run_app.ps1" -ErrorAction SilentlyContinue
		            # Note: Don't remove job_id.txt as we might need it
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