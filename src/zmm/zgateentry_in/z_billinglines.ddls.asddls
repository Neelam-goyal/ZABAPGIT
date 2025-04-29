@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BILLING DOCUMENT LINES'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_BILLINGLINES as select from zgatebillingline as GateBillingLines
association to parent ZR_GateEntryHeader as _GateEntryHeader on $projection.Gateentryno = _GateEntryHeader.Gateentryno
{
    key billingdocument as Billingdocument,
    key billingdocumentitem as Billingdocumentitem, 
    gateentryno   as Gateentryno,  
    product as Product,
    plant as Plant,
    billingquantity as Billingquantity,
    baseunit as Baseunit,
    referencesddocument as Referencesddocument,
    referencesddocumentitem as Referencesddocumentitem,
    _GateEntryHeader
    
    
}
