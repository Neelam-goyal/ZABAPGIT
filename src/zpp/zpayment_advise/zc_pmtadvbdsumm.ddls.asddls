@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Payment Advise BarDana Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'PaymentAdviseNumber' ]
@Search.searchable: true
define view entity ZC_PMTADVBDSUMM as projection on ZR_PMTADVBDSUMM as PmtAdvBDSumm
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
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
    _PmtAdvHeader : redirected to parent ZC_PMTADVHEADER
}
