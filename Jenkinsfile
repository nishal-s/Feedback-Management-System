pipeline {
    // This assumes your Jenkins agent supports standard Linux shell and Python 3.
    agent any

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
                    flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
                    
                    echo "=> Running Unit Tests"
                    python -m pytest tests/
                '''
            }
        }

        stage('Deploy Locally (Single VM)') {
            steps {
                echo 'Deploying to the same Azure VM that Jenkins is running on...'
                
                // Because Jenkins has local ownership of /var/www/feedops
                // and a specific sudoers rule to restart the service without a password,
                // we can just run native shell commands!
                sh '''
                    cd /var/www/feedops
                    
                    echo "=> Pulling Latest Code"
                    git pull origin main
                    
                    echo "=> Updating Dependencies"
                    source venv/bin/activate
                    pip install -r requirements.txt
                    
                    echo "=> Restarting Live Server"
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
