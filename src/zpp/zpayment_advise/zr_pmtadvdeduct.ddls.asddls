@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advise For Deduction CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_PMTADVDEDUCT as select from zpmtadvdeduct
association to parent ZR_PMTADVHEADER as _PmtAdvHeader on $projection.PaymentAdviseNumber = _PmtAdvHeader.PaymentAdviseNumber
{
    key pmtadvno as PaymentAdviseNumber,
    key itemno as ItemNo,    
    particulars as Particulars,
    type as Type,
    cond as ConditionNumber,
    actual as Actual,
    final as Final,
    diff as Difference,
    @Semantics.amount.currencyCode: 'Currency'
    deducamt as DeductionAmount,
    currency as Currency,
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
