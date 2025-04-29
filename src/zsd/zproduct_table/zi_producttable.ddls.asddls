@EndUserText.label: 'Product Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZI_ProductTable
  as select from zproduct_table
  association to parent ZI_ProductTable_S as _ProductTableAll on $projection.SingletonID = _ProductTableAll.SingletonID
{
 @Search.defaultSearchElement: true
  key product as Product,
  product_description as ProductDescription,
  @Consumption.hidden: true
  1 as SingletonID,
  _ProductTableAll
  
}
