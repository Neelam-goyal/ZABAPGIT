@EndUserText.label: 'I_OperationalAcctgDocItem CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ACCT_PRINT'
@UI.headerInfo: {typeName: 'VOUCHER PRINT'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZCDS_ACCO
  as select from I_OperationalAcctgDocItem
{
       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:1 }]
       @UI.lineItem   : [{ position:1, label:'Accounting Document' }]
  key  AccountingDocument,
       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:2 }]
       @UI.lineItem   : [{ position:2, label:'Company Code' }]
  key  CompanyCode,

       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:3 }]
       @UI.lineItem   : [{ position:3, label:'Fiscal Year' }]
  key  FiscalYear,
       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:4 }]
       @UI.lineItem   : [{ position:4, label:'Accounting Document Item' }]
  key  AccountingDocumentItem,

       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:5}]
       @UI.lineItem   : [{ position:5, label:'Accounting DocumentType' }]
  key  AccountingDocumentType,

       @UI.lineItem   : [{ position:5.2, label:'Document Item Text' }]
       DocumentItemText,

       @Search.defaultSearchElement: true
       @UI.selectionField   : [{ position:5.5}]
       @UI.lineItem   : [{ position:5.5, label:' Document Date' }]
       DocumentDate,
       @UI.lineItem   : [{ position:6, label:'Clearing Date' }]
       ClearingDate,
       @UI.selectionField   : [{ position:8}]
       @UI.lineItem   : [{ position:8, label:'GL Account' }]
       GLAccount,
       Customer,
       Supplier,

       @UI.lineItem   : [{ position:10, label:'Transactional Type Determination' }]
       TransactionTypeDetermination,
       @Semantics.amount.currencyCode: 'curr'
       @UI.lineItem   : [{ position:9, label:'Amount In CompanyCode Currency' }]
       AmountInCompanyCodeCurrency,
       CompanyCodeCurrency as curr,
       /* Associations */
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _CompanyCode,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _CompanyCodeCurrency,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _Customer,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _CustomerCompany,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _CustomerText,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _FiscalYear,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _GLAccountInCompanyCode,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _JournalEntry,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _JournalEntryItemOneTimeData,

       /*_OneTimeAccountBP,*/
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _Supplier,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _SupplierCompany,
       @ObjectModel.filter.enabled: false
       @ObjectModel.sort.enabled: false
       _SupplierText

}
