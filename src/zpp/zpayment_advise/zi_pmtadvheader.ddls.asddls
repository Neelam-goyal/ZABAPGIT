@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise Header Interface View'
define root view entity ZI_PMTADVHEADER
 provider contract transactional_interface
  as projection on ZR_PMTADVHEADER
{
    key PaymentAdviseNumber,
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
//    @Semantics.quantity.unitOfMeasure : 'InvoiceBagsUOM'
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
    /* Associations */
    _PmtAmtBDSumm : redirected to composition child ZI_PMTADVBDSUMM,
    _PmtAmtDeduct : redirected to composition child ZI_PMTADVDEDUCT
}
