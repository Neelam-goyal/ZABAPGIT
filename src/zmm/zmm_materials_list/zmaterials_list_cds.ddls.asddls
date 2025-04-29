//@AbapCatalog.sqlViewName: ''
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Material List Cds Entity'
//@Metadata.ignorePropagatedAnnotations: true
//define view ZMaterials_List_cds as select from data_source_name
//{
//
//}
 
@EndUserText.label: 'Materials List'
//@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MATERIALS_LIST'
@UI.headerInfo : { typeName : 'Materials List Report'  ,
                   typeNamePlural : 'Materials List Report'
                    }
 
define custom entity ZMaterials_List_cds
{
      @UI.facet                   : [{ purpose: #STANDARD ,
                     type         : #IDENTIFICATION_REFERENCE  ,
                     position     : 1 ,
                     label        : 'MATNR' }]
 
      @UI.selectionField          : [{ position: 1 }]
      @UI.lineItem                : [{ position: 2 , label: 'Material Number' }]
//            @Search.defaultSearchElement: true
  key PRODUCT                     : abap.char(40);
 
//            @Search.defaultSearchElement: true
      @UI.selectionField          : [{ position: 2 }]
      @UI.lineItem                : [{ position: 20 , label: 'Plant' }]
  key PLANT                       : abap.char(5);
 
      @UI.lineItem                : [{ position: 130 , label: 'Storage Location' }]
   key   STORAGELOCATION             : abap.char(10);
   
   @UI.lineItem                : [{ position: 120 , label: 'Distribution Channel' }]
  key    PRODUCTDISTRIBUTIONCHNL     : abap.char(10);
 
 
      @UI.lineItem                : [{ position: 1 , label: 'Old Material Number' }]
      PRODUCTOLDID                : abap.char(40);
 
      @UI.lineItem                : [{ position: 10 , label: 'Material Description' }]
      PRODUCTDESCRIPTION          : abap.char(100);
 
      @UI.lineItem                : [{ position:11  , label: 'Creation Date' }]
      CREATIONDATE                : abap.dats;
 
 
      @UI.lineItem                : [{ position: 30 , label: 'Plant Name' }]
      PLANTNAME                   : abap.char(40);
 
      @UI.lineItem                : [{ position: 40 , label: 'Material UOM' }]
      BASEUNIT                    : abap.char(3);
 
      @UI.lineItem                : [{ position: 50 , label: 'Material Type' }]
      PRODUCTTYPE                 : abap.char(10);
 
      @UI.lineItem                : [{ position: 60 , label: 'Material Type Description' }]
      MATERIALTYPENAME            : abap.char(40);
 
      @UI.lineItem                : [{ position: 70 , label: 'Material Group' }]
      PRODUCTGROUP                : abap.char(10);
 
      @UI.lineItem                : [{ position: 80 , label: 'Material Group Description' }]
      MATERIALGROUPTEXT           : abap.char(10);
 
      @UI.lineItem                : [{ position: 90 , label: 'Gross Weight' }]
      GROSSWEIGHT                 : abap.dec(13,2);
 
      @UI.lineItem                : [{ position: 100 , label: 'Net Weight' }]
      NETWEIGHT                   : abap.dec(13,2);
 
      @UI.lineItem                : [{ position: 110 , label: 'Sales Organization' }]
      PRODUCTSALESORG             : abap.char(10);
 
      
 
      @UI.lineItem                : [{ position: 140 , label: 'Price' }]
      STANDARDPRICE               : abap.dec(13,2);
 
      @UI.lineItem                : [{ position: 150 , label: 'Valuation Class' }]
      VALUATIONCLASS              : abap.char(4);
 
      @UI.lineItem                : [{ position: 160 , label: 'Valuation Class Description' }]
      VALUATIONCLASSDESCRIPTION   : abap.char(40);
 
      @UI.lineItem                : [{ position: 170 , label: 'QM Indicator' }]
      HASPOSTTOINSPECTIONSTOCK    : abap.char(1);
 
      @UI.lineItem                : [{ position: 180 , label: 'HSN Code' }]
      CONSUMPTIONTAXCTRLCODE      : abap.char(10);
 
      @UI.lineItem                : [{ position: 185 , label: 'Account Assignment Group' }]
      ACCOUNTDETNPRODUCTGROUP     : abap.char(2);
 
      @UI.lineItem                : [{ position: 190 , label: 'Price Control' }]
      INVENTORYVALUATIONPROCEDURE : abap.char(1);
 
 
 
 
      @UI.lineItem                : [{ position: 200 , label: 'Procurement Type' }]
      PROCUREMENTTYPE             : abap.char(1);
 
      @UI.lineItem                : [{ position: 210 , label: 'MRP Type' }]
      MRPTYPE                     : abap.char(2);
 
      @UI.lineItem                : [{ position: 220 , label: 'MRP Group' }]
      MRPGROUP                    : abap.char(4);
 
      @UI.lineItem                : [{ position: 230 , label: 'MRP Controller' }]
      MRPRESPONSIBLE              : abap.char(3);
 
      @UI.lineItem                : [{ position: 240 , label: 'Lot Size' }]
      LOTSIZINGPROCEDURE          : abap.char(2);
 
      @UI.lineItem                : [{ position: 250 , label: 'Reorder Point' }]
      REORDERTHRESHOLDQUANTITY    : abap.dec(13,3);
 
      @UI.lineItem                : [{ position: 260 , label: 'Safety Stock' }]
      SAFETYSTOCKQUANTITY         : abap.dec(13,3);
 
      @UI.lineItem                : [{ position: 270 , label: 'Maximum Stock Level' }]
      MAXIMUMSTOCKQUANTITY        : abap.dec(13,3);
 
      @UI.lineItem                : [{ position: 280 , label: 'Min Lot Size' }]
      MINIMUMLOTSIZEQUANTITY      : abap.dec(13,3);
 
      @UI.lineItem                : [{ position: 290 , label: 'Availablity Check' }]
      AVAILABILITYCHECKTYPE       : abap.char(2);
 
      @UI.lineItem                : [{ position: 300 , label: 'Plant-sp.matl status of MRP' }]
      PROFILECODE                 : abap.char(2);
 
      @UI.lineItem                : [{ position: 310 , label: 'Cross-Plant Material Status' }]
      CROSSPLANTSTATUS            : abap.char(2);
 
      @UI.lineItem                : [{ position: 320 , label: 'DF-Plant Level ' }]
      ISMARKEDFORDELETION         : abap.char(1);
 
      @UI.lineItem                : [{ position: 260 , label: 'X-distr.chain status' }]
      SALESSTATUS                 : abap.char(2);
 
      @UI.lineItem                : [{ position: 260 , label: 'X-distr.chain Valid from' }]
      SALESSTATUSVALIDITYDATE     : abap.dats;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
}
