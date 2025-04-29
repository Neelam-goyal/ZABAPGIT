@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise Deduction Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PMTADVDEDUCT as projection on ZR_PMTADVDEDUCT as PmtAdvDeduction
{
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
    _PmtAdvHeader  : redirected to parent ZI_PMTADVHEADER
    
}
