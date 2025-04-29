@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GATE ENTRY BILLING LINE INTERFACE'
define view entity ZI_BILLINGLINES 
 as projection on Z_BILLINGLINES  as GateBillingLines
{
    key Billingdocument,
    key Billingdocumentitem,
    Gateentryno,
    Product,
    Plant,
    Billingquantity,
    Baseunit,
    Referencesddocument,
    Referencesddocumentitem,
    _GateEntryHeader : redirected to parent ZI_GateEntryHeader
}
