@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Value Help for Tank Master'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MATERIAL_VH_TM
  with parameters
    p_Plant : abap.char(4)
  as select from I_StorageLocation
{
    @ObjectModel.text.element: ['StorageLocationName']
    @Search.defaultSearchElement: true
    key StorageLocation,
    
    @Search.defaultSearchElement: true
    key Plant,
    
    @Semantics.text: true
    @Search.defaultSearchElement: true
    StorageLocationName
}
where Plant = $parameters.p_Plant





// with parameters
//    p_Plant: abap.char(4)
//    as select from I_Plant
//    inner join I_StorageLocation on I_StorageLocation.Plant = I_Plant.Plant
//                                      and I_StorageLocation.Plant = I_Plant.Plant
//{
//    key I_Plant.Plant,
//    key I_StorageLocation.StorageLocation,
//    I_StorageLocation.StorageLocationName
//}
//where I_Plant.Plant = $parameters.p_Plant
//  and I_Plant.Plant is not initial
