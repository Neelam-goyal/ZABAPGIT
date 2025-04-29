    @AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Z_Purchaseorder'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_PURCHSEORDER as select from I_PurchaseOrderAPI01
{
   key PurchaseOrder                            as                  DocumentNo,
   key 'PUR'                                    as                  EntryType,
   key _PurchaseOrderItem.Material              as                  DocumentItem,
   key _PurchaseOrderItem.PurchaseOrderItem     as                  PurchaseorderItem,
    _PurchaseOrderItem.PurchaseOrderItemText    as                  DocumentItemText,
    PurchaseOrderDate                           as                  DocumentDate,
    PurchaseOrderType                           as                  DocumentType,
    Supplier                                    as                  InvoicingParty,
    _Supplier.SupplierName                      as                  InvoicingPartyName,
    CompanyCode                                 as                  CompanyCode,
    _PurchaseOrderItem.Plant                    as                  Plant,
    _PurchaseOrderItem.StorageLocation          as                  StorageLocation,
   
    @Semantics.quantity.unitOfMeasure: 'DocumentItemQtyUnit'
    _PurchaseOrderItem.OrderQuantity            as                  DocumentItemQty,
    @Semantics.amount.currencyCode: 'DocumentCurrency'  
    _PurchaseOrderItem.NetAmount                as                  DocumentItemPrice,
    _PurchaseOrderItem.DocumentCurrency         as                  DocumentCurrency,
    _PurchaseOrderItem.PurchaseOrderQuantityUnit            as  DocumentItemQtyUnit
}
