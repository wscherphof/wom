#!/bin/bash

START=$(date)

echo "Provisioning a new base from the generic 'coord' image"
docker run --name base -v $(pwd)/provision:/provision coord /bin/bash -c 'cp /provision/deploy/* /app/ismobile/jboss-4.2.3.GA/server/coord/deploy'
docker commit base wom:base
docker rm -v base

echo "Removing existing wom container & image"
docker stop wom 2> /dev/null
docker rm wom 2> /dev/null
docker rmi wom 2> /dev/null
echo "Building the new wom image"
docker build -t wom wom
echo "Removing the intermediairy image"
docker rmi wom:base

echo ""
echo "Done. Timer:"
echo "- Now:     $(date)"
echo "- Started: $START"
echo ""

RUN="docker run --name wom -d -p 8085:8085 --link coorddb:db wom"
echo "Starting a new container: \$ ${RUN}"
${RUN}

echo "If the database container is new as well, open http://docker:8085/cmc now to create a teamcluster"
read -n 1 -s -p "Press any key to continue... "; echo ""
read -p "Name of new teamcluster [Enter for none]: " teamcluster
if [ "${teamcluster}" ]; then
	docker run --rm -v $(pwd)/teamcluster:/setup --link coorddb:db wom /setup/map ${teamcluster}
fi
