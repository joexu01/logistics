/* created by joexu01@UESTC */
/* The chaincode depends on Hyperledger Fabric V2.2 LTS */

package chaincode

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"strconv"
	"time"
)

type ProductInfo struct {
	Amount       int       `json:"amount"`
	Origin       string    `json:"origin"`
	Name         string    `json:"name"`
	LastModified string `json:"last_modified"`
}

type OrderInfo struct {
	//OrderNumber    string  `json:"order_number"`
	BatchNumber    string  `json:"batch_number"`
	TrackingNumber string  `json:"tracking_number"`
	Sorter         string  `json:"sorter"` // 分拣员
	UnitPrice      float32 `json:"unit_price"`
	Quantity       int     `json:"quantity"`
	Client         string  `json:"client"`
}

type LogisticsRecord struct {
	Items []RecordSubItem `json:"items"`
}

type RecordSubItem struct {
	RecordTime string `json:"record_time"`
	Status     string    `json:"status"`
}

type PrivateLogisticsRecord struct {
	Items []PrivateSubItem `json:"items"`
}

type PrivateSubItem struct {
	RecordTime string `json:"record_time"`
	PeerID     string    `json:"peer_id"`
	Operator   string    `json:"operator"`
}

// ContractHandler provides functions to trace logistics history
type ContractHandler struct {
	contractapi.Contract
}

// NewProductInfo adds relevant information of a batch of products.
// This function can be called by the manufacturer only.
// *origin means place of origin
func (h *ContractHandler) NewProductInfo(ctx contractapi.TransactionContextInterface,
	batchNum, amount, name, origin string) error {
	//0. check the client identity
	err := verifyManufacturerMSPID(ctx)
	if err != nil {
		return fmt.Errorf("function NewProductInfo error: %v", err)
	}

	// Verify that the client is submitting request to peer in their organization
	// This is to ensure that a client from another org doesn't attempt to read or
	// write private data from this peer.
	err = verifyClientOrgMatchesPeerOrg(ctx)
	if err != nil {
		return fmt.Errorf("function NewProductInfo error: %v", err)
	}

	//1. verify variables are not empty strings
	if batchNum == "" || amount == "" || name == "" || origin == "" {
		return fmt.Errorf("function NewProductInfo error: args may be empty strings")
	}

	//2. verify variable amount is a positive number
	num, err := strconv.Atoi(amount)
	if err != nil {
		if num < 0 {
			return fmt.Errorf("function NewProductInfo error: arg amount must be a positive number")
		}
		return fmt.Errorf("function NewProductInfo error: %v", err)
	}

	compositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyProduct, []string{batchNum})
	if err != nil {
		return fmt.Errorf("function NewProductInfo error: failed to construct composite key: %v", err)
	}

	//3. verify variable batchNum is a exclusive key
	bytes, err := ctx.GetStub().GetState(compositeKey)
	if err != nil {
		return err
	}

	if bytes != nil {
		//return error if found the batch number
		return fmt.Errorf("function NewProductInfo: product serial number %s has already existed", batchNum)
	}

	//4. serialization and write state
	product := &ProductInfo{
		Amount:       num,
		Origin:       origin,
		Name:         name,
		LastModified: time.Now().Format(`2006-02-06 15:01:05`),
	}
	prodBytes, _ := json.Marshal(product)

	return ctx.GetStub().PutState(compositeKey, prodBytes)
}

// NewOrder is always called by the manufacturer.
// Orders data will be stored in the sideDBs of the collection members.
// Order information related arguments will be provided by a transient.
func (h *ContractHandler) NewOrder(ctx contractapi.TransactionContextInterface) error {
	err := verifyManufacturerMSPID(ctx)
	if err != nil {
		return fmt.Errorf("function NewOrder: %v", err)
	}

	err = verifyClientOrgMatchesPeerOrg(ctx)
	if err != nil {
		return fmt.Errorf("function NewProductInfo error: %v", err)
	}

	//1. Get arguments from the transient
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return fmt.Errorf("function NewOrder: error getting transient: %v", err)
	}

	orderInputJSON, ok := transientMap[TransientKeyOrderInput]
	if !ok {
		return fmt.Errorf("function NewOrder: order info not found in the transient map input")
	}

	type orderInput struct {
		OrderNumber    string  `json:"order_number"`
		BatchNumber    string  `json:"batch_number"`
		TrackingNumber string  `json:"tracking_number"`
		Sorter         string  `json:"sorter"` // 分拣员
		UnitPrice      float32 `json:"unit_price"`
		Quantity       int     `json:"quantity"`
		Collection     string  `json:"collection"`
	}

	input := &orderInput{}
	err = json.Unmarshal(orderInputJSON, input)
	if err != nil {
		return fmt.Errorf("function NewOrder: error unmarshaling order input: %v", err)
	}

	//2. verification

	//collection name
	if input.Collection != CollectionTransaction1 && input.Collection != CollectionTransaction2 {
		return fmt.Errorf("function NewOrder: please specify a collection name")
	}

	//check if batch number exists
	prodCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyProduct, []string{input.BatchNumber})
	if err != nil {
		return err
	}

	bytes, err := ctx.GetStub().GetState(prodCompositeKey)
	if err != nil {
		return err
	}

	if bytes == nil {
		//return error if not found the batch number
		return fmt.Errorf("function NewOrder: batch number %s not found", bytes)
	}

	//3. Create order and store the record to the sideDB
	order := &OrderInfo{
		//OrderNumber:    input.OrderNumber,
		BatchNumber:    input.BatchNumber,
		TrackingNumber: input.TrackingNumber,
		Sorter:         input.Sorter,
		UnitPrice:      input.UnitPrice,
		Quantity:       input.Quantity,
		Client:         "",
	}
	if input.Collection == CollectionTransaction1 {
		order.Client = MSPIDRetailer1
	} else {
		order.Client = MSPIDRetailer2
	}

	orderJSONBytes, err := json.Marshal(order)
	if err != nil {
		return fmt.Errorf("function NewOrder: failed to marshal into JSON: %v", err)
	}
	orderCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyOrder, []string{input.OrderNumber})
	if err != nil {
		return fmt.Errorf("function NewOrder: error creating composite key: %v", err)
	}
	err = ctx.GetStub().PutPrivateData(input.Collection, orderCompositeKey, orderJSONBytes)
	if err != nil {
		return fmt.Errorf(
			"function NewOrder: failed to put order into private data collection: %v", err)
	}

	return nil
}

// UpdateLogisticRecord will append the latest state of logistics item to the record.
func (h *ContractHandler) UpdateLogisticRecord(ctx contractapi.TransactionContextInterface,
	trackingNum, status string) error {

	// only send the proposal to peers in the organization
	err := verifyClientOrgMatchesPeerOrg(ctx)
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: %v", err)
	}

	trackingCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyLogistics, []string{trackingNum})
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: failed to create composite key: %v", err)
	}
	logisticsRecordJSONBytes, err := ctx.GetStub().GetState(trackingCompositeKey)
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: error querying world state: %v", err)
	}

	current := time.Now().Format("2006-01-02 15:01:05")

	logisticsRecord := &LogisticsRecord{}

	if logisticsRecordJSONBytes != nil {
		err := json.Unmarshal(logisticsRecordJSONBytes, logisticsRecord)
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: error unmarshaling order input: %v", err)
		}
	}

	subItem := RecordSubItem{
		RecordTime: current,
		Status:     status,
	}
	logisticsRecord.Items = append(logisticsRecord.Items, subItem)

	bytes, err := json.Marshal(logisticsRecord)
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: failed to marshal JSON: %v", err)
	}
	err = ctx.GetStub().PutState(trackingCompositeKey, bytes)
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: failed to put state: %v", err)
	}

	mspID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return fmt.Errorf("function UpdateLogisticRecord: error getting MSP ID: %v", err)
	}

	if mspID == MSPIDLogistic {
		transientMap, err := ctx.GetStub().GetTransient()
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: error getting transient: %v", err)
		}
		operatorInfo, ok := transientMap[TransientKeyLogisticOperatorInput]
		if !ok {
			return fmt.Errorf("function UpdateLogisticRecord: error getting transient info")
		}

		priTrackingKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyLogisticsPrivate, []string{trackingNum})
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: failed to create composite key: %v", err)
		}
		priTrackingJSONBytes, err := ctx.GetStub().GetPrivateData(CollectionLogistics, priTrackingKey)
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: error querying world state: %v", err)
		}

		privateLogisticsRecord := &PrivateLogisticsRecord{}
		if priTrackingJSONBytes != nil {
			err := json.Unmarshal(priTrackingJSONBytes, privateLogisticsRecord)
			if err != nil {
				return fmt.Errorf("function UpdateLogisticRecord: error unmarshaling order input: %v", err)
			}
		}
		clientID, err := ctx.GetClientIdentity().GetID()
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: error getting clientID: %v", err)
		}

		priItem := PrivateSubItem{
			RecordTime: current,
			PeerID:     clientID,
			Operator:   string(operatorInfo),
		}

		privateLogisticsRecord.Items = append(privateLogisticsRecord.Items, priItem)
		priRecordJSONBytes, err := json.Marshal(privateLogisticsRecord)
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: failed to marshal JSON: %v", err)
		}
		err = ctx.GetStub().PutPrivateData(CollectionLogistics, priTrackingKey, priRecordJSONBytes)
		if err != nil {
			return fmt.Errorf("function UpdateLogisticRecord: failed to put world state: %v", err)
		}
	}

	return nil
}
