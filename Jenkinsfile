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

        stage('Deploy to Azure VM') {
            steps {
                echo 'Connecting to Azure VM via SSH to update the live application...'
                
                // IMPORTANT: Replace the placeholders with your Azure VM username and public IP!
                // This step utilizes the 'SSH Agent Plugin' in Jenkins. 
                // You must add your Azure SSH Key to the Jenkins Credentials manager as 'azure-vm-ssh-key'.
                script {
                    def azureUser = "azureuser"
                    def azureIp = "YOUR.AZURE.PUBLIC.IP"
                    
                    echo "Initiating native rolling update on Azure VM..."
                    
                    /* UNCOMMENT THIS BLOCK ONCE YOUR JENKINS PLUGIN IS CONFIGURED
                    sshagent(['azure-vm-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${azureUser}@${azureIp} '
                                cd /var/www/feedops &&
                                git pull origin main &&
                                source venv/bin/activate &&
                                pip install -r requirements.txt &&
                                sudo systemctl restart feedops
                            '
                        """
                    }
                    */
                    echo 'SUCCESS: Mock deployment step passed. Please uncomment the sshagent block for real deployments.'
                }
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
