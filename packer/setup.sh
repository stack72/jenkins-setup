#!/bin/bash

echo "Sometimes ssh comes up a bit too quick so we sleep for 10 seconds before we begin..."
sleep 10

echo "Installing Jenkins"
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install -y jenkins git
sudo apt-get install -y awscli

echo "Starting the Jenkins service"
sudo service jenkins start

echo "Setting up the jenkins user .ssh directory"
sudo -u jenkins mkdir /var/lib/jenkins/.ssh

echo "Generating the ssh keypair and add it to agent"
ssh-keygen -f id_rsa -t rsa -N ''
eval `ssh-agent -s`
ssh-add id_rsa

echo "move the keys to the correct place in the jenkins root"
sudo mv id_rsa* /var/lib/jenkins/.ssh
sudo chown jenkins:nogroup -R /var/lib/jenkins/.ssh

echo "Install docker"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-engine

echo "Add the jenkins user to the docker group to allow commands to be run"
sudo usermod -a -G docker jenkins
sudo service jenkins restart
