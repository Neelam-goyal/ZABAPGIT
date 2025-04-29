//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'cds view for credit and debit'
//@Metadata.ignorePropagatedAnnotations: true
//define root view entity ZCDS_FI_CN_DN as select from data_source_name
//composition of target_data_source_name as _association_name
//{
//    
//    _association_name // Make association public
//}


@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
@UI.headerInfo: {typeName: 'ZCDS_CNDN'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZCDS_fi_cn_dn
  as select from C_SupplierInvoiceItemDEX 
{
       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:1 }]
       @UI.lineItem   : [{ position:1, label:'AccountingDocument' }]
      //@EndUserText.label: 'SupplierInvoice'
  key  SupplierInvoice,

       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:2 }]
       @UI.lineItem   : [{ position:2, label:'FiscalYear' }]
       // @EndUserText.label: 'Fiscal Year'
  key  FiscalYear,

  @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:3 }]
       @UI.lineItem   : [{ position:3, label:'Supplier_Invoice' }]
        
       
  key CompanyCode,
    @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:4 }]
       @UI.lineItem   : [{ position:4, label:'PostingDate' }]  
       
       key PostingDate,
        @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:5 }]
       @UI.lineItem   : [{ position:5, label:'Plant' }]  
       
       key Plant
       
  
}
