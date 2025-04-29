CLASS zcl_jv_print_dr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_final,
           AccountingDocument      TYPE i_operationalacctgdocitem-AccountingDocument,
           GLAccount                 TYPE i_operationalacctgdocitem-GLAccount,
           CompanyCode             type i_operationalacctgdocitem-CompanyCode,
           AbsoluteAmountInCoCodeCrcy TYPE i_operationalacctgdocitem-AbsoluteAmountInCoCodeCrcy,
           SupplierName            TYPE i_supplier-SupplierName,
           CustomerName            TYPE i_customer-CustomerName,
           GLAccountLongName       TYPE I_GLAccountTextRawData-GLAccountLongName,
           DebitCreditCode         type i_operationalacctgdocitem-DebitCreditCode,
           DocumentItemText        type i_operationalacctgdocitem-DocumentItemText,
           AccountName TYPE STRING,
            DEBIT TYPE STRING,
            CREDIT TYPE STRING,
            REMARKS TYPE STRING,
            DebitRemarks TYPE STRING,
            CreditRemarks TYPE STRING,
       END OF ty_final.

*    INTERFACES if_oo_adt_classrun .
*      CLASS-DATA: VAR1 TYPE i_operationalacctgdocitem-AccountingDocument.
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
        lv_belnr2                 TYPE string
        lv_companycode            type string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_Journal_Voucher/zfi_Journal_Voucher'."'zpo/zpo_v2'."

ENDCLASS.



CLASS ZCL_JV_PRINT_DR IMPLEMENTATION.


METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
ENDMETHOD .


METHOD read_posts .

*    DATA : user_belnr TYPE string.
*       VAR1 = LV_BELNR2.
*       VAR1   = |{ VAR1 ALPHA = IN }|.
*       user_belnr = LV_BELNR2.
*       user_belnr =  VAR1.


******************************* HEADER *****************************
    SELECT SINGLE
     FROM i_operationalacctgdocitem AS a
     LEFT JOIN I_CompanyCode AS b ON a~CompanyCode = b~CompanyCode
     left join i_address_2 as c on b~AddressID = c~AddressID
     fields b~CompanyCodeName,
            c~HouseNumber, c~StreetName, c~CityName, c~PostalCode, c~Region, c~Country,
            a~AccountingDocument, a~PostingDate, a~NetDueDate, a~DocumentDate , a~CompanyCode
     where a~AccountingDocument = @LV_BELNR2   "'1900000000'
      and   a~CompanyCode = @lv_companycode
     INTO @DATA(wa)
     privileged access.


*********************************   COMPANY ADDRESS
    Select single from I_OPERATIONALACCTGDOCITEM as a
    fields CompanyCode, AccountingDocument, FiscalYear, BusinessPlace
     WHERE     a~CompanyCode = @lv_companycode
               AND a~AccountingDocument = @lv_belnr2
               and a~FINANCIALACCOUNTTYPE = 'S'
*               and a~BusinessPlace is not INITIAL
        into @data(Cmpny_data).


        SELECT single from ztable_plant with PRIVILEGED ACCESS
            fields  address1, address2, city, state_name, pin, country , mob_no, email, remark2, remark3,
                    gstin_no, pan_no, cin_no, fssai_no
*          WHERE    comp_code = @lv_Companycode
               where plant_code = @cmpny_data-BusinessPlace
           into @Data(Cmpny_Address).

*********************************   PLANT CODE/ PLANT NAME
     SELECT single from ztable_plant with PRIVILEGED ACCESS
     fields  plant_code, plant_name1, plant_name2
         WHERE comp_code = @lv_companycode
      into @Data(Plant_Data).

******************************** VARIABLES
    DATA : cmpny_adress1 TYPE string.
    CONCATENATE Cmpny_Address-address1  Cmpny_Address-address2
                 INTO cmpny_adress1 SEPARATED BY ' '.

    DATA : cmpny_adress2 TYPE string.
    CONCATENATE Cmpny_Address-city  Cmpny_Address-state_name  Cmpny_Address-pin  Cmpny_Address-country
                 INTO cmpny_adress2 SEPARATED BY ' '.

     DATA : Plant_adress TYPE string.
    CONCATENATE Plant_Data-plant_code  Plant_Data-plant_name1  Plant_Data-plant_name2
                 INTO Plant_adress SEPARATED BY ' '.





******************************* LINE ITEM *****************************
DATA: lt_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

*************** SUPPLIER & CUSTOMER
SELECT
    a~AccountingDocument,
    a~GLAccount,
    a~AbsoluteAmountInCoCodeCrcy,
    a~DebitCreditCode,
    a~DocumentItemText,
    b~SupplierName,
    c~CustomerName
FROM i_operationalacctgdocitem AS a
LEFT JOIN i_supplier AS b ON a~Supplier = b~Supplier
LEFT JOIN i_customer AS c ON a~Customer = c~Customer
where a~AccountingDocument = @LV_BELNR2   "'1900000000'
    and   a~CompanyCode = @lv_companycode
    and DebitCreditCode IN ( 'S', 'H' )
INTO CORRESPONDING FIELDS OF TABLE @lt_final
privileged access.



***************** GLAccountLongName AND OTHER CONDITIONS.
LOOP AT lt_final INTO DATA(WA_TEST).

IF WA_TEST-suppliername IS INITIAL AND WA_TEST-customername IS INITIAL.
    SELECT single
        a~GLAccount,
           b~GLAccountLongName
    FROM i_operationalacctgdocitem AS a
    LEFT JOIN I_GLAccountTextRawData AS b ON a~GLAccount = b~GLAccount
    where a~AccountingDocument = @LV_BELNR2   "'1900000000'
     and   a~CompanyCode = @lv_companycode
      AND a~DebitCreditCode = @wa_test-DebitCreditCode
    INTO (@wa_test-GLAccount , @wa_test-GLAccountLongName).
ENDIF.


**************************** DEBIT / DebitRemarks / CREDIT / CreditRemarks
       IF wa_test-DebitCreditCode = 'S'.
         WA_TEST-DEBIT = wa_test-absoluteamountincocodecrcy.
         WA_TEST-REMARKS = wa_test-documentitemtext.
       elseif wa_test-debitcreditcode = 'H'.
         WA_TEST-CREDIT = wa_test-absoluteamountincocodecrcy.
         WA_TEST-REMARKS = wa_test-documentitemtext.
      ENDIF.


IF WA_TEST-suppliername IS NOT INITIAL .
        wa_test-accountname = wa_test-suppliername.
elseif WA_TEST-customername IS NOT INITIAL .
        wa_test-accountname = wa_test-customername.
elseif WA_TEST-glaccountlongname IS NOT INITIAL.
        wa_test-accountname = wa_test-glaccountlongname.
endif.


MODIFY lt_final from wa_test.
clear: wa_test.

ENDLOOP.


************* VARIABLES
         DATA:  CompanyAddress1 TYPE String.
         DATA:  CompanyAddress2 TYPE String.

    CONCATENATE: wa-HouseNumber wa-StreetName INTO CompanyAddress1 SEPARATED BY space.
    CONCATENATE: wa-CityName '-' wa-StreetName wa-PostalCode wa-Region wa-Country INTO CompanyAddress2 SEPARATED BY space.


* Header
    DATA(lv_xml) =    |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
                      |<CompanyName>{ wa-CompanyCodeName }</CompanyName>| &&
                      |<CompanyCode>{ wa-CompanyCode }</CompanyCode>| &&
                        |<CompanyAdress1>{ cmpny_adress1 }</CompanyAdress1>| &&
                        |<CompanyAdress2>{ cmpny_adress2 }</CompanyAdress2>| &&
                         |<GstNo>{ Cmpny_Address-gstin_no }</GstNo>| &&
                         |<PanNo>{ Cmpny_Address-pan_no }</PanNo>| &&
                         |<CinNo>{ Cmpny_Address-cin_no }</CinNo>| &&
                         |<FssaiNo>{ cmpny_address-fssai_no }</FssaiNo>| &&
                        |<PlantAdress>{ Plant_adress }</PlantAdress>| &&
                        |<PhoneNo>{ Cmpny_Address-mob_no }</PhoneNo>| &&
                        |<EmailId>{ Cmpny_Address-email }</EmailId>| &&
*                      |<CompanyAddress1>{ CompanyAddress1 }</CompanyAddress1>| &&
*                      |<CompanyAddress2>{ CompanyAddress2 }</CompanyAddress2>| &&
                      |<DocumentNumber>{ wa-AccountingDocument }</DocumentNumber>| &&
                      |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
                      |<DueDate>{ wa-NetDueDate }</DueDate>| &&
*                      |<TransactionCode>{ wa-CustomerName }</TransactionCode>| &&
                      |<DocumentDate>{ wa-DocumentDate }</DocumentDate>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.


* Item
    LOOP AT lt_final INTO DATA(wa_lines).

      DATA(lv_xml1) = |<tableDataRows>| &&
*                   |<AccountCode>{ wa_lines-AccountName }</AccountCode>| &&
*                   |<AccountNameDate>{ wa_lines-glaccount }</AccountNameDate>| &&
                    |<AccountCode>{ wa_lines-glaccount }</AccountCode>| &&
                   |<AccountNameDate>{ wa_lines-AccountName }</AccountNameDate>| &&
*                   |<Project>{  }</Project>| &&
                   |<Debit>{ wa_lines-DEBIT }</Debit>| &&
                   |<Credit>{ wa_lines-CREDIT }</Credit>| &&
                   |<Remarks>{ wa_lines-REMARKS }</Remarks>| &&
                   |</tableDataRows>| .

      CLEAR : wa_lines.
      CONCATENATE: lv_xml lv_xml1 INTO lv_xml.
    ENDLOOP.

    DATA(lv_xml2) = |</Table>| &&
                    |</AccountingRow>| &&
                    |</Form>|.

    CONCATENATE: lv_xml lv_xml2 INTO lv_xml.

    REPLACE ALL OCCURRENCES OF '&' in lv_xml with 'and'.


    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
