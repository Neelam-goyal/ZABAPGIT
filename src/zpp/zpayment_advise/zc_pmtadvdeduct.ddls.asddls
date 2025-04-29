@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise Deduction Projection CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'PaymentAdviseNumber' ]
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_PMTADVDEDUCT as projection on ZR_PMTADVDEDUCT
{
 @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    key PaymentAdviseNumber,
    key ItemNo,    
    Particulars,
    Type,
    ConditionNumber,
    Actual,
    Final,
    Difference,
     @Semantics.amount.currencyCode: 'Currency'
    DeductionAmount,
    Currency,
     CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    
    /* Associations */
    _PmtAdvHeader : redirected to parent ZC_PMTADVHEADER
}
