#!/bin/bash

source scriptUtils.sh

function createManufacturer() {
  infoln "Enroll CA admin - Manufacturer"
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacturer --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml

  echo "\[Step1\]register peer0"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "\[Step1\]register user"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "\[Step1\]register the org admin"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/peers
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com

  echo "\[Step1\]Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp --csr.hosts peer0.manufacturer.example.com --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/config.yaml

  echo "\[Step1\]Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls --enrollment.profile tls --csr.hosts peer0.manufacturer.example.com --csr.hosts localhost --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/signcerts/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.crt
  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/keystore/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/server.key

  mkdir -p "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts
  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts/ca.crt

  mkdir -p "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/tlsca
  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem

  mkdir -p "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/ca
  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/cacerts/* "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/ca/ca.manufacturer.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com

  echo "\[Step1\]Generate the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com

  echo "\[Step1\]Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7054 --caname ca-manufacturer -M "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp/config.yaml

}

function createLogistics() {
  infoln "\[Step1\]Enroll CA admin - Logistics"
  mkdir -p organizations/peerOrganizations/logistics.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/logistics.example.com/
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-logistics --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistics.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistics.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistics.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistics.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/config.yaml

  infoln "\[Step1\]register peer0"
  set -x
  fabric-ca-client register --caname ca-logistics --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "\[Step1\]register user"
  set -x
  fabric-ca-client register --caname ca-logistics --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "\[Step1\]register the org admin"
  set -x
  fabric-ca-client register --caname ca-logistics --id.name logisticsadmin --id.secret logisticsadminpw --id.type admin --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/logistics.example.com/peers
  mkdir -p organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com

  echo "\[Step1\]Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-logistics -M "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/msp --csr.hosts peer0.logistics.example.com --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/msp/config.yaml

  echo "\[Step1\]Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-logistics -M "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls --enrollment.profile tls --csr.hosts peer0.logistics.example.com --csr.hosts localhost --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/ca.crt
  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/signcerts/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/server.crt
  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/keystore/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/server.key

  mkdir -p "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/tlscacerts
  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/tlscacerts/ca.crt

  mkdir -p "${PWD}"/organizations/peerOrganizations/logistics.example.com/tlsca
  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/tlscacerts/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/tlsca/tlsca.logistics.example.com-cert.pem

  mkdir -p "${PWD}"/organizations/peerOrganizations/logistics.example.com/ca
  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/msp/cacerts/* "${PWD}"/organizations/peerOrganizations/logistics.example.com/ca/ca.logistics.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/logistics.example.com/users
  mkdir -p organizations/peerOrganizations/logistics.example.com/users/User1@logistics.example.com

  echo "\[Step1\]Generate the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-logistics -M "${PWD}"/organizations/peerOrganizations/logistics.example.com/users/User1@logistics.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/logistics.example.com/users/User1@logistics.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com

  echo "\[Step1\]Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://logisticsadmin:logisticsadminpw@localhost:8054 --caname ca-logistics -M "${PWD}"/organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/logistics/tls-cert.pem
  { set +x; } 2>/dev/null

  cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com/msp/config.yaml

}

function createOrderer() {
  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/example.com/orderers
  mkdir -p organizations/ordererOrganizations/example.com/orderers/example.com

  mkdir -p organizations/ordererOrganizations/example.com/orderers/orderer.example.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p organizations/ordererOrganizations/example.com/users
  mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml
}
