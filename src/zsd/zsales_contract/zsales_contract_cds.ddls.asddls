@EndUserText.label: 'Sales Contract Report'
@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZSALES_CONTRACT_CLASS'


@UI.headerInfo:{
    typeName: 'Sales COntract ',
    typeNamePlural : 'Sales Contract Records'
}
define custom entity ZSALES_CONTRACT_CDS

{

      @Search.defaultSearchElement : true
      @UI.selectionField           : [{ position: 20 }]
      @UI.lineItem                 : [{ position: 10, label: 'Sales Contract No' }]
  key SALESCONTRACT                : abap.char(20);
   @UI.lineItem                 : [{ position: 20, label: 'Sales Contract Item' }]
  key SalesContractItem            : abap.char(20);
      @Search.defaultSearchElement : true
      @UI.selectionField           : [{ position: 10 }]
      @UI.lineItem                 : [{ position: 10, label: 'Reference No' }]
      PURCHASEORDERBYCUSTOMER      : abap.char(20);

      //      @Consumption.valueHelpDefinition: [{ entity : { element: 'SALESCONTRACT', name : 'i_salescontract' } } ]


      @Search.defaultSearchElement : true
      @UI.selectionField           : [{ position: 60 }]
      @UI.lineItem                 : [{ position: 60, label: 'Plant Code' }]
      PLANT                        : abap.char(4);

      @UI.hidden                   : true
      //        key PartnerFunction              : abap.char(15);
      //      @UI.hidden                   : true
      //        key SDDocPartnerSequenceNumber   : abap.char(20);
      //      @UI.hidden                   : true

      //            //      @UI.hidden                   : true
      Product                      : abap.char(20);
      //            //      @UI.hidden                   : true
      //        key vbeln                        : abap.char(10);
      //            //      @UI.hidden                   : true
      //        key posnr                        : abap.char(30);




      @Consumption.valueHelpDefinition: [{ entity : { element: 'PURCHASEORDERBYCUSTOMER', name : 'I_SalesContract' } } ]

      @UI.lineItem                 : [{ position: 30, label: 'Status' }]
      OVERALLSDPROCESSSTATUS       : abap.char(20);


      @UI.lineItem                 : [{ position: 40, label: ' Bill-to Party Code ' }]
      PARTNER                      : abap.char(20);


      @UI.lineItem                 : [{ position: 50, label: 'Bill-to Party Name' }]
      FULLNAME                     : abap.char(30);



      @UI.lineItem                 : [{ position: 70, label: 'Plant Name ' }]
      PLANTNAME                    : abap.char(20);

      @UI.lineItem                 : [{ position: 80, label: 'Sales Employee Name' }]
      FULLNAME_sales               : abap.char(30);

      @UI.lineItem                 : [{ position: 90, label: 'Broker Name' }]
      FULLNAME_Broker              : abap.char(30);

      @Search.defaultSearchElement : true
      @UI.selectionField           : [{ position: 100 }]
      @UI.lineItem                 : [{ position: 100, label: 'Sales Contract Date' }]
      CREATIONDATE                 : abap.dats(8);

      @UI.lineItem                 : [{ position: 120, label: 'Sales Contract Validity Date' }]
      SALESCONTRACTVALIDITYENDDATE : abap.dats(8);

      @UI.lineItem                 : [{ position: 130, label: 'Inco Terms' }]
      INCOTERMSCLASSIFICATION      : abap.char(20);

      @UI.lineItem                 : [{ position: 140, label: 'Item Code' }]
      MATERIAL                     : abap.char(20);

      @UI.lineItem                 : [{ position: 150, label: 'Item Code Description' }]
      SALESCONTRACTITEMTEXT        : abap.char(40);

      @UI.lineItem                 : [{ position: 160, label: 'Material Type' }]
      PRODUCTTYPE                  : abap.char(20);

      @UI.lineItem                 : [{ position: 170, label: 'Material Group Code' }]
      PRODUCTGROUP                 : abap.char(20);

      @UI.lineItem                 : [{ position: 180, label: 'Contract quantity' }]
      TARGETQUANTITY               : abap.char(20);

      @UI.lineItem                 : [{ position: 190, label: 'Contract Quantity UOM' }]
      TARGETQUANTITYUNIT           : abap.char(10);

      @UI.lineItem                 : [{ position: 200, label: 'Sales Order Quantity' }]
      ORDERQUANTITY                : abap.char(20);

      @UI.lineItem                 : [{ position: 210, label: 'Delivered Quantity' }]
      ACTUALDELIVERYQUANTITY       : abap.char(20);

      @UI.lineItem                 : [{ position: 230, label: 'Contract Balance Quantity' }]
      Contract_Balance_Quantity    : abap.char(20);

      @UI.lineItem                 : [{ position: 240, label: 'Contract Net Weight' }]
      ITEMNETWEIGHT                : abap.char(20);

      @UI.lineItem                 : [{ position: 250, label: 'Sales Order Net Weight' }]
      ITEMNETWEIGHT_so            : abap.char(20);

      @UI.lineItem                 : [{ position: 260, label: 'Delivery Net Weight' }]
      ITEMNETWEIGHT_delivery       : abap.char(20);


    @UI.lineItem                 : [{ position: 270, label: 'Contract Pending Net Weight' }]
      Contract_Pending_Net_Weight      : abap.char(20);

      @UI.lineItem                 : [{ position: 280, label: 'Weight UOM' }]
      ITEMWEIGHTUNIT               : abap.char(20);




}
