webContainerTag=$1
mongoContainerTag=$2
echo "required web container tag $webContainerTag"
echo "required mongo container tag $mongoContainerTag"
isContainerRunning=$(sudo docker ps -q -f "name=adpq-web")
if [[ "$isContainerRunning" != "" ]]
then
        sudo docker stop $isContainerRunning
        sudo docker rm $isContainerRunning
fi
sudo docker build --build-arg tag=$webContainerTag -f /home/ubuntu/dockerFiles/web/dockerfile .
sudo docker build --rm --pull=true --build-arg tag=$webContainerTag -t yashittdocker/adpq-web -f /home/ubuntu/dockerFiles/web/dockerfile .
sudo docker run -d --name adpq-web -p 80:8080 yashittdocker/adpq-web:$webContainerTag

isContainerRunning=$(sudo docker ps -q -f "name=adpq-mongo")
if [[ "$isContainerRunning" != "" ]]
then
        sudo docker stop $isContainerRunning
        sudo docker rm $isContainerRunning
fi
sudo docker build --build-arg tag=$mongoContainerTag -f /home/ubuntu/dockerFiles/mongo/dockerfile .
sudo docker build --rm --pull=true --build-arg tag=$mongoContainerTag -t yashittdocker/adpq-mongo -f /home/ubuntu/dockerFiles/mongo/dockerfile .
sudo docker run -d --name adpq-mongo -p 27017:27017 yashittdocker/adpq-mongo:$mongoContainerTag
