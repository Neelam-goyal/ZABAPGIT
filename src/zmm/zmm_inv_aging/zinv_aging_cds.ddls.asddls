//@AbapCatalog.sqlViewName: ''
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Inventory aging Cds'
//@Metadata.ignorePropagatedAnnotations: true
//define view ZInv_aging_cds as select from data_source_name
//{
//
//}

@EndUserText.label: 'Materials List'
@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INV_AGING'
@UI.headerInfo : { typeName : 'Materials List Report'  ,
                   typeNamePlural : 'Inventory Aging Report'
                    }

define custom entity ZInv_aging_cds
{
      @UI.facet          : [{ purpose: #STANDARD ,
                     type: #IDENTIFICATION_REFERENCE  ,
                     position   : 1 ,
                     label      : 'MATNR' }]

      @UI.selectionField : [{ position: 1 }]
      @UI.lineItem       : [{ position: 1 , label: 'Plant' }]
      @Search.defaultSearchElement: true
  key PLANT              : abap.char(4);

      @UI.lineItem       : [{ position: 3 , label: 'Material Code' }]
      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position: 2 }]
  key PRODUCT            : abap.char(40);
  
   @UI.lineItem       : [{ position: 10 , label: 'Total Qty Of Stock' }]
    key  TOTALSTOCK         : abap.dec(17,2);

      @UI.lineItem       : [{ position: 2 , label: 'Plant Name' }]
      PLANTNAME          : abap.char(30);

      @UI.lineItem       : [{ position: 4 , label: 'Material Description' }]
      PRODUCTDESCRIPTION : abap.char(60);

      @UI.lineItem       : [{ position: 5 , label: 'Storage Location' }]
      STORAGELOCATION    : abap.char(10);

//      @UI.lineItem       : [{ position: 10 , label: 'Total Qty Of Stock' }]
//      TOTALSTOCK         : abap.dec(17,2);

      @UI.lineItem       : [{ position: 11 , label: 'Total Valuation Of Stock' }]
      STOCKVALUEINCCCRCY : abap.dec(17,2);

      @UI.lineItem       : [{ position: 20 , label: 'Aging Qty > 1095 Days' }]
      qty1095            : abap.dec(17,2);

      @UI.lineItem       : [{ position: 30 , label: 'Aging qty 731 to 1095 Days' }]
      qty731_1095        : abap.dec(17,2);

      @UI.lineItem       : [{ position: 40 , label: 'Aging qty 366 to 730 Days' }]
      qty366_730         : abap.dec(17,2);

      @UI.lineItem       : [{ position: 50 , label: 'Aging qty 181 to 365 Days' }]
      qty181_365         : abap.dec(17,2);

      @UI.lineItem       : [{ position: 60 , label: 'Aging qty 61 to 180 Days' }]
      qty61_180          : abap.dec(17,2);

      @UI.lineItem       : [{ position: 70 , label: 'Aging qty 31 to 61 Days' }]
      qty31_61           : abap.dec(17,2);

      @UI.lineItem       : [{ position: 80 , label: 'Aging qty 0 to 31 Days' }]
      qty0_31            : abap.dec(17,2);
      
      @UI.lineItem       : [{ position: 90 , label: 'Aging Value > 1095' }]
      Value1095          : abap.dec(17,2);
      
      @UI.lineItem       : [{ position: 100 , label: 'Aging Value 731 to 1095' }]
      Value731_1095          : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 110 , label: 'Aging Value 366 to 730' }]
      Value366_730          : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 120 , label: 'Aging Value 181 to 365' }]
      Value181_365          : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 130 , label: 'Aging Value 61 to 180' }]
      Value61_180        : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 140 , label: 'Aging Value 31 to 61' }]
      Value31_61          : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 150 , label: 'Aging Value 0 to 31' }]
      Value0_31          : abap.dec(17,2);
      
       @UI.lineItem       : [{ position: 160 , label: 'Batch No' }]
      BATCH          : abap.char(10);
      
      
      
      
      












}
