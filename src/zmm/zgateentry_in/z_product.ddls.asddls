@EndUserText.label: 'product detail'
@Search.searchable: false
@UI.headerInfo: {typeName: 'product'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity Z_product as select from I_Product
 association [0..1] to I_ProductDescription as _Product
    on $projection.Product = _Product.Product
 association [0..1] to I_ProductPlantBasic as _ProductPlant
    on $projection.Product = _ProductPlant.Product
   
{
    key Product,
    _Product.ProductDescription,
    BaseUnit,
    _ProductPlant.Plant
}
