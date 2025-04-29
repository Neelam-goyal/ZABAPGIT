@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption for TABLE'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_TANK_MASTER_NEW as projection on ZI_TANK_MASTER_NEW
{
    key Plant,
    key Tankno,
    key Product,
    Materialdescription,
    Storagelocationname,
    Validitystartdate,
    Validityenddate,
    Tankmaximumcapacity,
    Tanksafecapacity,
    Capacitytype,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt
}
