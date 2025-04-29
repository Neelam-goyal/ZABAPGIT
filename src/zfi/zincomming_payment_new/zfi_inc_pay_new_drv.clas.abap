CLASS zfi_inc_pay_new_drv DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
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
        IMPORTING accounting_no     TYPE string
             Company_code type string
             acc_doctype type string

        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZFI_INCOMING_PAY/ZFI_INCOMING_PAY'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.


ENDCLASS.



CLASS ZFI_INC_PAY_NEW_DRV IMPLEMENTATION.


METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


   METHOD read_posts. "if_oo_adt_classrun~main.

    TYPES : BEGIN OF ty_material,
              accountingdocument(10)         TYPE c,
              debitamountintranscrcy         TYPE i_accountingdocumentjournal-debitamountintranscrcy,
              clearingaccountingdocument(40) TYPE c,
              accountingdocumenttype(30)     TYPE c,
            END OF ty_material.

    TYPES : BEGIN OF ty_temp,
              accountingdocument(10) TYPE c,
              debitamountintranscrcy TYPE i_accountingdocumentjournal-debitamountintranscrcy,
            END OF ty_temp.

    DATA : it_temp TYPE TABLE OF ty_temp.
    DATA: wa_temp TYPE ty_temp.

    DATA: wa_item TYPE  ty_material.
    DATA: item_it_temp TYPE TABLE OF ty_material.
    DATA: item_it TYPE TABLE OF  ty_material.


SELECT FROM i_accountingdocumentjournal AS a
    LEFT JOIN i_companycode AS b ON a~companycode = b~companycode
    LEFT JOIN i_address_2 AS c ON  b~addressid = c~addressid
    LEFT JOIN i_customer AS d ON a~customer = d~customer
    FIELDS a~companycode, a~accountingdocument , a~postingdate ,
*    a~housebank ,
     a~accountingdocumentheadertext,
    b~companycodename,
     c~housenumber , c~cityname , c~streetname , c~region , c~country, c~postalcode,
    d~customername , d~streetname AS customerstrname , d~postalcode AS customerpostalcode , d~cityname AS customercityname , d~country AS customercounrty , d~region AS customerregion
   WHERE a~ledger = '0L' AND a~fiscalyear = '2024' AND a~financialaccounttype = 'D' AND
    a~accountingdocument = @accounting_no  and  a~CompanyCode = @Company_code
*    and a~AccountingDocumentType = 'DZ'
    INTO TABLE @DATA(header_it).

"FOR BANK NAME
select single from i_accountingdocumentjournal as a
        left join I_HOUSEBANKBASIC as b on a~HouseBank = b~HouseBank AND A~FinancialAccountType = 'S' and a~GLAccountType = 'C'
    fields b~BankName
         WHERE "a~CompanyCode = @lv_Companycode
               a~Ledger = '0L'
               AND a~AccountingDocument = @accounting_no  AND a~CompanyCode = @Company_code
    into @data(Bank_Data) PRIVILEGED ACCESS.


*OUT->WRITE( Bank_Data ).


SELECT FROM i_accountingdocumentjournal AS a
      FIELDS a~clearingaccountingdocument , a~accountingdocumenttype  , a~accountingdocument , a~debitamountintranscrcy
      WHERE   A~Ledger = '0L' and a~AccountingDocument = @accounting_no  AND  A~FiscalYear = '2024' AND a~CompanyCode = @Company_code
*      and a~AccountingDocumentType = 'DZ'
     INTO CORRESPONDING FIELDS OF TABLE @item_it .

SORT item_it BY accountingdocument ASCENDING .

   IF item_it IS NOT INITIAL.

      LOOP AT item_it INTO wa_item.
        wa_temp-accountingdocument = wa_item-accountingdocument.
        wa_temp-debitamountintranscrcy = wa_item-debitamountintranscrcy.
        COLLECT wa_temp INTO it_temp.
        ENDLOOP.

    ENDIF.
* out->write(  it_temp  ).





   READ TABLE it_temp  INTO data(wa_item1) index 1  .
    READ TABLE header_it INTO DATA(wa_header) INDEX 1.




    DATA : lv_xml TYPE string.
    lv_xml = |<Form>| &&
      |<COMPANYNAME>{ wa_header-companycodename }</COMPANYNAME>| &&
       |<COMPANYCODE>{ wa_header-CompanyCode }</COMPANYCODE>| &&
      |<HOUSENUMBER>{  wa_header-housenumber }</HOUSENUMBER>| &&
      |<STREETNAME>{  wa_header-streetname }</STREETNAME>| &&
      |<CITYNAME>{ wa_header-cityname }</CITYNAME>| &&
      |<POSTALCODE>{ wa_header-postalcode }</POSTALCODE> | &&
      |<REGION>{ wa_header-region }</REGION> | &&
      |<COUNTRY>{  wa_header-country }</COUNTRY> | &&
      |<ACCOUNTINGNUMBER>{  wa_header-accountingdocument }</ACCOUNTINGNUMBER>| &&
      |<POSTINGDATE>{  wa_header-postingdate }</POSTINGDATE>| &&
      |<CSTREETNAME>{  wa_header-customerstrname }</CSTREETNAME>| &&
      |<CNAME>{  wa_header-CustomerName }</CNAME>| &&
      |<CPOSTALCODE>{  wa_header-customerpostalcode }</CPOSTALCODE>| &&
      |<CCITYNAME>{  wa_header-customercityname }</CCITYNAME>| &&
      |<CREGION>{  wa_header-customerregion }</CREGION>| &&
      |<CCOUNTRY>{  wa_header-customercounrty }</CCOUNTRY>| &&
     |<BANKNAME>{  Bank_Data }</BANKNAME>| &&
      |<Footer_Date>{  wa_header-postingdate }</Footer_Date>| &&
      |<REFERENCE>{  wa_header-accountingdocumentheadertext }</REFERENCE>| &&
      |<totalBill>{ wA_item1-debitamountintranscrcy }</totalBill>| &&
      |</Form>| .


 CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
