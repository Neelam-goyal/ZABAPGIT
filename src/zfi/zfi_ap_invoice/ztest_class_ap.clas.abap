CLASS ztest_class_ap DEFINITION
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


*    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,
*
*      read_posts
*        IMPORTING
*                  lv_Accountingdocument TYPE string
*                  lv_fiscalyear         TYPE string
*                  lv_Companycode        TYPE string
*        RETURNING VALUE(result12)       TYPE string
*        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_outg_pay_voucher/zfi_outg_pay_voucher'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZTEST_CLASS_AP IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TYPES : BEGIN OF ty_main,
              desc                TYPE i_glaccounttextrawdata-glaccountname,
              sac_code            TYPE i_operationalacctgdocitem-in_hsnorsaccode,
              taxable_value       TYPE i_operationalacctgdocitem-amountincompanycodecurrency,
              discunt             TYPE c LENGTH 20,
              igst_rate_percent   TYPE c LENGTH 20,
              sgst_rate_percent   TYPE c LENGTH 20,
              cgst_rate_percent   TYPE c LENGTH 20,
              igst_rate_amount    TYPE c LENGTH 20,
              sgst_rate_amount    TYPE c LENGTH 20,
              cgst_rate_amount    TYPE c LENGTH 20,
              total_amount        TYPE c LENGTH 20,
              total_amount_footer TYPE c LENGTH 20,
              remarks             TYPE i_operationalacctgdocitem-DocumentItemText,
              rounding            TYPE i_operationalacctgdocitem-amountincompanycodecurrency,
              Amount_in_words     TYPE c LENGTH 20,
            END OF ty_main.
*
*
*
    DATA : it_final TYPE TABLE OF ty_MAIN.
    DATA : wa_final TYPE ty_MAIN.





    SELECT SINGLE FROM  i_companycode AS a LEFT JOIN i_operationalacctgdocitem AS b
                                     ON a~CompanyCode = b~CompanyCode
                            LEFT JOIN i_plant AS c ON c~plant = b~businessplace
                            LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
                            LEFT JOIN i_regiontext AS e ON e~region = d~region
                            LEFT JOIN i_accountingdocumentjournal AS f ON
                            f~CompanyCode = b~companycode
                            LEFT JOIN I_Supplier AS g ON g~Supplier = b~Supplier
                       LEFT JOIN i_kr_businessplace AS h ON h~BusinessPlaceName = b~BusinessPlace
      FIELDS a~CompanyCodeName , b~CompanyCode,
             b~AccountingDocument , b~documentdate , b~PostingDate  AS delivery_date ,
             c~plantname AS plant_name_bill_to ,
             d~region AS state_code , d~HouseNumber , d~floor , d~DistrictName ,d~CityName,
             d~PostalCode , d~Region ,d~Country ,
             h~taxnumber1 AS gst_no_bill_to,
             e~regionname AS states, e~regionname AS place_of_supply ,
             f~documentreferenceid AS vendor_reff_no , g~SupplierName ,

             g~StreetName , g~CityName AS city_name_supp , g~PostalCode AS postal_code_supp ,
             g~Country AS country_supp,
             g~REGion AS state_code_supp, g~taxnumber3 AS gst_no_supp

    "  WHERE b~CompanyCode = @lv_Companycode AND b~AccountingDocument = @lv_Accountingdocument
     WHERE f~financialaccounttype = 'K'
      INTO @DATA(lv_header) .

    DATA : SUPPLIER_adress TYPE string.
    CONCATENATE lv_header-StreetName lv_header-postal_code_supp  lv_header-city_name_supp
                 lv_header-country_supp lv_header-state_code_supp
                INTO SUPPLIER_adress.

    DATA : bill_adress TYPE string.
    CONCATENATE lv_header-HouseNumber  lv_header-Floor lv_header-DistrictName
               lv_header-cityname lv_header-postalcode
                lv_header-Region lv_header-Country
                INTO bill_adress.





    SELECT FROM i_operationalacctgdocitem AS a
    LEFT JOIN i_glaccounttextrawdata AS b ON a~glaccount = b~GLAccount
    FIELDS a~accountingdocumentitemtype , a~CompanyCode , a~AccountingDocument, a~FiscalYear ,
    a~in_hsnorsaccode AS sac_code, a~amountincompanycodecurrency AS taxable_value,
    a~DocumentItemText AS remarks, a~amountincompanycodecurrency AS amount,
     b~glaccountname AS desc
   " WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
      "   a~FiscalYear = @lv_fiscalyear and
     WHERE  accountingdocumentitemtype <> 'T'
*      AND
*        COSTELEMENT IS NOT INITIAL AND
       AND a~amountincompanycodecurrency > '1'
          AND a~financialaccounttype = 'K'
    INTO TABLE @DATA(it_item).


    SELECT FROM i_operationalacctgdocitem AS a
  FIELDS  a~amountincompanycodecurrency AS rounding, a~CompanyCode ,
   a~AccountingDocument , a~FiscalYear
     " WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
      "   a~FiscalYear = @lv_fiscalyear and
      WHERE a~amountincompanycodecurrency < '1'
         INTO @DATA(roundingoff).


      SELECT FROM i_operationalacctgdocitem AS a
      FIELDS a~amountincompanycodecurrency , a~CompanyCode ,a~AccountingDocument ,a~FiscalYear,
      a~transactiontypedetermination
      "WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
       "    a~FiscalYear = @lv_fiscalyear and ACCOUNTINGDOCUMENTITEMTYPE = 'T' and
        WHERE   a~transactiontypedetermination  IN ( 'JII','JIC','JIS' )
      INTO TABLE @DATA(it_gst).

    ENDSELECT.

  ENDMETHOD.
ENDCLASS.
