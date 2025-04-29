@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Gate Purchase Record'
define root view entity ZI_GATEPURCHSEReco
  as select from Z_GATEPURCHASEREC
{
    key Gateentryno,
        Gateno,
        Entrytype,
        Documentno,
        DocumentQty
}
