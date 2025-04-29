@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZRAPC_PRODUCT_TABLE
  provider contract TRANSACTIONAL_QUERY
  as projection on ZRAPR_PRODUCT_TABLE
{
  key Product,
  ProductDescription,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
