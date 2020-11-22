#!/bin/bash
repository_url=`head -1 rep_url.txt`
#echo $repository_url

##WORKER docker file###

cd modules/ECS/Worker
docker build .

####API docker file###

cd ../API
docker build .

cd ../../..
tag_file1="image1"
tag_file2="image2"
#echo $tag_file1

docker images > xyz.txt
imageid2=`awk '{print$3}' xyz.txt | head -2 | tail -1`
echo $imageid2

imageid1=`awk '{print$3}' xyz.txt | head -3 | tail -1`
echo $imageid1

rm -f xyz.txt



docker tag $imageid1 image1
docker tag $imageid2 image2



login_cmd=`cut -b 1-44 rep_url.txt`
#echo $login_cmd > a.txt
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $login_cmd

docker tag image2:latest $login_cmd/dp-insight:image2
docker tag image1:latest $login_cmd/dp-insight:image1

#echo $repository_url
#echo $login_cmd/dp-insight/name:image2
#echo $login_cmd >> a.txt
#echo $login_cmd/dp-insight/name:image1 >> a.txt
#echo "abc" >> a.txt
#rm a.txt

docker push $login_cmd/dp-insight:image1
docker push $login_cmd/dp-insight:image2




