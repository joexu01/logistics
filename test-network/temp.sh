# Logistics

echo "\[Step1\]Enroll CA admin - Logistics"
mkdir -p organizations/peerOrganizations/manufacturer.example.com/
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.example.com/
set -x
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacturer --tls.certfiles
"${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
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
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M
"${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp --csr.hosts peer0.manufacturer.example.com --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
{ set +x; } 2>/dev/null

cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/msp/config.yaml

#cp "${PWD}"/organizations/peerOrganizations/logistics.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/logistics.example.com/users/User1@logistics.example.com/msp/config.yaml
#mkdir -p organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com

echo "\[Step1\]Generate the peer0-tls certificates"
set -x
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M
"${PWD}"/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls --enrollment.profile tls --csr.hosts peer0.manufacturer.example.com --csr.hosts localhost --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
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
fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacturer -M
"${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
{ set +x; } 2>/dev/null

cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/User1@manufacturer.example.com/msp/config.yaml

mkdir -p organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com

echo "\[Step1\]Generate the org admin msp"
set -x
fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7054 --caname ca-manufacturer -M
"${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp --tls.certfiles "${PWD}"/organizations/fabric-ca/manufacturer/tls-cert.pem
{ set +x; } 2>/dev/null

cp "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml "${PWD}"/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp/config.yaml