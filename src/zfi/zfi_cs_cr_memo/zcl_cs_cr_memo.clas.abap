CLASS zcl_cs_cr_memo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.
      CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING supplier_invoice  TYPE string
                  Company_code    TYPE string
                  fiscal_year     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
   CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_cr_memo/zfi_cr_memo'."'zpo/zpo_v2'."
**    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



 CLASS zcl_cs_cr_memo IMPLEMENTATION.

  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .
    """""""""""""""""""""""""'header lebel""""""""""""""""""""""""""""""""
  SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  b~COMPANYCODENAME
  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
  LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS as b on a~CompanyCode = b~CompanyCode
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  INTO @DATA(header).
""""""""""""""""""""""""""""""plant add""""""""""""""""""""""""""""
   SELECT SINGLE
     a~businessplace,
     a~companycode,
     b~addressid,
     c~HOUSENUMBER,
     c~FLOOR,
     c~DISTRICTNAME,
     c~CITYNAME,
     c~POSTALCODE,
     c~REGION,
     c~COUNTRY

   FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_plant WITH PRIVILEGED ACCESS as b on a~BusinessPlace = b~Plant
   LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS as c on b~AddressID = c~AddressID
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
      INTO @DATA(plant_add).
data plant_addstr1 type string.
 CONCATENATE plant_add-HouseNumber plant_add-Floor plant_add-DistrictName plant_add-CityName plant_add-PostalCode plant_add-Region  plant_add-Country INTO plant_addstr1 SEPARATED BY space.
    """"""""""""""""""""""""""""""""""""""""""""""""""plant2""""""""
     SELECT SINGLE
     a~businessplace,
     a~companycode,
     b~plant_name1,
     b~address1,
     b~address2,
     b~city,
     b~state_code1,
     b~state_name,
     b~pin,
     b~country,
     b~cin_no,
     b~gstin_no,
     b~pan_no,
     b~fssai_no
     FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~BusinessPlace = b~plant_code
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
    INTO @DATA(plant_str1).

    data plant_addstr2 type string.
  CONCATENATE plant_add-Floor plant_add-DistrictName plant_add-CityName plant_add-PostalCode plant_add-Region  plant_add-Country INTO plant_addstr1 SEPARATED BY space.

    """""""""""""""""""""""""bill to """"""""""""""""""""""""""""""""""
    SELECT SINGLE
     a~businessplace,
     a~companycode,
     a~customer,
     b~customername
     FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
     AND a~FINANCIALACCOUNTTYPE =  'D'
     INTO @DATA(billto).
    """""""""""""""""""Billing customer add""""""""""""""""""""""
      SELECT SINGLE
     a~businessplace,
     a~companycode,
     a~customer,
     b~customername,
     b~ADDRESSID,
     b~TAXNUMBER3,   """"""""""""" stade code take before two digit this is gst number "" pan no
     b~TelephoneNumber1,
     b~TelephoneNumber2,
     c~STREETNAME,
     c~STREETPREFIXNAME1,
     c~STREETPREFIXNAME2,
     c~CITYNAME,
     c~DistrictName,
     c~REGION,
     c~POSTALCODE,
     c~COUNTRY,
     c~HOUSENUMBER,
     d~regionname,
     e~BPIDENTIFICATIONNUMBER   """"""""""""""""""""""""""BPIDENTIFICATIONTYPE = 'FSSAI'
     FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
     LEFT JOIN  i_address_2 WITH PRIVILEGED ACCESS as c on  b~AddressID = c~AddressID
     LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS as d on  b~Region = d~Region
     LEFT JOIN i_bupaidentification WITH PRIVILEGED ACCESS as e on a~customer = e~BusinessPartner
 WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code

     INTO @DATA(billto_add).
     data billto_addstr1 type string.
     data billto_addstr2 type string.

 CONCATENATE billto_add-StreetName billto_add-StreetPrefixName1 billto_add-StreetPrefixName2 billto_add-CityName billto_add-DistrictName INTO  billto_addstr1   SEPARATED BY space.
CONCATENATE billto_addstr1  billto_add-Region billto_add-PostalCode billto_add-Country billto_add-HouseNumber INTO billto_addstr2 SEPARATED BY space.
*     out->write( billto_add ).
     """""""""""""""""""""' ship to """""""""""""""""""""""""""""""""""""""""'
      SELECT SINGLE
*     a~businessplace,
*     a~companycode,
     a~customer,
     b~customername,
     b~ADDRESSID,
     b~TAXNUMBER3,   """"""""""""" stade code take before two digit this is gst number "" pan no
     b~TelephoneNumber1,
     b~TelephoneNumber2,
     c~STREETNAME,
     c~STREETPREFIXNAME1,
     c~STREETPREFIXNAME2,
     c~CITYNAME,
     c~DistrictName,
     c~REGION,
     c~POSTALCODE,
     c~COUNTRY,
     c~HOUSENUMBER,
     d~regionname,
     e~BPIDENTIFICATIONNUMBER   """"""""""""""""""""""""""BPIDENTIFICATIONTYPE = 'FSSAI'
     FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
     LEFT JOIN  i_address_2 WITH PRIVILEGED ACCESS as c on  b~AddressID = c~AddressID
     LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS as d on  b~Region = d~Region
     LEFT JOIN i_bupaidentification WITH PRIVILEGED ACCESS as e on a~customer = e~BusinessPartner
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
     INTO @DATA(shipto_add).
*     out->write( shipto_add ).

"""""""""""""""""""""""""""ship to add""""""""""""""""""""""""""""""""""""""""""

SELECT SINGLE

  a~customer,
    b~ADDRESSID,
     c~STREETNAME,
     c~STREETPREFIXNAME1,
     c~STREETPREFIXNAME2,
     c~CITYNAME,
     c~DistrictName,
     c~REGION,
     c~POSTALCODE,
     c~COUNTRY,
     c~HOUSENUMBER


   FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
    LEFT JOIN  i_address_2 WITH PRIVILEGED ACCESS as c on  b~AddressID = c~AddressID
  WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
     INTO @DATA(shipto_addstr1).

  data   shipto_str1 type string.
  data   shipto_str2 type string.

  CONCATENATE shipto_addstr1-StreetName shipto_addstr1-StreetPrefixName1 shipto_addstr1-StreetPrefixName2 shipto_addstr1-CityName shipto_addstr1-DistrictName INTO shipto_str1 SEPARATED BY space.
 CONCATENATE shipto_str1 shipto_addstr1-Region shipto_addstr1-PostalCode shipto_addstr1-Country  shipto_addstr1-HouseNumber INTO shipto_str2 SEPARATED BY shipto_str2.
""""""""""""""""""""""""""
 SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~DOCUMENTDATE, """"""""""""""""""""Invoice Date
  a~ORIGINALREFERENCEDOCUMENT, """"""""""""""""""""Reference No.
  b~customer,
  c~INCOTERMSCLASSIFICATION,   """"""""""""""""""""incoterms
  c~INCOTERMSLOCATION1         """""""""""""Incoterms Location 1
  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
  LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
  LEFT JOIN   i_billingdocument  WITH PRIVILEGED ACCESS as c on b~Customer = c~PAYERPARTY
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  INTO @DATA(header1).

  """"""""""""""""""Invoice No."""""""""""""""""
   SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~DOCUMENTREFERENCEID
  FROM  i_accountingdocumentjournal  WITH PRIVILEGED ACCESS as a
  LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS as b on a~CompanyCode = b~CompanyCode
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  INTO @DATA(Invoice_No).
*  out->write( invoice_no ).

  DATA(lv_xml) =
  |<Form>| &&
  |<Header>| &&
  |<Company_name>{ header-CompanyCodeName }</Company_name>| &&
  |<Plant_Add>{ plant_addstr1 }</Plant_Add> | &&
  |<Plant_Pan>{ plant_str1-pan_no  }</Plant_Pan>| &&
  |<Plant_GSTIN>{ plant_str1-gstin_no }</Plant_GSTIN>| &&
  |<Plant_FSSAI_No>{ plant_str1-fssai_no }</Plant_FSSAI_No>| &&
  |<Billto>| &&
  |<Customer_No>{ billto-Customer }</Customer_No>| &&
  |<Billing_Customer_Name>{ billto-CustomerName }</Billing_Customer_Name>|  &&
  |<Billing_Customer_Address>{ billto_addstr2 }</Billing_Customer_Address>| &&
  |<Phone_number1>{ billto_add-TelephoneNumber1 }</Phone_number1>| &&
  |<Phone_number2>{ billto_add-TelephoneNumber2 }</Phone_number2>| &&
  |<State></State>| &&
  |<GSTIN>{ billto_add-TaxNumber3 }</GSTIN>| &&
  |<FSSAI_No>{ billto_add-BPIDENTIFICATIONNUMBER }</FSSAI_No>| &&
  |<PAN></PAN>| &&
  |</Billto>| &&
  |<Shipto>| &&
  |<Customer_No>{ shipto_add-Customer }</Customer_No>| &&
  |<Billing_Customer_Name>{ shipto_add-CustomerName }</Billing_Customer_Name>|  &&
  |<Shipping_Customer_Address>{ shipto_str2 }</Shipping_Customer_Address>| &&
  |<Phone_number1>{ shipto_add-TelephoneNumber1 }</Phone_number1>| &&
  |<Phone_number2>{ shipto_add-TelephoneNumber2 }</Phone_number2>| &&
  |<State></State>| &&
  |<GSTIN>{ shipto_add-TaxNumber3 }</GSTIN>| &&
  |<FSSAI_No>{ shipto_add-BPIdentificationNumber }</FSSAI_No>| &&
  |<PAN></PAN>| &&
  |</Shipto>| &&
  |<Invoice_No>{ Invoice_No-DocumentReferenceID }</Invoice_No>| &&
  |<Invoice_Date>{ header1-DocumentDate }</Invoice_Date>| &&
  |<Reference_No>{ header1-OriginalReferenceDocument }</Reference_No>| &&
  |<Incoterms>{ header1-IncotermsClassification }</Incoterms>| &&
  |<Incoterms_loc1>{ header1-IncotermsLocation1 }</Incoterms_loc1>| &&
  |<Vehical_no></Vehical_no>| &&
  |<Transporter_Name></Transporter_Name>| &&
  |<LR_No></LR_No>| &&
  |<LR_Date></LR_Date>| &&
  |<Mode_Of_Transport></Mode_Of_Transport>| &&
  |</Header>| &&
  |<Line_item>|  .


  """""""""""""""""""""""""""""""item level """""""""""""""""""""""""""""
  SELECT

   a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~GLACCOUNT,
  a~product as material,    """""""""" this is use  item
  b~GLACCOUNTNAME,      """"""""""" this is use  gl_discription
  c~PRODUCTDESCRIPTION,     """"""""""""""" this is use  batch
  a~IN_HSNORSACCODE,     """"""""""""hsn_code
  a~QUANTITY,             """""""""""""""Qty"""""
  a~BASEUNIT,              """"""""""""""uom""""""""""
  a~AMOUNTINCOMPANYCODECURRENCY  """""""""""""""""""""""""Total Amount (INR)
  FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
  LEFT JOIN  i_glaccounttextrawdata WITH PRIVILEGED ACCESS as b on a~GLAccount = b~GLAccount
  LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS as c on a~Product = c~Product
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
  INTO TABLE @DATA(item).
*  out->write( item ).
 data str1 type string.
LOOP AT item INTO DATA(wa_item).

SELECT SUM( a~QUANTITY )
 FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
 INTO @DATA(Total_Qty).


SELECT SUM( a~AMOUNTINCOMPANYCODECURRENCY )
 FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
 INTO @DATA(Total_Amount).
 str1 = total_amount / wa_item-Quantity.

 DATA(lv_xml_item) =
 |<item>| &&
 |<Contract_no></Contract_no>| &&
 |<Item_Code>{ wa_item-material }</Item_Code>| &&
 |<Discription_Of_Goods>{ wa_item-ProductDescription }</Discription_Of_Goods>| &&
 |<Hsn_Code>{ wa_item-IN_HSNOrSACCode }</Hsn_Code>| &&
 |<Qty>{ wa_item-Quantity }</Qty>| &&
 |<Wgt_Kg></Wgt_Kg>| &&
 |<Uom>{ wa_item-BaseUnit }</Uom>| &&
 |<Rate_Per_Uom>{ str1 }</Rate_Per_Uom>| &&
 |<Disc></Disc>| &&
 |<Total_Amount_inr>{ total_amount }</Total_Amount_inr>| &&
 |</item>|.

 CONCATENATE lv_xml lv_xml_item INTO lv_xml.

ENDLOOP.

""""""""""""""""""""""""""'''footer""""""""""""""""""""
"""""""""""""""""""""""""""""plant add""""""""""""""""""""""""""""
   SELECT SINGLE
     a~businessplace,
     a~companycode,
     b~addressid,
     c~HOUSENUMBER,
     c~FLOOR,
     c~DISTRICTNAME,
     c~CITYNAME,
     c~POSTALCODE,
     c~REGION,
     c~COUNTRY
   FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
   LEFT JOIN i_plant WITH PRIVILEGED ACCESS as b on a~BusinessPlace = b~Plant
   LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS as c on b~AddressID = c~AddressID
  WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
   INTO @DATA(plantfooter_add).   """""""""""""""""" Branch_add"""""""""""""""""""""

   """""""""""""""""""""""""'header lebel""""""""""""""""""""""""""""""""
  SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~businessplace,
  b~plant_name1       """"""""""""""""""""""'Branch

  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
  LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS as b on a~BusinessPlace = b~plant_code
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  INTO @DATA(footer).

   SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~businessplace,
 a~DOCUMENTITEMTEXT       """"""""""""""""""""""'Remarks

  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~DEBITCREDITCODE = 'H'
  INTO @DATA(footerRemarks).



   SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~CUSTOMER,
  b~DISTRIBUTIONCHANNEL,
  c~acoount_number,
  c~bank_details,
  c~ifsc_code


  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
 LEFT JOIN  i_billingdocument WITH PRIVILEGED ACCESS as b on a~Customer = b~PayerParty
 LEFT JOIN  zbank_tab WITH PRIVILEGED ACCESS as c on b~DistributionChannel = c~distributionchannel
  WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~FINANCIALACCOUNTTYPE = 'D'
  INTO @DATA(footerBankDetails).
*  out->write( footerBankDetails ).

  """"""""""""""""""""gst"""""""""""""""""""""" this is for footer level not for table
   SELECT
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~AMOUNTINCOMPANYCODECURRENCY,
  a~TRANSACTIONTYPEDETERMINATION
  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
 WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
 AND a~TransactionTypeDetermination IN ( 'JOI','JOC' )
  INTO TABLE @DATA(gst).
*  out->write( gst ).
DATA igst_Amount TYPE STRING.
DATA Sgst_Amount TYPE STRING.
DATA Sgst_Rate TYPE STRING.
DATA Sgst_Rategst TYPE STRING.
DATA Cgst_Amount TYPE STRING.



  LOOP AT gst INTO DATA(wa_gst).
  if  wa_gst-TransactionTypeDetermination = 'JOI' .
       igst_amount = wa_gst-AmountInCompanyCodeCurrency.

       ELSEIF wa_gst-TransactionTypeDetermination = 'JOC'.
        cgst_amount = wa_gst-AmountInCompanyCodeCurrency.
        ELSEIF wa_gst-TransactionTypeDetermination = 'JOS'.
         sgst_amount = wa_gst-AmountInCompanyCodeCurrency.

  ENDIF.

SELECT SUM( a~AMOUNTINCOMPANYCODECURRENCY )
 FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
 INTO @DATA(Total_Amountgst).

sgst_rate = cgst_amount / total_amountgst * 100.
Sgst_Rategst = igst_amount / total_amountgst * 100 .

  DATA(lv_wa_gst) =
   |<Gst>| &&
  |<igst_Amount>{ igst_amount }</igst_Amount>| &&
  |<Sgst_Amount>{ cgst_amount }</Sgst_Amount>| &&
  |<Cgst_Amount>{ cgst_amount }</Cgst_Amount>| &&
  |<Cgst_Rate>{ sgst_rate }</Cgst_Rate>| &&
  |<igst_Rate>{ Sgst_Rategst }</igst_Rate>| &&
   |</Gst>|.

  CONCATENATE lv_xml lv_wa_gst INTO lv_xml.

  ENDLOOP.

""""""""""""""""""""""Round off"""""""""""""""""""""""""""""""""""""""
 SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~AMOUNTINCOMPANYCODECURRENCY

  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
   WHERE a~AccountingDocument = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
  INTO  @DATA(footerstr1).
*  out->write( footerstr1 ).


  DATA(lv_xml_footer) =
  |</Line_item>| &&
  |<Footer>| &&
  |<Branch>{ footer-plant_name1 }</Branch>| &&
  |<Broker></Broker>| &&
  |<Remarks>{ footerRemarks-DocumentItemText }</Remarks>| &&
  |<Bank_Details>{ footerbankdetails-bank_details }</Bank_Details>| &&
  |<Ac_No>{ footerbankdetails-acoount_number }</Ac_No>| &&
  |<Ifsc_No>{ footerbankdetails-ifsc_code }</Ifsc_No>| &&
  |<TaxAble_Value>{ footerstr1-AmountInCompanyCodeCurrency }</TaxAble_Value> | &&
  |</Footer>|.

CONCATENATE lv_xml lv_xml_footer INTO lv_xml.

CONCATENATE lv_xml '</Form>' INTO lv_xml.

* REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

   CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).



 ENDMETHOD.
ENDCLASS.
