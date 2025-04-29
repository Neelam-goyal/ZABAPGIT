@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for SAP BOOK (Daily DIP Input)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SAP_BOOK_VH_DI   
    with parameters P_DisplayCurrency : abap.cuky( 5 )
    as select from I_StockQuantityCurrentValue_2(P_DisplayCurrency: $parameters.P_DisplayCurrency)
{
    key Product,
    key Plant,
    key StorageLocation,
@UI.hidden: true
  key Batch,
 @UI.hidden: true
  key Supplier,
  @UI.hidden: true
  key SDDocument,
  @UI.hidden: true
  key SDDocumentItem,
  @UI.hidden: true
  key WBSElementInternalID,
  @UI.hidden: true
  key Customer,
@UI.hidden: true
  key SpecialStockIdfgStockOwner,
  @UI.hidden: true
  Currency,
  
    @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
    MatlWrhsStkQtyInMatlBaseUnit as StockQuantity,
    MaterialBaseUnit
}





//    with parameters 
//        P_DisplayCurrency : abap.cuky( 5 )
//    as select from ZI_TANK_MASTER_NEW as a
//    inner join I_StockQuantityCurrentValue_2(P_DisplayCurrency: $parameters.P_DisplayCurrency) as b 
//        on  b.Plant = a.Plant
//        and b.StorageLocation = a.Storagelocation
//        and b.Product = a.Material   
//{
//    key a.Plant,
//    key a.Material as Product,
//    key a.Storagelocation as StorageLocation,
//    @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
//    cast( b.MatlWrhsStkQtyInMatlBaseUnit as abap.quan( 13, 3 ) ) as StockQuantity,
//    b.MaterialBaseUnit
//}




//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Value help for SAP BOOK (Daily DIP Input)'
//@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.usageType:{
//    serviceQuality: #X,
//    sizeCategory: #S,
//    dataClass: #MIXED
//}
//define view entity ZI_SAP_BOOK_VH_di with parameters P_DisplayCurrency : abap.cuky( 5 )
//    as select from ZI_TANK_MASTER_NEW as a
//    inner join I_StockQuantityCurrentValue_2(P_DisplayCurrency: $parameters.P_DisplayCurrency) as b on   b.Plant = a.Plant
//                                                  and  b.StorageLocation = a.Storagelocation
//                                                  and  b.Product = a.Material   
//{
//    key a.Plant,
//     @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
//    cast( b.MatlWrhsStkQtyInMatlBaseUnit as abap.quan( 13, 3 ) ) as StockQuantity,
////    @Semantics.unitOfMeasure: true
//    b.MaterialBaseUnit,
//    a.Material,
//    a.Storagelocation
//
//}
