package main

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/joexu01/logistics/chaincode"
	"log"
)

func main() {
	logisticsChaincode, err := contractapi.NewChaincode(&chaincode.ContractHandler{})
	if err != nil {
		log.Panicf("Error creating logistics chaincode: %v", err)
	}
	if err := logisticsChaincode.Start(); err != nil {
		log.Panicf("Error starting logistics chaincode: %v", err)
	}
}
