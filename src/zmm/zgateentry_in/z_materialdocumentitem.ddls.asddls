@EndUserText.label: 'Material Document Item'
@Search.searchable: false
@UI.headerInfo: {typeName: 'MaterialdocumentItem'}
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view entity Z_MaterialdocumentItem as select from I_MaterialDocumentItem_2
{
key PurchaseOrder,
@Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
QuantityInBaseUnit,
MaterialBaseUnit,
GoodsMovementType,
MaterialDocument,
Material,
PurchaseOrderItem
}
