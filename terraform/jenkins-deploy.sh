#!/bin/bash

# install jenkins
sudo apt update && sudo apt install -y fontconfig openjdk-17-jre

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# create
# -m flag to create user home, and -s to set the shell
sudo useradd -m -s /bin/bash jenkins
echo "jenkins:$jenkinspwd" | sudo chpasswd
sudo usermod -aG sudo jenkins

# login
sudo su - jenkins

# generate ssh keys for jenkins user. N flag is for empty password
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# send the ssh creds to the web server
# ssh-copy-id -i /home/jenkins/.ssh/id_rsa.pub jenkins@$webserver_ip

# test the ssh connection
# ssh ubuntu@$webserver_ip

# change to ubuntu user
exit

# install required packages as the ubuntu
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.7
sudo apt install -y python3.7-venv
