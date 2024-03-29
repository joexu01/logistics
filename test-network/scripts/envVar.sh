#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

source scriptUtils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_MANUFACTURER_CA=${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
export PEER0_LOGISTICS_CA=${PWD}/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/ca.crt
export PEER0_RETAILER1_CA=${PWD}/organizations/peerOrganizations/retailer1.example.com/peers/peer0.retailer1.example.com/tls/ca.crt
export PEER0_RETAILER2_CA=${PWD}/organizations/peerOrganizations/retailer2.example.com/peers/peer0.retailer2.example.com/tls/ca.crt
export PEER0_REGULATOR_CA=${PWD}/organizations/peerOrganizations/regulator.example.com/peers/peer0.regulator.example.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_ORG_FULL_NAME="orderer"
  export CORE_ORG_FULL_NAME_CAPS="ORDERER"
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp
}

# Set environment variables for the peer org
# 1 = Manufacturer
# 2 = Logistics
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi

  if [ "$USING_ORG" -eq 1 ]; then
    infoln "Using organization manufacturer"

    export CORE_ORG_FULL_NAME="manufacturer"
    export CORE_ORG_FULL_NAME_CAPS="MANUFACTURER"

    export CORE_PEER_LOCALMSPID="ManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANUFACTURER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

  elif [ $USING_ORG -eq 2 ]; then
    infoln "Using organization logistics"

    export CORE_ORG_FULL_NAME="logistics"
    export CORE_ORG_FULL_NAME_CAPS="LOGISTICS"

    export CORE_PEER_LOCALMSPID="LogisticsMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LOGISTICS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_ORG -eq 3 ]; then
    infoln "Using organization retailer1"

    export CORE_ORG_FULL_NAME="retailer1"
    export CORE_ORG_FULL_NAME_CAPS="RETAILER1"

    export CORE_PEER_LOCALMSPID="Retailer1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILER1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailer1.example.com/users/Admin@retailer1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

  elif [ $USING_ORG -eq 4 ]; then
    infoln "Using organization retailer2"

    export CORE_ORG_FULL_NAME="retailer2"
    export CORE_ORG_FULL_NAME_CAPS="RETAILER2"

    export CORE_PEER_LOCALMSPID="Retailer2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILER2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/retailer2.example.com/users/Admin@retailer2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051

  elif [ $USING_ORG -eq 5 ]; then
    infoln "Using organization regulator"

    export CORE_ORG_FULL_NAME="regulator"
    export CORE_ORG_FULL_NAME_CAPS="REGULATOR"

    export CORE_PEER_LOCALMSPID="RegulatorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGULATOR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulator.example.com/users/Admin@regulator.example.com/msp
    export CORE_PEER_ADDRESS=localhost:15051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$CORE_ORG_FULL_NAME"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_${CORE_ORG_FULL_NAME_CAPS}_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}