@EndUserText.label: 'Delivery CDS'
@Search.searchable: false
@UI.headerInfo: {typeName: 'Custom CDS for Delivery Item'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity zdelivery_item
  as select from I_DeliveryDocumentItem
  association [0..1] to I_ProductDescription as _Product
    on $projection.Product = _Product.Product
{
      @UI.lineItem   : [{ position:1, label:'Delivery Document' }]
      key DeliveryDocument,

      @UI.lineItem   : [{ position:2, label:'Item' }]
      key DeliveryDocumentItem,

      @UI.lineItem   : [{ position:3, label:'Plant' }]
      Plant,

      @UI.lineItem   : [{ position:4, label:'Product Code' }]
      Product,

      @UI.lineItem   : [{ position:5, label:'Product Description' }]
      _Product.ProductDescription,
      
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      @UI.hidden: true
      OriginalDeliveryQuantity,    

      @UI.lineItem   : [{ position:6, label:'Quantity' }]
      cast(OriginalDeliveryQuantity as abap.dec(13,3)) as QuantityWithoutUOM, 
      
      @UI.lineItem   : [{ position:7, label:'UOM' }]
      BaseUnit,

      _Product
}
