package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
)

type Identity struct {
	RawID     string `json:"raw_id"`
	DecodedID string `json:"decoded_id"`
	MspID     string `json:"msp_id"`
	Creator   string `json:"creator"`
}

type orderInput struct {
	OrderNumber string `json:"order_number"`
	//BatchNumber    string  `json:"batch_number"`
	//TrackingNumber string  `json:"tracking_number"`
	//Sorter         string  `json:"sorter"` // 分拣员
	UnitPrice   float32 `json:"unit_price"`
	Quantity    int     `json:"quantity"`
	Collection  string  `json:"collection"`
	ProductName string  `json:"product_name"`
}

type acceptOrderInput struct {
	BatchNumber    string `json:"batch_number"`
	TrackingNumber string `json:"tracking_number"`
	Sorter         string `json:"sorter"` // 分拣员
}

const baseDir = "/home/joseph/fabric-tests/logistics-test-3/test-network"
const TransientKeyOrderInput = "order_input"
const TransientKeyLogisticOperatorInput = "operator_info"
const TransientKeyAcceptOrderInput = "accept_order_input"

const (
	OrderStatusAccepted   = "Accepted"
	OrderStatusRejected   = "Rejected"
	OrderStatusUnaccepted = "Unaccepted"
)

func main() {
	order := &orderInput{
		OrderNumber: "20003",
		UnitPrice:   20,
		Quantity:    10,
		Collection:  "transactionCollection1",
		ProductName: "乌龙茶",
	}
	bytes, err := json.Marshal(order)
	if err != nil {
		panic(bytes)
	}
	transient := base64.StdEncoding.EncodeToString(bytes)

	invoke, err := executeFuncUsingInvoke(
		"logisticschannel",
		"logisticscc",
		"NewOrder",
		``,
		TransientKeyOrderInput,
		transient)
	if err != nil {
		fmt.Println(string(invoke))
		panic(err)
	}

	fmt.Println(string(invoke))

	//acceptInput := &acceptOrderInput{
	//	BatchNumber:    "10002",
	//	TrackingNumber: "30001",
	//	Sorter:         "分拣01",
	//}
	//bytes, _ := json.Marshal(acceptInput)
	//
	//transient := base64.StdEncoding.EncodeToString(bytes)
	//
	//invoke, _ := executeFuncUsingInvoke(
	//	"logisticschannel",
	//	"logisticscc",
	//	"AcceptOrder",
	//	`"transactionCollection1","20001"`,
	//	TransientKeyAcceptOrderInput,
	//	transient)
	//fmt.Println(string(invoke))

	//
	//all := strings.ReplaceAll(string(invoke), `\`, ``)
	//
	//fmt.Println(all)
	//
	//invokeRe, err := regexp.Compile(`.+status:([0-9]+)[^p]+payload:"(.+"})`)
	//if err != nil {
	//	panic(err)
	//}
	//subMatch := invokeRe.FindSubmatch([]byte(all))
	//for _, each := range subMatch {
	//	fmt.Println(string(each), "OK")
	//}

	//id := &Identity{}
	//_ = json.Unmarshal(subMatch[2], id)
	//fmt.Println(id.MspID)
}

func executeFuncUsingInvoke(channel, ccName, function, args, transientKey string, transientData string) ([]byte,
	error) {
	var cmd *exec.Cmd
	if transientKey == "" {
		cmd = exec.Command("bin/peer", "chaincode", "invoke", "-o", "localhost:7050", "--ordererTLSHostnameOverride",
			`orderer.example.com`, `--tls`, `--cafile`,
			baseDir+`/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem`,
			`-C`, channel, "-n", ccName, "-c", `{"function":"`+function+`","Args":[`+args+`]}`)
	} else {
		cmd = exec.Command("bin/peer", "chaincode", "invoke", "-o", "localhost:7050", "--ordererTLSHostnameOverride",
			`orderer.example.com`, `--tls`, `--cafile`,
			baseDir+`/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem`,
			`-C`, channel, "-n", ccName, "-c", `{"function":"`+function+`","Args":[`+args+`]}`, `--transient`,
			`{"`+transientKey+`":"`+transientData+`"}`)
	}

	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env,
		"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
		`PEER0_RETAILER1_CA=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/retailer1.example.com/peers/peer0.retailer1.example.com/tls/ca.crt`,
		`CORE_PEER_TLS_ENABLED=true`,
		`CORE_PEER_LOCALMSPID=Retailer1MSP`,
		`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/retailer1.example.com/peers/peer0.retailer1.example.com/tls/ca.crt`,
		`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/retailer1.example.com/users/Admin@retailer1.example.com/msp`,
		`CORE_PEER_ADDRESS=localhost:11051`,
	)
	//cmd.Env = append(cmd.Env,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`CORE_PEER_TLS_ENABLED=true`,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`CORE_PEER_LOCALMSPID=ManufacturerMSP`,
	//	`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt`,
	//	`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp`,
	//	`CORE_PEER_ADDRESS=localhost:7051`,
	//)

	//cmd.Env = append(cmd.Env,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`CORE_PEER_TLS_ENABLED=true`,
	//	`CORE_PEER_LOCALMSPID=LogisticsMSP`,
	//	`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/ca.crt`,
	//	`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com/msp`,
	//	`CORE_PEER_ADDRESS=localhost:9051`,
	//)

	bytes, err := cmd.CombinedOutput()
	if err != nil {
		return bytes, err
	}
	return bytes, nil
}
