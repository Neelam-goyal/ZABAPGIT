
CLASS zap_invoice_class DEFINITION
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
    CONSTANTS lc_template_name TYPE string VALUE 'zap_invoice/zap_invoice'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS zap_invoice_class IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .


    TYPES : BEGIN OF ty_main,
              desc                       TYPE i_glaccounttextrawdata-glaccountname,
              sac_code                   TYPE i_operationalacctgdocitem-in_hsnorsaccode,
              taxable_value              TYPE i_operationalacctgdocitem-amountincompanycodecurrency,
              discunt                    TYPE c LENGTH 20,
              igst_rate_percent          TYPE c LENGTH 20,
              sgst_rate_percent          TYPE c LENGTH 20,
              cgst_rate_percent          TYPE c LENGTH 20,
              igst_rate_amount           TYPE c LENGTH 20,
              sgst_rate_amount           TYPE c LENGTH 20,
              cgst_rate_amount           TYPE c LENGTH 20,
              total_amount               TYPE c LENGTH 20,
              remarks                    TYPE i_operationalacctgdocitem-DocumentItemText,
              rounding                   TYPE i_operationalacctgdocitem-amountincompanycodecurrency,
              amount                     TYPE i_operationalacctgdocitem-amountincompanycodecurrency,
              accountingdocumentitemtype TYPE i_operationalacctgdocitem-accountingdocumentitemtype,
              Amount_in_words            TYPE c LENGTH 20,
              payment_terms              TYPE c LENGTH 20,
              total_gst                  TYPE c LENGTH 20,
              total_tax_before_tex       TYPE c LENGTH 20,
              total_amount_footer        TYPE c LENGTH 20,
              srno                       TYPE i,
              CompanyCode                TYPE i_operationalacctgdocitem-CompanyCode,
              FiscalYear                 TYPE i_operationalacctgdocitem-FiscalYear,
              AccountingDocument         TYPE i_operationalacctgdocitem-AccountingDocument,
              accountingdocumentitem     TYPE i_operationalacctgdocitem-accountingdocumentitem,
              taxcode                    TYPE i_operationalacctgdocitem-TaxCode,
              total_amt                  TYPE c LENGTH 15,

            END OF ty_main.

    DATA : roundingS             TYPE p DECIMALS 2.
*
*
    DATA : it_FINAL TYPE TABLE OF ty_MAIN,
           wa_FINAL TYPE ty_MAIN.


    DATA : total_gst1            TYPE c LENGTH 20,
           total_tax_before_tex1 TYPE c LENGTH 20,
           total_amount_footer1  TYPE c LENGTH 20,
           total_cgst            TYPE c LENGTH 20,
           total_sgst            TYPE c LENGTH 20,
           total_igst            TYPE c LENGTH 20,
           grand_total_amt       TYPE c LENGTH 15,
           prev_srno             TYPE i VALUE 0.






    SELECT SINGLE FROM i_operationalacctgdocitem AS a
                            LEFT JOIN i_companycode AS b ON a~CompanyCode = b~CompanyCode
                            LEFT JOIN i_plant AS c ON c~plant = a~businessplace
                            LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
*                            LEFT JOIN i_accountingdocumentjournal AS f ON
*                            f~CompanyCode = b~companycode and f~AccountingDocument = b~AccountingDocument and f~FiscalYear = b~FiscalYear
                            LEFT JOIN I_Supplier AS g ON g~Supplier = a~Supplier
                            LEFT JOIN i_regiontext AS e ON e~region = g~region AND e~Country = g~Country AND e~Language = 'E'
*                            left join i_region as rg on g~Region = rg~region
                            LEFT JOIN i_kr_businessplace AS h ON h~BusinessPlaceName = a~BusinessPlace
                            LEFT JOIN ztable_plant AS i ON a~BusinessPlace = i~plant_code
      FIELDS b~CompanyCodeName ,
             a~AccountingDocument , a~documentdate , a~PostingDate  AS delivery_date ,
             a~CompanyCode, a~documentdate AS document_date,
             c~plantname AS plant_name_bill_to,
             d~region AS state_code , d~HouseNumber , d~floor , d~DistrictName ,d~CityName,
             d~PostalCode , d~Region ,d~Country ,
             h~taxnumber1 AS gst_no_bill_to,
             e~regionname AS states, e~regionname AS place_of_supply ,
*             f~documentreferenceid AS vendor_reff_no ,
*             g~SupplierName , g~StreetName , g~CityName AS city_name_supp ,
*             g~PostalCode AS postal_code_supp ,
*             g~Country AS country_supp,
*             g~REGion AS state_code_supp, g~taxnumber3 AS gst_no_supp,
            i~comp_code, i~plant_name1 ,i~address1, i~address2, i~address3 ,
            i~city,  i~district, i~state_code1 , i~state_name ,  i~pin , i~country AS countrys,
            i~cin_no , i~gstin_no ,i~pan_no ,i~email ,i~mob_no ,i~fssai_no

      WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND a~FiscalYear = @lv_fiscalyear
      AND a~financialaccounttype = 'K'
      INTO @DATA(lv_header) .



    DATA : PLANT_adress TYPE string.
    CONCATENATE lv_header-address2
             lv_header-address1
             ', '
             lv_header-address3
             ', '
             lv_header-city
             ', '
             lv_header-district
             ',   '
             lv_header-state_name
             ', '
             lv_header-countrys
             '-'
             lv_header-pin
        INTO plant_adress.





**********************************************************************BILL TO ADDRESS ON 17/04/2025

    SELECT SINGLE FROM I_CompanyCode AS a
    LEFT JOIN i_operationalacctgdocitem AS b ON a~CompanyCode = b~CompanyCode
    LEFT JOIN ztable_plant AS tp ON b~BusinessPlace = tp~plant_code
    LEFT JOIN i_plant AS c ON c~plant = b~businessplace
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~region = d~region
    LEFT JOIN i_kr_businessplace AS h ON h~BusinessPlaceName = b~BusinessPlace
    FIELDS d~HouseNumber , d~CityName , d~Floor , d~DistrictName , d~PostalCode , d~Region , d~Country , e~RegionName , h~taxnumber1,
           tp~plant_name1, tp~state_code1, tp~address1, tp~address2, tp~city, tp~district, tp~pin, tp~country AS plant_county, tp~state_name ,
           tp~gstin_no
    WHERE b~CompanyCode = @lv_Companycode AND b~AccountingDocument = @lv_Accountingdocument AND b~FiscalYear = @lv_fiscalyear
                                          AND b~financialaccounttype = 'K'
    INTO @DATA(lv_biLLtoaddr) .


    DATA : bill_adress TYPE string.
*    CONCATENATE lv_biLLtoaddr-HouseNumber  lv_biLLtoaddr-Floor lv_biLLtoaddr-DistrictName
*               lv_biLLtoaddr-cityname lv_biLLtoaddr-postalcode
*                lv_biLLtoaddr-Region lv_biLLtoaddr-Country
*                INTO bill_adress.
    CONCATENATE lv_biLLtoaddr-address1 ', ' lv_biLLtoaddr-address2 ', ' lv_biLLtoaddr-district  lv_biLLtoaddr-city ', '
    lv_billtoaddr-state_name ', '
          lv_biLLtoaddr-plant_county '-'  lv_biLLtoaddr-pin
           INTO bill_adress.

**********************************************************************BILL TO ADDRESS ON 17/04/2025 END

**********************************************************************SUPPLIER ADDRESS ON 17/04/2025

    SELECT SINGLE FROM I_CompanyCode AS a
    LEFT JOIN i_operationalacctgdocitem AS b ON a~CompanyCode = b~CompanyCode
    LEFT JOIN I_Supplier AS g ON g~Supplier = b~Supplier
    LEFT JOIN I_RegionText AS h ON g~Region = h~Region AND g~Country = h~Country AND h~Language = 'E'
    FIELDS g~SupplierName , g~StreetName , g~CityName AS city_name_supp ,
                 g~PostalCode AS postal_code_supp ,
                 g~Country AS country_supp,
                 g~REGion AS state_code_supp, g~taxnumber3 AS gst_no_supp,
                 h~RegionName
    WHERE b~CompanyCode = @lv_Companycode AND b~AccountingDocument = @lv_Accountingdocument AND b~financialaccounttype = 'K'
    INTO @DATA(lv_SUPPLADDR) .

    DATA : SUPPLIER_adress TYPE string.
    CONCATENATE lv_SUPPLADDR-StreetName ','  lv_SUPPLADDR-city_name_supp ','
                lv_SUPPLADDR-RegionName ',' lv_SUPPLADDR-country_supp '-' lv_SUPPLADDR-postal_code_supp
                    INTO SUPPLIER_adress SEPARATED BY space.

    DATA : st_cd_supp TYPE c LENGTH 2.
    st_cd_supp = lv_suppladdr-gst_no_supp+0(2).

**********************************************************************SUPPLIER ADDRESS ON 17/04/2025 END

**********************************************************************Vendor Ref No

    SELECT SINGLE FROM i_accountingdocumentjournal AS a
    FIELDS a~documentreferenceid , a~AccountingDocument
    WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND a~FiscalYear = @lv_fiscalyear AND a~financialaccounttype = 'K' AND a~Ledger IN ('0L'  , '0l' )
    INTO @DATA(wa_vendorrefno).

**********************************************************************Vendor Ref No END

    SELECT FROM i_operationalacctgdocitem AS a
    LEFT JOIN i_glaccounttextrawdata AS b ON a~glaccount = b~GLAccount
    FIELDS a~accountingdocumentitemtype , a~CompanyCode , a~AccountingDocument, a~FiscalYear ,
    a~in_hsnorsaccode AS sac_code, a~amountincompanycodecurrency AS taxable_value,
    a~DocumentItemText AS remarks, a~amountincompanycodecurrency AS amount,
    a~accountingdocumentitem, a~taxcode,
     b~glaccountname AS desc
    WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
         a~FiscalYear = @lv_fiscalyear AND
          accountingdocumentitemtype <> 'T' AND
          a~costelement IS NOT INITIAL AND
          a~amountincompanycodecurrency > 1
    INTO TABLE @DATA(it_item).


    SELECT FROM i_operationalacctgdocitem AS a
  FIELDS  a~amountincompanycodecurrency AS rounding, a~CompanyCode, a~accountingdocumentitemtype,
  a~debitcreditcode ,
   a~AccountingDocument , a~FiscalYear
      WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
         a~FiscalYear = @lv_fiscalyear AND a~amountincompanycodecurrency < 1
      AND accountingdocumentitemtype <> 'T' AND debitcreditcode = 'S'
         INTO @DATA(roundingoff).
    ENDSELECT.

    SELECT SINGLE FROM i_operationalacctgdocitem AS a
    LEFT JOIN i_paymenttermstext AS b ON a~PaymentTerms = b~PaymentTerms
    FIELDS  a~financialaccounttype , a~CompanyCode ,
   a~AccountingDocument , a~FiscalYear , a~DocumentItemText , a~PaymentTerms  , b~PaymentTermsName
   WHERE a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
   a~FiscalYear = @lv_fiscalyear AND a~financialaccounttype = 'K'
   INTO @DATA(lv_payment_term).




    SELECT FROM i_operationalacctgdoctaxitem AS a
     LEFT JOIN i_operationalacctgdocitem AS b ON a~TaxCode = b~taxcode
    FIELDS a~TaxAmountInCoCodeCrcy , a~CompanyCode ,a~AccountingDocument ,a~FiscalYear,
    a~transactiontypedetermination ,accountingdocumentitem ,a~taxcode
    FOR ALL ENTRIES IN @it_item
    WHERE a~taxcode = @it_item-taxcode AND
    a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
    a~FiscalYear = @lv_fiscalyear
     AND a~transactiontypedetermination  IN ( 'JII' )
    INTO TABLE @DATA(it_gst).

    SORT it_gst BY taxcode.
    DELETE ADJACENT DUPLICATES FROM it_gst COMPARING taxcode.

    SELECT FROM i_operationalacctgdoctaxitem AS a
      LEFT JOIN i_operationalacctgdocitem AS b ON a~TaxCode = b~taxcode
     FIELDS a~TaxAmountInCoCodeCrcy , a~CompanyCode ,a~AccountingDocument ,a~FiscalYear,
     a~transactiontypedetermination ,accountingdocumentitem ,a~taxcode
      FOR ALL ENTRIES IN @it_item
    WHERE a~taxcode = @it_item-taxcode AND
     a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
     a~FiscalYear = @lv_fiscalyear
      AND a~transactiontypedetermination  IN ( 'JIC' )
     INTO TABLE @DATA(it_gst1).

    SORT it_gst1 BY taxcode.
    DELETE ADJACENT DUPLICATES FROM it_gst1 COMPARING taxcode.

    SELECT FROM i_operationalacctgdoctaxitem AS a
      LEFT JOIN i_operationalacctgdocitem AS b ON a~TaxCode = b~taxcode
     FIELDS a~TaxAmountInCoCodeCrcy , a~CompanyCode ,a~AccountingDocument ,a~FiscalYear,
     a~transactiontypedetermination ,accountingdocumentitem ,a~taxcode
      FOR ALL ENTRIES IN @it_item
    WHERE a~taxcode = @it_item-taxcode AND
    a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
     a~FiscalYear = @lv_fiscalyear
      AND a~transactiontypedetermination  IN ( 'JIS' )
     INTO TABLE @DATA(it_gst2).

    SORT it_gst2 BY taxcode.
    DELETE ADJACENT DUPLICATES FROM it_gst2 COMPARING taxcode.

    LOOP AT it_item INTO DATA(wa_ITEM).

      wa_final-CompanyCode     = wa_item-CompanyCode.
      wa_final-FiscalYear      = wa_item-FiscalYear.
      wa_final-AccountingDocument  = wa_item-AccountingDocument.
      wa_final-desc            = wa_item-desc.
      wa_final-sac_code        = wa_item-sac_code.
      wa_final-taxable_value   = wa_item-taxable_value.
*      wa_final-payment_terms   = payment_term.
*      wa_final-remarks         = wa_item-remarks.


      LOOP AT it_gst1 INTO DATA(wa_gst1) WHERE CompanyCode = wa_item-companycode AND AccountingDocument
      = wa_item-AccountingDocument AND taxcode  = wa_item-taxcode
       AND TransactionTypeDetermination = 'JIC'.
        wa_FINAL-cgst_rate_percent = wa_gst1-TaxAmountInCoCodeCrcy.
        CONDENSE  wa_FINAL-cgst_rate_percent .
        wa_final-cgst_rate_amount = ( wa_gst1-TaxAmountInCoCodeCrcy / wa_final-taxable_value ) * 100 .
        CONDENSE  wa_FINAL-cgst_rate_amount .
      ENDLOOP.
      CLEAR : wa_gst1.


      LOOP AT it_gst INTO DATA(wa_gst) WHERE CompanyCode = wa_item-companycode AND AccountingDocument
        = wa_item-AccountingDocument AND taxcode  = wa_item-taxcode
         AND TransactionTypeDetermination = 'JII'.
        wa_FINAL-igst_rate_percent = wa_gst-TaxAmountInCoCodeCrcy.
        CONDENSE  wa_FINAL-igst_rate_percent .
        wa_final-igst_rate_amount = ( wa_gst-TaxAmountInCoCodeCrcy / wa_final-taxable_value ) * 100 .
        CONDENSE  wa_FINAL-igst_rate_amount.
      ENDLOOP.
      CLEAR : wa_gst.

      LOOP AT it_gst2 INTO DATA(wa_gst2) WHERE CompanyCode = wa_item-companycode AND AccountingDocument
           = wa_item-AccountingDocument AND taxcode  = wa_item-taxcode
            AND TransactionTypeDetermination = 'JIS'.
        wa_FINAL-sgst_rate_percent = wa_gst2-TaxAmountInCoCodeCrcy.
        CONDENSE  wa_FINAL-sgst_rate_percent .
        wa_final-sgst_rate_amount = ( wa_gst2-TaxAmountInCoCodeCrcy / wa_final-taxable_value ) * 100 .
        CONDENSE  wa_FINAL-sgst_rate_amount .
      ENDLOOP.
      CLEAR : wa_gst2.



      wa_final-total_amt   = wa_FINAL-cgst_rate_percent + wa_FINAL-sgst_rate_percent +
                   wa_FINAL-igst_rate_percent + wa_final-taxable_value.
      CONDENSE wa_final-total_amt .

      total_tax_before_tex1 +=  wa_final-total_amt.
      CONDENSE total_tax_before_tex1 .

      total_gst1 +=  wa_FINAL-cgst_rate_percent +  wa_FINAL-sgst_rate_percent +  wa_FINAL-igst_rate_percent.
      CONDENSE total_gst1.

      total_sgst  +=   wa_FINAL-sgst_rate_percent.
      CONDENSE total_sgst .

      total_cgst  +=  wa_FINAL-cgst_rate_percent.
      CONDENSE total_cgst .

      total_igst +=  wa_FINAL-igst_rate_percent.
      CONDENSE total_igst.

      grand_total_amt = total_gst1 + roundingoff-rounding + total_tax_before_tex1.
      CONDENSE grand_total_amt .

      wa_FINAL-srno = prev_srno + 1.
      prev_srno =  wa_FINAL-srno.


      APPEND wa_FINAL TO it_FINAL.
      CLEAR: wa_item, wa_FINAL .
    ENDLOOP.

    SELECT companycode , fiscalyear ,
    accountingdocument , amountincompanycodecurrency ,transactiontypedetermination
    FROM I_OperationalAcctgDocItem AS a
    WHERE a~TransactionTypeDetermination = 'WIT'  AND
    a~CompanyCode = @lv_Companycode AND a~AccountingDocument = @lv_Accountingdocument AND
     a~FiscalYear = @lv_fiscalyear
    INTO @DATA(tds).
    ENDSELECT.




*
    DATA(lv_xml) = |<Form>| &&
                    |<Header>| &&
                    |<CompanyCode>{ lv_header-CompanyCode }</CompanyCode>| &&
                    |<CompanyCodeName>{ lv_header-CompanyCodeName }</CompanyCodeName>| &&
                    |<CompanyAdress>{ PLANT_adress }</CompanyAdress>| &&
                    |<Email>{ lv_header-email }</Email>| &&
                    |<Phone>{ lv_header-mob_no }</Phone>| &&
                    |<Pan_no>{ lv_header-pan_no }</Pan_no>| &&
                    |<gstin>{ lv_header-gstin_no }</gstin>| &&
                    |<Cin>{ lv_header-cin_no }</Cin>| &&
                    |<fssai_no>{ lv_header-fssai_no }</fssai_no>| &&
                    |<InvoiceNumber>{ lv_header-AccountingDocument }</InvoiceNumber>| &&
                    |<InvoiceDate>{ lv_header-documentdate }</InvoiceDate>| &&
                    |<State>{ lv_header-state_name }</State>| &&
                    |<Statecode>{ lv_header-state_code1 }</Statecode>| &&
                    |<place_of_supplay>{ lv_header-place_of_supply }</place_of_supplay>| &&
                    |<Delivery_date>{ lv_header-delivery_date }</Delivery_date>| &&
                    |<document_date>{ lv_header-document_date }</document_date>| &&
                    |<Vendor_Ref_No>{ wa_vendorrefno-DocumentReferenceID }</Vendor_Ref_No>| &&
                    |<VendorName>{ lv_suppladdr-SupplierName }</VendorName>| &&
                    |<SUPPLIER_adress>{ SUPPLIER_adress }</SUPPLIER_adress>| &&
                    |<Regionname_supp>{ lv_header-state_code1 }</Regionname_supp>| &&
                    |<state_code_supp>{ st_cd_supp }</state_code_supp>| &&
                    |<state_name>{ lv_suppladdr-RegionName }</state_name>| &&
                    |<GST_NO_SUPP>{  lv_suppladdr-gst_no_supp } </GST_NO_SUPP>| &&
                    |<plantnbame_bill_to>{ lv_header-plant_name_bill_to }</plantnbame_bill_to>| &&
                    |<VendorAdress>{ bill_adress }</VendorAdress>| &&
                    |<state_bill>{ lv_biLLtoaddr-state_name }</state_bill>| &&
                    |<state_code_bill>{ lv_biLLtoaddr-state_code1 }</state_code_bill>| &&
                    |<gst_no_bill>{ lv_biLLtoaddr-gstin_no }</gst_no_bill>| &&
                    |<Rounding>{ roundingoff-rounding }</Rounding>| &&
                    |<tds>{ tds-AmountInCompanyCodeCurrency }</tds>| &&
                    |<Remarks>{  lv_payment_term-DocumentItemText }</Remarks>| &&
                    |<payment_term>{  lv_payment_term-PaymentTermsName }</payment_term>| &&
                    |</Header>| &&
                    |<Item>|.


    LOOP AT it_FINAL INTO wa_FINAL.
      DATA(lv_xml2) =  |<Line_Item>| &&
       |<SRNO>{  wa_FINAL-srno }</SRNO>| &&
       |<Description>{  wa_FINAL-desc }</Description>| &&
       |<SAC_CODE>{  wa_FINAL-sac_code }</SAC_CODE>| &&
       |<taxable_value>{  wa_FINAL-taxable_value }</taxable_value>| &&
       |<igst_rate>{  wa_FINAL-igst_rate_percent }</igst_rate>| &&
       |<IGST_AMT>{  wa_FINAL-igst_rate_amount }</IGST_AMT>| &&
       |<Cgst_rate>{  wa_FINAL-cgst_rate_percent }</Cgst_rate>| &&
       |<CGST_AMT>{ wa_FINAL-cgst_rate_amount }</CGST_AMT>| &&
       |<Sgst_rate>{  wa_FINAL-sgst_rate_percent }</Sgst_rate>| &&
       |<SGST_AMT>{  wa_FINAL-sgst_rate_amount }</SGST_AMT>| &&
       |<Total_amt>{   wa_final-total_amt }</Total_amt>| &&
       |<COMPANY>{  wa_FINAL-companycode }</COMPANY>| &&
       |<YEAR>{  wa_FINAL-fiscalyear }</YEAR>| &&
       |<DOCUMENT>{ wa_FINAL-AccountingDocument }</DOCUMENT>| &&
       |<Total_tax_before_tex1>{ total_tax_before_tex1 }</Total_tax_before_tex1>| &&
       |<total_igst>{ total_igst }</total_igst>| &&
       |<total_cgst>{ total_cgst }</total_cgst>| &&
       |<total_sgst>{ total_sgst }</total_sgst>| &&
       |<total_gst1>{ total_gst1 }</total_gst1>| &&
       |<grand_total_amt>{ grand_total_amt }</grand_total_amt>| .



      CONCATENATE lv_xml  lv_xml2  '</Line_Item>' INTO lv_xml.

    ENDLOOP.



    CONCATENATE lv_xml '</Item>' '</Form>' INTO lv_xml.


    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.
    REPLACE ALL OCCURRENCES OF ',,' IN lv_xml WITH ','.
    REPLACE ALL OCCURRENCES OF ',,,' IN lv_xml WITH space.

    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
