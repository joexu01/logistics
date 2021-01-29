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

	MSPIDManufacturer = "Manufacturer"
	MSPIDRetailer1    = "Retailer1"
	MSPIDRetailer2    = "Retailer2"
	MSPIDLogistic     = "Logistic"
	MSPIDRegulator    = "Regulator"

	CollectionTransaction1 = "transactionCollection1"
	CollectionTransaction2 = "transactionCollection2"
	CollectionLogistics    = "logisticCollection"
)
