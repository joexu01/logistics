/* created by joexu01@UESTC */
/* The chaincode depends on Hyperledger Fabric V2.2 LTS */

package chaincode

import (
	"fmt"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// verifyClientOrgMatchesPeerOrg is an internal function used verify client org id and matches peer org id.
func verifyClientOrgMatchesPeerOrg(ctx contractapi.TransactionContextInterface) error {
	clientMSPID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return fmt.Errorf("failed getting the client's MSPID: %v", err)
	}
	peerMSPID, err := shim.GetMSPID()
	if err != nil {
		return fmt.Errorf("failed getting the peer's MSPID: %v", err)
	}

	if clientMSPID != peerMSPID {
		return fmt.Errorf("client from org %v is not authorized to read or write private data from an org %v peer", clientMSPID, peerMSPID)
	}

	return nil
}

func verifyManufacturerMSPID(ctx contractapi.TransactionContextInterface) error {
	identity := ctx.GetClientIdentity()
	mspID, err := identity.GetMSPID()
	if err != nil {
		return err
	}
	if mspID != MSPIDManufacturer {
		return fmt.Errorf("incorrect identity: %s", mspID)
	}
	return nil
}

func verifyRetailer1MSPID(ctx contractapi.TransactionContextInterface) (bool, error) {
	identity := ctx.GetClientIdentity()
	mspID, err := identity.GetMSPID()
	if err != nil {
		return false, err
	}
	if mspID != MSPIDRetailer1 {
		return false, nil
	}
	return true, nil
}

func verifyRetailer2MSPID(ctx contractapi.TransactionContextInterface) (bool, error) {
	identity := ctx.GetClientIdentity()
	mspID, err := identity.GetMSPID()
	if err != nil {
		return false, err
	}
	if mspID != MSPIDRetailer2 {
		return false, nil
	}
	return true, nil
}

func verifyLogisticMSPID(ctx contractapi.TransactionContextInterface) (bool, error) {
	identity := ctx.GetClientIdentity()
	mspID, err := identity.GetMSPID()
	if err != nil {
		return false, err
	}
	if mspID != MSPIDLogistic {
		return false, nil
	}
	return true, nil
}

func verifyRegulatorMSPID(ctx contractapi.TransactionContextInterface) (bool, error) {
	identity := ctx.GetClientIdentity()
	mspID, err := identity.GetMSPID()
	if err != nil {
		return false, err
	}
	if mspID != MSPIDRegulator {
		return false, nil
	}
	return true, nil
}
