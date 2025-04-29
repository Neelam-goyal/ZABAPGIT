@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BILLINGDOCUMENT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_BILLINGDOCUMENT as select from I_BillingDocumentItem
{
    key BillingDocument,
    key BillingDocumentItem,
    Product,
    Plant,
    @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
    BillingQuantity,
    BillingQuantityUnit,
    BaseUnit,
    ReferenceSDDocument,
    ReferenceSDDocumentItem
   
}
