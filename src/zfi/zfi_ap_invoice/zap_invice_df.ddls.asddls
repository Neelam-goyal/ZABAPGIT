@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Data Definaitions for ZAP INVOICE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
     
}


define view entity ZAP_INVICE_DF as select distinct from  I_OperationalAcctgDocItem as a
 inner join  I_GLAccountTextRawData as B on  a.GLAccount = B.GLAccount
//define view entity ZAP_INVICE_DF
//  with parameters 
//    p_companycode         : bukrs,
//    p_AccountingDocument  : abap.char(10),
//    p_FiscalYear          : abap.char(4)
//
//  as select from I_OperationalAcctgDocItem as a 
//    inner join I_GLAccountTextRawData as b 
//      on a.GLAccount = b.GLAccount
       
     
   
{


     @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'Accounting Document' }]
  key a.AccountingDocument,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'Company Code' }]
  key a.CompanyCode,
 
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'Fiscal Year' }]
  key a.FiscalYear,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4 }]
      @UI.lineItem   : [{ position:4, label:'Accounting Document Item' }]
      @UI.hidden: true
  key a.AccountingDocumentItem,
 
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:5}]
      @UI.lineItem   : [{ position:5, label:'Accounting DocumentType' }]
   key a.AccountingDocumentType,
 
      @UI.lineItem   : [{ position:6, label:'Document Item Text' }]
      a.DocumentItemText,
 
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:7}]
      @UI.lineItem   : [{ position:7, label:' Document Date' }]
      a.DocumentDate,
      @UI.lineItem   : [{ position:8, label:'Clearing Date' }]
      a.ClearingDate,
      @UI.selectionField   : [{ position:9}]
      @UI.lineItem   : [{ position:9, label:'GL Account' }]
      a.GLAccount,
      a.Customer,
      a.Supplier,
      B.GLAccountName
      
}
  
         
  where 
//         a.CompanyCode = $parameters.p_companycode and
//          a.AccountingDocument = $parameters.p_AccountingDocument and
//          a.FiscalYear =  $parameters.p_FiscalYear and
          a.AccountingDocumentItemType <> 'T' and
          a.CostElement is not initial and
          a.AmountInCompanyCodeCurrency > 1
