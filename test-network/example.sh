peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"InitCollections","Args":[]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"ShowIdentity","Args":[]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"NewProductInfo","Args":["10001","200","测试产品1","成都"]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"NewProductInfo","Args":["10002","500","测试产品2","厦门"]}'

peer chaincode query -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"ReadProductInfo","Args":["10002"]}'

peer chaincode query -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"ReadOrderInfo","Args":["20001","transactionCollection2"]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C "${CHANNEL_NAME}" -n "${CC_NAME}" -c '{"function":"UpdateLogisticRecord","Args":["30001","制造商已发货，正在等待售货员揽收"]}'
