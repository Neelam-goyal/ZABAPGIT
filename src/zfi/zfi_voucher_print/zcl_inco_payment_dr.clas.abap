CLASS zcl_inco_payment_dr DEFINITION
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
        IMPORTING accounting_no     TYPE string
             Company_code type string
*             acc_doctype type string

        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZFI_INCOMING_PAY/ZFI_INCOMING_PAY'."'zpo/zpo_v2'."


ENDCLASS.



CLASS ZCL_INCO_PAYMENT_DR IMPLEMENTATION.


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

***Header Table
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
   WHERE a~ledger = '0L' AND a~fiscalyear = '2025' AND a~financialaccounttype = 'D' AND
    a~accountingdocument = @accounting_no
*     and a~AccountingDocumentType = @acc_doctype
   and  a~CompanyCode = @Company_code
    INTO TABLE @DATA(header_it)
    privileged access.


*********************************   COMPANY ADDRESS
    Select single from I_OPERATIONALACCTGDOCITEM as a
    fields CompanyCode, AccountingDocument, FiscalYear, BusinessPlace,  a~PostingDate, a~DocumentDate
     WHERE     a~CompanyCode = @Company_code   "@lv_header-CompanyCode
*               AND a~Ledger = '0L'
*               and a~FiscalYear = @lv_fiscalyear
               AND a~AccountingDocument = @accounting_no
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
         WHERE comp_code = @Company_code
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



*FOR BANK NAME
*select from i_accountingdocumentjournal as a
*fields a~HouseBank , a~FinancialAccountType
*where a~FinancialAccountType = 'S'  and a~fiscalyear = '2024' and a~ledger = '0L' and a~accountingdocument = @accounting_no
**  and a~AccountingDocumentType = @acc_doctype
*and a~CompanyCode = @Company_code
* into table @data(it_bank).

    select SINGLE from i_accountingdocumentjournal as a
        INNER join I_HOUSEBANKBASIC as b on a~HouseBank = b~HouseBank AND A~FinancialAccountType = 'S' and a~GLAccountType = 'C'
    fields b~BankName ", B~BankInternalID, B~CompanyCode, B~HouseBank
         WHERE a~CompanyCode = @Company_code   "@lv_header-CompanyCode
               AND a~Ledger = '0L'
               AND a~AccountingDocument = @accounting_no   "@lv_header-AccountingDocument "
    into @data(Bank_Data) PRIVILEGED ACCESS.



SELECT FROM i_accountingdocumentjournal AS a
      FIELDS a~clearingaccountingdocument , a~accountingdocumenttype  , a~accountingdocument , a~debitamountintranscrcy
      WHERE   A~Ledger = '0L' and a~AccountingDocument = @accounting_no
*        and a~AccountingDocumentType = @acc_doctype
     and a~CompanyCode = @Company_code
       AND  A~FiscalYear = '2025'
     INTO CORRESPONDING FIELDS OF TABLE @item_it
     privileged access.


   IF item_it IS NOT INITIAL.
*
      LOOP AT item_it INTO wa_item.
        wa_temp-accountingdocument = wa_item-accountingdocument.
        wa_temp-debitamountintranscrcy = wa_item-debitamountintranscrcy.
        COLLECT wa_temp INTO it_temp.
        ENDLOOP.

    ENDIF.

   READ TABLE it_temp  INTO wa_item WITH KEY accountingdocument = wa_item-accountingdocument .
    READ TABLE header_it INTO DATA(wa_header) INDEX 1.
*     READ TABLE it_bank INTO DATA(wa_bank) INDEX 1.
    DATA : lv_xml TYPE string.
    lv_xml = |<Form>| &&
      |<COMPANYNAME>{ wa_header-companycodename }</COMPANYNAME>| &&
       |<COMPANYCODE>{ wa_header-CompanyCode }</COMPANYCODE>| &&
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
*      |<HOUSENUMBER>{  wa_header-housenumber }</HOUSENUMBER>| &&
*      |<STREETNAME>{  wa_header-streetname }</STREETNAME>| &&
*      |<CITYNAME>{ wa_header-cityname }</CITYNAME>| &&
*      |<POSTALCODE>{ wa_header-postalcode }</POSTALCODE> | &&
*      |<REGION>{ wa_header-region }</REGION> | &&
*      |<COUNTRY>{  wa_header-country }</COUNTRY> | &&
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
      |<totalBill>{ wA_item-debitamountintranscrcy }</totalBill>| &&
      |</Form>| .


REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and' .


 CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
