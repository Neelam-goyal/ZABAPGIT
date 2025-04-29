@EndUserText.label: 'i_accountingdocumentjournal CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PAY_VOUCHER'
@UI.headerInfo: {typeName: 'Payment Voucher Print'}
define custom entity zcds_pay_voucher
{
      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:10 }]
      @UI.lineItem       : [{ position: 10, label: 'Accounting Document' }]
      @EndUserText.label : 'Accounting Document'
  key ACCOUNTINGDOCUMENT : abap.char( 10 );

      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:20 }]
      @UI.lineItem       : [{ position: 20, label: 'Fiscal Year' }]
      @EndUserText.label : 'Fiscal Year'
  key FISCALYEAR         : abap.numc(4);


      @Search.defaultSearchElement: true
      @UI.selectionField : [{ position:30 }]
      @UI.lineItem       : [{ position: 30, label: 'Company Code' }]
      @EndUserText.label : 'Company Code'
  key COMPANYCODE        : abap.char(4);


      @Search.defaultSearchElement: true
//      @UI.selectionField : [{ position:40 }]
      @UI.lineItem       : [{ position: 40, label: 'Posting Date' }]
//      @EndUserText.label : 'Posting Date'
      PostingDate        : abap.dats(8);


}
