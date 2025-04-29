@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_GSTUOM
  provider contract transactional_query
  as projection on ZR_GSTUOM
{
  key Bukrs,
  key Uom,
  Gstuom,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
