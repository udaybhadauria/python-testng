pipeline {
    agent any

    environment {
        DOCKER_USERNAME = credentials('docker-username')  // Jenkins credentials
        DOCKER_PASSWORD = credentials('docker-password')  // Jenkins credentials
        SLACK_WEBHOOK_URL = credentials('slack-webhook')  // Jenkins credentials
	GITHUB_PAT = credentials('github-pat')            // GitHub Personal Access Token
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/udaybhadauria/python-testng.git'  // Replace with your repo
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    source venv/bin/activate
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
            slackSend color: '#00FF00', message: "✅ BUILD SUCCESS: ${env.JOB_NAME} [${env.BUILD_NUMBER}]"
        }
        failure {
            slackSend color: '#FF0000', message: "❌ BUILD FAILED: ${env.JOB_NAME} [${env.BUILD_NUMBER}]"
        }
    }
}
