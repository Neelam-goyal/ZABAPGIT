@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise BarDana Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PMTADVBDSUMM as projection on ZR_PMTADVBDSUMM
{
    key PaymentAdviseNumber,
    key ItemNo,    
    Material,
    @Semantics.quantity.unitOfMeasure : 'BagsUOM'
    ReceivedBags,
    BagsUOM,
    @Semantics.quantity.unitOfMeasure : 'BDUnitWeightUOM'
    BDUnitWeight,
    BDUnitWeightUOM,
    @Semantics.quantity.unitOfMeasure : 'BDNetWeightUOM'
    BDNetWeight,
    BDNetWeightUOM,
    @Semantics.quantity.unitOfMeasure : 'WeightPerBagUOM'
    WeightPerBag,
    WeightPerBagUOM,
    @Semantics.quantity.unitOfMeasure : 'MSNetWeightUOM'
    MSNetWeight,
    MSNetWeightUOM,
     CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _PmtAdvHeader: redirected to parent ZI_PMTADVHEADER
    
}
