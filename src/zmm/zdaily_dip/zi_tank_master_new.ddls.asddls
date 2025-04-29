@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption for TABLE'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}define root view entity ZI_TANK_MASTER_NEW as select from ztank_master_new
{
  key plant as Plant,
  key storagelocation as Tankno,
  key material as Product,
  materialdescription as Materialdescription,
  storagelocationname as Storagelocationname,
  validitystartdate as Validitystartdate,
  validityenddate as Validityenddate,
  tankmaximumcapacity as Tankmaximumcapacity,
  tanksafecapacity as Tanksafecapacity,
  capacitytype as Capacitytype,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
}






//define root view entity ZI_TANK_MASTER_NEW
//  as select from ztank_master_new
//  association [0..1] to I_StorageLocation as _StorageLocation on  $projection.Plant = _StorageLocation.Plant
//                                                             and $projection.Tankno = _StorageLocation.StorageLocation
////                                                             and $projection.Product = _StorageLocation.m
//{
//    key plant as Plant,
//    key storagelocation as Tankno,
//    key material as Product,
//    storagelocationname as Storagelocationname,
//    validitystartdate as Validitystartdate,
//    validityenddate as Validityenddate,
//    tankmaximumcapacity as Tankmaximumcapacity,
//    tanksafecapacity as Tanksafecapacity,
//    capacitytype as Capacitytype,
//    @Semantics.user.createdBy: true
//    created_by as CreatedBy,
//    @Semantics.systemDateTime.createdAt: true
//    created_at as CreatedAt,
//    @Semantics.user.lastChangedBy: true
//    last_changed_by as LastChangedBy,
//    @Semantics.systemDateTime.lastChangedAt: true
//    last_changed_at as LastChangedAt,
//    
//    /* Associations */
//    _StorageLocation
//}
