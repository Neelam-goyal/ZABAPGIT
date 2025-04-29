CLASS ztest_class_inc_pay DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS_INC_PAY IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
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
   WHERE a~ledger = '0L' AND a~fiscalyear = '2024' AND a~financialaccounttype = 'D' AND
    a~accountingdocument = '1400000008'  and  a~CompanyCode = 'BNAL'
*    and a~AccountingDocumentType = 'DZ'
    INTO TABLE @DATA(header_it).

"FOR BANK NAME
select single from i_accountingdocumentjournal as a
        left join I_HOUSEBANKBASIC as b on a~HouseBank = b~HouseBank AND A~FinancialAccountType = 'S' and a~GLAccountType = 'C'
    fields b~BankName
         WHERE "a~CompanyCode = @lv_Companycode
               a~Ledger = '0L'
               AND a~AccountingDocument = '1400000008'  AND a~CompanyCode = 'BNAL'
    into @data(Bank_Data) PRIVILEGED ACCESS.


OUT->WRITE( Bank_Data ).


SELECT FROM i_accountingdocumentjournal AS a
      FIELDS a~clearingaccountingdocument , a~accountingdocumenttype  , a~accountingdocument , a~debitamountintranscrcy
      WHERE   A~Ledger = '0L' and a~AccountingDocument = '1400000008'  AND  A~FiscalYear = '2024' AND a~CompanyCode = 'BNAL'
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
 out->write(  it_temp  ).





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

   out->write(  lv_xml  ).

*    CALL METHOD zcl_ads_print=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = 'zfi_voucher_print/zfi_voucher_print'.
*      RECEIVING
*        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
