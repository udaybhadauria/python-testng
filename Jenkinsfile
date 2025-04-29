pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('docker-username')  // Jenkins credentials for docket user name
        DOCKER_PASSWORD = credentials('docker-password')  // Jenkins credentials for docker password
        SLACK_WEBHOOK_URL = credentials('slack-webhook-python-testng')  // Jenkins credentials for Slack
	GITHUB_PAT = credentials('github-pat')            // Jenkins credentials GitHub PAT
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
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
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
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }  // Only if tests passed
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
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }  // Only if tests passed
            }
            steps {
                sh '''
                    git config --global user.email "you@example.com"
                    git config --global user.name "Your Name"
                    git checkout --orphan gh-pages
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
            	    # Update badge in README.md dynamically

            	    # Set BADGE_URL based on build result
            	    BADGE_URL="https://img.shields.io/badge/Build-Passed-brightgreen"

            	    # Update the badge link inside README.md
            	    sed -i "s|\\!\\[Build Status\\](.*)|![Build Status]($BADGE_URL)|" README.md

            	    # Git commit and push
            	    git config --global user.name "jenkins-bot"
            	    git config --global user.email "jenkins-bot@example.com"
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

                sh "curl -X POST -H \"Content-type: application/json\" --data '${summary}' \$SLACK_WEBHOOK_URL"
            }
        }

        failure {
            script {
                def summary = """{
"text": "❌ *Build FAILED*: Job ${env.JOB_NAME} #${env.BUILD_NUMBER} - <${env.BUILD_URL}|View Build>"
}"""

                sh "curl -X POST -H \"Content-type: application/json\" --data '${summary}' \$SLACK_WEBHOOK_URL"
            }
        }
    }
}
