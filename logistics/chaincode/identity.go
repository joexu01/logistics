/* created by joexu01@UESTC */
/* The chaincode depends on Hyperledger Fabric V2.2 LTS */

package chaincode

import (
	"encoding/base64"
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

func submittingClientIdentity(ctx contractapi.TransactionContextInterface) (string, error) {
	b64ID, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		return "", fmt.Errorf("failed to read clientID: %v", err)
	}
	decodeID, err := base64.StdEncoding.DecodeString(b64ID)
	if err != nil {
		return "", fmt.Errorf("failed to base64 decode clientID: %v", err)
	}
	return string(decodeID), nil
}

type Identity struct {
	RawID     string `json:"raw_id"`
	DecodedID string `json:"decoded_id"`
	MspID     string `json:"msp_id"`
	Creator   string `json:"creator"`
}

type Result struct {
	Msg string `json:"msg"`
}

func (h *ContractHandler) ShowIdentity(ctx contractapi.TransactionContextInterface) (*Identity, error) {
	identity := ctx.GetClientIdentity()
	id, err := identity.GetID()
	if err != nil {
		return nil, err
	}
	mspID, err := identity.GetMSPID()
	if err != nil {
		return nil, err
	}

	creator, err := ctx.GetStub().GetCreator()
	if err != nil {
		return nil, err
	}

	dID, err := submittingClientIdentity(ctx)
	if err != nil {
		return nil, err
	}

	idResult := &Identity{
		RawID:     id,
		MspID:     mspID,
		Creator:   string(creator),
		DecodedID: dID,
	}
	return idResult, nil
}


func (h *ContractHandler) InitCollections(ctx contractapi.TransactionContextInterface) error {
	return ctx.GetStub().PutState(
		"collections_config", []byte("transactionCollection1 transactionCollection2 logisticCollection"))
}
