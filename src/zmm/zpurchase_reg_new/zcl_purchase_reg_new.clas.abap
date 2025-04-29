CLASS zcl_purchase_reg_new DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_rap_query_provider.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_purchase_reg_new IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lt_response TYPE TABLE OF zdt_pur_reg_new,
          ls_response TYPE zdt_pur_reg_new.




    SELECT  FROM I_SupplierInvoiceAPI01 AS c
    LEFT JOIN I_BusPartAddress WITH PRIVILEGED ACCESS AS hdr1 ON c~BusinessPlace = hdr1~BusinessPartner
    LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 WITH PRIVILEGED ACCESS AS a ON a~SupplierInvoice = c~SupplierInvoice AND a~FiscalYear = c~FiscalYear
    LEFT JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS li ON a~PurchaseOrder = li~PurchaseOrder AND li~PurchaseOrderItem = a~PurchaseOrderItem
    LEFT JOIN zmaterial_table WITH PRIVILEGED ACCESS AS li4 ON li~Material = li4~mat
    LEFT JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
    LEFT JOIN i_deliverydocument WITH PRIVILEGED ACCESS AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS poa ON a~PurchaseOrder = poa~PurchaseOrder
    LEFT JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS li7 ON li6~Supplier = li7~BusinessPartner
    LEFT JOIN I_BusinessPartnerLegalFormText WITH PRIVILEGED ACCESS AS li8 ON li7~LegalForm = li8~LegalForm
    LEFT JOIN i_purchaseorderitemtp_2 WITH PRIVILEGED ACCESS AS li9 ON li~PurchaseOrder = li9~PurchaseOrder AND li~PurchaseOrderItem = li9~PurchaseOrderItem
    LEFT JOIN I_Requestforquotation_Api01 WITH PRIVILEGED ACCESS AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
    LEFT JOIN I_SupplierQuotation_Api01 WITH PRIVILEGED ACCESS AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
    LEFT JOIN i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS AS li13 ON li13~PurchaseRequisition = li~PurchaseRequisition
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON b~supplier = a~freightsupplier
    FIELDS  c~CompanyCode , c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear, c~PostingDate , hdr1~AddressID ,
            a~PurchaseOrderItem, a~SupplierInvoiceItem ,
            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
            a~FreightSupplier , a~TaxJurisdiction AS SInvwithFYear, a~plant,
            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear , c~documentdate ,
            b~BusinessPartnerPanNumber , b~SupplierName , b~BPPanReferenceNumber ,
************************************
            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier , li4~trade_name ,
            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
            li11~QuotationSubmissionDate , li6~PurchaseOrderType , li6~PaymentTerms , li6~supplier AS frsup ,
            li~OrderQuantity ,li~NetAmount , li13~PurReqCreationDate , li~PurchaseRequisition , li13~RequestedQuantity ,
            li~OverdelivTolrtdLmtRatioInPct , poa~PurchaseOrderType AS po_type " , li5~DocumentDate  , li5~PostingDate as postingdate2 , li12~DocumentReferenceID
*            WHERE c~SupplierInvoice = '5105600336'
*            AND c~FiscalYear IN @lt_fiscalyear
*            AND c~CompanyCode IN @lt_compcode
            INTO TABLE @DATA(it_header).


    SELECT FROM I_IN_BusinessPlaceTaxDetail AS a
    LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
    FIELDS
    a~companycode ,
    a~businessplace ,
    a~BusinessPlaceDescription,
    a~IN_GSTIdentificationNumber,
    b~Street, b~PostalCode , b~CityName
   FOR ALL ENTRIES IN @it_header WHERE a~CompanyCode = @it_header-CompanyCode AND a~BusinessPlace = @it_header-Plant
   INTO TABLE @DATA(it_plant)
   PRIVILEGED ACCESS.



    SELECT FROM I_Producttext AS a FIELDS
        a~ProductName, a~Product
    FOR ALL ENTRIES IN @it_header
    WHERE a~Product = @it_header-material AND a~Language = 'E'
        INTO TABLE @DATA(it_product)
        PRIVILEGED ACCESS.

    SELECT FROM I_PurchaseOrderItemAPI01 AS a
        LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
        FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
        b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
    FOR ALL ENTRIES IN @it_header
    WHERE a~PurchaseOrder = @it_header-PurchaseOrder AND a~PurchaseOrderItem = @it_header-PurchaseOrderItem
        INTO TABLE @DATA(it_po)
        PRIVILEGED ACCESS.

    SELECT FROM I_MaterialDocumentItem_2
        FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
    FOR ALL ENTRIES IN @it_header
    WHERE MaterialDocument  = @it_header-ReferenceDocument
        INTO TABLE @DATA(it_grn)
        PRIVILEGED ACCESS.

    SELECT FROM I_ProductPlantIntlTrd FIELDS
        product , plant  , ConsumptionTaxCtrlCode
        FOR ALL ENTRIES IN @it_header
    WHERE product = @it_header-Material  AND plant = @it_header-Plant
        INTO TABLE @DATA(it_hsn)
        PRIVILEGED ACCESS.


   SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
    LEFT JOIN I_taxcodetext AS B ON B~TaxCode = A~TaxCode
       FIELDS A~SupplierInvoice  ,A~SupplierInvoiceItem , B~TaxCodeName
   FOR ALL ENTRIES IN @it_header
   WHERE Language = 'E' AND A~SupplierInvoice = @it_header-SupplierInvoice
   and A~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
       INTO TABLE @DATA(it_tax)
       PRIVILEGED ACCESS.

    SELECT  FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
  LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
  FIELDS a~freightsupplier ,
  a~purchaseorder ,
  b~supplierfullname ,
  a~supplierinvoice ,
  a~SupplierInvoiceItem
  FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType  IN ('ZFRQ' , 'ZFRV') AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
  INTO TABLE @DATA(it_tc)
  PRIVILEGED ACCESS.

    SELECT FROM i_operationalacctgdocitem AS a
    LEFT JOIN i_supplier AS b ON b~Supplier = a~Supplier
    FIELDS a~CompanyCode ,
    a~FiscalYear ,
    a~AccountingDocument ,
    b~TaxNumberType ,
    b~TaxNumber3
    FOR ALL ENTRIES IN @it_header WHERE a~AccountingDocument = @it_header-SupplierInvoice AND
                                        a~FiscalYear = @it_header-FiscalYear   AND
                                        a~CompanyCode = @it_header-CompanyCode
    INTO TABLE @DATA(it_vgst).


*     SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
*      FIELDS a~purchaseorder ,
*      b~BPPanReferenceNumber ,
*      b~suppliername ,
*      b~BusinessPartnerPanNumber ,
*      a~supplierinvoice ,
*      a~SupplierInvoiceItem
*      FOR ALL ENTRIES IN @IT_HEADER WHERE a~supplierinvoice = @IT_HEADER-supplierinvoice and a~purchaseorder = @IT_HEADER-purchaseorder " AND a~SupplierInvoiceItem = @IT_HEADER-SupplierInvoiceItem
*      INTO TABLE @DATA(it_vln)
*      PRIVILEGED ACCESS.

    SELECT  FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN I_BuPaIdentification AS b ON b~BusinessPartner = a~FreightSupplier
    FIELDS a~purchaseorder ,
    b~BPIdentificationNumber ,
    b~BPIdentificationType ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE b~BPIdentificationType = 'TAN' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_vtn)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
     FIELDS a~SupplierInvoiceItemAmount ,
     a~purchaseorder ,
     a~supplierinvoice ,
     a~SupplierInvoiceItem
     FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZINP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
     INTO TABLE @DATA(it_zinp)
     PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZINV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zinv)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZPKP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zpkp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZPKQ' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zpkq)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZADP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zadp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZADV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zadv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZFRV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zfrv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZFRQ' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zfrq)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN I_Product AS c ON c~Product = a~PurchaseOrderItemMaterial
    FIELDS a~purchaseorder ,
    c~productgroup ,
    c~producttype ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~supplierinvoice = @it_header-SupplierInvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_fc)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZCHV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zchv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZLUQ' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zluq)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZLUV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zluv)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZMNP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zmnp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZDSC' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zdsc)
    PRIVILEGED ACCESS.

     SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZDSV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zdsv)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN ztable_plant AS b ON b~plant_code = a~Plant
    FIELDS a~SupplierInvoice ,
    a~SupplierInvoiceItem ,
    b~city ,
    b~Address1 ,
    b~address2 ,
    b~address3 ,
    b~pin
    FOR ALL ENTRIES IN @it_header WHERE a~SupplierInvoice = @it_header-SupplierInvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_plantaddcity)
    PRIVILEGED ACCESS.


*   SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*   LEFT JOIN I_SupplierInvoiceAPI01 AS B on B~SupplierInvoice = A~SupplierInvoice
*   LEFT JOIN I_OperationalAcctgDocItem AS c ON c~OriginalReferenceDocument = B~SupplierInvoiceWthnFiscalYear
*   FIELDS A~SupplierInvoice , A~SupplierInvoiceItem , C~TransactionTypeDetermination , C~AmountInCompanyCodeCurrency
*   FOR ALL ENTRIES IN @IT_HEADER WHERE A~SupplierInvoice = @IT_HEADER-SUPPLIERINVOICE
*   AND A~SupplierInvoiceItem = @IT_HEADER-SUPPLIERINVOICEITEM
*   INTO TABLE @DATA(IT_PLNTGSTTAX)
*   PRIVILEGED ACCESS.

    LOOP AT it_header INTO DATA(waheader).

      ls_response-supplierinvoice = waheader-SupplierInvoice.
      ls_response-companycode = waheader-CompanyCode.
      ls_response-fiscalyearvalue = waheader-FiscalYear.
      ls_response-postingdate = waheader-PostingDate.
      ls_response-plantadr = waheader-AddressID.
      ls_response-supplierinvoiceitem = waheader-SupplierInvoiceItem.
*    ls_response-plantcity = waheader-plantcity.
*    ls_response-plantpin = waheader-plantpin.
      ls_response-product_trade_name = waheader-trade_name.
      ls_response-vendor_invoice_no = waheader-DeliveryDocumentBySupplier.
      ls_response-vendor_invoice_date = waheader-DocumentDate.
      ls_response-vendor_type = waheader-LegalFormDescription.
      ls_response-rfqno = waheader-SupplierQuotation.
      ls_response-rfqno = waheader-SupplierQuotation.
      ls_response-rfqdate = waheader-RFQPublishingDate.
      ls_response-supplierquotation = waheader-sq.
      ls_response-supplierquotationdate = waheader-QuotationSubmissionDate.
      ls_response-mrnquantityinbaseunit = waheader-PostingDate.
      ls_response-product                   = waheader-material.
      ls_response-purchaseorder             = waheader-PurchaseOrder.
      ls_response-purchaseorderitem         = waheader-PurchaseOrderItem.
      ls_response-pouom                      = waheader-PurchaseOrderPriceUnit.
      ls_response-poqty                      = waheader-QuantityInPurchaseOrderUnit.
      ls_response-netamount                  = waheader-SupplierInvoiceItemAmount.



      READ TABLE it_plant INTO DATA(wa_plant) WITH KEY businessplace = waheader-plant companycode = waheader-companycode.
      ls_response-plantname = wa_plant-BusinessPlaceDescription.
      ls_response-plantgst = wa_plant-IN_GSTIdentificationNumber.

      READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = waheader-PurchaseOrder
                                                 PurchaseOrderItem = waheader-PurchaseOrderItem.

      ls_response-baseunit                  = wa_po-BaseUnit.
      ls_response-profitcenter              = wa_po-ProfitCenter.
      ls_response-purchaseordertype         = wa_po-PurchaseOrderType.
      ls_response-purchaseorderdate         = wa_po-PurchaseOrderDate.
      ls_response-purchasingorganization    = wa_po-PurchasingOrganization.
      ls_response-purchasinggroup           = wa_po-PurchasingGroup.

      READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = waheader-ReferenceDocument.
      ls_response-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
      ls_response-mrnpostingdate            = wa_grn-PostingDate.

      READ TABLE it_hsn INTO DATA(wa_hsn) WITH KEY plant = waheader-Plant Product = waheader-Material.
      ls_response-hsncode                    = wa_hsn-ConsumptionTaxCtrlCode.

      READ TABLE it_tax INTO DATA(wa_tax) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-taxcodename                = wa_tax-TaxCodeName.

      READ TABLE it_product INTO DATA(wa_product) WITH KEY product = waheader-material.
      ls_response-productname = wa_product-ProductName.



*
*SELECT SINGLE TaxItemAcctgDocItemRef FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear AND TaxItemAcctgDocItemRef IS NOT INITIAL
*            AND AccountingDocumentItemType <> 'T'
*            AND FiscalYear = @waheader-FiscalYear
*            AND CompanyCode = @waheader-CompanyCode
*            AND AccountingDocumentType = 'RE'
*        INTO  @DATA(lv_TaxItemAcctgDocItemRef).
*
*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                AND AccountingDocumentItemType = 'T'
*                AND FiscalYear = @waheader-FiscalYear
*                AND CompanyCode = @waheader-CompanyCode
*                AND TransactionTypeDetermination = 'JII'
*        INTO  @ls_response-igst.
*
*        IF ls_response-igst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @ls_response-cgst.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @ls_response-sgst.
*        ENDIF.


*      ls_response-rateigst   = 0.
*      ls_response-ratecgst   = 0.
*      ls_response-ratesgst   = 0.
*
*      IF waheader-TaxCode = 'L0'.
*        ls_response-ratecgst   = 3.
*        ls_response-ratesgst   = 3.
*      ELSEIF waheader-TaxCode = 'I0'.
*        ls_response-rateigst   = 3.
*      ELSEIF waheader-TaxCode = 'L5'.
*        ls_response-ratecgst   = 5.
*        ls_response-ratesgst   = 5.
*      ELSEIF waheader-TaxCode = 'I1'.
*        ls_response-rateigst   = 5.
*      ELSEIF waheader-TaxCode = 'L2'.
*        ls_response-ratecgst   = 6.
*        ls_response-ratesgst   = 6.
*      ELSEIF waheader-TaxCode = 'I2'.
*        ls_response-rateigst   = 12.
*      ELSEIF waheader-TaxCode = 'L3'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*      ELSEIF waheader-TaxCode = 'I3'.
*        ls_response-rateigst   = 18.
*      ELSEIF waheader-TaxCode = 'L4'.
*        ls_response-ratecgst   = 14.
*        ls_response-ratesgst   = 14.
*      ELSEIF waheader-TaxCode = 'I4'.
*        ls_response-rateigst   = 28.
*      ELSEIF waheader-TaxCode = 'F5'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*      ELSEIF waheader-TaxCode = 'H5'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*        ls_response-rateigst   = 18.
*      ELSEIF waheader-TaxCode = 'H6'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               wa_purchinvlines-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'H4'.
*        ls_response-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'H3'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'J3'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'G6'.
*        ls_response-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'G7'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
**               ls_response-CESSRate = '18'.
*      ENDIF.



 SELECT FROM i_suplrinvcitempurordrefapi01 AS a
        FIELDS a~supplierinvoice, a~fiscalyear , a~SupplierInvoiceItem
        WHERE a~supplierinvoice     = @waheader-supplierinvoice
          AND a~supplierinvoiceitem = @waheader-supplierinvoiceitem
        INTO TABLE @DATA(it_gtstax3).

      LOOP AT it_gtstax3 INTO DATA(wa_gtstax3).

        " Format supplier invoice with leading zeros (assumed width: 10)
        DATA(suppl)   = |{ wa_gtstax3-supplierinvoice WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
        DATA(fiscy)   = wa_gtstax3-fiscalyear.
        DATA(combine) = |{ suppl }{ fiscy }|.


        SELECT SINGLE FROM  i_operationalacctgdocitem
        FIELDS SUM( AmountInCompanyCodeCurrency )
        WHERE OriginalReferenceDocument = @combine
        AND TaxItemAcctgDocItemRef = @wa_gtstax3-SupplierInvoiceItem
        AND TransactionTypeDetermination = 'JII'
        INTO @DATA(lvvv).

        SELECT SINGLE FROM  i_operationalacctgdocitem
        FIELDS SUM( AmountInCompanyCodeCurrency )
        WHERE OriginalReferenceDocument = @combine
         AND TaxItemAcctgDocItemRef = @wa_gtstax3-SupplierInvoiceItem
        AND TransactionTypeDetermination = 'JIC'
        INTO @DATA(lvvv2).

        ls_response-cgst = lvvv2.
        ls_response-sgst = lvvv2.
        ls_response-igst = lvvv.

        ls_response-rateigst = ( ls_response-igst / ls_response-netamount ) * 100.
        ls_response-ratecgst = ( ls_response-cgst / ls_response-netamount ) * 100.
        ls_response-ratesgst = ( ls_response-sgst / ls_response-netamount ) * 100.
  endloop.



*      SELECT supplierinvoice, fiscalyear
*        FROM i_suplrinvcitempurordrefapi01 AS a
*        WHERE a~supplierinvoice = @waheader-supplierinvoice
*          AND a~supplierinvoiceitem = @waheader-supplierinvoiceitem
*        INTO TABLE @DATA(it_gtstax3).
*
*      LOOP AT it_gtstax3 INTO DATA(wa_gtstax3).
*
*        " Format supplier invoice with leading zeros (assumed width: 10)
*        DATA(suppl)   = |{ wa_gtstax3-supplierinvoice WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
*        DATA(fiscy)   = wa_gtstax3-fiscalyear.
*        DATA(combine) = |{ suppl }{ fiscy }|.
*
*        " Fetch all matching records for this reference document
*        SELECT originalreferencedocument,
*               amountincompanycodecurrency,
*               transactiontypedetermination
*          FROM i_operationalacctgdocitem AS b
*          WHERE b~originalreferencedocument = @combine
*          INTO TABLE @DATA(it_gsttax3).
*
*        LOOP AT it_gsttax3 INTO DATA(wa_gsttax3).
*
*          CASE wa_gsttax3-transactiontypedetermination.
*            WHEN 'JII'.
*              ls_response-igst = wa_gsttax3-amountincompanycodecurrency.
*              APPEND ls_response TO lt_response.
*            WHEN 'JIC'.
*              ls_response-cgst = wa_gsttax3-amountincompanycodecurrency.
*              ls_response-sgst = wa_gsttax3-amountincompanycodecurrency.
*              APPEND ls_response TO lt_response.
*          ENDCASE.
*
*        ENDLOOP.
*
*        " Clear only the formatted variables, not the entire structures
*        CLEAR: suppl, fiscy, combine.
*
*      ENDLOOP.
*
*      CLEAR: it_gtstax3, it_gsttax3.
*








      ls_response-basicrate                  = round( val = ls_response-netamount / ls_response-poqty dec = 2 ).

      ls_response-taxamount                  = ls_response-igst + ls_response-sgst +
                                                    ls_response-cgst.
      ls_response-totalamount                = ls_response-taxamount + ls_response-netamount.







      READ TABLE it_tc INTO DATA(wa_tc) WITH KEY  SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-transportercode = wa_tc-FreightSupplier.
      ls_response-transportername = wa_tc-SupplierFullName.

      ls_response-vendorcode = waheader-frsup.


*      READ TABLE IT_VGST INTO DATA(WA_VGST) WITH KEY SupplierInvoice = waheader-SupplierInvoice.
*        ls_response-vendorgstin = WA_VGST-TaxNumberType.

*       READ TABLE it_vln INTO DATA(wa_vln) WITH KEY SupplierInvoice = waheader-supplierinvoice purchaseorder = waheader-purchaseorder. "supplierinvoiceitem = waheader-supplierinvoiceitem .
*        ls_response-vendorlegalname = wa_vln-BPPanReferenceNumber.
*        ls_response-vendorname = wa_vln-SupplierName.
*        ls_response-vendorpanno = wa_vln-BusinessPartnerPanNumber.
*
      ls_response-vendorlegalname = waheader-BPPanReferenceNumber.
      ls_response-vendorname = waheader-SupplierName.
      ls_response-vendorpanno = waheader-BusinessPartnerPanNumber.

      READ TABLE it_vtn INTO DATA(wa_vtn) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-vendortanname = wa_vtn-BPIdentificationType.
      ls_response-vendortanno = wa_vtn-BPIdentificationNumber.


      READ TABLE it_zinp INTO DATA(wa_zinp)  WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-insurancechargesper = wa_zinp-SupplierInvoiceItemAmount.

      READ TABLE it_zinv INTO DATA(wa_zinv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-insurancecost = wa_zinv-SupplierInvoiceItemAmount.

      READ TABLE it_zpkp INTO DATA(wa_zpkp) WITH KEY  SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-packingchargesper = wa_zpkp-SupplierInvoiceItemAmount.

      READ TABLE it_zpkq INTO DATA(wa_zpkq) WITH KEY  SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-packingchargesqty = wa_zpkq-SupplierInvoiceItemAmount.

      READ TABLE it_zadp INTO DATA(wa_zadp) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-antidumpingper = wa_zadp-SupplierInvoiceItemAmount.

      READ TABLE it_zadv INTO DATA(wa_zadv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-antidumpingvalue = wa_zadv-SupplierInvoiceItemAmount.

      READ TABLE it_zfrv INTO DATA(wa_zfrv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-freightval = wa_zfrv-SupplierInvoiceItemAmount.

      READ TABLE it_zfrq INTO DATA(wa_zfrq) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-freightqty = wa_zfrq-SupplierInvoiceItemAmount.

      READ TABLE it_zmnp INTO DATA(wa_zmnp) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-manditax = wa_zmnp-SupplierInvoiceItemAmount.


      READ TABLE it_fc INTO DATA(wa_fc) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-materialgroup = wa_fc-ProductGroup.
      ls_response-materialtype = wa_fc-ProductType.

      ls_response-prdate = waheader-PurReqCreationDate.
      ls_response-prno = waheader-PurchaseRequisition.
      ls_response-prqty = waheader-RequestedQuantity.

      READ TABLE it_zchv INTO DATA(wa_zchv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-chachargesval = wa_zchv-SupplierInvoiceItemAmount.

      READ TABLE it_zluq INTO DATA(wa_zluq) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-ldguldgchgsqty = wa_zluq-SupplierInvoiceItemAmount.

      READ TABLE it_zluv INTO DATA(wa_zluv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-ldguldgchgsval = wa_zluv-SupplierInvoiceItemAmount.

      READ TABLE it_zdsc INTO DATA(wa_zdsc) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-discountper = wa_zdsc-SupplierInvoiceItemAmount.

      READ TABLE it_zdsv INTO DATA(wa_zdsv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-discountval = wa_zdsv-SupplierInvoiceItemAmount.

      SELECT SINGLE FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
      LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice AND b~FiscalYear = a~FiscalYear
      FIELDS a~purchaseorder ,
      a~supplierinvoice ,
      b~supplierinvoice AS sp3 ,
      b~fiscalyear ,
      a~SupplierInvoiceItem
      WHERE  a~SupplierInvoice = @waheader-SupplierInvoice AND a~SupplierInvoiceItem = @waheader-SupplierInvoiceItem
      INTO  @DATA(wa_pdnew)
      PRIVILEGED ACCESS.

*         LOOP AT it_pdnew INTO DATA(wa_pdnew).
      DATA : suppinv3 TYPE string .
      DATA : fiscyea3 TYPE string .
      DATA : comb3 TYPE string .
      suppinv3 = WA_pdnew-sp3.
      fiscyea3 = wa_pdnew-FiscalYear.
      CONCATENATE suppinv3 fiscyea3 INTO comb3.

      SELECT FROM i_supplierinvoiceapi01 AS a
      LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb3 AND b~FiscalYear = a~FiscalYear
      LEFT JOIN I_Supplier AS c ON c~Supplier = b~Supplier
      FIELDS b~AccountingDocumentType ,
      a~supplierinvoice ,
      c~TaxNumber3
      INTO TABLE @DATA(it_comb3).

      READ TABLE it_comb3 INTO DATA(wa_comb3) WITH KEY supplierinvoice = wa_pdnew-SupplierInvoice  .
      ls_response-mirodocumenttype = wa_comb3-AccountingDocumentType.
      ls_response-vendorgstin = wa_comb3-TaxNumber3.
      CLEAR : wa_comb3 , wa_pdnew  , comb3 , suppinv3 , fiscyea3 .
*        ENDLOOP.


      READ TABLE it_plantaddcity INTO DATA(wa_plantaddcity) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      DATA : plant_address TYPE string.
      CONCATENATE wa_plantaddcity-address1 wa_plantaddcity-address2 wa_plantaddcity-address3 INTO plant_address.
      ls_response-plantcity = wa_plantaddcity-city.
      ls_response-plantadr = plant_address.
      ls_response-plantpin = wa_plantaddcity-pin.




*APPEND ls_response TO lt_response.
      MODIFY zdt_pur_reg_new FROM @ls_response.
      CLEAR: waheader ,ls_response , wa_grn , wa_po , wa_plant , wa_hsn , wa_tax , wa_product , wa_tc   , wa_vtn ,
             wa_zinp , wa_zinv , wa_zpkp , wa_zpkq , wa_zadp , wa_zadv , wa_zfrv , wa_zfrq , wa_fc , wa_zchv , wa_zluq , wa_zluv ,
             wa_plantaddcity , plant_address , wa_zmnp  , wa_zdsc , wa_zdsv. ", lv_taxitemacctgdocitemref .
      .  ", WAPLANTGSTTAX.  " , wa_vln

    ENDLOOP.


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.


    DATA: lt_response TYPE TABLE OF zdt_pur_reg_new,
          ls_response TYPE zdt_pur_reg_new.

    DELETE FROM zdt_pur_reg_new WHERE supplierinvoice IS  INITIAL.


    SELECT  FROM I_SupplierInvoiceAPI01 AS c
    LEFT JOIN I_BusPartAddress WITH PRIVILEGED ACCESS AS hdr1 ON c~BusinessPlace = hdr1~BusinessPartner
    LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 WITH PRIVILEGED ACCESS AS a ON a~SupplierInvoice = c~SupplierInvoice AND a~FiscalYear = c~FiscalYear
    LEFT JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS li ON a~PurchaseOrder = li~PurchaseOrder AND li~PurchaseOrderItem = a~PurchaseOrderItem
    LEFT JOIN zmaterial_table WITH PRIVILEGED ACCESS AS li4 ON li~Material = li4~mat
    LEFT JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
    LEFT JOIN i_deliverydocument WITH PRIVILEGED ACCESS AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS poa ON a~PurchaseOrder = poa~PurchaseOrder
    LEFT JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS li7 ON li6~Supplier = li7~BusinessPartner
    LEFT JOIN I_BusinessPartnerLegalFormText WITH PRIVILEGED ACCESS AS li8 ON li7~LegalForm = li8~LegalForm
    LEFT JOIN i_purchaseorderitemtp_2 WITH PRIVILEGED ACCESS AS li9 ON li~PurchaseOrder = li9~PurchaseOrder AND li~PurchaseOrderItem = li9~PurchaseOrderItem
    LEFT JOIN I_Requestforquotation_Api01 WITH PRIVILEGED ACCESS AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
    LEFT JOIN I_SupplierQuotation_Api01 WITH PRIVILEGED ACCESS AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
    LEFT JOIN i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS AS li13 ON li13~PurchaseRequisition = li~PurchaseRequisition
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON b~supplier = a~FreightSupplier
    FIELDS  c~CompanyCode , c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear, c~PostingDate , hdr1~AddressID ,
            a~PurchaseOrderItem, a~SupplierInvoiceItem ,
            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
            a~FreightSupplier , a~TaxJurisdiction AS SInvwithFYear, a~plant,
            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear , c~documentdate ,
            b~BusinessPartnerPanNumber , b~SupplierName , b~BPPanReferenceNumber ,
************************************
            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier , li4~trade_name ,
            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
            li11~QuotationSubmissionDate , li6~PurchaseOrderType , li6~PaymentTerms , li6~supplier AS frsup ,
            li~OrderQuantity ,li~NetAmount , li13~PurReqCreationDate , li~PurchaseRequisition , li13~RequestedQuantity ,
            li~OverdelivTolrtdLmtRatioInPct , poa~PurchaseOrderType AS po_type " , li5~DocumentDate  , li5~PostingDate as postingdate2 , li12~DocumentReferenceID
*            WHERE c~SupplierInvoice = '5105600336'
*            AND c~FiscalYear IN @lt_fiscalyear
*            AND c~CompanyCode IN @lt_compcode
            INTO TABLE @DATA(it_header).


    SELECT FROM I_IN_BusinessPlaceTaxDetail AS a
    LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
    FIELDS
    a~companycode ,
    a~businessplace ,
    a~BusinessPlaceDescription,
    a~IN_GSTIdentificationNumber,
    b~Street, b~PostalCode , b~CityName
   FOR ALL ENTRIES IN @it_header WHERE a~CompanyCode = @it_header-CompanyCode AND a~BusinessPlace = @it_header-Plant
   INTO TABLE @DATA(it_plant)
   PRIVILEGED ACCESS.



    SELECT FROM I_Producttext AS a FIELDS
        a~ProductName, a~Product
    FOR ALL ENTRIES IN @it_header
    WHERE a~Product = @it_header-material AND a~Language = 'E'
        INTO TABLE @DATA(it_product)
        PRIVILEGED ACCESS.

    SELECT FROM I_PurchaseOrderItemAPI01 AS a
        LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
        FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
        b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
    FOR ALL ENTRIES IN @it_header
    WHERE a~PurchaseOrder = @it_header-PurchaseOrder AND a~PurchaseOrderItem = @it_header-PurchaseOrderItem
        INTO TABLE @DATA(it_po)
        PRIVILEGED ACCESS.

    SELECT FROM I_MaterialDocumentItem_2
        FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
    FOR ALL ENTRIES IN @it_header
    WHERE MaterialDocument  = @it_header-ReferenceDocument
        INTO TABLE @DATA(it_grn)
        PRIVILEGED ACCESS.

    SELECT FROM I_ProductPlantIntlTrd FIELDS
        product , plant  , ConsumptionTaxCtrlCode
        FOR ALL ENTRIES IN @it_header
    WHERE product = @it_header-Material  AND plant = @it_header-Plant
        INTO TABLE @DATA(it_hsn)
        PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
    LEFT JOIN I_taxcodetext AS B ON B~TaxCode = A~TaxCode
       FIELDS A~SupplierInvoice  ,A~SupplierInvoiceItem , B~TaxCodeName
   FOR ALL ENTRIES IN @it_header
   WHERE Language = 'E' AND A~SupplierInvoice = @it_header-SupplierInvoice
   and A~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
       INTO TABLE @DATA(it_tax)
       PRIVILEGED ACCESS.

    SELECT  FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
    FIELDS  a~freightsupplier ,
    a~purchaseorder ,
    b~supplierfullname ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
 FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType  IN ('ZFRQ' , 'ZFRV') AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
 INTO TABLE @DATA(it_tc)
 PRIVILEGED ACCESS.

*      SELECT
*      A~SupplierInvoice ,
*      B~TaxNumberType
*      FROM I_SuplrInvcItemPurOrdRefAPI01 AS A
*      LEFT JOIN I_SUPPLIER AS B ON B~Supplier = A~FreightSupplier
*      FOR ALL ENTRIES IN @IT_HEADER where A~SupplierInvoice = @IT_HEADER-SupplierInvoice " and B~ResponsibleType = 'IN3'
*      into table @data(IT_VGST).


*       SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplier AS b ON b~Supplier = a~FreightSupplier
*      FIELDS a~purchaseorder ,
*      b~BPPanReferenceNumber ,
*      b~suppliername ,
*      b~BusinessPartnerPanNumber ,
*      a~supplierinvoice ,
*      a~SupplierInvoiceItem
*      FOR ALL ENTRIES IN @IT_HEADER WHERE a~supplierinvoice = @IT_HEADER-supplierinvoice and a~purchaseorder = @IT_HEADER-purchaseorder " and a~SupplierInvoiceItem = @IT_HEADER-SupplierInvoiceItem"
*      INTO TABLE @DATA(it_vln)
*      PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN I_BuPaIdentification AS b ON b~BusinessPartner = a~FreightSupplier
    FIELDS a~purchaseorder ,
    b~BPIdentificationNumber ,
    b~BPIdentificationType ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE b~BPIdentificationType = 'TAN' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_vtn)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
     FIELDS a~SupplierInvoiceItemAmount ,
     a~purchaseorder ,
     a~supplierinvoice ,
     a~SupplierInvoiceItem
     FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZINP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
     INTO TABLE @DATA(it_zinp)
     PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZINV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zinv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZPKP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zpkp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZPKQ' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zpkq)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZADP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zadp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZADV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zadv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZFRV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zfrv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZFRQ' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zfrq)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    LEFT JOIN I_Product AS c ON c~Product = a~PurchaseOrderItemMaterial
    FIELDS a~purchaseorder ,
    c~productgroup ,
    c~producttype ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~supplierinvoice = @it_header-SupplierInvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_fc)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZCHV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zchv)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZLUQ' AND a~supplierinvoice = @it_header-supplierinvoice
    INTO TABLE @DATA(it_zluq)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE  a~SuplrInvcDeliveryCostCndnType = 'ZLUV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zluv)
    PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZMNP' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zmnp)
    PRIVILEGED ACCESS.

    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZDSC' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zdsc)
    PRIVILEGED ACCESS.

     SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
    FIELDS a~SupplierInvoiceItemAmount ,
    a~purchaseorder ,
    a~supplierinvoice ,
    a~SupplierInvoiceItem
    FOR ALL ENTRIES IN @it_header WHERE a~SuplrInvcDeliveryCostCndnType = 'ZDSV' AND a~supplierinvoice = @it_header-supplierinvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
    INTO TABLE @DATA(it_zdsv)
    PRIVILEGED ACCESS.


*      SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
*      LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice AND b~FiscalYear = a~FiscalYear
*      FIELDS a~purchaseorder ,
*      a~supplierinvoice ,
*      b~supplierinvoice AS sp3 ,
*      b~fiscalyear
*      FOR ALL ENTRIES IN @IT_HEADER WHERE  a~SupplierInvoice = @IT_HEADER-SupplierInvoice
*      INTO TABLE @DATA(it_pdnew)
*      PRIVILEGED ACCESS.


    SELECT FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
   LEFT JOIN ztable_plant AS b ON b~plant_code = a~Plant
   FIELDS a~SupplierInvoice ,
   a~SupplierInvoiceItem ,
   b~city ,
   b~Address1 ,
   b~address2 ,
   b~address3 ,
   b~pin
   FOR ALL ENTRIES IN @it_header WHERE a~SupplierInvoice = @it_header-SupplierInvoice AND a~SupplierInvoiceItem = @it_header-SupplierInvoiceItem
   INTO TABLE @DATA(it_plantaddcity)
   PRIVILEGED ACCESS.





    LOOP AT it_header INTO DATA(waheader).

      ls_response-supplierinvoice = waheader-SupplierInvoice.
      ls_response-companycode = waheader-CompanyCode.
      ls_response-fiscalyearvalue = waheader-FiscalYear.
      ls_response-postingdate = waheader-PostingDate.
      ls_response-plantadr = waheader-AddressID.
      ls_response-supplierinvoiceitem = waheader-SupplierInvoiceItem.
*    ls_response-plantcity = waheader-plantcity.
*    ls_response-plantpin = waheader-plantpin.
      ls_response-product_trade_name = waheader-trade_name.
      ls_response-vendor_invoice_no = waheader-DeliveryDocumentBySupplier.
      ls_response-vendor_invoice_date = waheader-DocumentDate.
      ls_response-vendor_type = waheader-LegalFormDescription.
      ls_response-rfqno = waheader-SupplierQuotation.
      ls_response-rfqno = waheader-SupplierQuotation.
      ls_response-rfqdate = waheader-RFQPublishingDate.
      ls_response-supplierquotation = waheader-sq.
      ls_response-supplierquotationdate = waheader-QuotationSubmissionDate.
      ls_response-mrnquantityinbaseunit = waheader-PostingDate.
      ls_response-product                   = waheader-material.
      ls_response-purchaseorder             = waheader-PurchaseOrder.
      ls_response-purchaseorderitem         = waheader-PurchaseOrderItem.
      ls_response-pouom                      = waheader-PurchaseOrderPriceUnit.
      ls_response-poqty                      = waheader-QuantityInPurchaseOrderUnit.
      ls_response-netamount                  = waheader-SupplierInvoiceItemAmount.



      READ TABLE it_plant INTO DATA(wa_plant) WITH KEY businessplace = waheader-plant companycode = waheader-companycode.
      ls_response-plantname = wa_plant-BusinessPlaceDescription.
      ls_response-plantgst = wa_plant-IN_GSTIdentificationNumber.

      READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = waheader-PurchaseOrder
                                                 PurchaseOrderItem = waheader-PurchaseOrderItem.

      ls_response-baseunit                  = wa_po-BaseUnit.
      ls_response-profitcenter              = wa_po-ProfitCenter.
      ls_response-purchaseordertype         = wa_po-PurchaseOrderType.
      ls_response-purchaseorderdate         = wa_po-PurchaseOrderDate.
      ls_response-purchasingorganization    = wa_po-PurchasingOrganization.
      ls_response-purchasinggroup           = wa_po-PurchasingGroup.

      READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = waheader-ReferenceDocument.
      ls_response-mrnquantityinbaseunit     = wa_grn-QuantityInBaseUnit.
      ls_response-mrnpostingdate            = wa_grn-PostingDate.

      READ TABLE it_hsn INTO DATA(wa_hsn) WITH KEY plant = waheader-Plant Product = waheader-Material.
      ls_response-hsncode                    = wa_hsn-ConsumptionTaxCtrlCode.

      READ TABLE it_tax INTO DATA(wa_tax) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-taxcodename                = wa_tax-TaxCodeName.

      READ TABLE it_product INTO DATA(wa_product) WITH KEY product = waheader-material.
      ls_response-productname = wa_product-ProductName.




*SELECT SINGLE TaxItemAcctgDocItemRef FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear AND TaxItemAcctgDocItemRef IS NOT INITIAL
*            AND AccountingDocumentItemType <> 'T'
*            AND FiscalYear = @waheader-FiscalYear
*            AND CompanyCode = @waheader-CompanyCode
*            AND AccountingDocumentType = 'RE'
*        INTO  @DATA(lv_TaxItemAcctgDocItemRef)
*        PRIVILEGED ACCESS.
*
*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                AND AccountingDocumentItemType = 'T'
*                AND FiscalYear = @waheader-FiscalYear
*                AND CompanyCode = @waheader-CompanyCode
*                AND TransactionTypeDetermination = 'JII'
*        INTO  @ls_response-igst
*        PRIVILEGED ACCESS.
*
*        IF ls_response-igst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @ls_response-cgst
*          PRIVILEGED ACCESS.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @ls_response-sgst
*          PRIVILEGED ACCESS.
*        ENDIF.



*      ls_response-rateigst   = 0.
*      ls_response-ratecgst   = 0.
*      ls_response-ratesgst   = 0.
*
*      IF waheader-TaxCode = 'L0'.
*        ls_response-ratecgst   = 3.
*        ls_response-ratesgst   = 3.
*      ELSEIF waheader-TaxCode = 'I0'.
*        ls_response-rateigst   = 3.
*      ELSEIF waheader-TaxCode = 'L5'.
*        ls_response-ratecgst   = 5.
*        ls_response-ratesgst   = 5.
*      ELSEIF waheader-TaxCode = 'I1'.
*        ls_response-rateigst   = 5.
*      ELSEIF waheader-TaxCode = 'L2'.
*        ls_response-ratecgst   = 6.
*        ls_response-ratesgst   = 6.
*      ELSEIF waheader-TaxCode = 'I2'.
*        ls_response-rateigst   = 12.
*      ELSEIF waheader-TaxCode = 'L3'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*      ELSEIF waheader-TaxCode = 'I3'.
*        ls_response-rateigst   = 18.
*      ELSEIF waheader-TaxCode = 'L4'.
*        ls_response-ratecgst   = 14.
*        ls_response-ratesgst   = 14.
*      ELSEIF waheader-TaxCode = 'I4'.
*        ls_response-rateigst   = 28.
*      ELSEIF waheader-TaxCode = 'F5'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*      ELSEIF waheader-TaxCode = 'H5'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
*        ls_response-rateigst   = 18.
*      ELSEIF waheader-TaxCode = 'H6'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               wa_purchinvlines-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'H4'.
*        ls_response-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'H3'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'J3'.
*        ls_response-ratecgst   = 9.
**               ls_response-Ugstrate = '9'.
**               LS_RESPONSE-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'G6'.
*        ls_response-rateigst   = 18.
**               ls_response-Ugstrate = '9'.
**               ls_response-CESSRate = '18'.
*      ELSEIF waheader-TaxCode = 'G7'.
*        ls_response-ratecgst   = 9.
*        ls_response-ratesgst   = 9.
**               ls_response-CESSRate = '18'.
*      ENDIF.


      SELECT FROM i_suplrinvcitempurordrefapi01 AS a
        FIELDS a~supplierinvoice, a~fiscalyear , a~SupplierInvoiceItem
        WHERE a~supplierinvoice     = @waheader-supplierinvoice
          AND a~supplierinvoiceitem = @waheader-supplierinvoiceitem
        INTO TABLE @DATA(it_gtstax3).

      LOOP AT it_gtstax3 INTO DATA(wa_gtstax3).

        " Format supplier invoice with leading zeros (assumed width: 10)
        DATA(suppl)   = |{ wa_gtstax3-supplierinvoice WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
        DATA(fiscy)   = wa_gtstax3-fiscalyear.
        DATA(combine) = |{ suppl }{ fiscy }|.


        SELECT SINGLE FROM  i_operationalacctgdocitem
        FIELDS SUM( AmountInCompanyCodeCurrency )
        WHERE OriginalReferenceDocument = @combine
        AND TaxItemAcctgDocItemRef = @wa_gtstax3-SupplierInvoiceItem
        AND TransactionTypeDetermination = 'JII'
        INTO @DATA(lvvv).

        SELECT SINGLE FROM  i_operationalacctgdocitem
        FIELDS SUM( AmountInCompanyCodeCurrency )
        WHERE OriginalReferenceDocument = @combine
         AND TaxItemAcctgDocItemRef = @wa_gtstax3-SupplierInvoiceItem
        AND TransactionTypeDetermination = 'JIC'
        INTO @DATA(lvvv2).

        ls_response-cgst = lvvv2.
        ls_response-sgst = lvvv2.
        ls_response-igst = lvvv.

        ls_response-rateigst = ( ls_response-igst / ls_response-netamount ) * 100.
        ls_response-ratecgst = ( ls_response-cgst / ls_response-netamount ) * 100.
        ls_response-ratesgst = ( ls_response-sgst / ls_response-netamount ) * 100.

        " Fetch all matching records for this reference document
****        SELECT FROM i_operationalacctgdocitem AS b
****          FIELDS
****            b~originalreferencedocument,
****            b~amountincompanycodecurrency,
****            b~transactiontypedetermination
****          WHERE b~originalreferencedocument = @combine
****          INTO TABLE @DATA(it_gsttax3).
****
****        LOOP AT it_gsttax3 INTO DATA(wa_gsttax3).
****
****          CASE wa_gsttax3-transactiontypedetermination.
****            WHEN 'JII'.
****              ls_response-igst = wa_gsttax3-amountincompanycodecurrency.
****              append ls_response to lt_response.
****            WHEN 'JIC'.
****              ls_response-cgst = wa_gsttax3-amountincompanycodecurrency.
****              ls_response-sgst = wa_gsttax3-amountincompanycodecurrency.
****              append ls_response to lt_response.
****          ENDCASE.
****          CLEAR: suppl, fiscy, combine, wa_gsttax3.
****        ENDLOOP.

*  CLEAR: suppl, fiscy, combine, it_gsttax3, wa_gsttax3, wa_gtstax3.
****        CLEAR : it_gsttax3.
      ENDLOOP.















      ls_response-basicrate                  = round( val = ls_response-netamount / ls_response-poqty dec = 2 ).

      ls_response-taxamount                  = ls_response-igst + ls_response-sgst +
                                                    ls_response-cgst.
      ls_response-totalamount                = ls_response-taxamount + ls_response-netamount.





      READ TABLE it_tc INTO DATA(wa_tc) WITH KEY  SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-transportercode = wa_tc-FreightSupplier.
      ls_response-transportername = wa_tc-SupplierFullName.

      ls_response-vendorcode = waheader-frsup.

*        READ TABLE IT_VGST INTO DATA(WA_VGST) WITH KEY SupplierInvoice = waheader-SupplierInvoice.
*        ls_response-vendorgstin = WA_VGST-TaxNumberType.

*        READ TABLE it_vln INTO DATA(wa_vln) WITH KEY SupplierInvoice = waheader-supplierinvoice purchaseorder = waheader-purchaseorder." SupplierInvoiceItem = waheader-SupplierInvoiceItem.
*        ls_response-vendorlegalname = wa_vln-BPPanReferenceNumber.
*        ls_response-vendorname = wa_vln-SupplierName.
*        ls_response-vendorpanno = wa_vln-BusinessPartnerPanNumber.
*
      ls_response-vendorlegalname = waheader-BPPanReferenceNumber.
      ls_response-vendorname = waheader-SupplierName.
      ls_response-vendorpanno = waheader-BusinessPartnerPanNumber.

      READ TABLE it_vtn INTO DATA(wa_vtn) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-vendortanname = wa_vtn-BPIdentificationType.
      ls_response-vendortanno = wa_vtn-BPIdentificationNumber.

      READ TABLE it_zinp INTO DATA(wa_zinp)  WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-insurancechargesper = wa_zinp-SupplierInvoiceItemAmount.

      READ TABLE it_zinv INTO DATA(wa_zinv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-insurancecost = wa_zinv-SupplierInvoiceItemAmount.

      READ TABLE it_zpkp INTO DATA(wa_zpkp) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-packingchargesper = wa_zpkp-SupplierInvoiceItemAmount.

      READ TABLE it_zpkq INTO DATA(wa_zpkq) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-packingchargesqty = wa_zpkq-SupplierInvoiceItemAmount.

      READ TABLE it_zadp INTO DATA(wa_zadp) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-antidumpingper = wa_zadp-SupplierInvoiceItemAmount.

      READ TABLE it_zadv INTO DATA(wa_zadv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-antidumpingvalue = wa_zadv-SupplierInvoiceItemAmount.

      READ TABLE it_zfrv INTO DATA(wa_zfrv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-freightval = wa_zfrv-SupplierInvoiceItemAmount.

      READ TABLE it_zfrq INTO DATA(wa_zfrq) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-freightqty = wa_zfrq-SupplierInvoiceItemAmount.

      READ TABLE it_zmnp INTO DATA(wa_zmnp) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-manditax = wa_zmnp-SupplierInvoiceItemAmount.

      READ TABLE it_fc INTO DATA(wa_fc) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-materialgroup = wa_fc-ProductGroup.
      ls_response-materialtype = wa_fc-ProductType.

      ls_response-prdate = waheader-PurReqCreationDate.
      ls_response-prno = waheader-PurchaseRequisition.
      ls_response-prqty = waheader-RequestedQuantity.

      READ TABLE it_zchv INTO DATA(wa_zchv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-chachargesval = wa_zchv-SupplierInvoiceItemAmount.

      READ TABLE it_zluq INTO DATA(wa_zluq) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-ldguldgchgsqty = wa_zluq-SupplierInvoiceItemAmount.

      READ TABLE it_zluv INTO DATA(wa_zluv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem.
      ls_response-ldguldgchgsval = wa_zluv-SupplierInvoiceItemAmount.

      READ TABLE it_zdsc INTO DATA(wa_zdsc) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-discountper = wa_zdsc-SupplierInvoiceItemAmount.

      READ TABLE it_zdsv INTO DATA(wa_zdsv) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      ls_response-discountval = wa_zdsv-SupplierInvoiceItemAmount.


*        LOOP AT it_pdnew INTO DATA(wa_pdnew).
*          DATA : suppinv3 TYPE string .
*          DATA : fiscyea3 TYPE string .
*          DATA : comb3 TYPE string .
*          suppinv3 = WA_pdnew-sp3.
*          fiscyea3 = wa_pdnew-FiscalYear.
*          CONCATENATE suppinv3 fiscyea3 INTO comb3.
*
*          SELECT FROM i_supplierinvoiceapi01 AS a
*          LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb3 AND b~FiscalYear = a~FiscalYear
*          FIELDS b~AccountingDocumentType ,
*          a~supplierinvoice
*          INTO TABLE @DATA(it_comb3).
*
*          READ TABLE it_comb3 INTO DATA(wa_comb3) WITH KEY supplierinvoice = wa_pdnew-SupplierInvoice.
*          ls_response-mirodocumenttype = wa_comb3-AccountingDocumentType.
*          CLEAR : wa_comb3 , wa_pdnew  , comb3 , suppinv3 , fiscyea3 .
*        ENDLOOP.

      SELECT SINGLE FROM I_SuplrInvcItemPurOrdRefAPI01 AS a
   LEFT JOIN i_supplierinvoiceapi01 AS b ON b~SupplierInvoice = a~SupplierInvoice AND b~FiscalYear = a~FiscalYear
   FIELDS a~purchaseorder ,
   a~supplierinvoice ,
   b~supplierinvoice AS sp3 ,
   b~fiscalyear ,
   a~SupplierInvoiceItem
   WHERE  a~SupplierInvoice = @waheader-SupplierInvoice AND a~SupplierInvoiceItem = @waheader-SupplierInvoiceItem
   INTO  @DATA(wa_pdnew)
   PRIVILEGED ACCESS.

*         LOOP AT it_pdnew INTO DATA(wa_pdnew).
      DATA : suppinv3 TYPE string .
      DATA : fiscyea3 TYPE string .
      DATA : comb3 TYPE string .
      suppinv3 = WA_pdnew-sp3.
      fiscyea3 = wa_pdnew-FiscalYear.
      CONCATENATE suppinv3 fiscyea3 INTO comb3.

      SELECT FROM i_supplierinvoiceapi01 AS a
      LEFT JOIN I_OperationalAcctgDocItem AS b ON b~OriginalReferenceDocument = @comb3 AND b~FiscalYear = a~FiscalYear
      LEFT JOIN I_Supplier AS c ON c~Supplier = b~Supplier
      FIELDS b~AccountingDocumentType ,
      a~supplierinvoice ,
      c~TaxNumber3
      INTO TABLE @DATA(it_comb3).

      READ TABLE it_comb3 INTO DATA(wa_comb3) WITH KEY supplierinvoice = wa_pdnew-SupplierInvoice  .
      ls_response-mirodocumenttype = wa_comb3-AccountingDocumentType.
      ls_response-vendorgstin = wa_comb3-TaxNumber3.
      CLEAR : wa_comb3 , wa_pdnew  , comb3 , suppinv3 , fiscyea3 .
*        ENDLOOP.


      READ TABLE it_plantaddcity INTO DATA(wa_plantaddcity) WITH KEY SupplierInvoice = waheader-SupplierInvoice SupplierInvoiceItem = waheader-SupplierInvoiceItem .
      DATA : plant_address TYPE string.
      CONCATENATE wa_plantaddcity-address1 wa_plantaddcity-address2 wa_plantaddcity-address3 INTO plant_address.
      ls_response-plantcity = wa_plantaddcity-city.
      ls_response-plantadr = plant_address.
      ls_response-plantpin = wa_plantaddcity-pin.


*APPEND ls_response TO lt_response.
      MODIFY zdt_pur_reg_new FROM @ls_response.
      CLEAR: waheader ,ls_response , wa_grn , wa_po , wa_plant , wa_hsn , wa_tax , wa_product , wa_tc ,
             wa_vtn , wa_zinp , wa_zinv , wa_zpkp ,wa_zpkq , wa_zadp , wa_zadv  , wa_zfrq , wa_zfrv , wa_fc , wa_zchv , wa_zluq , wa_zluv ,
             wa_plantaddcity , plant_address  , wa_zmnp , wa_zdsc , wa_zdsv. ", lv_taxitemacctgdocitemref . " , waplantgsttax . " , wa_vln

    ENDLOOP.


  ENDMETHOD.



  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_purchase_reg_new,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).



      " Handle Search
      DATA(lv_search_string) = io_request->get_search_expression( ).
      DATA: lv_search_clause TYPE string.
      IF lv_search_string IS NOT INITIAL.
        " Create WHERE condition for search
        lv_search_clause = |AND ( UPPER( a~MaintenanceOrder ) LIKE UPPER( '%{ lv_search_string }%' ) |.
        lv_search_clause = |{ lv_search_clause } OR UPPER( b~OperationDescription ) LIKE UPPER( '%{ lv_search_string }%' ) )|.
      ENDIF.


      TRY.
          DATA(lt_clause) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
          CLEAR lx_no_range.
      ENDTRY.

      DATA(lt_parameter) = io_request->get_parameters( ).
      DATA(lt_fields)    = io_request->get_requested_elements( ).
      DATA(lt_sort)      = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lx_no_sel_option.
      ENDTRY.


* DATA: lt_suppinvoice_no      TYPE RANGE OF I_SupplierInvoiceAPI01-SupplierInvoice.
* DATA: lt_fiscalyear      TYPE RANGE OF I_SupplierInvoiceAPI01-FiscalYear.
* DATA: lt_compcode      TYPE RANGE OF I_SupplierInvoiceAPI01-CompanyCode.
*
*LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
*        CASE ls_filter_cond-name.
*          WHEN 'SUPPLIERINVOICENO'.
*            lt_suppinvoice_no = CORRESPONDING #( ls_filter_cond-range ).
*          WHEN 'FISCALYEAR'.
*            lt_fiscalyear = CORRESPONDING #( ls_filter_cond-range ).
*          WHEN 'COMPANYCODE'.
*            lt_compcode = CORRESPONDING #( ls_filter_cond-range ).
*        ENDCASE.
*      ENDLOOP.



      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'SUPPLIERINVOICENO'.
          DATA(lt_suppinvoice_no) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
          DATA(lt_fiscalyear) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_compcode) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'SUPPLIERINVOICEITEM'.
          DATA(lt_suppinvoice_item) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.



*    SELECT  FROM I_SupplierInvoiceAPI01 AS c
*    LEFT JOIN I_BusPartAddress WITH PRIVILEGED ACCESS AS hdr1 ON c~BusinessPlace = hdr1~BusinessPartner
*    LEFT JOIN I_SuplrInvcItemPurOrdRefAPI01 WITH PRIVILEGED ACCESS AS a on a~SupplierInvoice = c~SupplierInvoice and a~FiscalYear = c~FiscalYear
*    LEFT JOIN I_PurchaseOrderItemAPI01 WITH PRIVILEGED ACCESS AS li ON a~PurchaseOrder = li~PurchaseOrder and li~PurchaseOrderItem = a~PurchaseOrderItem
*    LEFT JOIN zmaterial_table WITH PRIVILEGED ACCESS AS li4 ON li~Material = li4~mat
*    LEFT JOIN i_deliverydocumentitem WITH PRIVILEGED ACCESS AS li2 ON li~PurchaseOrder = li2~ReferenceSDDocument AND li~PurchaseOrderItem = li2~ReferenceSDDocumentItem
*    LEFT JOIN i_deliverydocument WITH PRIVILEGED ACCESS AS li3 ON li2~DeliveryDocument = li3~DeliveryDocument
**    LEFT JOIN i_purchaseorderhistoryapi01 AS li5 ON li~PurchaseOrder = li5~PurchaseOrder AND li~PurchaseOrderItem = li5~PurchaseOrderItem
*    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS li6 ON li~PurchaseOrder = li6~PurchaseOrder
*    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS poa ON a~PurchaseOrder = poa~PurchaseOrder
*    LEFT JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS li7 ON li6~Supplier = li7~BusinessPartner
*    LEFT JOIN I_BusinessPartnerLegalFormText WITH PRIVILEGED ACCESS AS li8 ON li7~LegalForm = li8~LegalForm
*    LEFT JOIN i_purchaseorderitemtp_2 WITH PRIVILEGED ACCESS AS li9 ON li~PurchaseOrder = li9~PurchaseOrder and li~PurchaseOrderItem = li9~PurchaseOrderItem
*    LEFT JOIN I_Requestforquotation_Api01 WITH PRIVILEGED ACCESS AS li10 ON li9~SupplierQuotation = li10~RequestForQuotation
*    LEFT JOIN I_SupplierQuotation_Api01 WITH PRIVILEGED ACCESS AS li11 ON li9~SupplierQuotation = li11~SupplierQuotation
**    LEFT JOIN i_accountingdocumentjournal AS li12 ON li5~PurchasingHistoryDocument = li12~DocumentReferenceID
*    LEFT JOIN i_purchaserequisitionitemapi01 WITH PRIVILEGED ACCESS AS li13 ON li13~PurchaseRequisition = li~PurchaseRequisition
*    FIELDS  c~CompanyCode , c~FiscalYear, c~SupplierInvoice, c~SupplierInvoiceWthnFiscalYear, c~PostingDate , hdr1~AddressID ,
*            a~PurchaseOrderItem, a~SupplierInvoiceItem ,
*            a~PurchaseOrder, a~SupplierInvoiceItemAmount AS tax_amt, a~SupplierInvoiceItemAmount, a~taxcode,
*            a~FreightSupplier , a~TaxJurisdiction AS SInvwithFYear, a~plant,
*            a~PurchaseOrderItemMaterial AS material, a~QuantityInPurchaseOrderUnit, a~QtyInPurchaseOrderPriceUnit,
*            a~PurchaseOrderQuantityUnit, PurchaseOrderPriceUnit, a~ReferenceDocument , a~ReferenceDocumentFiscalYear , c~documentdate ,
*************************************
*            li~Plant AS plantcity, li~Plant AS plantpin, li3~DeliveryDocumentBySupplier , li4~trade_name ,
*            li8~LegalFormDescription, li9~SupplierQuotation, li10~RFQPublishingDate, li11~SupplierQuotation AS sq,
*            li11~QuotationSubmissionDate , li6~PurchaseOrderType , li6~PaymentTerms ,
*            li~OrderQuantity ,li~NetAmount , li13~PurReqCreationDate , li~PurchaseRequisition , li13~RequestedQuantity ,
*            li~OverdelivTolrtdLmtRatioInPct , poa~PurchaseOrderType AS po_type " , li5~DocumentDate  , li5~PostingDate as postingdate2 , li12~DocumentReferenceID
*            WHERE c~SupplierInvoice IN @lt_suppinvoice_no
*            AND c~FiscalYear IN @lt_fiscalyear
*            AND c~CompanyCode IN @lt_compcode
*            INTO table @DATA(IT_HEADER).
*
*
*            SELECT FROM I_IN_BusinessPlaceTaxDetail AS a
*            LEFT JOIN  I_Address_2  AS b ON a~AddressID = b~AddressID
*            FIELDS
*            a~companycode ,
*            a~businessplace ,
*            a~BusinessPlaceDescription,
*            a~IN_GSTIdentificationNumber,
*            b~Street, b~PostalCode , b~CityName
*           for all entries in @it_header WHERE a~CompanyCode = @it_header-CompanyCode AND a~BusinessPlace = @it_header-Plant
*           INTO TABLE @data(IT_PLANT).
*
*
*
*        SELECT FROM I_Producttext AS a FIELDS
*            a~ProductName, a~Product
*        FOR ALL ENTRIES IN @IT_HEADER
*        WHERE a~Product = @IT_HEADER-material AND a~Language = 'E'
*            INTO TABLE @DATA(it_product).
*
*        SELECT FROM I_PurchaseOrderItemAPI01 AS a
*            LEFT JOIN I_PurchaseOrderAPI01 AS b ON a~PurchaseOrdeR = b~PurchaseOrder
*            FIELDS a~BaseUnit , b~PurchaseOrderType , b~PurchasingGroup , b~PurchasingOrganization ,
*            b~PurchaseOrderDate , a~PurchaseOrder , a~PurchaseOrderItem , a~ProfitCenter
*        FOR ALL ENTRIES IN @IT_HEADER
*        WHERE a~PurchaseOrder = @IT_HEADER-PurchaseOrder AND a~PurchaseOrderItem = @IT_HEADER-PurchaseOrderItem
*            INTO TABLE @DATA(it_po).
*
*        SELECT FROM I_MaterialDocumentItem_2
*            FIELDS MaterialDocument , PurchaseOrder , PurchaseOrderItem , QuantityInBaseUnit , PostingDate
*        FOR ALL ENTRIES IN @IT_HEADER
*        WHERE MaterialDocument  = @IT_HEADER-ReferenceDocument
*            INTO TABLE @DATA(it_grn).
*
*        SELECT FROM I_ProductPlantIntlTrd FIELDS
*            product , plant  , ConsumptionTaxCtrlCode
*            FOR ALL ENTRIES IN @IT_HEADER
*        WHERE product = @IT_HEADER-Material  AND plant = @IT_HEADER-Plant
*            INTO TABLE @DATA(it_hsn).
*
*
*         SELECT FROM I_taxcodetext
*            FIELDS TaxCode , TaxCodeName
*        FOR ALL ENTRIES IN @IT_HEADER
*        WHERE Language = 'E' AND taxcode = @IT_HEADER-TaxCode
*            INTO TABLE @DATA(it_tax).

      DATA: lt_result TYPE STANDARD TABLE OF zdt_pur_reg_new.

      SELECT * FROM zdt_pur_reg_new AS a
      WHERE a~supplierinvoice IN @lt_suppinvoice_no
            AND a~companycode IN @lt_compcode
            AND a~fiscalyearvalue IN @lt_fiscalyear
            AND a~supplierinvoiceitem IN @lt_suppinvoice_item
            INTO TABLE @lt_result.


      LOOP AT lt_result INTO DATA(waheader).

        ls_response-supplierinvoice = waheader-SupplierInvoice.
        ls_response-companycode = waheader-CompanyCode.
        ls_response-fiscalyearvalue = waheader-fiscalyearvalue.
        ls_response-postingdate = waheader-PostingDate.
*    ls_response-supplierinvoicewthnfiscalyear = waheader-SupplierInvoiceWthnFiscalYear.
        ls_response-plantadr = waheader-plantadr.
        ls_response-supplierinvoiceitem = waheader-SupplierInvoiceItem.
*    ls_response-plantcity = waheader-plantcity.
*    ls_response-plantpin = waheader-plantpin.
        ls_response-ProductTradeName = waheader-product_trade_name.
        ls_response-VendorInvoiceNo = waheader-vendor_invoice_no.
        ls_response-vendorinvoicedate = waheader-vendor_invoice_date.
        ls_response-VendorType = waheader-vendor_type.
        ls_response-rfqno = waheader-SupplierQuotation.
        ls_response-rfqno = waheader-SupplierQuotation.
        ls_response-rfqdate = waheader-rfqdate.
        ls_response-supplierquotation = waheader-supplierquotation.
        ls_response-supplierquotationdate = waheader-supplierquotationdate.
        ls_response-mrnquantityinbaseunit = waheader-PostingDate.
*   ls_response-hsncode = waheader-DocumentReferenceID.
        ls_response-product                   = waheader-product.
        ls_response-purchaseorder             = waheader-PurchaseOrder.
        ls_response-purchaseorderitem         = waheader-PurchaseOrderItem.
        ls_response-pouom                      = waheader-pouom.
        ls_response-poqty                      = waheader-poqty.
        ls_response-netamount                  = waheader-netamount.



*     READ TABLE IT_PLANT INTO DATA(WA_PLANT) WITH KEY businessplace = waheader-plant companycode = waheader-companycode.
        ls_response-plantname = waheader-plantname.
        ls_response-plantgst = waheader-plantgst.

*     READ TABLE it_po INTO DATA(wa_po) WITH KEY PurchaseOrder = waheader-PurchaseOrder
*                                                PurchaseOrderItem = waheader-PurchaseOrderItem.

        ls_response-baseunit                  = waheader-BaseUnit.
        ls_response-profitcenter              = waheader-ProfitCenter.
        ls_response-purchaseordertype         = waheader-PurchaseOrderType.
        ls_response-purchaseorderdate         = waheader-PurchaseOrderDate.
        ls_response-purchasingorganization    = waheader-PurchasingOrganization.
        ls_response-purchasinggroup           = waheader-PurchasingGroup.

*    READ TABLE it_grn INTO DATA(wa_grn) WITH KEY MaterialDocument = waheader-ReferenceDocument.
        ls_response-mrnquantityinbaseunit     = waheader-mrnquantityinbaseunit.
        ls_response-mrnpostingdate            = waheader-PostingDate.

*     READ TABLE it_hsn INTO DATA(wa_hsn) WITH KEY plant = waheader-Plant Product = waheader-Material.
        ls_response-hsncode                    = waheader-hsncode.

*        READ TABLE it_tax INTO DATA(wa_tax) WITH KEY TaxCode = waheader-TaxCode.
        ls_response-taxcodename                = waheader-TaxCodeName.

*READ TABLE it_product INTO DATA(wa_product) WITH KEY product = waheader-material.
        ls_response-productname = waheader-ProductName.




*SELECT SINGLE TaxItemAcctgDocItemRef FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear AND TaxItemAcctgDocItemRef IS NOT INITIAL
*            AND AccountingDocumentItemType <> 'T'
*            AND FiscalYear = @waheader-FiscalYear
*            AND CompanyCode = @waheader-CompanyCode
*            AND AccountingDocumentType = 'RE'
*        INTO  @DATA(lv_TaxItemAcctgDocItemRef).
*
*        SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*            WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                AND AccountingDocumentItemType = 'T'
*                AND FiscalYear = @waheader-FiscalYear
*                AND CompanyCode = @waheader-CompanyCode
*                AND TransactionTypeDetermination = 'JII'
*        INTO  @ls_response-igst.
*
*        IF ls_response-igst IS INITIAL.
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIC'
*          INTO  @ls_response-cgst.
*
*          SELECT  SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
*              WHERE OriginalReferenceDocument = @waheader-sinvwithfyear
*                  AND TaxItemAcctgDocItemRef = @lv_TaxItemAcctgDocItemRef
*                  AND AccountingDocumentItemType = 'T'
*                  AND FiscalYear = @waheader-FiscalYear
*                  AND CompanyCode = @waheader-CompanyCode
*                  AND TransactionTypeDetermination = 'JIS'
*          INTO  @ls_response-sgst.
*        ENDIF.

*        ls_response-Cgst = waheader-cgst.
*        ls_response-Sgst = waheader-cgst.
*        ls_response-Igst = waheader-igst.


        ls_response-basicrate                  = round( val = ls_response-netamount / ls_response-poqty dec = 2 ).

        ls_response-taxamount                  = ls_response-igst + ls_response-sgst +
                                                      ls_response-cgst.
        ls_response-totalamount                = ls_response-taxamount + ls_response-netamount.



        ls_response-transportercode = waheader-transportercode.
        ls_response-transportername = waheader-transportername.
        ls_response-vendorcode = waheader-vendorcode.


*        ls_response-vendorgstin = waheader-vendorgstin.


        ls_response-vendorlegalname = waheader-vendorlegalname.
        ls_response-vendorname = waheader-vendorname.
        ls_response-vendorpanno = waheader-vendorpanno.

        ls_response-vendortanname = waheader-vendortanname.
        ls_response-vendortanno = waheader-vendortanno.

        ls_response-manditax = waheader-manditax.

        ls_response-Insurancechargesper = waheader-insurancechargesper.
        ls_response-Insurancecost = waheader-insurancecost.

        ls_response-Packingchargesper = waheader-packingchargesper.
        ls_response-Packingchargesqty = waheader-packingchargesqty.

        ls_response-Antidumpingper = waheader-antidumpingper.
        ls_response-Antidumpingvalue = waheader-antidumpingvalue.

        ls_response-freightval = waheader-freightval.
        ls_response-freightqty = waheader-freightqty.

        ls_response-materialgroup = waheader-materialgroup.
        ls_response-materialtype = waheader-materialtype.

        ls_response-prdate = waheader-prdate.
        ls_response-prno = waheader-prno.
        ls_response-prqty = waheader-prqty.

        ls_response-Discountper = waheader-discountper.
        ls_response-Discountval = waheader-discountval.

        ls_response-chachargesval = waheader-chachargesval.

        ls_response-ldguldgchgsqty = waheader-ldguldgchgsqty.
        ls_response-ldguldgchgsval = waheader-ldguldgchgsval.

        ls_response-Mirodocumenttype = waheader-mirodocumenttype.
        ls_response-vendorgstin = waheader-vendorgstin.

        ls_response-plantcity = waheader-plantcity.
        ls_response-plantadr = waheader-plantadr.
        ls_response-plantpin = waheader-plantpin.

        APPEND ls_response TO lt_response.
        CLEAR: waheader ,ls_response .", wa_grn , wa_po , wa_plant , wa_hsn , wa_tax , wa_product.

      ENDLOOP.



      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).



    ENDIF.


  ENDMETHOD.

ENDCLASS.






