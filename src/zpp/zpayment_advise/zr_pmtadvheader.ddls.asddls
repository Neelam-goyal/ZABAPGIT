@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise Header CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PMTADVHEADER as select from zpmtadvheader as _PmtAdvHeader
composition [0..*] of ZR_PMTADVBDSUMM as _PmtAmtBDSumm 
composition [0..*] of ZR_PMTADVDEDUCT as _PmtAmtDeduct
//association [0..1] to zpmtadvmtsumm as _PmtAdvMtSumm on _PmtAdvMtSumm.pmtadvno = $projection.PaymentAdviseNumber

{
    key pmtadvno as PaymentAdviseNumber,
    grnno as GRNNumber,
    grndate as GRNDate,
    duedate as DueDate,
    inspectionlot as InspectionLot,
    brokername as BrokerName,
    suppliername as SupplierName,
    bargainno as BargainNumber,
    bargaindate as BargainDate,
    place as Place,
    ponumber as PONumber,
    invoiceno as InvoiceNumber,
    vehicleno as VehicleNumber,
    invoicedate as InvoiceDate,
//    _PmtAdvMtSumm.material as Material,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceBagsUOM'
//    _PmtAdvMtSumm.invbags as InvoicedBags,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceBagsUOM'
//    _PmtAdvMtSumm.rcvdbags as ReceivedBags,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.invwt as InvoiceWeight,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.rcvdwt as ReceivedWeight,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.shortwt as ShortWeight,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.msnetwt as MSNetWeight,
//    @Semantics.amount.currencyCode: 'InvoiceCurrency'
//    _PmtAdvMtSumm.invrate as InvoiceRate,
//    @Semantics.amount.currencyCode: 'InvoiceCurrency'
//    _PmtAdvMtSumm.invtaxableamt as InvoiceTaxableAmount,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.rcvdgr as ReceivedGross,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.rcvdtr as ReceivedTare,
//    @Semantics.quantity.unitOfMeasure: 'InvoiceWeightUOM'
//    _PmtAdvMtSumm.rcvdnt as ReceivedNet,
//    _PmtAdvMtSumm.currency as InvoiceCurrency,
//    _PmtAdvMtSumm.bagsuom as InvoiceBagsUOM,
//    _PmtAdvMtSumm.wtuom as InvoiceWeightUOM,    
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.localInstanceLastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    _PmtAmtBDSumm,
    _PmtAmtDeduct

    
}
