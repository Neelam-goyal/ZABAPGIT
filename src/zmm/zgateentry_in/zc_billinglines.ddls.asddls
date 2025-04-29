@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GATE ENTRY BILLING LINE PROJECTION'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'Billingdocument' ]
@Search.searchable: true
define view entity ZC_BILLINGLINES 
as projection on Z_BILLINGLINES as GateBillingLines
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    key Billingdocument,
    key Billingdocumentitem,
    Gateentryno,
    Product,
    Plant, 
    Billingquantity,
    Baseunit,
    Referencesddocument,
    Referencesddocumentitem,
    /* Associations */
     _GateEntryHeader : redirected to parent ZC_GateEntryHeader
}
