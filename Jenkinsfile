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
		            $processes = Get-NetTCPConnection -LocalPort 9090 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
		            foreach ($pid in $processes) {
		                Write-Host "Killing PID: $pid"
		                Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
		            }
		            
		            # Get WAR file
		            $warFile = Get-ChildItem -Path "target\\*.war" | Select-Object -First 1
		            if (-not $warFile) {
		                Write-Host "❌ No WAR file found!" -ForegroundColor Red
		                exit 1
		            }
		            Write-Host "Using WAR: $($warFile.FullName)" -ForegroundColor Green
		            
		            # Kill any Java processes that might be running our app
		            Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*9090*" } | Stop-Process -Force
		            
		            # Create PowerShell script to run the app
		            $scriptPath = Join-Path $env:WORKSPACE "run_app.ps1"
		            @"
		`$logFile = "$env:WORKSPACE\\app.log"
		`$javaHome = "`$env:JAVA_HOME"
		if (-not `$javaHome) { `$javaHome = "java" }
		& "`$javaHome" -jar "$($warFile.FullName)" --server.port=$env:PORT *>> `$logFile
		"@ | Out-File -FilePath $scriptPath -Encoding ASCII
		            
		            # Start the application as a background job
		            Write-Host "Starting application from WAR..." -ForegroundColor Yellow
		            $job = Start-Job -FilePath $scriptPath
		            
		            # Save job info for later
		            $job.Id | Out-File -FilePath "$env:WORKSPACE\\job_id.txt"
		            
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
		                
		                # Show job status
		                $job = Get-Job -Id (Get-Content "$env:WORKSPACE\\job_id.txt")
		                Write-Host "Job State: $($job.State)"
		                if ($job.State -eq 'Failed') {
		                    Write-Host "Job Error: $($job.Error)"
		                    Receive-Job -Job $job
		                }
		                
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
		                    Write-Host "Attempt $attempts failed, retrying..." -ForegroundColor Yellow
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
		                Write-Host "⚠️ Health check not available" -ForegroundColor Yellow
		            }
		            
		            Write-Host "========================================" -ForegroundColor Cyan
		            Write-Host "✅ Deployment completed!" -ForegroundColor Green
		            Write-Host "========================================" -ForegroundColor Cyan
		            Write-Host "Application URL: http://localhost:$env:PORT/" -ForegroundColor Green
		            Write-Host "========================================" -ForegroundColor Cyan
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