#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGCAP}/$6/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGCAP}/$6/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=manufacturer
ORGCAP=Manufacturer
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem
CAPEM=organizations/peerOrganizations/manufacturer.example.com/ca/ca.manufacturer.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/manufacturer.example.com/connection-manufacturer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/manufacturer.example.com/connection-manufacturer.yaml

ORG=logistics
ORGCAP=Logistics
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/logistics.example.com/tlsca/tlsca.logistics.example.com-cert.pem
CAPEM=organizations/peerOrganizations/logistics.example.com/ca/ca.logistics.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/logistics.example.com/connection-logistics.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/logistics.example.com/connection-logistics.yaml

ORG=retailer1
ORGCAP=Retailer1
P0PORT=11051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/retailer1.example.com/tlsca/tlsca.retailer1.example.com-cert.pem
CAPEM=organizations/peerOrganizations/retailer1.example.com/ca/ca.retailer1.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/retailer1.example.com/connection-retailer1.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/retailer1.example.com/connection-retailer1.yaml

ORG=retailer2
ORGCAP=Retailer2
P0PORT=13051
CAPORT=11054
PEERPEM=organizations/peerOrganizations/retailer2.example.com/tlsca/tlsca.retailer2.example.com-cert.pem
CAPEM=organizations/peerOrganizations/retailer2.example.com/ca/ca.retailer2.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/retailer2.example.com/connection-retailer2.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/retailer2.example.com/connection-retailer2.yaml

ORG=regulator
ORGCAP=Regulator
P0PORT=15051
CAPORT=12054
PEERPEM=organizations/peerOrganizations/regulator.example.com/tlsca/tlsca.regulator.example.com-cert.pem
CAPEM=organizations/peerOrganizations/regulator.example.com/ca/ca.regulator.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/regulator.example.com/connection-regulator.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGCAP)" > organizations/peerOrganizations/regulator.example.com/connection-regulator.yaml
