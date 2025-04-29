

CLASS zcl_purchasejob_lines DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS runJob  .
    CLASS-METHODS runJob1  .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purchasejob_lines IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    runJob(  ).
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    runJob(  ).
  ENDMETHOD.

  METHOD runJob1.
*    TYPES ty_id TYPE c LENGTH 10.
*
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
*    SELECT FROM zpurchinvlines      "zbillinglines
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
*    " Getting the actual parameter values
*    LOOP AT it_parameters INTO DATA(ls_parameter).
*      CASE ls_parameter-selname.
*        WHEN 'S_ID'.
*          APPEND VALUE #( sign   = ls_parameter-sign
*                          option = ls_parameter-option
*                          low    = ls_parameter-low
*                          high   = ls_parameter-high ) TO s_id.
*        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
*        WHEN 'P_COUNT'. p_count = ls_parameter-low.
*        WHEN 'P_SIMUL'. p_simul = ls_parameter-low.
*      ENDCASE.
*    ENDLOOP.
*
*    TRY.
**      read own runtime info catalog
*        cl_apj_rt_api=>get_job_runtime_info(
*                         IMPORTING
*                           ev_jobname        = jobname
*                           ev_jobcount       = jobcount
*                           ev_catalog_name   = catalog
*                           ev_template_name  = template ).
*
*      CATCH cx_apj_rt.
*        DATA(lv_catch) = '1'.
*
*    ENDTRY.
*    DATA(lv_date1) = cl_abap_context_info=>get_system_date( ).
*    processfrom = lv_date1 - 30.
*    IF p_simul = abap_true.
*      processfrom = lv_date1 - 2000.
*    ENDIF.
*
******************************************************** HEADER **********************************
*    SELECT  FROM I_SupplierInvoiceAPI01 AS c
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
*            c~DocumentDate, c~PostingDate ,
***************************************
*            hdr1~AddressID
***************************************
*        WHERE c~PostingDate >= @processfrom
*            AND NOT EXISTS (
*               SELECT supplierinvoice FROM zpurchinvproc
*               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
*                 c~CompanyCode = zpurchinvproc~companycode AND
*                 c~FiscalYear = zpurchinvproc~fiscalyearvalue )
*            INTO table @DATA(ltheader).
*
*
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
*          AND a~FiscalYear = @waheader-FiscalYear
*          INTO TABLE @DATA(ltlines).
*
*
*
*
************************************** NEW FILEDS ADDED ************************************
**SELECT from  I_OPERATIONALACCTGDOCITEM as a
**left join I_SupplierInvoiceAPI01 as b on b~SupplierInvoice = a~OriginalReferenceDocument
**FIELDS a~ACCOUNTINGDOCUMENT ,
**b~documentcurrency ,
**a~PurchasingDocument
**FOR ALL ENTRIES IN @ltlines WHERE A~PurchasingDocument = @ltlines-PurchaseOrder
**into table @data(IT_NEW2).
*
*
*
*
*
**data : acc type string.
**    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
**      LEFT JOIN I_SupplierInvoiceAPI01 AS B ON B~SupplierInvoice = A~SupplierInvoice
**      FIELDS B~SupplierInvoice , B~FiscalYear , a~PurchaseOrder
**      FOR ALL ENTRIES IN @ltlines where a~PurchaseOrder = @ltlines-PurchaseOrder
**      into  @data(wa_acc).
**      ENDSELECT.
**      CONCATENATE wa_acc-SupplierInvoice wa_acc-FiscalYear into  acc.
*
*      SELECT b~purchaseordertype ,
*      b~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_purchaseorderapi01 AS b ON b~PurchaseOrder = a~PurchaseOrder
*      FOR ALL ENTRIES IN @ltlines WHERE b~PurchaseOrder = @ltlines-PurchaseOrder AND a~supplierinvoice = @ltlines-SupplierInvoice
*      INTO TABLE @DATA(it_potype).
*
*      SELECT a~purchaseorder,
**          b~supplierinvoice,
*          b~FiscalYear ,
*          a~supplierinvoice
*     FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*     LEFT JOIN i_supplierinvoiceapi01 AS b
*       ON b~SupplierInvoice = a~SupplierInvoice
*     FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~supplierinvoice = @ltlines-supplierinvoice
*     INTO TABLE @DATA(it).
*
**      LOOP AT it INTO DATA(w).
**        DATA(concate) = ''.
**        CONCATENATE w-supplierinvoice w-FiscalYear INTO concate.
**
**        SELECT a~purchaseorder,
**              b~supplierinvoice,
**              b~FiscalYear,
**              c~AccountingDocument
**         FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
**         LEFT JOIN i_supplierinvoiceapi01 AS b
**           ON b~SupplierInvoice = a~SupplierInvoice
**          LEFT JOIN  I_OperationalAcctgDocItem AS c ON c~OriginalReferenceDocument = @concate
**             WHERE  c~OriginalReferenceDocument = @concate
**         INTO TABLE @DATA(it_main).
**        CLEAR : w .
**      ENDLOOP.
*
**      CONCATENATE wa_acc-
*
*
*
*      SELECT a~purchaseorder ,
*             b~documentcurrency ,
*             a~supplierinvoice
*             FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*             LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice
*             FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~supplierinvoice = @ltlines-supplierinvoice
*             INTO TABLE @DATA(it_new3).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~SuplrInvcDeliveryCostCndnType = 'ZAID' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zaid).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~SuplrInvcDeliveryCostCndnType = 'ZADP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zadp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~SuplrInvcDeliveryCostCndnType = 'ZADV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zadv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND  a~SuplrInvcDeliveryCostCndnType = 'ZBKQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zbkq).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZBKV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zbkv).
*
*      SELECT a~freightsupplier ,
*      a~purchaseorder ,
*      b~supplierfullname ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplier AS b ON b~supplier = a~FreightSupplier
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType  IN ('ZBKQ' , 'ZBKV'  )  AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_bvc).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZCHV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zchv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZCVV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zcvv).
*
*      SELECT
*            a~purchaseorder ,
**      b~additionalcurrency1 ,
**      b~amountinadditionalcurrency1 ,
*            a~ReferenceDocument ,
*            b~in_gstpartner ,
*            a~QuantityInPurchaseOrderUnit ,
*            c~productgroup ,
*            c~producttype ,
*            b~accountingdocumenttype ,
*            a~SupplierInvoiceItemAmount ,
*            d~gstin_no ,
*            b~TaxDeterminationDate ,
*            a~supplierinvoice
*            FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*            LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = a~SupplierInvoice and b~FinancialAccountType = 'K'
*            LEFT JOIN I_Product AS c ON c~Product = a~PurchaseOrderItemMaterial
*            LEFT JOIN ztable_plant AS d ON d~plant_code = a~Plant
*            FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~supplierinvoice = @ltlines-SupplierInvoice
*            INTO TABLE @DATA(it_fc).
*
*SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
*FIELDS A~SupplierInvoiceItemAmount , A~PurchaseOrder , A~SupplierInvoice , A~SupplierInvoiceItem
*FOR ALL ENTRIES IN @LTLINES  WHERE A~PurchaseOrder = @LTLINES-PurchaseOrder AND A~SupplierInvoice = @LTLINES-SupplierInvoice AND A~SupplierInvoiceItem = @LTLINES-SupplierInvoiceItem
*INTO TABLE @DATA(IT_NETPR).
*
*      SELECT a~purchaseorder ,
*      a~supplierinvoice ,
*      b~supplierinvoice AS sp ,
*      b~fiscalyear
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice
*      FOR ALL ENTRIES IN @ltlines WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~SupplierInvoice = @ltlines-SupplierInvoice
*      INTO TABLE @DATA(it_fcnew).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZFRV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zfrv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZFRQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zfrq).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'JCDB' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_jcdb).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'JSWC' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_jswc).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZINP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zinp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZINV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zinv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZKKP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zkkp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZLUQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zluq).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZLUV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zluv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZMNP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zmnp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZPKP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zpkp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZPKQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zpkq).
*
*
**      SELECT
**      a~purchaseorder ,
**      e~postingdate ,
**      A~supplierinvoice
**      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
**      LEFT JOIN I_SupplierInvoiceAPI01 AS d ON d~SupplierInvoice = a~SupplierInvoice AND d~FiscalYear = a~FiscalYear
**      LEFT JOIN i_operationalacctgdocitem AS e ON e~OriginalReferenceDocument = d~SupplierInvoice AND e~FiscalYear = d~FiscalYear AND e~CompanyCode = d~CompanyCode
**      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND d~AccountingDocumentType = 'KZ' and A~supplierinvoice = @ltlines-supplierinvoice
**      INTO TABLE @DATA(it_pd).
*
*      SELECT a~purchaseorder ,
*      a~supplierinvoice ,
*      b~supplierinvoice AS sp3 ,
*      b~fiscalyear
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice AND b~FiscalYear = a~FiscalYear
*      FOR ALL ENTRIES IN @ltlines WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~SupplierInvoice = @ltlines-SupplierInvoice
*      INTO TABLE @DATA(it_pdnew).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZPCQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zpcq).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZPCV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zpcv).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZSGP' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zsgp).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZSVQ' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zsvq).
*
*      SELECT a~SupplierInvoiceItemAmount ,
*      a~purchaseorder ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType = 'ZSVV' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_zsvv).
**
**SELECT  B~AMOUNTINCOMPANYCODECURRENCY,
**A~purchaseorder
**from I_SuplrInvcItemPurOrdRefAPI01 as a
**left join I_OperationalAcctgDocItem as b on b~OriginalReferenceDocument = a~SupplierInvoice
**FOR ALL ENTRIES IN @ltlines where A~purchaseorder = @ltlines-PurchaseOrder  and  b~ACCOUNTINGDOCUMENTITEMTYPE = 'T'
**into table @data(IT_TOP).
*
*      """""""""""""""""""""""""""""add""""""
*
*      SELECT a~purchaseorder ,
*      a~supplierinvoice ,
*      b~supplierinvoice AS sp2 ,
*      b~fiscalyear
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice
*      FOR ALL ENTRIES IN @ltlines WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~SupplierInvoice = @ltlines-SupplierInvoice
*      INTO TABLE @DATA(it_topnew).
*      DATA : total_amount TYPE p DECIMALS 3 .
*
*      """""""""""""""""""""""""""""add""""""
*
*      SELECT a~freightsupplier ,
*      a~purchaseorder ,
*      b~supplierfullname ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND a~SuplrInvcDeliveryCostCndnType  IN ('ZFRQ' , 'ZFRV') AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_tc).
*
**SELECT
**A~PURCHASEORDER ,
**B~TaxNumberType
**FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
**LEFT JOIN I_SUPPLIER AS B ON B~Supplier = A~FreightSupplier
**FOR ALL ENTRIES IN @ltlines where A~purchaseorder = @ltlines-PurchaseOrder  and B~ResponsibleType = 'IN3'
**into table @data(IT_VGST).
*
*      SELECT
*      a~purchaseorder ,
*      b~BPPanReferenceNumber ,
*      b~suppliername ,
*      b~BusinessPartnerPanNumber ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_vln).
*
*      SELECT FROM i_supplier AS a
*        FIELDS a~BusinessPartnerPanNumber, a~Supplier
*            FOR ALL ENTRIES IN @ltlines WHERE a~Supplier = @ltlines-FreightSupplier
*         INTO TABLE @DATA(it_panno).
*
*      SELECT
*      a~purchaseorder ,
*      b~BPIdentificationNumber ,
*      a~supplierinvoice
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN I_BuPaIdentification AS b ON b~BusinessPartner = a~FreightSupplier
*      FOR ALL ENTRIES IN @ltlines WHERE a~purchaseorder = @ltlines-PurchaseOrder  AND b~BPIdentificationType = 'TAN' AND a~supplierinvoice = @ltlines-supplierinvoice
*      INTO TABLE @DATA(it_vtn).
*
*
************************************** NEW FILEDS ADDED ************************************
*
*
*
*
*************************Additional LOOP For "Mrnpostingdate"***************************
*      LOOP AT ltlines INTO DATA(wa_new).
*        CLEAR: wa_new-PostingDate.
*        SELECT SINGLE postingdate FROM I_PurchaseOrderItemAPI01 AS a
*                LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
*            WHERE b~purchasinghistorycategory EQ 'Q' AND a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
*            INTO @wa_new-PostingDate.
*
******************************* FOR HSN CODE ****************************
*        SELECT SINGLE FROM I_PurchaseOrderItemAPI01 AS a
*              LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem AND b~GoodsMovementType EQ '101'
*              LEFT JOIN i_accountingdocumentjournal AS c ON b~PurchasingHistoryDocument = c~DocumentReferenceID
*            FIELDS c~documentreferenceid
*                WHERE a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
*                INTO @wa_new-documentreferenceid .
*
*      ENDLOOP.
****************************************************************************************
*
*
**      SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType
**        WHERE BillingDocument = @waheader-BillingDocument
**        INTO TABLE @DATA(it_price).
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_Producttext AS a FIELDS
*            a~ProductName, a~Product
*        FOR ALL ENTRIES IN @ltlines
*        WHERE a~Product = @ltlines-material AND a~Language = 'E'
*            INTO TABLE @DATA(it_product).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_PurchaseOrderItemAPI01 AS a
*            LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
*            FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
*            b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
*        FOR ALL ENTRIES IN @ltlines
*        WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
*            INTO TABLE @DATA(it_po).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_MaterialDocumentItem_2
*            FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
*        FOR ALL ENTRIES IN @ltlines
*        WHERE MaterialDocument  = @ltlines-ReferenceDocument
*            INTO TABLE @DATA(it_grn).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_ProductPlantIntlTrd FIELDS
*            product , plant  , ConsumptionTaxCtrlCode
*            FOR ALL ENTRIES IN @ltlines
*        WHERE product = @ltlines-Material  AND plant = @ltlines-Plant
*            INTO TABLE @DATA(it_hsn).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_taxcodetext
*            FIELDS TaxCode , TaxCodeName
*        FOR ALL ENTRIES IN @ltlines
*        WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
*            INTO TABLE @DATA(it_tax).
*      ENDIF.
*
***************************************************** LOOP *****************************
*      LOOP AT ltlines INTO DATA(walines).
*
*        LOOP AT it INTO DATA(w).
*          DATA: conc TYPE string.
*          DATA : supp TYPE string .
*          DATA : fisc TYPE string .
*          supp =  w-SupplierInvoice .
*          fisc = w-FiscalYear.
*          CONCATENATE supp fisc INTO conc.
*
*          SELECT "a~purchaseorder,
*                b~supplierinvoice,
*                b~FiscalYear,
*                c~AccountingDocument
*           "FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*           from i_supplierinvoiceapi01 AS b
*             "ON b~SupplierInvoice = a~SupplierInvoice
*            LEFT JOIN  I_OperationalAcctgDocItem AS c ON c~OriginalReferenceDocument = @conc
*               WHERE  c~OriginalReferenceDocument = @conc and b~SupplierInvoice = @w-SupplierInvoice
*           INTO TABLE @DATA(it_main).
*          READ TABLE it_main INTO DATA(wa_acco) WITH KEY SupplierInvoice =  walines-SupplierInvoice.
*          wa_purchinvlines-accdocno = wa_acco-AccountingDocument.
*          CLEAR : w , wa_acco.
*        ENDLOOP.
*
*        READ TABLE it_panno INTO DATA(wa_it_panno) WITH KEY Supplier = walines-FreightSupplier.
*        wa_purchinvlines-vendorpanno = wa_it_panno-BusinessPartnerPanNumber.
*
**        ENDLOOP.
*
*        READ TABLE it_new3 INTO DATA(wa_new3) WITH KEY purchaseorder =  walines-purchaseorder supplierinvoice = walines-SupplierInvoice.
**        wa_purchinvlines-accdocno = WA_NEW3-AccountingDocument.
*        wa_purchinvlines-accountingamtcurr = wa_new3-DocumentCurrency.
*        wa_purchinvlines-invoicecurr = wa_new3-DocumentCurrency.
*        READ TABLE it_zaid INTO DATA(wa_zaid) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-aidcper = wa_zaid-SupplierInvoiceItemAmount.
*        READ TABLE it_zaid INTO DATA(wa_zadp) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-antidumpingper = wa_zadp-SupplierInvoiceItemAmount.
**        LOOP AT IT_ZADV INTO DATA(ZADV).
*        READ TABLE it_zadv INTO DATA(wa_zadv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-antidumpingvalue = wa_zadv-SupplierInvoiceItemAmount.
**        CLEAR : WA_ZADV .
**        ENDLOOP.
*        READ TABLE it_zbkq INTO DATA(wa_zbkq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-brokerchargesqty = wa_zbkq-SupplierInvoiceItemAmount.
*        READ TABLE it_zbkv INTO DATA(wa_zbkv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-brokerchargesval = wa_zbkv-SupplierInvoiceItemAmount.
*        READ TABLE it_bvc INTO DATA(wa_bvc) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-brokervendorcode = wa_bvc-FreightSupplier.
*        wa_purchinvlines-brokervendorname = wa_bvc-SupplierFullName.
*        READ TABLE it_zchv INTO DATA(wa_zchv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-chachargesval = wa_zchv-SupplierInvoiceItemAmount.
*        READ TABLE it_zcvv INTO DATA(wa_zcvv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-cvdvalue = wa_zcvv-SupplierInvoiceItemAmount.
*
*        LOOP AT it_fcnew INTO DATA(wa_fcnew).
*          DATA : suppinv TYPE string .
*          DATA : fiscyea TYPE string .
*          DATA : comb TYPE string .
*          suppinv = wa_fcnew-sp.
*          fiscyea = wa_fcnew-FiscalYear.
*          CONCATENATE suppinv fiscyea INTO comb.
*
*          SELECT b~Additionalcurrency1 ,
*          a~supplierinvoice ,
*          b~Amountinadditionalcurrency1 ,
*          b~TaxDeterminationDate
*          FROM i_supplierinvoiceapi01 AS a
*          LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb AND b~FiscalYear = @fiscyea
*          INTO TABLE @DATA(it_comb).
*
*          READ TABLE it_comb INTO DATA(wa_comb) WITH KEY supplierinvoice = wa_fcnew-sp .
*          wa_purchinvlines-foreigncurrency = wa_comb-AdditionalCurrency1.
*          wa_purchinvlines-foreigncurrencyamount = wa_comb-AmountInAdditionalCurrency1.
*          wa_purchinvlines-taxmonthandyera = wa_comb-TaxDeterminationDate.
*          CLEAR : wa_comb ,  wa_fcnew , comb , suppinv , fiscyea.
*        ENDLOOP.
*
*READ TABLE IT_NETPR INTO DATA(WA_NETPR) WITH KEY PURCHASEORDER = WALINES-PurchaseOrder SUPPLIERINVOICE = WALINES-SupplierInvoice SUPPLIERINVOICEITEM = WALINES-SupplierInvoiceItem.
*wa_purchinvlines-netpriceafteramount = wa_netpr-SupplierInvoiceItemAmount .
*        READ TABLE it_fc INTO DATA(wa_fc) WITH KEY purchaseorder = walines-PurchaseOrder supplierinvoice = walines-SupplierInvoice.
**        wa_purchinvlines-foreigncurrency = wa_fc-AdditionalCurrency1.
*        wa_purchinvlines-grnno = wa_fc-ReferenceDocument.
**        wa_purchinvlines-foreigncurrencyamount = wa_fc-AmountInAdditionalCurrency1.
*        wa_purchinvlines-gstinpartner = wa_fc-IN_GSTPartner.
*        wa_purchinvlines-invoiceqty = wa_fc-QuantityInPurchaseOrderUnit.
*        wa_purchinvlines-materialgroup = wa_fc-ProductGroup.
*        wa_purchinvlines-materialtype = wa_fc-ProductType.
*        wa_purchinvlines-mirodocumenttype = wa_fc-AccountingDocumentType .
*        wa_purchinvlines-plantgst = wa_fc-gstin_no.
**        wa_purchinvlines-taxmonthandyera = wa_fc-TaxDeterminationDate.
*        READ TABLE it_zfrv INTO DATA(wa_zfrv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-freightvalue = wa_zfrv-SupplierInvoiceItemAmount.
*        READ TABLE it_zfrq INTO DATA(wa_zfrq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-freightqty = wa_zfrq-SupplierInvoiceItemAmount.
*        READ TABLE it_jcdb INTO DATA(wa_jcdb) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-inbasicscustoms = wa_jcdb-SupplierInvoiceItemAmount.
*        READ TABLE it_jswc INTO DATA(wa_jswc) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-insocialwelfarecess = wa_jswc-SupplierInvoiceItemAmount.
*        READ TABLE it_zinv INTO DATA(wa_zinv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-insurancecost = wa_zinv-SupplierInvoiceItemAmount.
*        READ TABLE it_zkkp INTO DATA(wa_zkkp) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-kisankalyantax = wa_zkkp-SupplierInvoiceItemAmount.
*        READ TABLE it_zluq INTO DATA(wa_zluq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-ldguldgchgsqty = wa_zluq-SupplierInvoiceItemAmount.
*        READ TABLE it_zluv INTO DATA(wa_zluv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-ldguldgchgsval = wa_zluv-SupplierInvoiceItemAmount.
*        READ TABLE it_zmnp INTO DATA(wa_zmnp) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-manditaxvalper = wa_zmnp-SupplierInvoiceItemAmount.
*        READ TABLE it_zpkp INTO DATA(wa_zpkp) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-packingchargesper = wa_zpkp-SupplierInvoiceItemAmount.
*        READ TABLE it_zpkq INTO DATA(wa_zpkq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-packingchargesqty = wa_zpkq-SupplierInvoiceItemAmount.
*
*        LOOP AT it_pdnew INTO DATA(wa_pdnew).
*          DATA : suppinv3 TYPE string .
*          DATA : fiscyea3 TYPE string .
*          DATA : comb3 TYPE string .
*          suppinv3 = WA_pdnew-sp3.
*          fiscyea3 = wa_pdnew-FiscalYear.
*          CONCATENATE suppinv3 fiscyea3 INTO comb3.
*
*          SELECT b~Additionalcurrency1 ,
*          a~supplierinvoice ,
*          b~Amountinadditionalcurrency1 ,
*          b~TaxDeterminationDate ,
*          b~postingdate
*          FROM i_supplierinvoiceapi01 AS a
*          LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb3 AND b~FiscalYear = a~FiscalYear
*          WHERE b~AccountingDocumentType = 'KZ'
*          INTO TABLE @DATA(it_comb3).
*
*          READ TABLE it_comb3 INTO DATA(wa_comb3) WITH KEY supplierinvoice = wa_pdnew-SupplierInvoice.
*          wa_purchinvlines-paymentdate = wa_comb3-PostingDate.
*          CLEAR : wa_comb3 , wa_pdnew  , comb3 , suppinv3 , fiscyea3 .
*        ENDLOOP.
*
**        READ TABLE it_pd INTO DATA(wa_pd) WITH KEY purchaseorder = walines-PurchaseOrder.
**        wa_purchinvlines-paymentdate = wa_pd-PostingDate.
*        READ TABLE it_zpcq INTO DATA(wa_zpcq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-purchasecomissionqty = wa_zpcq-SupplierInvoiceItemAmount.
*        READ TABLE it_zpcv INTO DATA(wa_zpcv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-purchasecomissionvalue = wa_zpcv-SupplierInvoiceItemAmount.
*        READ TABLE it_zsgp INTO DATA(wa_zsgp) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-safeguardper = wa_zsgp-SupplierInvoiceItemAmount.
*        READ TABLE it_zsvq INTO DATA(wa_zsvq) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-surveyorchargesqty = wa_zsvq-SupplierInvoiceItemAmount.
*        READ TABLE it_zsvv INTO DATA(wa_zsvv) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-surveyorchargesval = wa_zsvv-SupplierInvoiceItemAmount.
*
*        LOOP AT it_topnew INTO DATA(wa_topnew).
*          DATA : suppinv2 TYPE string .
*          DATA : fiscyea2 TYPE string .
*          DATA : comb2 TYPE string .
*          suppinv2 = wa_topnew-sp2.
*          fiscyea2 = wa_topnew-FiscalYear.
*          CONCATENATE suppinv2 fiscyea2 INTO comb2.
*
*          SELECT
*          a~supplierinvoice ,
*          b~AmountInCompanyCodeCurrency
*          FROM i_supplierinvoiceapi01 AS a
*          LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb2 AND b~FiscalYear = @fiscyea2
*          WHERE a~supplierinvoice = @fiscyea2  AND b~accountingdocumentitemtype = 'T'
*          INTO TABLE @DATA(it_comb2).
*
*          LOOP AT it_comb2 INTO DATA(wa_comb2) .
*            total_amount = total_amount + wa_comb2-AmountInCompanyCodeCurrency .
*            CLEAR : wa_comb2 .
*          ENDLOOP.
*
*
**        READ TABLE it_comb2 INTO DATA(wa_comb2) WITH KEY supplierinvoice = wa_topnew-sp2 .
*
*
*          CLEAR :  wa_topnew , comb2 , fiscyea2 , suppinv2 .
*        ENDLOOP.
*
*        wa_purchinvlines-taxesonpo = total_amount .
**       READ TABLE IT_TOP INTO WA_TOP WITH KEY PURCHASEORDER = walines-PurchaseOrder.
*
*        READ TABLE it_tc INTO DATA(wa_tc) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-transportercode = wa_tc-FreightSupplier.
*        wa_purchinvlines-transportername = wa_tc-SupplierFullName.
*        wa_purchinvlines-vendorcode = wa_tc-FreightSupplier.
**      READ TABLE IT_VGST INTO DATA(WA_VGST) WITH KEY PURCHASEORDER = walines-PurchaseOrder.
**        wa_purchinvlines-vendorgstin = WA_VGST-TaxNumberType.
*        READ TABLE it_vln INTO DATA(wa_vln) WITH KEY purchaseorder = walines-PurchaseOrder.
*        wa_purchinvlines-vendorlegalname = wa_vln-BPPanReferenceNumber.
*        wa_purchinvlines-vendorname = wa_vln-SupplierName.
**        wa_purchinvlines-vendorpanno = wa_vln-BusinessPartnerPanNumber.
*        READ TABLE it_vtn INTO DATA(wa_vtn) WITH KEY purchaseorder = walines-PurchaseOrder.
**        wa_purchinvlines-vendortanname = WA_VTN-.
*        wa_purchinvlines-vendortanno = wa_vtn-BPIdentificationNumber.
*        wa_purchinvlines-paymentterms = walines-PaymentTerms.
*        wa_purchinvlines-tolerance = walines-OverdelivTolrtdLmtRatioInPct.
*        wa_purchinvlines-plant = walines-Plant.
*        READ TABLE it_potype INTO DATA(wa_potype) WITH KEY purchaseorder = walines-PurchaseOrder supplierinvoice = walines-SupplierInvoice.
*        wa_purchinvlines-documenttype = wa_potype-PurchaseOrderType.
**        wa_purchinvlines-poqty = walines-OrderQuantity.
*        wa_purchinvlines-pototalvalue = walines-NetAmount.
*        wa_purchinvlines-prdate = walines-PurReqCreationDate.
*        wa_purchinvlines-prno = walines-PurchaseRequisition.
*        wa_purchinvlines-prqty = walines-RequestedQuantity.
*        wa_purchinvlines-client = sy-mandt.
*        wa_purchinvlines-companycode = waheader-CompanyCode.
*        wa_purchinvlines-fiscalyearvalue = waheader-FiscalYear.
*        wa_purchinvlines-supplierinvoice = waheader-SupplierInvoice.
*        wa_purchinvlines-supplierinvoiceitem = walines-SupplierInvoiceItem.
*        wa_purchinvlines-postingdate = waheader-PostingDate.
*************************************** Item Level Fields Added ****************************
*        wa_purchinvlines-plantcity = walines-plantcity.
*        wa_purchinvlines-plantpin = walines-plantpin.
**        wa_purchinvlines-product_trade_name = walines-trade_name.
*        wa_purchinvlines-vendor_invoice_no = walines-DeliveryDocumentBySupplier.
*        wa_purchinvlines-vendor_invoice_date = walines-DocumentDate.
*        wa_purchinvlines-vendor_type = walines-LegalFormDescription.
*        wa_purchinvlines-rfqno = walines-SupplierQuotation.
*        wa_purchinvlines-rfqno = walines-SupplierQuotation.
*        wa_purchinvlines-rfqdate = walines-RFQPublishingDate.
*        wa_purchinvlines-supplierquotation = walines-sq.
*        wa_purchinvlines-supplierquotationdate = walines-QuotationSubmissionDate.
*        wa_purchinvlines-mrnquantityinbaseunit = walines-PostingDate.
*        wa_purchinvlines-hsncode = walines-DocumentReferenceID.
*
*
*        SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
*            LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
*            FIELDS
*            a~BusinessPlaceDescription,
*            a~IN_GSTIdentificationNumber,
*            b~Street, b~PostalCode , b~CityName
*        WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walines-Plant
*        INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
*            @wa_purchinvlines-plantcity ).
*
*        wa_purchinvlines-product                   = walines-material.
*        READ TABLE it_product INTO DATA(wa_product) WITH KEY product = walines-material.
*        wa_purchinvlines-productname = wa_product-ProductName.
*
*        wa_purchinvlines-purchaseorder             = walines-PurchaseOrder.
*        wa_purchinvlines-purchaseorderitem         = walines-PurchaseOrderItem.
*
*        READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = walines-PurchaseOrder
*                                                PurchaseOrderItem = walines-PurchaseOrderItem.
*
*        wa_purchinvlines-baseunit                  = wa_po-BaseUnit.
*        wa_purchinvlines-profitcenter              = wa_po-ProfitCenter.
*        wa_purchinvlines-purchaseordertype         = wa_po-PurchaseOrderType.
**            wa_purchinvlines-purchaseorderdate         : wa_po-PurchaseOrderDate.
*        wa_purchinvlines-purchasingorganization    = wa_po-PurchasingOrganization.
*        wa_purchinvlines-purchasinggroup           = wa_po-PurchasingGroup.
*
*        READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
*        wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
**            wa_purchinvlines-mrnpostingdate            = wa_grn-PostingDate;
**            ls_response-grn = wa_it-ReferenceDocument.
**        ls_response-grnyear = wa_it-ReferenceDocumentFiscalYear.
*
*        READ TABLE it_hsn INTO DATA(wa_hsn) WITH KEY plant = walines-Plant Product = walines-Material.
*        wa_purchinvlines-hsncode                    = wa_hsn-ConsumptionTaxCtrlCode.
*        CLEAR wa_hsn.
*
*        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY TaxCode = walines-TaxCode.
*        wa_purchinvlines-taxcodename                = wa_tax-TaxCodeName.
*
**        wa_purchinvlines-originalreferencedocument : abap.char(20);
*
*        SELECT SINGLE TaxItemAcctgDocItemRef FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @walines-sinvwithfyear AND TaxItemAcctgDocItemRef IS NOT INITIAL
*            AND AccountingDocumentItemType <> 'T'
*            AND FiscalYear = @walines-FiscalYear
*            AND CompanyCode = @waheader-CompanyCode
*            AND AccountingDocumentType = 'RE'
*        INTO  @DATA(lv_TaxItemAcctgDocItemRef).
*
*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @walines-sinvwithfyear
*                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                AND AccountingDocumentItemType = 'T'
*                AND FiscalYear = @walines-FiscalYear
*                AND CompanyCode = @waheader-CompanyCode
*                AND TransactionTypeDetermination = 'JII'
*        INTO  @wa_purchinvlines-igst.
*
*        IF wa_purchinvlines-igst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @walines-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @wa_purchinvlines-cgst.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @walines-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @wa_purchinvlines-sgst.
*        ENDIF.
*
**            wa_purchinvlines-igst = ABS( wa_purchinvlines-igst ).
**            wa_purchinvlines-cgst = ABS( wa_purchinvlines-cgst ).
**            wa_purchinvlines-sgst = ABS( wa_purchinvlines-sgst ).
*
**        wa_purchinvlines-rateigst                  : abap.dec(13,2);
**        wa_purchinvlines-ratecgst                  : abap.dec(13,2);
**        wa_purchinvlines-ratesgst                  : abap.dec(13,2);
*
*        SELECT SINGLE FROM I_JournalEntry
*            FIELDS DocumentDate ,
*                DocumentReferenceID ,
*                IsReversed
*        WHERE OriginalReferenceDocument = @walines-SupplierInvoice
*        INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).
*
*        wa_purchinvlines-pouom                      = walines-PurchaseOrderPriceUnit.
*        wa_purchinvlines-poqty                      = walines-QuantityInPurchaseOrderUnit.
*        wa_purchinvlines-netamount                  = walines-SupplierInvoiceItemAmount.
*        wa_purchinvlines-basicrate                  = round( val = wa_purchinvlines-netamount / wa_purchinvlines-poqty dec = 2 ).
*
*        wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst +
*                                                      wa_purchinvlines-cgst.
*        wa_purchinvlines-totalamount                = wa_purchinvlines-taxamount + wa_purchinvlines-netamount.
*
**        wa_purchinvlines-roundoff                  : abap.dec(13,2);
**        wa_purchinvlines-manditax                  : abap.dec(13,2);
**        wa_purchinvlines-mandicess                 : abap.dec(13,2);
**        wa_purchinvlines-discount                  : abap.dec(13,2);
*
**       CLEAR wa_price.
*
*
**        DELETE ADJACENT DUPLICATES FROM lt_purchinvlines COMPARING ALL FIELDS.
*        APPEND wa_purchinvlines TO lt_purchinvlines.
********************** Added on 11.03.2025
*        MODIFY zpurchinvlines FROM @wa_purchinvlines.
*        CLEAR : wa_purchinvlines.
*        CLEAR : wa_po, wa_grn, wa_hsn, wa_tax, lv_taxitemacctgdocitemref.
*        CLEAR : wa_new3 , wa_zaid , wa_zadp , wa_zadv , wa_zbkq , wa_ZBKV , wa_bvc , wa_zchv , wa_zcvv , wa_fc , wa_zfrv , wa_zfrq , wa_jcdb ,
*                wa_jswc , wa_zinv , wa_zkkp , wa_zluv , wa_zmnp , wa_zpkp , wa_zpkq , wa_pdnew , wa_zpcq  , wa_zpcv  , wa_zsgp , wa_zsvq , wa_zsvv ,
*                wa_topnew , wa_tc , wa_vln , wa_vtn , wa_netpr. "WA_NEW3
*      ENDLOOP.
*
**      INSERT zpurchinvlines FROM TABLE @lt_purchinvlines.
*
*
*      wa_purchinvprocessed-client = sy-mandt.
*      wa_purchinvprocessed-supplierinvoice = waheader-SupplierInvoice.
*      wa_purchinvprocessed-companycode = waheader-CompanyCode.
*      wa_purchinvprocessed-fiscalyearvalue = waheader-FiscalYear.
*      wa_purchinvprocessed-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
*      wa_purchinvprocessed-creationdatetime = lv_timestamp.
****************************************** Header Level Fields Added *******************************
*      wa_purchinvlines-plantadr = waheader-AddressID.
**       HT 08/04/2025
*
*      APPEND wa_purchinvprocessed TO lt_purchinvprocessed.
*********************** Added on 11.03.2025
*      MODIFY zpurchinvproc FROM @wa_purchinvprocessed.
**      INSERT zpurchinvproc FROM TABLE @lt_purchinvprocessed.
*      COMMIT WORK.
*
*      CLEAR :  wa_purchinvprocessed, lt_purchinvprocessed, lt_purchinvlines.
*      CLEAR : ltlines, it_product, it_po, it_grn, it_hsn, it_tax.
*
*    ENDLOOP.
*
*
  ENDMETHOD.





  METHOD runJob .
    TYPES ty_id TYPE c LENGTH 10.

    DATA s_id    TYPE RANGE OF ty_id.
    DATA p_descr TYPE c LENGTH 80.
    DATA p_count TYPE i.
    DATA p_simul TYPE abap_boolean.
    DATA processfrom TYPE d.

    DATA: jobname   TYPE cl_apj_rt_api=>ty_jobname.
    DATA: jobcount  TYPE cl_apj_rt_api=>ty_jobcount.
    DATA: catalog   TYPE cl_apj_rt_api=>ty_catalog_name.
    DATA: template  TYPE cl_apj_rt_api=>ty_template_name.

    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
          wa_purchinvlines     TYPE zpurchinvlines,
          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
          wa_purchinvprocessed TYPE zpurchinvproc.


****************************************************************************************
    DATA maxpostingdate TYPE d.
    DATA deleteString TYPE c LENGTH 4.
    DATA: lv_tstamp TYPE timestamp, lv_date TYPE d, lv_time TYPE t, lv_dst TYPE abap_bool.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    GET TIME STAMP FIELD lv_tstamp.
    CONVERT TIME STAMP lv_tstamp TIME ZONE sy-zonlo INTO DATE lv_date TIME lv_time DAYLIGHT SAVING TIME lv_dst.

    deleteString = |{ lv_date+6(2) }| && |{ lv_time+0(2) }|.

    IF deleteString = '2819'.
      DELETE FROM zpurchinvlines WHERE companycode IS NOT INITIAL.
      DELETE FROM zpurchinvproc WHERE companycode IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.

    SELECT FROM zpurchinvlines "zbillinglines
      FIELDS MAX( postingdate )
      WHERE companycode IS NOT INITIAL
      INTO @maxpostingdate .

    IF maxpostingdate IS INITIAL.
      maxpostingdate = 20010101.
    ELSE.
      maxpostingdate = maxpostingdate - 30.
    ENDIF.
****************************************************************************************


    TRY.
*      read own runtime info catalog
        cl_apj_rt_api=>get_job_runtime_info(
                         IMPORTING
                           ev_jobname        = jobname
                           ev_jobcount       = jobcount
                           ev_catalog_name   = catalog
                           ev_template_name  = template ).

    CATCH cx_apj_rt.
        DATA(lv_catch) = '1'.

    ENDTRY.
    DATA(lv_date1) = cl_abap_context_info=>get_system_date( ).
    processfrom = lv_date1 - 30.
    IF p_simul = abap_true.
      processfrom = lv_date1 - 2000.
    ENDIF.


******************************************************* HEADER **********************************
    SELECT  FROM I_SupplierInvoiceAPI01 AS c
        LEFT JOIN i_supplier AS b ON b~supplier = c~InvoicingParty
***********************************
        LEFT JOIN I_PurchaseOrderItemAPI01 AS hdr ON c~BusinessPlace = hdr~Plant
        LEFT JOIN I_BusPartAddress AS hdr1 ON hdr~Plant = hdr1~BusinessPartner
***********************************
        FIELDS
            b~Supplier , b~PostalCode , b~BPAddrCityName , b~BPAddrStreetName , b~TaxNumber3,
            b~SupplierFullName, b~region, c~ReverseDocument , c~ReverseDocumentFiscalYear,
            c~CompanyCode , c~PaymentTerms , c~CreatedByUser , c~CreationDate , c~InvoicingParty , c~InvoiceGrossAmount,
            c~DocumentCurrency , c~SupplierInvoiceIDByInvcgParty, c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear,
            c~DocumentDate, c~PostingDate ,
**************************************
            hdr1~AddressID
**************************************
        WHERE c~PostingDate >= @processfrom
            AND NOT EXISTS (
               SELECT supplierinvoice FROM zpurchinvproc
               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
                 c~CompanyCode = zpurchinvproc~companycode AND
                 c~FiscalYear = zpurchinvproc~fiscalyearvalue )
            INTO table @DATA(ltheader).



******************************************************* LINE ITEM **********************************
    LOOP AT ltheader INTO DATA(waheader).
      lv_timestamp = cl_abap_tstmp=>add_to_short( tstmp = lv_timestamp secs = 11111 ).

* Delete already processed sales line
      DELETE FROM zpurchinvlines
        WHERE zpurchinvlines~companycode = @waheader-CompanyCode AND
        zpurchinvlines~fiscalyearvalue = @waheader-FiscalYear AND
        zpurchinvlines~supplierinvoice = @waheader-SupplierInvoice.


      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
************************************
        LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder
*        LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
        LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
        LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
        LEFT JOIN i_purchaseorderhistoryapi01 AS li5 ON li~PurchaseOrder = li5~PurchaseOrder AND li~PurchaseOrderItem = li5~PurchaseOrderItem
        LEFT JOIN i_purchaseorderapi01 AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
*        LEFT JOIN i_purchaseorderapi01 AS poa ON a~PurchaseOrder = poa~PurchaseOrder
        LEFT JOIN I_BusinessPartner AS li7 ON li6~Supplier = li7~BusinessPartner
        LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
        LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder
        LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
        LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
        LEFT JOIN i_accountingdocumentjournal AS li12 ON li5~PurchasingHistoryDocument = li12~DocumentReferenceID
        LEFT JOIN i_purchaserequisitionitemapi01 AS li13 ON li13~PurchaseRequisition = li~PurchaseRequisition

************************************

        FIELDS
            a~PurchaseOrderItem, a~SupplierInvoiceItem,
            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
            a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction AS SInvwithFYear, a~plant,
            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear ,
************************************
            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,  "li4~trade_name,
            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
            li11~QuotationSubmissionDate, li5~PostingDate, li12~DocumentReferenceID , li6~PurchaseOrderType , li6~PaymentTerms ,
            li~OrderQuantity ,li~NetAmount , li13~PurReqCreationDate , li~PurchaseRequisition , li13~RequestedQuantity ,
            li~OverdelivTolrtdLmtRatioInPct ", poa~PurchaseOrderType AS po_type
************************************
        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
          AND a~FiscalYear = @waheader-FiscalYear
          INTO TABLE @DATA(ltlines).

************************************* NEW FILEDS ADDED ************************************




************************Additional LOOP For "Mrnpostingdate"***************************
      LOOP AT ltlines INTO DATA(wa_new).
        CLEAR: wa_new-PostingDate.
        SELECT SINGLE postingdate FROM I_PurchaseOrderItemAPI01 AS a
                LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
            WHERE b~purchasinghistorycategory EQ 'Q' AND a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
            INTO @wa_new-PostingDate.

****************************** FOR HSN CODE ****************************
        SELECT SINGLE FROM I_PurchaseOrderItemAPI01 AS a
              LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem AND b~GoodsMovementType EQ '101'
              LEFT JOIN i_accountingdocumentjournal AS c ON b~PurchasingHistoryDocument = c~DocumentReferenceID
            FIELDS c~documentreferenceid
                WHERE a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
                INTO @wa_new-documentreferenceid .

      ENDLOOP.
***************************************************************************************


*      SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType
*        WHERE BillingDocument = @waheader-BillingDocument
*        INTO TABLE @DATA(it_price).

      IF ( ltlines[] IS NOT INITIAL ).
        SELECT FROM I_Producttext AS a FIELDS
            a~ProductName, a~Product
        FOR ALL ENTRIES IN @ltlines
        WHERE a~Product = @ltlines-material AND a~Language = 'E'
            INTO TABLE @DATA(it_product).
      ENDIF.

      IF ( ltlines[] IS NOT INITIAL ).
        SELECT FROM I_PurchaseOrderItemAPI01 AS a
            LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
            FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
            b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
        FOR ALL ENTRIES IN @ltlines
        WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
            INTO TABLE @DATA(it_po).
      ENDIF.

      IF ( ltlines[] IS NOT INITIAL ).
        SELECT FROM I_MaterialDocumentItem_2
            FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
        FOR ALL ENTRIES IN @ltlines
        WHERE MaterialDocument  = @ltlines-ReferenceDocument
            INTO TABLE @DATA(it_grn).
      ENDIF.

      IF ( ltlines[] IS NOT INITIAL ).
        SELECT FROM I_ProductPlantIntlTrd FIELDS
            product , plant  , ConsumptionTaxCtrlCode
            FOR ALL ENTRIES IN @ltlines
        WHERE product = @ltlines-Material  AND plant = @ltlines-Plant
            INTO TABLE @DATA(it_hsn).
      ENDIF.

      IF ( ltlines[] IS NOT INITIAL ).
        SELECT FROM I_taxcodetext
            FIELDS TaxCode , TaxCodeName
        FOR ALL ENTRIES IN @ltlines
        WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
            INTO TABLE @DATA(it_tax).
      ENDIF.

**************************************************** LOOP *****************************
      LOOP AT ltlines INTO DATA(walines).




*        wa_purchinvlines-poqty = walines-OrderQuantity.
        wa_purchinvlines-client = sy-mandt.
        wa_purchinvlines-companycode = waheader-CompanyCode.
        wa_purchinvlines-fiscalyearvalue = waheader-FiscalYear.
        wa_purchinvlines-supplierinvoice = waheader-SupplierInvoice.
        wa_purchinvlines-supplierinvoiceitem = walines-SupplierInvoiceItem.
        wa_purchinvlines-postingdate = waheader-PostingDate.
************************************** Item Level Fields Added ****************************
        wa_purchinvlines-plantcity = walines-plantcity.
        wa_purchinvlines-plantpin = walines-plantpin.
*        wa_purchinvlines-product_trade_name = walines-trade_name.
        wa_purchinvlines-vendor_invoice_no = walines-DeliveryDocumentBySupplier.
        wa_purchinvlines-vendor_invoice_date = walines-DocumentDate.
        wa_purchinvlines-vendor_type = walines-LegalFormDescription.
        wa_purchinvlines-rfqno = walines-SupplierQuotation.
        wa_purchinvlines-rfqno = walines-SupplierQuotation.
        wa_purchinvlines-rfqdate = walines-RFQPublishingDate.
        wa_purchinvlines-supplierquotation = walines-sq.
        wa_purchinvlines-supplierquotationdate = walines-QuotationSubmissionDate.
        wa_purchinvlines-mrnquantityinbaseunit = walines-PostingDate.
        wa_purchinvlines-hsncode = walines-DocumentReferenceID.


        SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
            LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
            FIELDS
            a~BusinessPlaceDescription,
            a~IN_GSTIdentificationNumber,
            b~Street, b~PostalCode , b~CityName
        WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walines-Plant
        INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
            @wa_purchinvlines-plantcity ).

        wa_purchinvlines-product                   = walines-material.
        READ TABLE it_product INTO DATA(wa_product) WITH KEY product = walines-material.
        wa_purchinvlines-productname = wa_product-ProductName.

        wa_purchinvlines-purchaseorder             = walines-PurchaseOrder.
        wa_purchinvlines-purchaseorderitem         = walines-PurchaseOrderItem.

        READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = walines-PurchaseOrder
                                                PurchaseOrderItem = walines-PurchaseOrderItem.

        wa_purchinvlines-baseunit                  = wa_po-BaseUnit.
        wa_purchinvlines-profitcenter              = wa_po-ProfitCenter.
        wa_purchinvlines-purchaseordertype         = wa_po-PurchaseOrderType.
*            wa_purchinvlines-purchaseorderdate         : wa_po-PurchaseOrderDate.
        wa_purchinvlines-purchasingorganization    = wa_po-PurchasingOrganization.
        wa_purchinvlines-purchasinggroup           = wa_po-PurchasingGroup.

        READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
        wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
*            wa_purchinvlines-mrnpostingdate            = wa_grn-PostingDate;
*            ls_response-grn = wa_it-ReferenceDocument.
*        ls_response-grnyear = wa_it-ReferenceDocumentFiscalYear.

        READ TABLE it_hsn INTO DATA(wa_hsn) WITH KEY plant = walines-Plant Product = walines-Material.
        wa_purchinvlines-hsncode                    = wa_hsn-ConsumptionTaxCtrlCode.
        CLEAR wa_hsn.

        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY TaxCode = walines-TaxCode.
        wa_purchinvlines-taxcodename                = wa_tax-TaxCodeName.

*        wa_purchinvlines-originalreferencedocument : abap.char(20);

        SELECT SINGLE TaxItemAcctgDocItemRef FROM i_operationalacctgdocitem
            WHERE OriginalReferenceDocument = @walines-sinvwithfyear AND TaxItemAcctgDocItemRef IS NOT INITIAL
            AND AccountingDocumentItemType <> 'T'
            AND FiscalYear = @walines-FiscalYear
            AND CompanyCode = @waheader-CompanyCode
            AND AccountingDocumentType = 'RE'
        INTO  @DATA(lv_TaxItemAcctgDocItemRef).

        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
            WHERE OriginalReferenceDocument = @walines-sinvwithfyear
                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                AND AccountingDocumentItemType = 'T'
                AND FiscalYear = @walines-FiscalYear
                AND CompanyCode = @waheader-CompanyCode
                AND TransactionTypeDetermination = 'JII'
        INTO  @wa_purchinvlines-igst.

        IF wa_purchinvlines-igst IS INITIAL.
          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @walines-sinvwithfyear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JIC'
          INTO  @wa_purchinvlines-cgst.

          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
              WHERE OriginalReferenceDocument = @walines-sinvwithfyear
                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
                  AND AccountingDocumentItemType = 'T'
                  AND FiscalYear = @walines-FiscalYear
                  AND CompanyCode = @waheader-CompanyCode
                  AND TransactionTypeDetermination = 'JIS'
          INTO  @wa_purchinvlines-sgst.
        ENDIF.

*            wa_purchinvlines-igst = ABS( wa_purchinvlines-igst ).
*            wa_purchinvlines-cgst = ABS( wa_purchinvlines-cgst ).
*            wa_purchinvlines-sgst = ABS( wa_purchinvlines-sgst ).

*        wa_purchinvlines-rateigst                  : abap.dec(13,2);
*        wa_purchinvlines-ratecgst                  : abap.dec(13,2);
*        wa_purchinvlines-ratesgst                  : abap.dec(13,2);

        SELECT SINGLE FROM I_JournalEntry
            FIELDS DocumentDate ,
                DocumentReferenceID ,
                IsReversed
        WHERE OriginalReferenceDocument = @walines-SupplierInvoice
        INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).

        wa_purchinvlines-pouom                      = walines-PurchaseOrderPriceUnit.
        wa_purchinvlines-poqty                      = walines-QuantityInPurchaseOrderUnit.
        wa_purchinvlines-netamount                  = walines-SupplierInvoiceItemAmount.
        wa_purchinvlines-basicrate                  = round( val = wa_purchinvlines-netamount / wa_purchinvlines-poqty dec = 2 ).

        wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst +
                                                      wa_purchinvlines-cgst.
        wa_purchinvlines-totalamount                = wa_purchinvlines-taxamount + wa_purchinvlines-netamount.

*        wa_purchinvlines-roundoff                  : abap.dec(13,2);
*        wa_purchinvlines-manditax                  : abap.dec(13,2);
*        wa_purchinvlines-mandicess                 : abap.dec(13,2);
*        wa_purchinvlines-discount                  : abap.dec(13,2);

*       CLEAR wa_price.


*        DELETE ADJACENT DUPLICATES FROM lt_purchinvlines COMPARING ALL FIELDS.
        APPEND wa_purchinvlines TO lt_purchinvlines.
********************* Added on 11.03.2025
        MODIFY zpurchinvlines FROM @wa_purchinvlines.
        CLEAR : wa_purchinvlines.
        CLEAR : wa_po, wa_grn, wa_hsn, wa_tax, lv_taxitemacctgdocitemref.
      ENDLOOP.

*      INSERT zpurchinvlines FROM TABLE @lt_purchinvlines.


      wa_purchinvprocessed-client = sy-mandt.
      wa_purchinvprocessed-supplierinvoice = waheader-SupplierInvoice.
      wa_purchinvprocessed-companycode = waheader-CompanyCode.
      wa_purchinvprocessed-fiscalyearvalue = waheader-FiscalYear.
      wa_purchinvprocessed-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
      wa_purchinvprocessed-creationdatetime = lv_timestamp.
***************************************** Header Level Fields Added *******************************
      wa_purchinvlines-plantadr = waheader-AddressID.
*       HT 08/04/2025

      APPEND wa_purchinvprocessed TO lt_purchinvprocessed.
********************** Added on 11.03.2025
      MODIFY zpurchinvproc FROM @wa_purchinvprocessed.
*      INSERT zpurchinvproc FROM TABLE @lt_purchinvprocessed.
      COMMIT WORK.

      CLEAR :  wa_purchinvprocessed, lt_purchinvprocessed, lt_purchinvlines.
      CLEAR : ltlines, it_product, it_po, it_grn, it_hsn, it_tax.

    ENDLOOP.


  ENDMETHOD.
ENDCLASS.







*    DATA processfrom TYPE d.
*    DATA p_simul TYPE abap_boolean.
*    DATA assignmentreference TYPE string.
*
*
*    DATA: lt_purchinvlines     TYPE STANDARD TABLE OF zpurchinvlines,
*          wa_purchinvlines     TYPE zpurchinvlines,
*          lt_purchinvprocessed TYPE STANDARD TABLE OF zpurchinvproc,
*          wa_purchinvprocessed TYPE zpurchinvproc.
*
*    GET TIME STAMP FIELD DATA(lv_timestamp).
*
**    DELETE FROM zpurchinvproc.
**    DELETE FROM zpurchinvlines.
**    COMMIT WORK.
*
*    p_simul = abap_true.
*    processfrom = sy-datum - 30.
*    IF p_simul = abap_true.
*      processfrom = sy-datum - 2000.
*    ENDIF.
*
*
****************************************************** HEADER *****************************************
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
*        WHERE c~PostingDate >= @processfrom
*            AND NOT EXISTS (
*               SELECT supplierinvoice FROM zpurchinvproc
*               WHERE c~supplierinvoice = zpurchinvproc~supplierinvoice AND
*                 c~CompanyCode = zpurchinvproc~companycode AND
*                 c~FiscalYear = zpurchinvproc~fiscalyearvalue )
**                 AND c~supplierinvoice = '5105600237'
*            INTO TABLE @DATA(ltheader).
*
********************************************************** LINE ITEM ***************************************
*    LOOP AT ltheader INTO DATA(waheader).
**      lv_timestamp = cl_abap_tstmp=>add_to_short( tstmp = lv_timestamp secs = 11111 ).
*      GET TIME STAMP FIELD lv_timestamp.
*
** Delete already processed sales line
*      DELETE FROM zpurchinvlines
*        WHERE zpurchinvlines~companycode = @waheader-CompanyCode AND
*        zpurchinvlines~fiscalyearvalue = @waheader-FiscalYear AND
*        zpurchinvlines~supplierinvoice = @waheader-SupplierInvoice.
*
*
*
*      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
***********************************************
*        LEFT JOIN I_PurchaseOrderItemAPI01 AS li ON a~PurchaseOrder = li~PurchaseOrder
**        LEFT JOIN zmaterial_table AS li4 ON li~Material = li4~mat
*        LEFT JOIN i_deliverydocumentitem AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
*        LEFT JOIN i_deliverydocument AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
*        LEFT JOIN i_purchaseorderhistoryapi01 AS li5 ON li~PurchaseOrder = li5~PurchaseOrder AND li~PurchaseOrderItem = li5~PurchaseOrderItem
*        LEFT JOIN i_purchaseorderapi01 AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
*        LEFT JOIN I_BusinessPartner AS li7 ON li6~Supplier = li7~BusinessPartner
*        LEFT JOIN I_BusinessPartnerLegalFormText AS li8 ON li7~LegalForm = li8~LegalForm
*        LEFT JOIN i_purchaseorderitemtp_2 AS li9 ON li~PurchaseOrder = li9~PurchaseOrder
*        LEFT JOIN I_Requestforquotation_Api01 AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
*        LEFT JOIN I_SupplierQuotation_Api01 AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
*        LEFT JOIN i_accountingdocumentjournal AS li12 ON li5~PurchasingHistoryDocument = li12~DocumentReferenceID
**********************************************
*        FIELDS
*            a~PurchaseOrderItem, a~SupplierInvoiceItem,
*            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
*            a~FreightSupplier , a~SupplierInvoice , a~FiscalYear , a~TaxJurisdiction, a~plant,
*            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
*            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear,
*************************************************
*            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier, li5~DocumentDate,  "li4~trade_name,
*            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
*            li11~QuotationSubmissionDate, li5~PostingDate,  li12~DocumentReferenceID
************************************************
*        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
*          AND a~FiscalYear = @waheader-FiscalYear
**          AND a~SuplrInvcDeliveryCostCndnType = ''
*        ORDER BY a~PurchaseOrderItem, a~SupplierInvoiceItem
*          INTO TABLE @DATA(ltlines).
*
*
*************************Additional LOOP For "Mrnpostingdate"***************************
*      LOOP AT ltlines INTO DATA(wa_new).
*        CLEAR: wa_new-PostingDate.
*
*        SELECT SINGLE    postingdate FROM I_PurchaseOrderItemAPI01 AS a
*                LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem
*            WHERE b~purchasinghistorycategory EQ 'Q' AND a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
*            INTO @wa_new-PostingDate.
*
******************************* FOR HSN CODE ****************************
*        SELECT SINGLE FROM I_PurchaseOrderItemAPI01 AS a
*              LEFT JOIN i_purchaseorderhistoryapi01 AS b ON a~PurchaseOrder = b~PurchaseOrder AND a~PurchaseOrderItem = b~PurchaseOrderItem AND b~GoodsMovementType EQ '101'
*              LEFT JOIN i_accountingdocumentjournal AS c ON b~PurchasingHistoryDocument = c~DocumentReferenceID
*            FIELDS c~documentreferenceid
*                WHERE a~purchaseorder = @wa_new-PurchaseOrder AND a~purchaseorderitem = @wa_new-PurchaseOrderItem
*                INTO @wa_new-documentreferenceid.
*
*      ENDLOOP.
****************************************************************************************
*
*
**      SELECT FROM I_BillingDocItemPrcgElmntBasic FIELDS BillingDocument , BillingDocumentItem, ConditionRateValue, ConditionAmount, ConditionType
**        WHERE BillingDocument = @waheader-BillingDocument
**        INTO TABLE @DATA(it_price).
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_Producttext AS a FIELDS
*            a~ProductName, a~Product
*        FOR ALL ENTRIES IN @ltlines
*        WHERE a~Product = @ltlines-material AND a~Language = 'E'
*            INTO TABLE @DATA(it_product).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_PurchaseOrderItemAPI01 AS a
*            LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
*            FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
*            b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
*        FOR ALL ENTRIES IN @ltlines
*        WHERE a~PurchaseOrder = @ltlines-PurchaseOrder AND a~PurchaseOrderItem = @ltlines-PurchaseOrderItem
*            INTO TABLE @DATA(it_po).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_MaterialDocumentItem_2
*            FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
*        FOR ALL ENTRIES IN @ltlines
*        WHERE MaterialDocument  = @ltlines-ReferenceDocument
*            INTO TABLE @DATA(it_grn).
*      ENDIF.
*
*      IF ( ltlines[] IS NOT INITIAL ).
*        SELECT FROM I_taxcodetext
*            FIELDS TaxCode , TaxCodeName
*        FOR ALL ENTRIES IN @ltlines
*        WHERE Language = 'E' AND taxcode = @ltlines-TaxCode
*            INTO TABLE @DATA(it_tax).
*      ENDIF.
*
*      LOOP AT ltlines INTO DATA(walines).
*        wa_purchinvlines-client = sy-mandt.
*        wa_purchinvlines-companycode = waheader-CompanyCode.
*        wa_purchinvlines-fiscalyearvalue = waheader-FiscalYear.
*        wa_purchinvlines-supplierinvoice = waheader-SupplierInvoice.
*        wa_purchinvlines-supplierinvoiceitem = walines-SupplierInvoiceItem.
*        wa_purchinvlines-postingdate = waheader-PostingDate.
*********************************** Item Level Fields Added ****************************
*        wa_purchinvlines-plantcity = walines-plantcity.
*        wa_purchinvlines-plantpin = walines-plantpin.
**        wa_purchinvlines-product_trade_name = walines-trade_name.
*        wa_purchinvlines-vendor_invoice_no = walines-DeliveryDocumentBySupplier.
*        wa_purchinvlines-vendor_invoice_date = walines-DocumentDate.
*        wa_purchinvlines-vendor_type = walines-LegalFormDescription.
*        wa_purchinvlines-rfqno = walines-SupplierQuotation.
*        wa_purchinvlines-rfqno = walines-SupplierQuotation.
*        wa_purchinvlines-rfqdate = walines-RFQPublishingDate.
*        wa_purchinvlines-supplierquotation = walines-sq.
*        wa_purchinvlines-supplierquotationdate = walines-QuotationSubmissionDate.
*        wa_purchinvlines-mrnquantityinbaseunit = walines-PostingDate.
*        wa_purchinvlines-hsncode = walines-DocumentReferenceID.
*
*
*        SELECT SINGLE FROM I_IN_BusinessPlaceTaxDetail AS a
*            LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
*            FIELDS
*            a~BusinessPlaceDescription,
*            a~IN_GSTIdentificationNumber,
*            b~Street, b~PostalCode , b~CityName
*        WHERE a~CompanyCode = @waheader-CompanyCode AND a~BusinessPlace = @walines-Plant
*        INTO ( @wa_purchinvlines-plantname, @wa_purchinvlines-plantgst, @wa_purchinvlines-plantadr, @wa_purchinvlines-plantpin,
*            @wa_purchinvlines-plantcity ).
*
*        wa_purchinvlines-product                   = walines-material.
*        READ TABLE it_product INTO DATA(wa_product) WITH KEY product = walines-material.
*        wa_purchinvlines-productname = wa_product-ProductName.
*
*        wa_purchinvlines-purchaseorder             = walines-PurchaseOrder.
*        wa_purchinvlines-purchaseorderitem         = walines-PurchaseOrderItem.
*        CONCATENATE walines-SupplierInvoice walines-FiscalYear INTO wa_purchinvlines-originalreferencedocument.
*
*        READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = walines-PurchaseOrder
*                                                PurchaseOrderItem = walines-PurchaseOrderItem.
*
*        wa_purchinvlines-baseunit                  = wa_po-BaseUnit.
*        wa_purchinvlines-profitcenter              = wa_po-ProfitCenter.
*        wa_purchinvlines-purchaseordertype         = wa_po-PurchaseOrderType.
*        wa_purchinvlines-purchaseorderdate         = wa_po-PurchaseOrderDate.
*        wa_purchinvlines-purchasingorganization    = wa_po-PurchasingOrganization.
*        wa_purchinvlines-purchasinggroup           = wa_po-PurchasingGroup.
*
*        READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = walines-ReferenceDocument.
*        wa_purchinvlines-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
**            wa_purchinvlines-mrnpostingdate            = wa_grn-PostingDate;
**            ls_response-grn = wa_it-ReferenceDocument.
**        ls_response-grnyear = wa_it-ReferenceDocumentFiscalYear.
*
*        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY TaxCode = walines-TaxCode.
*        wa_purchinvlines-taxcodename                = wa_tax-TaxCodeName.
*
*
*        CONCATENATE walines-PurchaseOrder walines-PurchaseOrderItem INTO assignmentreference.
*
*        SELECT SINGLE TaxItemAcctgDocItemRef, IN_HSNOrSACCode FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear AND TaxItemAcctgDocItemRef IS NOT INITIAL
*            AND AccountingDocumentItemType <> 'T'
*            AND FiscalYear = @walines-FiscalYear
*            AND CompanyCode = @waheader-CompanyCode
*            AND AccountingDocumentType = 'RE'
*            AND AssignmentReference = @assignmentreference
*            AND product = @walines-material
*        INTO  (  @DATA(lv_TaxItemAcctgDocItemRef), @DATA(lv_HSNCode) ).
*        wa_purchinvlines-hsncode = lv_HSNCode.
*
*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                AND AccountingDocumentItemType = 'T'
*                AND FiscalYear = @walines-FiscalYear
*                AND CompanyCode = @waheader-CompanyCode
*                AND TransactionTypeDetermination = 'JII'
*        INTO  @wa_purchinvlines-igst.
*
*        IF wa_purchinvlines-igst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @wa_purchinvlines-cgst.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-SupplierInvoiceWthnFiscalYear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @walines-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @wa_purchinvlines-sgst.
*        ENDIF.
*
*        """"""""""""""""""""""""""""""""""""""""""""""""for rate percent.
*        wa_purchinvlines-rateigst   = 0.
*        wa_purchinvlines-ratecgst   = 0.
*        wa_purchinvlines-ratesgst   = 0.
*
*        IF walines-TaxCode = 'L0'.
*          wa_purchinvlines-ratecgst   = 3.
*          wa_purchinvlines-ratesgst   = 3.
*        ELSEIF walines-TaxCode = 'I0'.
*          wa_purchinvlines-rateigst   = 3.
*        ELSEIF walines-TaxCode = 'L5'.
*          wa_purchinvlines-ratecgst   = 5.
*          wa_purchinvlines-ratesgst   = 5.
*        ELSEIF walines-TaxCode = 'I1'.
*          wa_purchinvlines-rateigst   = 5.
*        ELSEIF walines-TaxCode = 'L2'.
*          wa_purchinvlines-ratecgst   = 6.
*          wa_purchinvlines-ratesgst   = 6.
*        ELSEIF walines-TaxCode = 'I2'.
*          wa_purchinvlines-rateigst   = 12.
*        ELSEIF walines-TaxCode = 'L3'.
*          wa_purchinvlines-ratecgst   = 9.
*          wa_purchinvlines-ratesgst   = 9.
*        ELSEIF walines-TaxCode = 'I3'.
*          wa_purchinvlines-rateigst   = 18.
*        ELSEIF walines-TaxCode = 'L4'.
*          wa_purchinvlines-ratecgst   = 14.
*          wa_purchinvlines-ratesgst   = 14.
*        ELSEIF walines-TaxCode = 'I4'.
*          wa_purchinvlines-rateigst   = 28.
*        ELSEIF walines-TaxCode = 'F5'.
*          wa_purchinvlines-ratecgst   = 9.
*          wa_purchinvlines-ratesgst   = 9.
*        ELSEIF walines-TaxCode = 'H5'.
*          wa_purchinvlines-ratecgst   = 9.
*          wa_purchinvlines-ratesgst   = 9.
*          wa_purchinvlines-rateigst   = 18.
*        ELSEIF walines-TaxCode = 'H6'.
*          wa_purchinvlines-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               wa_purchinvlines-CESSRate = '18'.
*        ELSEIF walines-TaxCode = 'H4'.
*          wa_purchinvlines-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*        ELSEIF walines-TaxCode = 'H3'.
*          wa_purchinvlines-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*        ELSEIF walines-TaxCode = 'J3'.
*          wa_purchinvlines-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*        ELSEIF walines-TaxCode = 'G6'.
*          wa_purchinvlines-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*        ELSEIF walines-TaxCode = 'G7'.
*          wa_purchinvlines-ratecgst   = 9.
*          wa_purchinvlines-ratesgst   = 9.
**               ls_response-CESSRate = '18'.
*        ENDIF.
*
*        SELECT SINGLE FROM I_JournalEntry
*            FIELDS DocumentDate ,
*                DocumentReferenceID ,
*                IsReversed
*        WHERE OriginalReferenceDocument = @walines-SupplierInvoice
*        INTO (  @wa_purchinvlines-journaldocumentdate , @wa_purchinvlines-journaldocumentrefid, @wa_purchinvlines-isreversed ).
*
*        wa_purchinvlines-pouom                      = walines-PurchaseOrderPriceUnit.
*        wa_purchinvlines-poqty                      = walines-QuantityInPurchaseOrderUnit.
*        wa_purchinvlines-netamount                  = walines-SupplierInvoiceItemAmount.
*        wa_purchinvlines-basicrate                  = round( val = wa_purchinvlines-netamount / wa_purchinvlines-poqty dec = 2 ).
*
*        wa_purchinvlines-taxamount                  = wa_purchinvlines-igst + wa_purchinvlines-sgst +
*                                                      wa_purchinvlines-cgst.
*        wa_purchinvlines-totalamount                = wa_purchinvlines-taxamount + wa_purchinvlines-netamount.
*
*        SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*        FIELDS
*            a~PurchaseOrderItem, a~SupplierInvoiceItem,a~SuplrInvcDeliveryCostCndnType,
*            a~PurchaseOrder, a~SupplierInvoiceItemAmount, a~taxcode,
*            a~FreightSupplier
*        WHERE a~SupplierInvoice = @waheader-SupplierInvoice
*          AND a~FiscalYear = @waheader-FiscalYear
*          AND a~PurchaseOrderItem = @walines-PurchaseOrderItem
*          AND a~SuplrInvcDeliveryCostCndnType <> ''
*          INTO TABLE @DATA(ltsublines).
*
*        wa_purchinvlines-discount       = 0.
*        wa_purchinvlines-freight        = 0.
*        wa_purchinvlines-insurance      = 0.
*        wa_purchinvlines-ecs            = 0.
*        wa_purchinvlines-epf            = 0.
*        wa_purchinvlines-othercharges   = 0.
*        wa_purchinvlines-packaging      = 0.
*        LOOP AT ltsublines INTO DATA(wasublines).
*          IF wasublines-SuplrInvcDeliveryCostCndnType = 'FGW1'.
**                   Freight
*            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FQU1'.
**                   Freight
*            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'FVA1'.
**                   Freight
*            wa_purchinvlines-freight += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZDIN'.
**                   Insurance Value
*            wa_purchinvlines-insurance += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZINS'.
**                   Insurance Value
*            wa_purchinvlines-insurance += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZECS'.
**                   ECS
*            wa_purchinvlines-ecs += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZEPF'.
**                   EPF
*            wa_purchinvlines-epf += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZOTH'.
**                   Other Charges
*            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.
*          ELSEIF wasublines-SuplrInvcDeliveryCostCndnType = 'ZPKG'.
**                   Packaging & Forwarding Charges
*            wa_purchinvlines-packaging += wasublines-SupplierInvoiceItemAmount.
*          ELSE.
*            wa_purchinvlines-othercharges += wasublines-SupplierInvoiceItemAmount.
*          ENDIF.
*        ENDLOOP.
*
*        wa_purchinvlines-totalamount    = wa_purchinvlines-taxamount + wa_purchinvlines-netamount + wa_purchinvlines-freight +
*                                          wa_purchinvlines-insurance + wa_purchinvlines-ecs +
*                                          wa_purchinvlines-epf + wa_purchinvlines-othercharges +
*                                          wa_purchinvlines-packaging.
*
**       CLEAR wa_price.
*
*
*        APPEND wa_purchinvlines TO lt_purchinvlines.
*********************** Added on 08.02.2025
*        MODIFY zpurchinvlines FROM @wa_purchinvlines.
*        CLEAR : wa_purchinvlines.
*        CLEAR : wa_po, wa_grn, wa_tax, lv_taxitemacctgdocitemref.
*      ENDLOOP.
*
**      INSERT zpurchinvlines FROM TABLE @lt_purchinvlines.
*
*
*      wa_purchinvprocessed-client = sy-mandt.
*      wa_purchinvprocessed-supplierinvoice = waheader-SupplierInvoice.
*      wa_purchinvprocessed-companycode = waheader-CompanyCode.
*      wa_purchinvprocessed-fiscalyearvalue = waheader-FiscalYear.
*      wa_purchinvprocessed-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
*      wa_purchinvprocessed-creationdatetime = lv_timestamp.
*************************************** Header Level Fields Added *******************************
*      wa_purchinvlines-plantadr = waheader-AddressID.
*
*      APPEND wa_purchinvprocessed TO lt_purchinvprocessed.
*********************** Added on 08.02.2025
*      MODIFY zpurchinvproc FROM @wa_purchinvprocessed.
**      INSERT zpurchinvproc FROM TABLE @lt_purchinvprocessed.
*      COMMIT WORK.
*
*      CLEAR :  wa_purchinvprocessed, lt_purchinvprocessed, lt_purchinvlines.
*      CLEAR : ltlines, it_product, it_po, it_grn, it_tax.
*
*    ENDLOOP.
*
**    SELECT * FROM zbillinglines
**               INTO TABLE @DATA(it).
**    LOOP AT it INTO DATA(wa1).
**      out->write( data = 'Data : client -' ) .
**      out->write( data = wa1-client ) .
**      out->write( data = '- bukrs-' ) .
**      out->write( data = wa1-materialdescription ) .
**      out->write( data = '- doc-' ) .
**      out->write( data = wa1-billingdocument ) .
**      out->write( data = '- item -' ) .
**      out->write( data = wa1-billingdocumentitem ) .
**    endloop.
*
*
*  ENDMETHOD.
*ENDCLASS.
