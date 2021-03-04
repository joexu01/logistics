/* created by joexu01@UESTC */
/* The chaincode depends on Hyperledger Fabric V2.2 LTS */

package chaincode

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type LogisticsCombineRecord struct {
	Public  *LogisticsRecord        `json:"public"`
	Private *PrivateLogisticsRecord `json:"private"`
}

// ReadProductInfo returns detailed product information
func (h *ContractHandler) ReadProductInfo(ctx contractapi.TransactionContextInterface,
	batchNum string) (*ProductInfo, error) {
	if batchNum == "" {
		return nil, fmt.Errorf("function ReadProductInfo error: args may be empty strings")
	}

	compositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyProduct, []string{batchNum})
	if err != nil {
		return nil, fmt.Errorf("function ReadProductInfo error: failed to construct composite key: %v", err)
	}

	bytes, err := ctx.GetStub().GetState(compositeKey)
	if err != nil {
		return nil, fmt.Errorf("function ReadProductInfo error: failed to get state: %v", err)
	}

	if bytes == nil {
		return nil, fmt.Errorf("function ReadProductInfo: product serial number %s doesn't exist", batchNum)
	}

	info := &ProductInfo{}
	err = json.Unmarshal(bytes, info)
	if err != nil {
		return nil, fmt.Errorf("function ReadProductInfo error: failed to unmarshal json: %v", err)
	}

	return info, nil
}

func (h *ContractHandler) ReadProductInfoByProductName(
	ctx contractapi.TransactionContextInterface, keyword string) ([]*ProductInfo, error) {
	query := fmt.Sprintf(`{"selector":{"name":"%s"}}`, keyword)
	iterator, err := ctx.GetStub().GetQueryResult(query)
	if err != nil {
		return nil, fmt.Errorf("function ReadProductInfoByProductName: %v", err)
	}

	var products []*ProductInfo

	for iterator.HasNext() {
		response, err := iterator.Next()
		if err != nil {
			return nil, err
		}

		prodInfo := &ProductInfo{}
		err = json.Unmarshal(response.Value, prodInfo)
		if err != nil {
			return nil, err
		}
		products = append(products, prodInfo)
	}

	return products, nil
}

// ReadOrderInfo returns order details with params provided
func (h *ContractHandler) ReadOrderInfo(ctx contractapi.TransactionContextInterface,
	orderNum, collectionName string) (*OrderInfo, error) {
	orderCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyOrder, []string{orderNum})
	if err != nil {
		return nil, fmt.Errorf("function ReadOrderInfo: error creating composite key: %v", err)
	}

	orderPrivateData, err := ctx.GetStub().GetPrivateData(collectionName, orderCompositeKey)
	if err != nil {
		return nil, fmt.Errorf("function ReadOrderInfo: error getting data: %v", err)
	}

	order := &OrderInfo{}
	err = json.Unmarshal(orderPrivateData, order)
	if err != nil {
		return nil, fmt.Errorf("function ReadOrderInfo: error unmarshaling json: %v", err)
	}

	return order, nil
}

func (h *ContractHandler) ReadLogisticsRecord(ctx contractapi.TransactionContextInterface,
	trackingNum string) (*LogisticsRecord, error) {
	trackingCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyLogistics, []string{trackingNum})
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsRecord: failed to create composite key: %v", err)
	}
	logisticsRecordJSONBytes, err := ctx.GetStub().GetState(trackingCompositeKey)
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsRecord: error querying world state: %v", err)
	}

	logisticsRecord := &LogisticsRecord{}

	_ = json.Unmarshal(logisticsRecordJSONBytes, logisticsRecord)
	return logisticsRecord, nil
}

func (h *ContractHandler) ReadLogisticsPriRecord(ctx contractapi.TransactionContextInterface,
	trackingNum string) (*LogisticsCombineRecord, error) {
	err := verifyClientOrgMatchesPeerOrg(ctx)
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: %v", err)
	}

	trackingCompositeKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyLogistics, []string{trackingNum})
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: failed to create composite key: %v", err)
	}
	logisticsRecordJSONBytes, err := ctx.GetStub().GetState(trackingCompositeKey)
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: error querying world state: %v", err)
	}

	logisticsRecord := &LogisticsRecord{}

	_ = json.Unmarshal(logisticsRecordJSONBytes, logisticsRecord)

	priTrackingKey, err := ctx.GetStub().CreateCompositeKey(CompositeKeyLogisticsPrivate, []string{trackingNum})
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: failed to create composite key: %v", err)
	}
	priTrackingJSONBytes, err := ctx.GetStub().GetPrivateData(CollectionLogistics, priTrackingKey)
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: error querying world state: %v", err)
	}

	privateLogisticsRecord := &PrivateLogisticsRecord{}
	_ = json.Unmarshal(priTrackingJSONBytes, privateLogisticsRecord)

	compositeRecord := &LogisticsCombineRecord{
		Public:  logisticsRecord,
		Private: privateLogisticsRecord,
	}
	return compositeRecord, err
}

func (h *ContractHandler) GetOrdersUnaccepted(
	ctx contractapi.TransactionContextInterface, collection string) ([]*OrderInfo, error) {
	err := verifyClientOrgMatchesPeerOrg(ctx)
	if err != nil {
		return nil, fmt.Errorf("function ReadLogisticsPriRecord: %v", err)
	}

	if collection == "" {
		collection = CollectionTransaction1
	}

	query := fmt.Sprintf(`{"selector":{"status":{"$eq":"%s"}}}`, OrderStatusUnaccepted)

	iterator, err := ctx.GetStub().GetPrivateDataQueryResult(collection, query)
	if err != nil {
		return nil, fmt.Errorf("function GetOrdersUnaccepted: failed to query world state: %v", err)
	}
	defer iterator.Close()

	var orders []*OrderInfo

	for iterator.HasNext() {
		response, err := iterator.Next()
		if err != nil {
			return nil, err
		}

		order := &OrderInfo{}
		err = json.Unmarshal(response.Value, order)
		if err != nil {
			return nil, fmt.Errorf("function GetOrdersUnaccepted: failed to unmarshal JSON: %v", err)
		}

		orders = append(orders, order)
	}

	return orders, nil
}
