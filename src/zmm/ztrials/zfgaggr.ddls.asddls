@AbapCatalog.sqlViewName: 'Z_FGAGGR'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FG Visibility Fact Aggregation'
@Analytics.dataCategory: #FACT
define view ZFGAGGR as select from ZFGFACT
{
  Product,
  Plant,
  BaseUnit,
  ProductDescription,
  sum(stockinhand) as OnHandQty,
  sum(QuoteOrderQty) as QtyonQuotation,
  sum(SalesOrderQty) as QtyonSalesOrder
    
}
group by Product,
  Plant,
  BaseUnit,
  ProductDescription
