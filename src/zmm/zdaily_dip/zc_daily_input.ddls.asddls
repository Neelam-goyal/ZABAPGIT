@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Daily Input'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_DAILY_INPUT as projection on ZI_DAILY_INPUT
{
    key Plant,
    key Tankno,
    key Product,
    key Pdate,
    Tankdescription,
    Tanksafecapacity,
    Tankdipcm,
    Parcelunloaded,
    Qtyunloaded,
      Qtymt,
    Totalavlstock,
//////    Diptime,
    BookStock,
    Variance,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    
     _TankMaster 
}
