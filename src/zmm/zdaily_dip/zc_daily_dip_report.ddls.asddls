@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Daily DIP Report'
@Metadata.allowExtensions: true
define root view entity ZC_DAILY_DIP_REPORT 
     provider contract transactional_query
    as projection on ZCDS_DAILY_DIP_REPORT
{
    key Plant,
    key Tankno,
    key Product,
    key Pdate,
    Tankdescription,
    Tanksafecapacity,
    Tankdipcm,
    Qtymt,
    Parcelunloaded,
    Qtyunloaded,
    Totalavlstock,
    Bookstock,
    Variance,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt
}
