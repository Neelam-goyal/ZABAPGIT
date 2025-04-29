@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'FG Visibility Fact Cube'
@Metadata.ignorePropagatedAnnotations: true

@Analytics.dataCategory: #CUBE
@Analytics.internalName: #LOCAL

define view entity ZFGCUBE as select from ZFGAGGR
{
  key Product,
  key Plant,
  BaseUnit,
  ProductDescription,
  @DefaultAggregation: #SUM
  OnHandQty,
  @DefaultAggregation: #SUM
  QtyonQuotation,
  @DefaultAggregation: #SUM
  QtyonSalesOrder
    
}
