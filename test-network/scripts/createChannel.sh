#!/bin/bash

source scriptUtils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: "${CHANNEL_NAME:="logisticschannel"}"
# CHANNEL_NAME 禁止大写字母出现
: "${DELAY:="3"}"
: "${MAX_RETRY:="5"}"
: "${VERBOSE:="false"}"

# import utils
. scripts/envVar.sh

if [ ! -d "channel-artifacts" ]; then
  mkdir channel-artifacts
fi

# configtxgen -profile LogisticsChannel -outputCreateChannelTx ./channel-artifacts/logisticschannel.tx -channelID logisticschannel
createChannelTx() {

  set -x
  configtxgen -profile LogisticsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate channel configuration transaction..."
  fi

}

# configtxgen -profile LogisticsChannel -outputAnchorPeersUpdate ./channel-artifacts/ManufacturerMSPanchors.tx -channelID logisticschannel -asOrg ManufacturerMSP
# configtxgen -profile LogisticsChannel -outputAnchorPeersUpdate ./channel-artifacts/LogisticsMSPanchors.tx -channelID logisticschannel -asOrg LogisticsMSP
createAnchorPeerTx() {

  for orgmsp in ManufacturerMSP LogisticsMSP; do

    infoln "Generating anchor peer update transaction for ${orgmsp}"
    set -x
    configtxgen -profile LogisticsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate anchor peer update transaction for ${orgmsp}..."
    fi

  done
}

# peer channel create -o localhost:7050 -c logisticschannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/logisticschannel.tx --outputBlock ./channel-artifacts/logisticschannel.block --tls --cafile "$ORDERER_CA"
createChannel() {
  setGlobals 1
  # Poll in case the raft leader is not set yet
  local rc=1
  local COUNTER=1
  # shellcheck disable=SC2166
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    set -x
    peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile "$ORDERER_CA"
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  verifyResult $res "Channel creation failed"
  successln "Channel '$CHANNEL_NAME' created"
}

# queryCommitted ORG
# peer channel join -b ./channel-artifacts/logisticschannel.block
joinChannel() {
  ORG=$1
  setGlobals "$ORG"
  local rc=1
  local COUNTER=1
  ## Sometimes Join takes time, hence retry
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  verifyResult $res "After $MAX_RETRY attempts, peer0.${ORG} has failed to join channel '$CHANNEL_NAME' "
}

# peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c logisticschannel -f ./channel-artifacts/"${CORE_PEER_LOCALMSPID}"anchors.tx --tls --cafile "$ORDERER_CA" >&log.txt
updateAnchorPeers() {
  ORG=$1
  setGlobals "$ORG"
  local rc=1
  local COUNTER=1
  ## Sometimes Join takes time, hence retry
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/"${CORE_PEER_LOCALMSPID}"anchors.tx --tls --cafile "$ORDERER_CA"
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
  sleep $DELAY
}

verifyResult() {
  if [ "$1" -ne 0 ]; then
    fatalln "$2"
  fi
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channeltx
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

## Create anchorpeertx
infoln "Generating anchor peer update transactions"
createAnchorPeerTx

FABRIC_CFG_PATH=$PWD/../config/

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel

## Join all the peers to the channel
infoln "Join Manufacturer peers to the channel..."
joinChannel 1
infoln "Join Logistics peers to the channel..."
joinChannel 2
infoln "Join Retailer1 peers to the channel..."
joinChannel 3
infoln "Join Retailer2 peers to the channel..."
joinChannel 4
infoln "Join Regulator peers to the channel..."
joinChannel 5

## Set the anchor peers for each org in the channel
infoln "Updating anchor peers for manufacturer..."
updateAnchorPeers 1
infoln "Updating anchor peers for logistics..."
updateAnchorPeers 2
infoln "Updating anchor peers for retailer1..."
updateAnchorPeers 3
infoln "Updating anchor peers for retailer2..."
updateAnchorPeers 4
infoln "Updating anchor peers for regulator..."
updateAnchorPeers 5

successln "Channel successfully joined"

exit 0
