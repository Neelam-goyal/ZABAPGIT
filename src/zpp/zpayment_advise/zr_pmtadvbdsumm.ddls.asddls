@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise BarDana Summary CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_PMTADVBDSUMM as select from zpmtadvbdsumm as _PmtAmtBDSumm
association to parent ZR_PMTADVHEADER as _PmtAdvHeader on $projection.PaymentAdviseNumber = _PmtAdvHeader.PaymentAdviseNumber
{
    key pmtadvno as PaymentAdviseNumber,
    key itemno as ItemNo,    
    material as Material,
    @Semantics.quantity.unitOfMeasure: 'BagsUOM'
    rcvdbags as ReceivedBags,
    bagsuom as BagsUOM,
    
    @Semantics.quantity.unitOfMeasure: 'BDUnitWeightUOM'
    bdnunitwt as BDUnitWeight,
    bdnunitwtuom as BDUnitWeightUOM,
    
    @Semantics.quantity.unitOfMeasure: 'BDNetWeightUOM'
    bdnwt as BDNetWeight,
    bdnwtuom as BDNetWeightUOM,
    
    @Semantics.quantity.unitOfMeasure: 'WeightPerBagUOM'
    wtperbag as WeightPerBag,
    wtperbaguom as WeightPerBagUOM,
    
    @Semantics.quantity.unitOfMeasure: 'MSNetWeightUOM'
    msnetwt as MSNetWeight,
    mswtuom as MSNetWeightUOM,
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
    _PmtAdvHeader

}
