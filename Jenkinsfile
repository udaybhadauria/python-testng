pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('docker-username')  
        DOCKER_PASSWORD = credentials('docker-password')  
        SLACK_WEBHOOK_URL = credentials('slack-webhook-python-testng')  
        GITHUB_PAT = credentials('github-pat')            
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/udaybhadauria/python-testng.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    rm -rf venv
                    python3 -m venv venv
                    ./venv/bin/python -m ensurepip --upgrade
                    ./venv/bin/python -m pip install --upgrade pip setuptools wheel
                    ./venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    make test
                    make report
                '''
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: 'reports/**', allowEmptyArchive: false
                archiveArtifacts artifacts: 'htmlcov/**', allowEmptyArchive: false
            }
        }

        stage('Docker Build and Push') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                sh '''
                    docker build -t $DOCKER_USERNAME/python-testng:latest .
                    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                    docker push $DOCKER_USERNAME/python-testng:latest
                '''
            }
        }

        stage('Update README.md Badge') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                sh '''
                    BADGE_URL="https://img.shields.io/badge/Build-Passed-brightgreen"
                    sed -i "s|!\\[Build Status\\](.*)|![Build Status]($BADGE_URL)|" README.md || true

                    git config --global user.name "udaybhadauria"
                    git config --global user.email "bhadauria.uday@gmail.com"
                    git add README.md
                    git commit -m "🔄 Auto-update Build Badge after build #$BUILD_NUMBER" || echo "No changes to commit"
                    git push https://$GITHUB_PAT@github.com/udaybhadauria/python-testng.git main
                '''
            }
        }
    }

    post {
        success {
            script {
                def summary = """{
                    "text": "✅ *Build SUCCESS*: Job ${env.JOB_NAME} #${env.BUILD_NUMBER} - <${env.BUILD_URL}|View Build>"
                }"""
                sh "curl -X POST -H 'Content-type: application/json' --data '${summary}' ${SLACK_WEBHOOK_URL}"
            }
        }

        failure {
            script {
                def summary = """{
                    "text": "❌ *Build FAILED*: Job ${env.JOB_NAME} #${env.BUILD_NUMBER} - <${env.BUILD_URL}|View Build>"
                }"""
                sh "curl -X POST -H 'Content-type: application/json' --data '${summary}' ${SLACK_WEBHOOK_URL}"
            }
        }

        always {
            echo "Pipeline completed for Job ${env.JOB_NAME} Build #${env.BUILD_NUMBER}"
        }
    }
}
