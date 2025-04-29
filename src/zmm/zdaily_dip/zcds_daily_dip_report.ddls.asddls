//@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS of Daily Dip Report'
@ObjectModel.query.implementedBy: 'ABAP:ZDAILY_DIP_REPORT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCDS_DAILY_DIP_REPORT 
            as select from zdt_daily_input
{
 key plant                 as Plant,
  key tankno                as Tankno,
  key product               as Product,
  key pdate                  as Pdate,  
      tankdescription       as Tankdescription,
      tanksafecapacity      as Tanksafecapacity,
      tankdipcm             as Tankdipcm,
      qtymt                 as Qtymt,
      parcelunloaded        as Parcelunloaded,
      qtyunloaded           as Qtyunloaded,
      totalavlstock         as Totalavlstock,
      bookstock             as Bookstock,
      variance              as Variance,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt
}       



































//@EndUserText.label: 'CDS of Daily Dip Report'
//@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZDAILY_DIP_REPORT'
////@UI.headerInfo: {typeName: 'CDS of Daily Dip Report'}
//@Metadata.allowExtensions: true
//@UI.headerInfo: {
//  typeName: 'CDS of Daily Dip Report',
//  typeNamePlural: 'Daily Dip Report',
//  title: {
//    type: #STANDARD,
//    value: 'Plant'
//  }
//}
//define custom entity ZCDS_DAILY_DIP_REPORT
//{
//
//   @Search.defaultSearchElement: true
//   @UI.selectionField: [{ position: 10 }] // Select-Options
//   @UI.lineItem: [{ position: 10, label: 'Plant' }]
//   @EndUserText.label: 'Plant' 
//   key Plant        : abap.char(4);
//  
//        @Search.defaultSearchElement: true
//   @UI.selectionField: [{ position: 30 }] // Select-Options
//   @UI.lineItem: [{ position: 30, label: 'Product' }]
//   @EndUserText.label: 'Product'
//   key product          : abap.char(10);
//   
//   @Search.defaultSearchElement: true
//   @UI.selectionField: [{ position: 40 }] // Select-Options
//   @UI.lineItem: [{ position: 40, label: 'Tank No' }]
//   @EndUserText.label: 'Tank No'
//   key tankno           : abap.char(10);
//    
//   @Search.defaultSearchElement: true
//   @UI.selectionField: [{ position: 20 }] // Select-Options
//   @UI.lineItem: [{ position: 20, label: 'Date' }]
//   @EndUserText.label: 'Date'
//   pdate            : abap.dats;
//   
////    @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 50 }] // Select-Options
//   @UI.lineItem: [{ position: 50, label: 'Tank Description' }]
//   @EndUserText.label: 'Tank Description'
//   tankdescription  : abap.char(30);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 60 }] // Select-Options
//   @UI.lineItem: [{ position: 60, label: 'Tank Safe Capacity' }]
//   @EndUserText.label: 'Tank Safe Capacity' 
//   tanksafecapacity : abap.dec(10,2);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 70 }] // Select-Options
//   @UI.lineItem: [{ position: 70, label: 'Tank Dip cm' }]
//   @EndUserText.label: 'Tank Dip cm'
//   tankdipcm        : abap.char(20);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 80 }] // Select-Options
//   @UI.lineItem: [{ position: 80, label: 'Qtymt' }]
//   @EndUserText.label: 'Qtymt'
//   qtymt            : abap.dec(10,2);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 90 }] // Select-Options
//   @UI.lineItem: [{ position: 90, label: 'Parcel Unloaded' }]
//   @EndUserText.label: 'Parcel Unloaded'
//   parcelunloaded   : abap.char(10);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 100 }] // Select-Options
//   @UI.lineItem: [{ position: 100, label: 'Qty Unloaded' }]
//   @EndUserText.label: 'Qty Unloaded'
//   qtyunloaded      : abap.char(10);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 110 }] // Select-Options
//   @UI.lineItem: [{ position: 110, label: 'Total ALV Stock' }]
//   @EndUserText.label: 'Total ALV Stock'
//   totalavlstock    : abap.dec(20,5);
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 120 }] // Select-Options
////   @UI.lineItem: [{ position: 120, label: 'Dip Time' }]
////   @EndUserText.label: 'Dip Time'
////   diptime          : abp_creation_tstmpl;
//   
////    @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 120 }] // Select-Options
//   @UI.lineItem: [{ position: 120, label: 'Tank SAP Book Stock@DipTime' }]
//   @EndUserText.label: 'Tank SAP Book Stock@DipTime'
//   bookstock        : abap.char(20);
//   
//   
////   @Search.defaultSearchElement: true
////   @UI.selectionField: [{ position: 130 }] // Select-Options
//   @UI.lineItem: [{ position: 130, label: 'Variance' }]
//   @EndUserText.label: 'Variance'
//   variance         : abap.char(10);
//   
//   
//}       
