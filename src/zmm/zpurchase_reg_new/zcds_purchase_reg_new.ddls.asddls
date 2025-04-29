//@EndUserText.label: 'Purchase Register'
//@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_PURCHASE_REG_NEW'
//@UI.headerInfo: {typeName: 'Purchase Register'}
//@Metadata.allowExtensions: true
//
//define custom entity zcds_purchase_reg_new 
//{  

  
//@EndUserText.label: 'Supplier Invoice'
//@UI.lineItem            : [{ position: 10, label: 'Supplier Invoice' }]
//@UI.selectionField      : [{ position: 10 }]
//@Search.defaultSearchElement: true
//key supplierinvoice            : abap.char(10);
//
////@Search.defaultSearchElement: true
////@UI.selectionField: [{ position: 10 }] // Select-Options
////@UI.lineItem   : [{ position:10, label:'Supplier Invoice' }]
//
//
//@EndUserText.label: 'Company Code'
//@UI.lineItem            : [{ position: 20, label: 'Company Code' }]
//@UI.selectionField      : [{ position: 20 }]
//@Search.defaultSearchElement: true
//key companycode                : abap.char(4) ;
// 
////@Search.defaultSearchElement: true
////@UI.selectionField: [{ position: 20 }] // Select-Options
////@UI.lineItem   : [{ position:20, label:'Company Code' }]
//
//
//  
//@UI.lineItem   : [{ position:30, label:'Fiscal Year Value' }]    
//key fiscalyearvalue            : abap.numc(4) ;
//  
//@UI.lineItem   : [{ position:40, label:'Supplier Invoice Item' }]
//key supplierinvoiceitem        : abap.numc(6) ;
//  
//  
//@UI.lineItem   : [{ position:50, label:'Posting Date' }]
//postingdate                    : abap.dats;
// 
//@UI.lineItem   : [{ position:60, label:'Plant Name' }]
//plantname                      : abap.char(30); 
//
//@UI.lineItem   : [{ position:70, label:'Plant Address' }]
//plantadr                       : abap.char(40);
//
//@UI.lineItem: [{ position:80, label:'Plant City' }]
//plantcity                      : abap.char(40);
//
//@UI.lineItem: [{ position:90, label:'Plant GST' }]
//plantgst                       : abap.char(18);
//
//@UI.lineItem: [{ position:100, label:'Plant PIN' }]
//plantpin                       : abap.char(10);
//
//@UI.lineItem: [{ position:110, label:'Product' }]
//product                        : abap.char(40);
//
//@UI.lineItem: [{ position:120, label:'Product Name' }]
//productname                    : abap.char(40);
//
//
//@EndUserText.label: 'Purchase Order'
//@UI.lineItem            : [{ position: 130, label: 'Purchase Order' }]
//@UI.selectionField      : [{ position: 30 }]
//@Search.defaultSearchElement: true
//purchaseorder                  : abap.char(10);
//
////@Search.defaultSearchElement: true
////@UI.selectionField: [{ position: 30 }] 
////@UI.lineItem: [{ position:130, label:'Purchase Order' }]
//
//
//@UI.lineItem: [{ position:140, label:'Purchase Order Item' }]
//purchaseorderitem              : abap.numc(5);
//
//@UI.lineItem: [{ position:150, label:'Product Trade Name' }]
//product_trade_name             : abap.char(100);
//
//@UI.lineItem: [{ position:160, label:'Vendor Invoice No' }]
//vendor_invoice_no              : abap.char(35);
//
//@UI.lineItem: [{ position:170, label:'Vendor Invoice Date' }]
//vendor_invoice_date            : abap.dats;
//
//@UI.lineItem: [{ position:180, label:'Vendor Type' }]
//vendor_type                    : abap.char(40);
//
//@UI.lineItem: [{ position:190, label:'Type of Enterprise' }]
//typeofenterprise               : abap.char(10);
//
//@UI.lineItem: [{ position:200, label:'Udhyam Aadhar No' }]
//udhyamaadharno                 : abap.char(30);
//
//@UI.lineItem: [{ position:210, label:'Udhyam Certificate Date' }]
//udhyamcertificatedate          : abap.dats;
//
//@UI.lineItem: [{ position:220, label:'Udhyam Certificate Receiving Date' }]
//udhyamcertificatereceivingdate : abap.dats;
//
//@UI.lineItem: [{ position:230, label:'RFQ No' }]
//rfqno                          : abap.char(20);
//
//@UI.lineItem: [{ position:240, label:'RFQ Date' }]
//rfqdate                        : abap.dats;
//
//@UI.lineItem: [{ position:250, label:'Supplier Quotation' }]
//supplierquotation              : abap.char(10);
//
//@UI.lineItem: [{ position:260, label:'Supplier Quotation Date' }]
//supplierquotationdate          : abap.dats;
//
//@UI.lineItem: [{ position:270, label:'Base Unit' }]
//baseunit                       : abap.unit(3);
//
//@UI.lineItem: [{ position:280, label:'Profit Center' }]
//profitcenter                   : abap.char(10);
//
//@EndUserText.label: 'Purchase Order Type'
//@UI.lineItem            : [{ position: 290, label: 'Purchase Order Type' }]
//@UI.selectionField      : [{ position: 40 }]
//@Search.defaultSearchElement: true
//purchaseordertype              : abap.char(4);
//
////@Search.defaultSearchElement: true
////@UI.selectionField: [{ position: 40 }] 
////@UI.lineItem: [{ position:290, label:'Purchase Order Type' }]
//
//@EndUserText.label: 'Purchase Order Date'
//@UI.lineItem            : [{ position: 300, label: 'Purchase Order Date' }]
//@UI.selectionField      : [{ position: 50 }]
//@Search.defaultSearchElement: true
//purchaseorderdate              : abap.dats;
//
//
////@Search.defaultSearchElement: true
////@UI.selectionField: [{ position: 50 }] 
////@UI.lineItem: [{ position:300, label:'Purchase Order Date' }]
////purchaseorderdate              : abap.dats;
//
//@UI.lineItem: [{ position:310, label:'Purchasing Organization' }]
//purchasingorganization         : abap.char(4);
//
//@UI.lineItem: [{ position:320, label:'Purchasing Group' }]
//purchasinggroup                : abap.char(3);
//
//@UI.lineItem: [{ position:330, label:'MRN Quantity in Base Unit' }]
//mrnquantityinbaseunit          : abap.dec(15,3);
//
//@UI.lineItem: [{ position:340, label:'MRN Posting Date' }]
//mrnpostingdate                 : abap.dats;
//
//@UI.lineItem: [{ position:350, label:'HSN Code' }]
//hsncode                        : abap.char(16);
//
//@UI.lineItem: [{ position:360, label:'Tax Code Name' }]
//taxcodename                    : abap.char(50);
//
//@UI.lineItem: [{ position:370, label:'Original Reference Document' }]
//originalreferencedocument      : abap.char(20);
//
//@UI.lineItem: [{ position:380, label:'IGST' }]
//igst                           : abap.dec(13,2);
//
//@UI.lineItem: [{ position:390, label:'SGST' }]
//sgst                           : abap.dec(13,2);
//
//@UI.lineItem: [{ position:400, label:'CGST' }]
//cgst                           : abap.dec(13,2);
//
//@UI.lineItem: [{ position:410, label:'Rate IGST' }]
//rateigst                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:420, label:'Rate CGST' }]
//ratecgst                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:430, label:'Rate SGST' }]
//ratesgst                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:440, label:'Journal Document Ref ID' }]
//journaldocumentrefid           : abap.char(16);
//
//@UI.lineItem: [{ position:450, label:'Journal Document Date' }]
//journaldocumentdate            : abap.dats;
//
//@UI.lineItem: [{ position:460, label:'Is Reversed' }]
//isreversed                     : abap.char(1);
//
//@UI.lineItem: [{ position:470, label:'Basic Rate' }]
//basicrate                      : abap.dec(13,2);
//
//@UI.lineItem: [{ position:480, label:'PO Qty' }]
//poqty                          : abap.dec(15,3);
//
//@UI.lineItem: [{ position:490, label:'PO UOM' }]
//pouom                          : abap.char(5);
//
//@UI.lineItem: [{ position:500, label:'Net Amount' }]
//netamount                      : abap.dec(13,2);
//
//@UI.lineItem: [{ position:510, label:'Tax Amount' }]
//taxamount                      : abap.dec(13,2);
//
//@UI.lineItem: [{ position:520, label:'Round Off' }]
//roundoff                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:530, label:'Mandi Tax' }]
//manditax                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:540, label:'Mandi Cess' }]
//mandicess                      : abap.dec(13,2);
//
//@UI.lineItem: [{ position:550, label:'Discount' }]
//discount                       : abap.dec(13,2);
//
//@UI.lineItem: [{ position:560, label:'Total Amount' }]
//totalamount                    : abap.dec(13,2);
//
//@UI.lineItem: [{ position:570, label:'Freight' }]
//freight                        : abap.dec(13,2);
//
//@UI.lineItem: [{ position:580, label:'Insurance' }]
//insurance                      : abap.dec(13,2);
//
//@UI.lineItem: [{ position:590, label:'ECS' }]
//ecs                            : abap.dec(13,2);
//
//@UI.lineItem: [{ position:600, label:'EPF' }]
//epf                            : abap.dec(13,2);
//
//@UI.lineItem: [{ position:610, label:'Other Charges' }]
//othercharges                   : abap.dec(13,2);
//
//@UI.lineItem: [{ position:620, label:'Packaging' }]
//packaging                      : abap.dec(13,2);
//
////@UI.lineItem: [{ position:630, label:'Supplier Invoice with Fiscal Year' }]
////supplierinvoicewthnfiscalyear  : abap.char(14);
////
////@UI.lineItem: [{ position:640, label:'Creation Date Time' }]
////creationdatetime               : abp_creation_tstmpl;
////
////@UI.lineItem: [{ position:650, label:'Address ID' }]
////addressid                      : abap.char(10);   
//
////@UI.lineItem: [{ position:660, label:'Account Doc No' }]
////accdocno                       : abap.char(10);
////
////@UI.lineItem: [{ position:670, label:'Accounting Amount Currency' }]
////accountingamtcurr              : abap.cuky;
//
//
//}

//@AccessControl.authorizationCheck: #CHECK
//@Metadata.allowExtensions: true
//@EndUserText.label: 'CDS View forpurchaseline'

@EndUserText.label: 'Purchase Register'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_PURCHASE_REG_NEW'
@UI.headerInfo: {typeName: 'Purchase Register', typeNamePlural: 'Purchase Register'} 
@Metadata.allowExtensions: true
define view entity ZCDS_PURCHASE_REG_NEW
  as select from zdt_pur_reg_new
  {
    key companycode as Companycode,
    key fiscalyearvalue as Fiscalyearvalue,
    key supplierinvoice as Supplierinvoice,
    key supplierinvoiceitem as Supplierinvoiceitem,
    postingdate as Postingdate,
    plantname as Plantname,
    plantadr as Plantadr,
    plantcity as Plantcity,
    plantgst as Plantgst,
    plantpin as Plantpin,
    product as Product,
    productname as Productname,
    purchaseorder as Purchaseorder,
    purchaseorderitem as Purchaseorderitem,
    product_trade_name as ProductTradeName,
    vendor_invoice_no as VendorInvoiceNo,
    vendor_invoice_date as VendorInvoiceDate,
    vendor_type as VendorType,
    typeofenterprise as Typeofenterprise,
    udhyamaadharno as Udhyamaadharno,
    udhyamcertificatedate as Udhyamcertificatedate,
    udhyamcertificatereceivingdate as Udhyamcertificatereceivingdate,
    rfqno as Rfqno,
    rfqdate as Rfqdate,
    supplierquotation as Supplierquotation,
    supplierquotationdate as Supplierquotationdate,
    baseunit as Baseunit,
    profitcenter as Profitcenter,
    purchaseordertype as Purchaseordertype,
    purchaseorderdate as Purchaseorderdate,
    purchasingorganization as Purchasingorganization,
    purchasinggroup as Purchasinggroup,
    mrnquantityinbaseunit as Mrnquantityinbaseunit,
    mrnpostingdate as Mrnpostingdate,
    hsncode as Hsncode,
    taxcodename as Taxcodename,
    originalreferencedocument as Originalreferencedocument,
    igst as Igst,
    sgst as Sgst,
    cgst as Cgst,
    rateigst as Rateigst,
    ratecgst as Ratecgst,
    ratesgst as Ratesgst,
    journaldocumentrefid as Journaldocumentrefid,
    journaldocumentdate as Journaldocumentdate,
    isreversed as Isreversed,
    basicrate as Basicrate,
    poqty as Poqty,
    pouom as Pouom,
    netamount as Netamount,
    taxamount as Taxamount,
    roundoff as Roundoff,
    manditax as Manditax,
    mandicess as Mandicess,
    discountper as Discountper,
    discountval as Discountval,
    totalamount as Totalamount,
    freight as Freight,
    insurance as Insurance,
    ecs as Ecs,
    epf as Epf,
    othercharges as Othercharges,
    packaging as Packaging , 
  antidumpingper as Antidumpingper   ,         
  antidumpingvalue as Antidumpingvalue ,        
  chachargesval  as Chachargesval          ,  
  cifvalue as Cifvalue        ,        
  cifandcustomduty as Cifandcustomduty  ,       
  clearingcharges as Clearingcharges    ,  
  freightval as Freightval ,    
  freightqty as Freightqty               , 
  insurancechargesper as Insurancechargesper ,
  insurancecost   as Insurancecost      ,         
  ldguldgchgsqty as Ldguldgchgsqty            ,     
  ldguldgchgsval as Ldguldgchgsval             ,    
  materialgroup as Materialgroup   ,               
  materialtype as Materialtype     ,              
  mirodocumenttype as Mirodocumenttype   ,             
  packingchargesper   as Packingchargesper  ,         
  packingchargesqty as Packingchargesqty      ,        
  prdate as Prdate         ,                
  prno as Prno            ,               
  prqty as Prqty            ,              
  transportercode as Transportercode        ,        
  transportername as Transportername         ,       
  vendorcode as Vendorcode     ,                
  vendorgstin as Vendorgstin     ,               
  vendorlegalname as Vendorlegalname  ,              
  vendorname as Vendorname        ,             
  vendorpanno as Vendorpanno        ,            
  vendortanname as Vendortanname       ,           
  vendortanno as Vendortanno              
    
  } 



