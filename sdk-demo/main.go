package main

import (
	"fmt"
	"io/ioutil"
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
	OrderNumber    string  `json:"order_number"`
	BatchNumber    string  `json:"batch_number"`
	TrackingNumber string  `json:"tracking_number"`
	Sorter         string  `json:"sorter"` // 分拣员
	UnitPrice      float32 `json:"unit_price"`
	Quantity       int     `json:"quantity"`
	Collection     string  `json:"collection"`
}

const baseDir = "/home/joseph/fabric-tests/logistics-test-3/test-network"
const TransientKeyOrderInput = "order_input"
const TransientKeyLogisticOperatorInput = "operator_info"

func main() {
	//addrs, err := net.InterfaceAddrs()
	//if err != nil{
	//	fmt.Println(err)
	//	return
	//}
	//for _, value := range addrs{
	//	if ipnet, ok := value.(*net.IPNet); ok && !ipnet.IP.IsLoopback(){
	//		if ipnet.IP.To4() != nil{
	//			if strings.HasPrefix(ipnet.IP.String(), "192.168") {
	//				fmt.Println(ipnet.IP.String())
	//			}
	//		}
	//	}
	//}
	_, err := ioutil.ReadDir(`app/app`)
	fmt.Printf("%+v", err)
	//order := &orderInput{
	//	OrderNumber:    "20001",
	//	BatchNumber:    "10001",
	//	TrackingNumber: "30001",
	//	Sorter:         "employee-01",
	//	UnitPrice:      20,
	//	Quantity:       10,
	//	Collection:     "transactionCollection2",
	//}
	//bytes, err := json.Marshal(order)
	//if err != nil {
	//	panic(bytes)
	//}
	//transient := base64.StdEncoding.EncodeToString(bytes)
	//
	//invoke, err := executeFuncUsingInvoke(
	//	"logisticschannel",
	//	"logisticscc",
	//	"NewOrder",
	//	``,
	//	TransientKeyOrderInput,
	//	transient)
	//if err != nil {
	//	fmt.Println(string(invoke))
	//	panic(err)
	//}

	//transient := base64.StdEncoding.EncodeToString([]byte(`快递员002`))
	//
	//invoke, err := executeFuncUsingInvoke(
	//	"logisticschannel",
	//	"logisticscc",
	//	"UpdateLogisticRecord",
	//	`"30001","发往中转"`,
	//	TransientKeyLogisticOperatorInput,
	//	transient)
	//if err != nil {
	//	fmt.Println(string(invoke))
	//	panic(err)
	//}
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
	//cmd.Env = append(cmd.Env,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`PEER0_MANUFACTURER_CA=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt`,
	//	`CORE_PEER_TLS_ENABLED=true`,
	//	`CORE_PEER_LOCALMSPID=ManufacturerMSP`,
	//	`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt`,
	//	`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp`,
	//	`CORE_PEER_ADDRESS=localhost:7051`,
	//)
	//cmd.Env = append(cmd.Env,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`CORE_PEER_TLS_ENABLED=true`,
	//	"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
	//	`CORE_PEER_LOCALMSPID=ManufacturerMSP`,
	//	`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt`,
	//	`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp`,
	//	`CORE_PEER_ADDRESS=localhost:7051`,	)

	cmd.Env = append(cmd.Env,
		"FABRIC_CFG_PATH=/home/joseph/fabric-tests/logistics-test-3/config/",
		`CORE_PEER_TLS_ENABLED=true`,
		`CORE_PEER_LOCALMSPID=LogisticsMSP`,
		`CORE_PEER_TLS_ROOTCERT_FILE=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/logistics.example.com/peers/peer0.logistics.example.com/tls/ca.crt`,
		`CORE_PEER_MSPCONFIGPATH=/home/joseph/fabric-tests/logistics-test-3/test-network/organizations/peerOrganizations/logistics.example.com/users/Admin@logistics.example.com/msp`,
		`CORE_PEER_ADDRESS=localhost:9051`,
		)

	bytes, err := cmd.CombinedOutput()
	if err != nil {
		return bytes, err
	}
	return bytes, nil
}
