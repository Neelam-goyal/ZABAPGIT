CLASS ZTEST_CLASS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_apj_dt_exec_object .
*    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


select  *
from zpurchinvproc
where supplierinvoice in ('5105600282' , '5105600283' , '5105600284' , '5105600285' ,
                          '5105600286' , '5105600287' , '5105600288' , '5105600289' ,
                          '5105600290' , '5105600291' , '5105600292' , '5105600293')
into table @data(it_supp).

Loop at it_supp into data(wa_supp).
Delete  zpurchinvproc from @wa_supp  .
Commit Work.
ENDLOOP.

*    TYPES ty_id TYPE c LENGTH 10.

*    DATA s_id    TYPE RANGE OF ty_id.
*    DATA p_descr TYPE c LENGTH 80.
*    DATA p_count TYPE i.
*    DATA p_simul TYPE abap_boolean.
*    DATA processfrom TYPE d.
*
*    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
*    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
*    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
*    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.
*
*    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
*          wa_purchinvlines     TYPE zpurchinvlines,
*          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
*          wa_purchinvprocessed TYPE zpurchinvproc.
*
*
*****************************************************************************************
*    DATA maxpostingdate TYPE d.
*    DATA deleteString TYPE c LENGTH 4.
*    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.
*
*    GET TIME STAMP FIELD DATA(lv_timestamp).
*
*    GET TIME STAMP FIELD lv_tstamp.
*    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.
*
*    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.
*
*    IF deleteString = '2819'.
*      DELETE FROM zpurchinvlines WHERE companycode IS NOT INITIAL.
*      DELETE FROM zpurchinvproc WHERE companycode IS NOT INITIAL.
*      COMMIT WORK.
*    ENDIF.
*
*    SELECT FROM zpurchinvlines "zbillinglines
*      FIELDS MAX( postingdate )
*      WHERE companycode IS NOT INITIAL
*      INTO @maxpostingdate .
*
*    IF maxpostingdate IS INITIAL.
*      maxpostingdate = 20010101.
*    ELSE.
*      maxpostingdate = maxpostingdate - 30.
*    ENDIF.
*****************************************************************************************
*
*
*
**    " Getting the actual parameter values
**    LOOP AT it_parameters INTO DATA(ls_parameter).
**      CASE ls_parameter-selname.
**        WHEN 'S_ID'.
**          APPEND VALUE #( sign   = ls_parameter-sign
**                          option = ls_parameter-option
**                          low    = ls_parameter-low
**                          high   = ls_parameter-high ) TO s_id.
**        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
**        WHEN 'P_COUNT'. p_count = ls_parameter-low.
**        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
**      ENDCASE.
**    ENDLOOP.
**
**    TRY.
***      read own runtime info catalog
**        cl_apj_rt_api=>get_job_runtime_info(
**                         IMPORTING
**                           ev_jobname        = jobname
**                           ev_jobcount       = jobcount
**                           ev_catalog_name   = catalog
**                           ev_template_name  = template ).
**
**      CATCH cx_apj_rt.
**        DATA(lv_catch) = '1'.
**
**    ENDTRY.
*
*    processfrom = sy-datum - 30.
*    IF p_simul = abap_true.
*      processfrom = sy-datum - 2000.
*    ENDIF.
*
******************************************************** HEADER **********************************
*    SELECT FROM I_SupplierInvoiceAPI01 AS c
*        LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
************************************
*        LEFT JOIN I_PurchaseOrderItemAPI01 AS hdr ON c~BusinessPlace = hdr~Plant
*        LEFT JOIN I_BusPartAddress AS hdr1 ON hdr~Plant = hdr1~BusinessPartner
************************************
*        FIELDS
*            b~Supplier , b~PostalCode , b~BPAddrCityName , b~BPAddrStreetName , b~TaxNumber3,
*            b~SupplierFullName, b~region, c~ReverseDocument , c~ReverseDocumentFiscalYear,
*            c~CompanyCode , c~PaymentTerms , c~CreatedByUser , c~CreationDate , c~InvoicingParty , c~InvoiceGrossAmount,
*            c~DocumentCurrency , c~SupplierInvoiceIDByInvcgParty, c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear,
*            c~DocumentDate, c~PostingDate,
***************************************
*            hdr1~AddressID
***************************************
*        where hdr~PurchaseOrder = '3100000167'
**        WHERE c~PostingDate >= @processfrom
**            AND NOT EXISTS (
**               SELECT supplierinvoice FROM zpurchinvproc
**               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
**                 c~CompanyCode = zpurchinvproc~companycode AND
**                 c~FiscalYear = zpurchinvproc~fiscalyearvalue )
*            INTO TABLE @DATA(ltheader).
*OUT->write( LTHEADER ).
*
******************************************************** LINE ITEM **********************************
*    LOOP AT ltheader INTO DATA(waheader).
*      lv_timestamp = cl_abap_tstmp=>add_to_short( tstmp = lv_timestamp secs = 11111 ).
*
** Delete already processed sales line
*      DELETE FROM zpurchinvlines
*        WHERE zpurchinvlines~companycode = @waheader-CompanyCode AND
*        zpurchinvlines~fiscalyearvalue = @waheader-FiscalYear AND
*        zpurchinvlines~supplierinvoice = @waheader-SupplierInvoice.
*
*
*      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*************************************
*        LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder
**        LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
*        LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
*        LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
*        LEFT JOIN i_purchaseorderhistoryapi01 AS li5 ON li~PurchaseOrder = li5~PurchaseOrder AND li~PurchaseOrderItem = li5~PurchaseOrderItem
*        LEFT JOIN i_purchaseorderapi01 AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
**        LEFT JOIN i_purchaseorderapi01 AS poa ON a~PurchaseOrder = poa~PurchaseOrder
*        LEFT JOIN I_BusinessPartner AS li7 ON li6~Supplier = li7~BusinessPartner
*        LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
*        LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder
*        LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
*        LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
*        LEFT JOIN i_accountingdocumentjournal AS li12 ON li5~PurchasingHistoryDocument = li12~DocumentReferenceID
*        LEFT JOIN i_purchaserequisitionitemapi01 AS li13 ON li13~PurchaseRequisition = li~PurchaseRequisition
*
*************************************
*
*        FIELDS
*            a~PurchaseOrderItem, a~SupplierInvoiceItem,
*            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
*            a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction AS SInvwithFYear, a~plant,
*            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
*            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear ,
*************************************
*            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,  "li4~trade_name,
*            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
*            li11~QuotationSubmissionDate, li5~PostingDate, li12~DocumentReferenceID , li6~PurchaseOrderType , li6~PaymentTerms ,
*            li~OrderQuantity ,li~NetAmount , li13~PurReqCreationDate , li~PurchaseRequisition , li13~RequestedQuantity ,
*            li~OverdelivTolrtdLmtRatioInPct ", poa~PurchaseOrderType AS po_type
*************************************
*        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
*           and  li~PurchaseOrder = '3100000167'
*          AND a~FiscalYear = @waheader-FiscalYear
*          INTO TABLE @DATA(ltlines).
*OUT->write( LTLINES ).
*
*
*      select from i_supplier as a
*        fields a~BusinessPartnerPanNumber, a~Supplier
*            FOR ALL ENTRIES IN @ltlines where a~Supplier = @ltlines-FreightSupplier
*         into table @data(it_panno).
*
*
*LOOP AT ltlines INTO DATA(walines).
*
*READ TABLE it_panno into data(wa_it_panno) with key Supplier = walines-FreightSupplier.
*         wa_purchinvlines-vendorpanno = wa_it_panno-BusinessPartnerPanNumber.
*
**Select a~purchaseorder ,
**      a~supplierinvoice ,
**      b~supplierinvoice as sp2 ,
**      b~fiscalyear
**      from I_SuplrInvcItemPurOrdRefAPI01 as a
**      left join i_supplierinvoiceapi01 as b on b~SupplierInvoice = a~SupplierInvoice
**      for all entries in @ltlines where a~PurchaseOrder = @ltlines-PurchaseOrder and a~SupplierInvoice = @ltlines-SupplierInvoice
**      into table @data(it_topnew).
**      DATA : total_amount TYPE p DECIMALS 3 .
*
**LOOP AT IT_TOPNEW INTO DATA(WA_TOPNEW).
**        DATA : SUPPINV2 TYPE STRING .
**        DATA : FISCYEA2 TYPE STRING .
**        DATA : COMB2 TYPE STRING .
**        SUPPINV2 = WA_TOPNEW-sp2.
**        FISCYEA2 = WA_TOPNEW-FiscalYear.
**        CONCATENATE SUPPINV2 FISCYEA2 INTO COMB2.
**
**        select
**        a~supplierinvoice ,
**        B~AmountInCompanyCodeCurrency ,
**        B~OriginalReferenceDocument
**        from i_supplierinvoiceapi01 as a
**        left join I_OperationalAcctgDocItem as b on b~OriginalReferenceDocument = @COMB2 and b~FiscalYear = A~FiscalYear
**        where b~accountingdocumentitemtype = 'T' " A~SUPPLIERINVOICE = @FISCYEA2 "AND
**        into table @data(it_comb2).
**
**         select
**         from I_OperationalAcctgDocItem
**         FIELDS
**        AmountInCompanyCodeCurrency ,
**        OriginalReferenceDocument
**        into TABLE @data(it_TESTING).
**
**        LOOP AT IT_COMB2 INTO DATA(WA_COMB2) .
**        total_amount = total_amount + wa_comb2-AmountInCompanyCodeCurrency .
**        clear : wa_comb2 .
**        ENDLOOP.
**
**
***        READ TABLE it_comb2 INTO DATA(wa_comb2) WITH KEY supplierinvoice = wa_topnew-sp2 .
**
**
**        clear :  wa_topnew , COMB2 , FISCYEA2 , SUPPINV2 .
**ENDLOOP.
**
**        wa_purchinvlines-taxesonpo = total_amount .
*
**Select a~purchaseorder ,
**      a~supplierinvoice ,
**      b~supplierinvoice as sp3 ,
**      b~fiscalyear
**      from I_SuplrInvcItemPurOrdRefAPI01 as a
**      left join i_supplierinvoiceapi01 as b on b~SupplierInvoice = a~SupplierInvoice AND B~FiscalYear = a~FiscalYear
**      for all entries in @ltlines where a~PurchaseOrder = @ltlines-PurchaseOrder and a~SupplierInvoice = @ltlines-SupplierInvoice
**      into table @data(it_pdnew).
**
**LOOP AT it_pdnew INTO DATA(wa_pdnew).
**        DATA : SUPPINV3 TYPE STRING .
**        DATA : FISCYEA3 TYPE STRING .
**        DATA : COMB3 TYPE STRING .
**        SUPPINV3 = WA_pdnew-sp3.
**        FISCYEA3 = wa_pdnew-FiscalYear.
**        CONCATENATE SUPPINV3 FISCYEA3 INTO COMB3.
**
**        select b~Additionalcurrency1 ,
**        a~supplierinvoice ,
**        B~Amountinadditionalcurrency1 ,
**        b~TaxDeterminationDate ,
**        b~postingdate
**        from i_supplierinvoiceapi01 as a
**        left join I_OperationalAcctgDocItem as b on b~OriginalReferenceDocument = @COMB3 and b~FiscalYear = a~FiscalYear
**        WHERE B~AccountingDocumentType = 'KZ'
**        into table @data(it_comb3).
**
**        READ TABLE it_comb3 INTO DATA(wa_comb3) WITH KEY supplierinvoice = wa_pdnew-SupplierInvoice.
**        wa_purchinvlines-paymentdate = wa_comb3-PostingDate.
**        clear : wa_comb3 , wa_pdnew  , COMB3 , SUPPINV3 , FISCYEA3 .
**        ENDLOOP.
*
*
*
*ENDLOOP.
**OUT->write( IT_COMB2 ).
*ENDLOOP.
ENDMETHOD.
ENDCLASS.
