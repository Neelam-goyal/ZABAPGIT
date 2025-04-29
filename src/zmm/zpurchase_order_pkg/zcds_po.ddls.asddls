@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for Purchase order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PO_SCREEN'  
@UI.headerInfo: {typeName: 'zpurchase order'}
define root view entity ZCDS_po as select from I_PurchaseOrderAPI01

{
     

     @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:10, label:'Purchasing Order' }]
  key PurchaseOrder,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:20, label:'Company Code' }]
    CompanyCode,
      
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:30, label:' Purchasing Organizations' }]
      PurchasingOrganization
}
