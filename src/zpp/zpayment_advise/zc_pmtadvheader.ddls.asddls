@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Payment Advise Header Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'PaymentAdviseNumber' ]
@Search.searchable: true
define root view entity ZC_PMTADVHEADER  
provider contract transactional_query
 as projection on ZR_PMTADVHEADER as PmtAdvHeader
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    @UI.connectedFields: [{label: 'Payment Advise'}]
    key PaymentAdviseNumber,
    @UI.connectedFields: [{label: 'GRN'}]
    GRNNumber,
    GRNDate,
    DueDate,
    InspectionLot,
    BrokerName,
    SupplierName,
    BargainNumber,
    BargainDate,
    PONumber,
    Place,
    InvoiceNumber,
    VehicleNumber,
    InvoiceDate,
//    Material,
//      @Semantics.quantity.unitOfMeasure : 'InvoiceBagsUOM'
//    InvoicedBags,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceBagsUOM'
//    ReceivedBags,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    InvoiceWeight,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    ReceivedWeight,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    ShortWeight,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    MSNetWeight,
//     @Semantics.amount.currencyCode : 'InvoiceCurrency'
//    InvoiceRate,
//     @Semantics.amount.currencyCode : 'InvoiceCurrency'
//    InvoiceTaxableAmount,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    ReceivedGross,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    ReceivedTare,
//    @Semantics.quantity.unitOfMeasure : 'InvoiceWeightUOM'
//    ReceivedNet,
//    InvoiceCurrency,
//    InvoiceBagsUOM,
//    InvoiceWeightUOM,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GATETIMEDIFF'
    @EndUserText.label: 'Time Difference'
    virtual Timedifference : abap.int2,
    /* Associations */
    _PmtAmtBDSumm : redirected to composition child ZC_PMTADVBDSUMM,
    _PmtAmtDeduct : redirected to composition child ZC_PMTADVDEDUCT
}
