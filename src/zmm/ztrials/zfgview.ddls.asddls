@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'FG visibility Consumption View'


define transient view entity ZFGView
provider contract analytical_query
as projection on ZFGCUBE
{
    @EndUserText.label: 'Product'
    @AnalyticsDetails.query.axis: #ROWS
    Product,
    @EndUserText.label: 'Plant'
    @AnalyticsDetails.query.axis: #ROWS
    Plant,
    @EndUserText.label: 'Base UOM'
    @AnalyticsDetails.query.axis: #ROWS
    BaseUnit,
    @EndUserText.label: 'Product Description'
    @AnalyticsDetails.query.axis: #ROWS
    ProductDescription,
    @EndUserText.label: 'On Hand Qty.'
    @AnalyticsDetails.query.axis: #COLUMNS
    OnHandQty,
    @EndUserText.label: 'On Hand Qty.'
    @AnalyticsDetails.query.axis: #COLUMNS
    QtyonQuotation,
    @EndUserText.label: 'On Hand Qty.'
    @AnalyticsDetails.query.axis: #COLUMNS
    QtyonSalesOrder
  
}
