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
                git branch: 'main', url: 'https://github.com/udaybhadauria/python-testng.git'  // Verify this URL
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

        stage('Deploy GitHub Pages (Reports)') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                sh '''
                    git config --global user.email "bhadauria.uday@gmail.com"
                    git config --global user.name "udaybhadauria"

                    git reset --hard
                    git clean -fd

                    # Check if gh-pages branch exists
                    if git show-ref --verify --quiet refs/heads/gh-pages; then
                        git checkout gh-pages
                    else
                        git checkout -b gh-pages
                    fi

                    git rm -rf .
                    echo "# Test Report" > index.html
                    git add index.html
                    git commit -m "Update test report"
                    git push origin gh-pages --force

                    git --work-tree=reports add --all
                    git --work-tree=reports commit -m "Deploy HTML Reports"
                    git push origin HEAD:gh-pages --force
                    git checkout main
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
                    sed -i "s|\\!\\[Build Status\\](.*)|![Build Status]($BADGE_URL)|" README.md

                    git config --global user.name "udaybhadauria"
                    git config --global user.email "bhadauria.uday@gmail.com"
                    git add README.md
                    git commit -m "🔄 Auto-update Build Badge after build #$BUILD_NUMBER"
                    git push origin main
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
            script {
                // Optional: You can add any cleanup or final notification logic here
                echo "Pipeline finished."
            }
        }
    }
}
