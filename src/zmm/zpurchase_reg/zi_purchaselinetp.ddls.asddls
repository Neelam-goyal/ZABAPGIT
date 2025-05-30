@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Line Interface View'
define view entity ZI_purchaselineTP
  as projection on ZR_purchaselineTP as purchaseline
{
  key Companycode,
  key Fiscalyearvalue,
  key Supplierinvoice,
  key Supplierinvoiceitem,
  Postingdate,
  Plantname,
  Plantadr,
  Plantcity,
  Plantgst,
  Plantpin,
  Product,
  Productname,
  Purchaseorder,
  Purchaseorderitem,
  Baseunit,
  Profitcenter,
  Purchaseordertype,
  Purchaseorderdate,
  Purchasingorganization,
  Purchasinggroup,
  Mrnquantityinbaseunit,
  Mrnpostingdate,
  Hsncode,
  Taxcodename,
  Originalreferencedocument,
  Igst,
  Sgst,
  Cgst,
  Rateigst,
  Ratecgst,
  Ratesgst,
  JournaldocumentrefID,
  Journaldocumentdate,
  Isreversed,
  Basicrate,
  Poqty,
  Pouom,
  Netamount,
  Taxamount,
  Roundoff,
  Manditax,
  Mandicess,
  Discount,
  Totalamount,
  Freight,
  Insurance,
  Ecs,
  Epf,
  Othercharges,
  Packaging,
          
  
  
  
  _purchaseinv : redirected to parent ZI_purchaseinvTP
  
}
