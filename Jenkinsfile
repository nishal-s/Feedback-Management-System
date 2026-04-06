pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/feedops"
        REPO_URL = "https://github.com/nishal-s/Feedback-Management-System.git"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Test & Lint') {
            steps {
                echo 'Setting up Python environment and running automated tests...'
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                    
                    echo "=> Running Linter"
                    flake8 . --exclude=venv,.git,__pycache__ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
                    
                    echo "=> Running Unit Tests"
                    python -m pytest tests/
                '''
            }
        }

        stage('Deploy Locally (Single VM)') {
            steps {
                echo 'Deploying to Azure VM...'

                sh '''
                    echo "=> Preparing deployment directory"
                    mkdir -p $APP_DIR
                    cd $APP_DIR

                    # ✅ FIX: Check if it's a git repo
                    if [ ! -d ".git" ]; then
                        echo "=> Cloning fresh repository"
                        rm -rf *
                        git clone $REPO_URL .
                    else
                        echo "=> Pulling latest changes"
                        git pull origin main
                    fi

                    echo "=> Setting up virtual environment"
                    if [ ! -d "venv" ]; then
                        python3 -m venv venv
                    fi

                    source venv/bin/activate
                    pip install -r requirements.txt

                    echo "=> Restarting application"
                    sudo systemctl restart feedops
                '''

                echo 'SUCCESS: Live deployment completed.'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution complete.'
        }
        success {
            echo 'Deployment Pipeline Succeeded!'
        }
        failure {
            echo 'Deployment Pipeline Failed. Check logs above.'
        }
    }
}