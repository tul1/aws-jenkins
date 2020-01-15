#!/bin/bash
# A simple Bash script to install docker and jenkins in an Ubuntu VM, by Patricio Tula
# install docker
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update
apt-get install -y docker-engine
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# build & run jenkins
docker build -t jenkins-docker /tmp/.
mkdir -p /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home/
docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home/:/var/jenkins_home -v /var/jenkins-dockerrun/docker.sock:/var/run/docker.sock --name jenkins -d jenkins-docker 
