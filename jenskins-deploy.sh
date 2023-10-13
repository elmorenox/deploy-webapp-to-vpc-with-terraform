:'
- Install Jenkins
- Create a Jenkins user password and log into the Jenkins user (Review Deployment 3 on how to do this)
- Create a public and private key on this instance with ssh-keygen
- Copy the public key contents and paste it into the second instance authorized_keys
- IMPORTANT: Test the ssh connection
- Exit the jenkins user
- Now, in the ubuntu user, install the following: {sudo apt install -y software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, sudo apt install -y python3.7, sudo apt install -y python3.7-venv}
'