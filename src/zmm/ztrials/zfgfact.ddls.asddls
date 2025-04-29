@AbapCatalog.sqlViewName: 'Z_FGFACT'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FG Visibility Fact'
@Analytics.dataCategory: #FACT
define view ZFGFACT as 
select from I_Productplantsales as pp
  join I_ProductPlantBasic as pb on pp.Product = pb.Product and pp.Plant = pb.Plant
  join I_ProductDescription as pd on pp.Product = pd.Product and pd.LanguageISOCode = 'EN'  
  left outer join I_MaterialStock_2 as sih 
    on pp.Plant = sih.Plant and pp.Product = sih.Material 
  left outer join I_SalesQuotationItem as qo on pp.Product = qo.Product and pp.Plant = qo.Plant 
  left outer join I_SalesQuotation as qh on qo.SalesQuotation = qh.SalesQuotation
  left outer join I_SalesOrderItem as so on pp.Product = so.Product and pp.Plant = so.Plant
  left outer join I_SalesOrder as sh on so.SalesOrder = sh.SalesOrder
{
  key pp.Product,
  key pp.Plant,
  pb.BaseUnit,
  pd.ProductDescription,
  cast( sih.MatlWrhsStkQtyInMatlBaseUnit as abap.dec( 12, 3 ) ) as stockinhand,
  qo.SalesQuotation,
  qh.SoldToParty as QuoteParty,
  cast(qo.RequestedQuantityInBaseUnit as abap.dec( 12, 3 ) ) as QuoteOrderQty,
  so.SalesOrder,
  sh.SoldToParty as OrderParty,
  cast(so.RequestedQuantityInBaseUnit as abap.dec( 12, 3 ) ) as SalesOrderQty
}
