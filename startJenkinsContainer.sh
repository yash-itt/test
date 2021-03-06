#!/bin/bash

#This script setup Docker Jenkins and Web Server containers

jenkinsContainerTag=$1

#update packages
sudo apt-get update

#checking if docker is already running or not. If not, installing docker-ce
dockerVersion=$(which docker)
emptyVariable=""
if [[ "$dockerVersion" == "$emptyVariable" ]]
then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        apt-cache policy docker-ce
        sudo apt-get install -y docker-ce
else
        echo '**********DOCKER INSTALLED************'
fi

#checking if zip is installed or not. If not, installing it
zipVersion=$(which zip)
if [[ "$zipVersion" == "$emptyVariable" ]]
then
        sudo apt-get update
        sudo apt-get install zip -y
else
        echo '**********ZIP INSTALLED************'
fi

lfsVersion=$(which git-lfs)
if [[ "$lfsVersion" == "$emptyVariable" ]]
then
        sudo apt-get install software-properties-common
        sudo add-apt-repository ppa:git-core/ppa
        curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
        sudo apt-get install git-lfs
        git lfs install
else
        echo '**********GIT LFS INSTALLED************'
fi


#deleting jenkins home directory
if [[ -d "/var/jenkins-home" ]]
then
        sudo rm -rf /var/jenkins-home
        echo "******** Jenkins Folder Deleted**********"
fi
#sudo mkdir /var/jenkins-home

#pulling required packages from Github
if [[ -d "/home/ubuntu/packageRepo" ]]
then
        sudo rm -rf /home/ubuntu/packageRepo
        echo "********** PackageRepo Folder Deleted**********"
fi

sudo mkdir /home/ubuntu/packageRepo
cd /home/ubuntu/packageRepo
echo "********** Packagerepo folder created **********"
sudo git lfs clone https://github.com/yash-itt/test.git
cd test
echo "********** Complete checkout to repo **********"
sudo unzip jenkins-home.zip -d /var/
echo "********** Unzip completed **********"
#stopping existing jenkins docker and pulling the upadted
isContainerRunning=$(sudo docker ps -q -f "name=adpq-jenkins")
if [[ "$isContainerRunning" != "" ]]
then
        sudo docker stop $isContainerRunning
        sudo docker rm $isContainerRunning
fi
#removing the existing jenkins image
isJenkinsImageExist=$(sudo docker images adpq-jenkins -q)
if [[ "$isJenkinsImageExist" != "" ]]
then
        sudo docker stop $isJenkinsImageExist
        sudo docker rm $isJenkinsImageExist
fi
sudo docker run -d --name adpq-jenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins-home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker -v /home/ubuntu:/var/jenkins_home/deployCodeFiles/ -u root yashittdocker/adpq-jenkins:$jenkinsContainerTag
