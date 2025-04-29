@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Combined CDS (Header + Line)'
define view entity Z_GATEPURCHASEREC
  as select from ZR_GateEntryHeader as Header
    left outer join ZR_GateEntryLines as Line
      on Header.Gateentryno = Line.Gateentryno
{
    key Header.Gateentryno       as Gateentryno,
        Header.Entrytype         as Entrytype,
        Header.Gateno            as Gateno,
        Line.Documentno          as Documentno,
        Line.Documentqty         as DocumentQty
}
