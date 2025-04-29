CLASS zcl_outg_payment_dr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  lv_Accountingdocument TYPE string
                  lv_fiscalyear         TYPE string
                  lv_Companycode        TYPE string
        RETURNING VALUE(result12)       TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_outg_pay_voucher/zfi_outg_pay_voucher'.

ENDCLASS.



CLASS ZCL_OUTG_PAYMENT_DR IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts .

    TYPES : BEGIN OF ty_st,
              bill_no      TYPE i_accountingdocumentjournal-Clearingaccountingdocument,
              gross_amt    TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
              pay_prev    TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
              tds          TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
              net_amt      TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
              invoice_date TYPE i_accountingdocumentjournal-PostingDate,
              invoice_no   TYPE i_accountingdocumentjournal-Accountingdocument,
*      total_gross_amt type i_accountingdocumentjournal-Debitamountintranscrcy,

            END OF ty_st.


    TYPES : BEGIN OF ty_gross,
              Accountingdocument     TYPE i_accountingdocumentjournal-Accountingdocument,
              Debitamountintranscrcy TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
            END OF ty_gross.

    TYPES : BEGIN OF ty_net,
              Accountingdocument      TYPE i_accountingdocumentjournal-Accountingdocument,
              Creditamountintranscrcy TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
            END OF ty_net.

    TYPES : BEGIN OF ty_tds,
              Accountingdocument      TYPE i_accountingdocumentjournal-Accountingdocument,
              Creditamountintranscrcy TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
            END OF ty_tds.


    DATA : it_final TYPE TABLE OF ty_st.
    DATA : wa_final TYPE ty_st.

    DATA : it_gross TYPE TABLE OF ty_gross.
    DATA : wa_gross TYPE ty_gross.

    DATA : it_net TYPE TABLE OF ty_net.
    DATA : wa_net TYPE ty_net.

    DATA : it_tds TYPE TABLE OF ty_tds.
    DATA : wa_tds TYPE ty_tds.

    data : total_gross_amount type i_accountingdocumentjournal-Creditamountintranscrcy.
    data : total_net_amount type i_accountingdocumentjournal-Creditamountintranscrcy.
    data : total_pay_prev type i_accountingdocumentjournal-Creditamountintranscrcy.
    data : total_bill_amount type i_accountingdocumentjournal-Creditamountintranscrcy.

   data : remarks type string.
   data : project type string.


   """""""""""
*   select from i_address_2
*   fields *
*   into table @data(it_temp)
*   privileged access.
   """""""""

    SELECT SINGLE FROM  i_companycode WITH PRIVILEGED ACCESS AS a  LEFT JOIN i_accountingdocumentjournal AS b
                                     ON a~CompanyCode = b~CompanyCode
                            LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON a~AddressID = c~AddressID
                            LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS d ON b~Supplier = d~Supplier

      FIELDS a~CompanyCodeName , a~CompanyCode, b~HouseBank , b~AccountingDocumentHeaderText,
             b~AccountingDocument , b~PostingDate ,
             c~HouseNumber , c~StreetName , c~CityName , c~PostalCode , c~Region , c~Country,
             d~SupplierName , d~StreetName AS ven_StreetName  , d~PostalCode AS ven_postalcode ,
             d~CityName AS ven_cityName , d~Region AS ven_region , d~Country AS Ven_country,
             d~PhoneNumber1
      WHERE b~CompanyCode = @lv_Companycode
            AND b~AccountingDocument = @lv_Accountingdocument
      INTO @DATA(lv_header).


    DATA : Company_adress TYPE string.
    CONCATENATE lv_header-HouseNumber lv_header-StreetName lv_header-CityName
                lv_header-PostalCode lv_header-Region lv_header-Country
                INTO company_adress.

    DATA : Vendor_adress TYPE string.
    CONCATENATE lv_header-ven_streetname lv_header-ven_cityname lv_header-ven_postalcode
                lv_header-ven_country lv_header-ven_region
                INTO Vendor_adress.


    SELECT FROM i_accountingdocumentjournal AS a
    FIELDS a~Clearingaccountingdocument , a~ClearingDocFiscalYear , a~Ledger , AccountingDocument
    WHERE CompanyCode = @lv_Companycode
            AND AccountingDocument = @lv_Accountingdocument
            AND Ledger = '0L' AND
         FiscalYear = @lv_fiscalyear AND Clearingaccountingdocument IS NOT INITIAL
    INTO TABLE @DATA(it_item)
    privileged access.


    IF it_item IS NOT INITIAL.
*      SELECT FROM i_accountingdocumentjournal
*      FIELDS AccountingDocument , CompanyCode , ClearingAccountingDocument , ClearingDocFiscalYear ,
*      Ledger , LedgerGLLineItem , FiscalYear
*      FOR ALL ENTRIES IN @it_item
*      WHERE  ClearingAccountingDocument = @it_item-Clearingaccountingdocument  AND
*             ClearingDocFiscalYear = @it_item-ClearingDocFiscalYear
*             AND Accountingdocumenttype = 'KR'
*             AND Ledger = @it_item-Ledger
*          INTO TABLE @DATA(it_item1)
*          privileged access.
SELECT a~AccountingDocument, a~CompanyCode, a~ClearingAccountingDocument,
       a~ClearingDocFiscalYear, a~Ledger, a~LedgerGLLineItem, a~FiscalYear
  FROM i_accountingdocumentjournal AS a
  INNER JOIN @it_item AS b
  ON a~ClearingAccountingDocument = b~ClearingAccountingDocument
  AND a~ClearingDocFiscalYear = b~ClearingDocFiscalYear
  AND a~Ledger = b~Ledger
  WHERE a~AccountingDocumentType = 'KR'
   INTO TABLE @DATA(it_item1)
  privileged access.

    ENDIF.

    IF it_item1 IS NOT INITIAL.
*      SELECT FROM i_accountingdocumentjournal
*    Fields companycode , FiscalYear , DebitAmountInTransCrcy , AccountingDocument,
*      CreditAmountInTransCrcy , Transactiontypedetermination , PostingDate ,
*      AccountingDocumentItem
*      FOR ALL ENTRIES IN @it_item1
*      WHERE AccountingDocument = @it_item1-AccountingDocument
*      AND ledger = @it_item1-ledger
*         and FiscalYear = @it_item1-FiscalYear
*      INTO TABLE @DATA(it_item2)
*      privileged access.

SELECT a~companycode, a~FiscalYear, a~DebitAmountInTransCrcy,
       a~AccountingDocument, a~CreditAmountInTransCrcy,
       a~Transactiontypedetermination, a~PostingDate,
       a~AccountingDocumentItem
  FROM i_accountingdocumentjournal AS a
  INNER JOIN @it_item1 AS b
  ON a~AccountingDocument = b~AccountingDocument
  AND a~ledger = b~ledger
  AND a~FiscalYear = b~FiscalYear
   INTO TABLE @DATA(it_item2)
     privileged access.
    ENDIF.

    LOOP AT it_item2 INTO DATA(wa_item2).

*      IF wa_item2-AccountingDocumentItem = '002'.
      wa_gross-debitamountintranscrcy = wa_item2-DebitAmountInTransCrcy.
      wa_gross-accountingdocument = wa_item2-AccountingDocument.
      COLLECT wa_gross INTO it_gross.
*      ENDIF.


      IF wa_item2-Transactiontypedetermination = 'EGK'.
       if wa_item2-CreditAmountInTransCrcy < 0 .
        wa_net-creditamountintranscrcy = -1 * wa_item2-CreditAmountInTransCrcy.
        endif.
        wa_net-accountingdocument = wa_item2-AccountingDocument.
        COLLECT wa_net INTO it_net.
      ENDIF.

      IF wa_item2-Transactiontypedetermination = 'WIT'.
       if wa_item2-CreditAmountInTransCrcy < 0.
        wa_tds-creditamountintranscrcy = -1 * wa_item2-CreditAmountInTransCrcy.
        ENDIF.
        wa_tds-accountingdocument = wa_item2-AccountingDocument.
        COLLECT wa_tds INTO it_tds.
      ENDIF.

    ENDLOOP.

    SORT it_item2 BY AccountingDocument .
    DELETE ADJACENT DUPLICATES FROM it_item2 COMPARING AccountingDocument.

    LOOP AT it_item2 INTO wa_item2.

      READ TABLE it_gross INTO wa_gross WITH KEY accountingdocument = wa_item2-AccountingDocument.
      IF sy-subrc = 0 .
        wa_final-gross_amt = wa_gross-debitamountintranscrcy.
        total_gross_amount += wa_gross-debitamountintranscrcy.
      ENDIF.

      READ TABLE it_tds INTO wa_tds WITH KEY accountingdocument = wa_item2-AccountingDocument.
      IF sy-subrc = 0 .
        wa_final-tds = wa_tds-creditamountintranscrcy.
      ENDIF.

      READ TABLE it_net INTO wa_net WITH KEY accountingdocument = wa_item2-AccountingDocument.
      IF sy-subrc = 0 .
        wa_final-net_amt = wa_net-creditamountintranscrcy.
        total_net_amount = wa_net-creditamountintranscrcy.
      ENDIF.

      READ TABLE it_item INTO DATA(wa_item) WITH KEY AccountingDocument = wa_item2-AccountingDocument.
      IF sy-subrc = 0.
        wa_final-bill_no = wa_item-ClearingAccountingDocument.
      ENDIF.
      wa_final-invoice_date = wa_item2-PostingDate.
      wa_final-invoice_no = wa_item2-AccountingDocument.
*      wa_final-bill_no = wa_item2-ClearingAccountingDocument.

    total_bill_amount = total_gross_amount.

      APPEND wa_final TO it_final.

    ENDLOOP.





    DATA(lv_xml) = |<Form>| &&
                    |<CompanyCode>{ lv_header-CompanyCode }</CompanyCode>| &&
                    |<CompanyCodeName>{ lv_header-CompanyCodeName }</CompanyCodeName>| &&
                    |<CompanyAdress>{ company_adress }</CompanyAdress>| &&
                    |<DocumentNo>{ lv_header-AccountingDocument }</DocumentNo>| &&
                    |<DocumentDate>{ lv_header-PostingDate }</DocumentDate>| &&
                    |<VendorName>{ lv_header-SupplierName }</VendorName>| &&
                    |<VendorAdress>{ vendor_adress }</VendorAdress>| &&
                    |<BankName>{ lv_header-HouseBank }</BankName>| &&
                    |<BankDate>{ lv_header-PostingDate }</BankDate>| &&
                    |<BankRefrence>{ lv_header-AccountingDocumentHeaderText }</BankRefrence>| &&
                    |<TotalGrossAmt>{ total_gross_amount }</TotalGrossAmt>| &&
                    |<TotalNetAmt>{ total_net_amount }</TotalNetAmt>| &&
                    |<TotalPayprev>{ total_pay_prev }</TotalPayprev>| &&
                    |<TotalBillAmt>{ total_bill_amount }</TotalBillAmt>| &&
                    |<Remarks>{   Remarks } </Remarks>| &&
                    |<Project>{   project }</Project>| &&
*                    |<Remaks>{ total_bill_amount }</Remarks>| &&
                    |<Table>|.
    DATA : lv_xml1 TYPE string .
    LOOP AT it_final INTO wa_final.
      DATA(lv_xml2) = |<Item>| &&
       |<BillNo>{ wa_final-bill_no }</BillNo>| &&
       |<GrossAmt>{ wa_final-gross_amt }</GrossAmt>| &&
       |<tds>{ wa_final-tds }</tds>| &&
       |<PayPrev>{ wa_final-pay_prev }</PayPrev>| &&
       |<NetAmt>{ wa_final-net_amt }</NetAmt>| &&
       |<InvoiceNo>{ wa_final-invoice_no }</InvoiceNo>| &&
       |<InvoiceDate>{ wa_final-invoice_date }</InvoiceDate>| &&
      |</Item>|.

      CONCATENATE lv_xml1 lv_xml2 INTO lv_xml1.

    ENDLOOP.

    DATA(lv_xml3) =   |</Table>| &&

   |</Form>|.

    CONCATENATE lv_xml lv_xml1 lv_xml3 INTO lv_xml.


    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

*  out->write( lv_header ) .


  ENDMETHOD .
ENDCLASS.
