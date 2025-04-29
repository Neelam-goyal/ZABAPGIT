@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant Purchase Organisation CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPlantPurchaseOrg as select from I_PlantPurchasingOrganization as PPO
{
    key PPO.Plant,
    key PPO.PurchasingOrganization
}
