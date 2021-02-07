#!/bin/bash

COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
CA_IMAGETAG="1.4.7"
export LOCAL_VERSION="2.2.0"
export DOCKER_IMAGE_VERSION="2.2.0"
export CA_LOCAL_VERSION="1.4.7"
export CA_DOCKER_IMAGE_VERSION="1.4.7"

# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=docker/docker-compose-test-net.yaml
# docker-compose.yaml file if you are using couchdb
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

source scriptUtils.sh

# create organizations
if [ -d "organizations/peerOrganizations" ]; then
  rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
fi

# Step1.
infoln "Up CA containers"
IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

infoln "Generate certificates using Fabric CA's"

. organizations/fabric-ca/registerEnroll.sh

while :; do
  if [ ! -f "organizations/fabric-ca/manufacturer/tls-cert.pem" ]; then
    sleep 1
  else
    break
  fi
done

infoln "Create Manufacturer Identities"

createManufacturer

infoln "Create Logistics Identities"

createLogistics

infoln "Create Orderer Org Identities"

createOrderer

# Generate CCP files for
infoln "Generate CCP files for manufacturer and logistics"
./organizations/ccp-generate.sh

infoln "Generate Genesis Block(Step2. create Consortium)"
# Generate Genesis Block(Step2. create Consortium)
set -x
configtxgen -profile LogisticsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
fi

# up all the containers
docker-compose -f ${COMPOSE_FILE_BASE} -f ${COMPOSE_FILE_COUCH} up -d 2>&1

# -------------------------------------------------- #
# 网络结构搭建完成，下面创建通道
# -------------------------------------------------- #

scripts/createChannel.sh "logisticschannel" 3 5 false

if [ $? -ne 0 ]; then
  fatalln "Create channel failed"
fi

# -------------------------------------------------- #
# 部署链码
# -------------------------------------------------- #

scripts/deployCC.sh "logisticschannel" "logisticscc" "../chaincode" "go" "1.0" "1"

if [ $? -ne 0 ]; then
  fatalln "Deploying chaincode failed"
fi

# network down
#docker-compose -f docker/docker-compose-ca.yaml -f docker/docker-compose-couch.yaml -f docker/docker-compose-test-net.yaml down --volumes --remove-orphans
