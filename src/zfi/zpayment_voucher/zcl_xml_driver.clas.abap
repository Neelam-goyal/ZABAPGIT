CLASS zcl_xml_driver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
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
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_outg_pay_voucher/zfi_outg_pay_voucher'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_XML_DRIVER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    TYPES : BEGIN OF ty_st,
              bill_no      TYPE i_accountingdocumentjournal-Clearingaccountingdocument,
              gross_amt    TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
              pay_prev     TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
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

    DATA : total_gross_amount TYPE i_accountingdocumentjournal-Creditamountintranscrcy.
    DATA : total_net_amount TYPE i_accountingdocumentjournal-Creditamountintranscrcy.
    DATA : total_pay_prev TYPE i_accountingdocumentjournal-Creditamountintranscrcy.
    DATA : total_bill_amount TYPE i_accountingdocumentjournal-Creditamountintranscrcy.

    DATA : remarks TYPE string.
    DATA : project TYPE string.


    """""""""""
*    SELECT   FROM i_address_2 WITH PRIVILEGED ACCESS
*    FIELDS *
*    INTO TABLE @DATA(it_temp).

*    SELECT FROM i_supplier as a
*    FIELDS supplier
*    where a~supplier is not initial
*    INTO TABLE @DATA(it_temp1)
*    PRIVILEGED ACCESS.



    """""""""

    SELECT SINGLE FROM  i_companycode WITH PRIVILEGED ACCESS AS a  LEFT JOIN i_accountingdocumentjournal AS b
                                     ON a~CompanyCode = b~CompanyCode
                            LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON a~AddressID = c~AddressID
*                            LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS d ON b~Supplier = d~Supplier

      FIELDS a~CompanyCodeName , a~CompanyCode, b~HouseBank , b~AccountingDocumentHeaderText,
             b~AccountingDocument , b~PostingDate , b~Supplier, a~AddressID , b~FiscalYear ,
             c~HouseNumber , c~StreetName , c~CityName , c~PostalCode , c~Region , c~Country
*             d~SupplierName , d~StreetName AS ven_StreetName  , d~PostalCode AS ven_postalcode ,
*             d~CityName AS ven_cityName , d~Region AS ven_region , d~Country AS Ven_country,
*             d~PhoneNumber1
      WHERE b~CompanyCode = @lv_Companycode AND b~AccountingDocument = @lv_Accountingdocument and b~FiscalYear = @lv_fiscalyear
      AND b~Ledger = '0L'
      INTO @DATA(lv_header).


    IF lv_header-AccountingDocument IS NOT INITIAL.
*********************************   COMPANY ADDRESS
      SELECT SINGLE FROM i_operationalacctgdocitem AS a
      FIELDS CompanyCode, AccountingDocument, FiscalYear, BusinessPlace, a~PostingDate, a~DocumentDate
       WHERE     a~CompanyCode = @lv_Companycode
*               AND a~Ledger = '0L'
                 AND a~FiscalYear = @lv_fiscalyear
                 AND a~AccountingDocument = @lv_Accountingdocument
                 AND a~financialaccounttype = 'S'
*               and a~BusinessPlace is not INITIAL
          INTO @DATA(Cmpny_data).


      SELECT SINGLE FROM ztable_plant WITH PRIVILEGED ACCESS
          FIELDS  address1, address2, city, state_name, pin, country , mob_no, email, remark2, remark3,
            gstin_no, pan_no, cin_no, fssai_no
*          WHERE    comp_code = @lv_Companycode
             WHERE plant_code = @cmpny_data-BusinessPlace
         INTO @DATA(Cmpny_Address).

*        loop at Cmpny_data into data(wa_cmpny).
*            if wa_cmpny-BusinessPlace ne wa_cmpny-Plant.
*                clear: wa_cmpny.
*            endif.
*            modify Cmpny_data from wa_cmpny.
*             clear: wa_cmpny.
*        endloop.


**********************************   COMPANY ADDRESS
*     SELECT single from ztable_plant with PRIVILEGED ACCESS
*     fields  address1, address2, city, state_name, pin, country , mob_no, email, remark2, remark3
*         WHERE comp_code = @lv_Companycode "AND b~AccountingDocument = @lv_Accountingdocument
*                                           "AND Ledger = '0L'
*      into @Data(Cmpny_Data).

*********************************   PLANT CODE/ PLANT NAME
      SELECT SINGLE FROM ztable_plant WITH PRIVILEGED ACCESS
      FIELDS  plant_code, plant_name1, plant_name2
          WHERE comp_code = @lv_Companycode "AND b~AccountingDocument = @lv_Accountingdocument
                                            "AND Ledger = '0L'
       INTO @DATA(Plant_Data).

*********************************    BANK NAME
      SELECT SINGLE FROM i_accountingdocumentjournal AS a
          INNER JOIN i_housebankbasic AS b ON a~HouseBank = b~HouseBank AND a~FinancialAccountType = 'S' AND a~GLAccountType = 'C'
      FIELDS b~BankName ", B~BankInternalID, B~CompanyCode, B~HouseBank
           WHERE a~CompanyCode = @lv_Companycode   "@lv_header-CompanyCode
                 AND a~Ledger = '0L'
                 AND a~FiscalYear = @lv_fiscalyear
                 AND a~AccountingDocument = @lv_Accountingdocument   "@lv_header-AccountingDocument "
      INTO @DATA(Bank_Data) PRIVILEGED ACCESS.



      SELECT SINGLE FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON a~Supplier = b~supplier
      FIELDS a~Supplier , b~SupplierName , b~StreetName AS ven_StreetName  , b~PostalCode AS ven_postalcode ,
             b~CityName AS ven_cityName , b~Region AS ven_region , b~Country AS Ven_country,
             b~PhoneNumber1
             WHERE a~AccountingDocument = @lv_header-AccountingDocument AND
                   a~CompanyCode = @lv_header-CompanyCode AND
                   a~FiscalYear = @lv_header-FiscalYear AND
                   a~Ledger = '0L' AND
                   a~Supplier IS NOT INITIAL
               INTO @DATA(lv_supplier).


      SELECT SINGLE FROM i_accountingdocumentjournal  AS a
      FIELDS a~HouseBank
       WHERE a~AccountingDocument = @lv_header-AccountingDocument AND
              a~CompanyCode = @lv_header-CompanyCode AND
              a~FiscalYear = @lv_header-FiscalYear AND
              a~Ledger = '0L' AND
              a~HouseBank IS NOT INITIAL
          INTO @lv_header-HouseBank.

    ENDIF.



*    DATA : Company_adress TYPE string.
*    CONCATENATE lv_header-HouseNumber lv_header-StreetName lv_header-CityName
*                 lv_header-PostalCode lv_header-Region lv_header-Country
*                 INTO company_adress SEPARATED BY ' '.

    DATA : cmpny_adress1 TYPE string.
    CONCATENATE Cmpny_Address-address1  Cmpny_Address-address2
                 INTO cmpny_adress1 SEPARATED BY ' '.

    DATA : cmpny_adress2 TYPE string.
    CONCATENATE Cmpny_Address-city  Cmpny_Address-state_name  Cmpny_Address-pin  Cmpny_Address-country
                 INTO cmpny_adress2 SEPARATED BY ' '.

    DATA : Plant_adress TYPE string.
    CONCATENATE Plant_Data-plant_code  Plant_Data-plant_name1  Plant_Data-plant_name2
                 INTO Plant_adress SEPARATED BY ' '.

    DATA : Vendor_adress TYPE string.
    CONCATENATE lv_supplier-ven_streetname lv_supplier-ven_cityname lv_supplier-ven_postalcode
                lv_supplier-ven_country lv_supplier-ven_region
                INTO Vendor_adress SEPARATED BY ' '.


    SELECT FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
           FIELDS amountincompanycodecurrency
           WHERE CompanyCode = @lv_Companycode AND AccountingDocument = @lv_Accountingdocument AND
           Accountingdocumenttype =  'KZ' AND debitcreditcode = 'S' AND
         FiscalYear = @lv_fiscalyear "AND Clearingaccountingdocument IS NOT INITIAL
    INTO TABLE  @DATA(it_item).

    LOOP AT it_item INTO DATA(wa_item).
      total_bill_amount += wa_item-AmountInCompanyCodeCurrency.
    ENDLOOP.


*            select SINGLE  sum( AMOUNTINCODECURRENCY )
*            from I_OPERATIONALACCTGDOCITEM
*
*             WHERE CompanyCode = @lv_Companycode AND AccountingDocument = @lv_Accountingdocument AND Ledger = '0L' AND
*         FiscalYear = @lv_fiscalyear AND Clearingaccountingdocument IS NOT INITIAL
*    INTO  @DATA(it_item)
*    PRIVILEGED ACCESS.
*

*    SELECT FROM i_accountingdocumentjournal AS a
*    FIELDS a~Clearingaccountingdocument , a~ClearingDocFiscalYear , a~Ledger , AccountingDocument , a~CompanyCode
*    WHERE CompanyCode = @lv_Companycode AND AccountingDocument = @lv_Accountingdocument AND Ledger = '0L' AND
*         FiscalYear = @lv_fiscalyear AND Clearingaccountingdocument IS NOT INITIAL
*    INTO TABLE @DATA(it_item)
*    PRIVILEGED ACCESS.
*
*
*    IF it_item IS NOT INITIAL.
*      SELECT FROM i_accountingdocumentjournal
*      FIELDS AccountingDocument , CompanyCode , ClearingAccountingDocument , ClearingDocFiscalYear ,
*      Ledger , LedgerGLLineItem , FiscalYear
*      FOR ALL ENTRIES IN @it_item
*      WHERE  ClearingAccountingDocument = @it_item-Clearingaccountingdocument  AND
*             ClearingDocFiscalYear = @it_item-ClearingDocFiscalYear
*             AND Accountingdocumenttype = 'KZ' AND Ledger = @it_item-Ledger and CompanyCode = @it_item-CompanyCode
*          INTO TABLE @DATA(it_item1)
*          PRIVILEGED ACCESS.
*    ENDIF.
*
*    IF it_item1 IS NOT INITIAL.
*      SELECT FROM i_accountingdocumentjournal
**      FIELDS *
*    FIELDS companycode , FiscalYear , DebitAmountInTransCrcy , AccountingDocument,
*      CreditAmountInTransCrcy , Transactiontypedetermination , PostingDate ,
*      AccountingDocumentItem
*      FOR ALL ENTRIES IN @it_item1
*      WHERE AccountingDocument = @it_item1-AccountingDocument AND ledger = @it_item1-ledger
*         AND FiscalYear = @it_item1-FiscalYear and CompanyCode = @it_item1-CompanyCode and Accountingdocumenttype = 'KZ'
*      INTO TABLE @DATA(it_item2)
*      PRIVILEGED ACCESS.
*    ENDIF.
*
*    LOOP AT it_item2 INTO DATA(wa_item2).
*
**      IF wa_item2-AccountingDocumentItem = '002'.
*      wa_gross-debitamountintranscrcy = wa_item2-DebitAmountInTransCrcy.
*      wa_gross-accountingdocument = wa_item2-AccountingDocument.
*      COLLECT wa_gross INTO it_gross.
**      ENDIF.
*
*
*      IF wa_item2-Transactiontypedetermination = 'EGK'.
*        IF wa_item2-CreditAmountInTransCrcy < 0 .
*          wa_net-creditamountintranscrcy = -1 * wa_item2-CreditAmountInTransCrcy.
*        ENDIF.
*        wa_net-accountingdocument = wa_item2-AccountingDocument.
*        COLLECT wa_net INTO it_net.
*      ENDIF.
*
*      IF wa_item2-Transactiontypedetermination = 'WIT'.
*        IF wa_item2-CreditAmountInTransCrcy < 0.
*          wa_tds-creditamountintranscrcy = -1 * wa_item2-CreditAmountInTransCrcy.
*        ENDIF.
*        wa_tds-accountingdocument = wa_item2-AccountingDocument.
*        COLLECT wa_tds INTO it_tds.
*      ENDIF.
*
*    ENDLOOP.
*
*    SORT it_item2 BY AccountingDocument .
*    DELETE ADJACENT DUPLICATES FROM it_item2 COMPARING AccountingDocument.
*
*    LOOP AT it_item2 INTO wa_item2.
*
*      READ TABLE it_gross INTO wa_gross WITH KEY accountingdocument = wa_item2-AccountingDocument.
*      IF sy-subrc = 0 .
*        wa_final-gross_amt = wa_gross-debitamountintranscrcy.
*        total_gross_amount += wa_gross-debitamountintranscrcy.
*      ENDIF.
*
*      READ TABLE it_tds INTO wa_tds WITH KEY accountingdocument = wa_item2-AccountingDocument.
*      IF sy-subrc = 0 .
*        wa_final-tds = wa_tds-creditamountintranscrcy.
*      ENDIF.
*
*      READ TABLE it_net INTO wa_net WITH KEY accountingdocument = wa_item2-AccountingDocument.
*      IF sy-subrc = 0 .
*        wa_final-net_amt = wa_net-creditamountintranscrcy.
*        total_net_amount = wa_net-creditamountintranscrcy.
*      ENDIF.
*
*      READ TABLE it_item INTO DATA(wa_item) WITH KEY AccountingDocument = wa_item2-AccountingDocument.
*      IF sy-subrc = 0.
*        wa_final-bill_no = wa_item-ClearingAccountingDocument.
*      ENDIF.
*      wa_final-invoice_date = wa_item2-PostingDate.
*      wa_final-invoice_no = wa_item2-AccountingDocument.
**      wa_final-bill_no = wa_item2-ClearingAccountingDocument.
*
*      total_bill_amount = total_gross_amount.
*
*      APPEND wa_final TO it_final.
*
*    ENDLOOP.




    DATA(lv_xml) = |<Form>| &&
                    |<CompanyCode>{ lv_header-CompanyCode }</CompanyCode>| &&
                    |<CompanyCodeName>{ lv_header-CompanyCodeName }</CompanyCodeName>| &&
                    |<CompanyAdress1>{ cmpny_adress1 }</CompanyAdress1>| &&
                    |<CompanyAdress2>{ cmpny_adress2 }</CompanyAdress2>| &&
                    |<PlantAdress>{ Plant_adress }</PlantAdress>| &&
                    |<PhoneNo>{ Cmpny_Address-mob_no }</PhoneNo>| &&
                    |<EmailId>{ Cmpny_Address-email }</EmailId>| &&
                         |<GstNo>{ Cmpny_Address-gstin_no }</GstNo>| &&
                         |<PanNo>{ Cmpny_Address-pan_no }</PanNo>| &&
                         |<CinNo>{ Cmpny_Address-cin_no }</CinNo>| &&
                         |<FssaiNo>{ cmpny_address-fssai_no }</FssaiNo>| &&
                         |<PostingDate>{ Cmpny_data-PostingDate }</PostingDate>| &&
*                    |<PhoneNo>{ cmpny_data-remark1 }</PhoneNo>| &&
*                    |<EmailId>{ cmpny_data-remark2 }</EmailId>| &&
*                    |<CompanyAdress>{ company_adress }</CompanyAdress>| &&
                    |<DocumentNo>{ lv_header-AccountingDocument }</DocumentNo>| &&
                    |<DocumentDate>{ lv_header-PostingDate }</DocumentDate>| &&
                    |<VendorName>{ lv_supplier-SupplierName }</VendorName>| &&
                    |<VendorAdress>{ vendor_adress }</VendorAdress>| &&
                    |<BankName>{ Bank_Data }</BankName>| &&
*                    |<BankName>{ lv_header-HouseBank }</BankName>| &&
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

    REPLACE ALL OCCURRENCES OF '&' IN lv_xml with 'and'.


    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

*  out->write( lv_header ) .


  ENDMETHOD .
ENDCLASS.
