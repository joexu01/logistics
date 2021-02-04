/* created by joexu01@UESTC */
/* The chaincode depends on Hyperledger Fabric V2.2 LTS */

package chaincode

const (
	CompositeKeyProduct          = "product"
	CompositeKeyOrder            = "order"
	CompositeKeyLogistics        = "logistics"
	CompositeKeyLogisticsPrivate = "logistics_pri"

	TransientKeyOrderInput            = "order_input"
	TransientKeyLogisticOperatorInput = "operator_info"

	MSPIDManufacturer = "ManufacturerMSP"
	MSPIDRetailer1    = "Retailer1MSP"
	MSPIDRetailer2    = "Retailer2MSP"
	MSPIDLogistic     = "LogisticMSP"
	MSPIDRegulator    = "RegulatorMSP"

	CollectionTransaction1 = "transactionCollection1"
	CollectionTransaction2 = "transactionCollection2"
	CollectionLogistics    = "logisticCollection"
)
