CLASS zfi_test_cs_cr_memo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zfi_test_cs_cr_memo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

     """""""""""""""""""""""""'header lebel""""""""""""""""""""""""""""""""
  SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  b~COMPANYCODENAME
  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
  LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS as b on a~CompanyCode = b~CompanyCode
  WHERE a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  INTO @DATA(header).

*  out->write( header ).

"""""""""""""""""""""""""""""""plant add""""""""""""""""""""""""""""
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
    WHERE  a~AccountingDocument = '1600000009'  AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'"""a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal
      INTO @DATA(plant_add).
    out->write( plant_add ) .
data plant_addstr1 type string.

 CONCATENATE plant_add-HouseNumber plant_add-Floor plant_add-DistrictName plant_add-CityName plant_add-PostalCode plant_add-Region  plant_add-Country INTO plant_addstr1 SEPARATED BY space.

    """"""""""""""""""""""""""""""""""""""""""""""""""plantadd on fs come this code""""""""
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
    WHERE  a~AccountingDocument = '1600000009'  AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025' """"AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal
    INTO @DATA(plant_str1).
*    out->write( plant_str1 ) .

*    data plant_addstr2 type string.
*
* CONCATENATE plant_add-plant_name1 plant_add-Floor plant_add-DistrictName plant_add-CityName plant_add-PostalCode plant_add-Region  plant_add-Country INTO plant_addstr1 SEPARATED BY space.
*
    """""""""""""""""""""""""bill to """"""""""""""""""""""""""""""""""
    SELECT SINGLE
     a~businessplace,
     a~companycode,
     a~customer,
     b~customername
     FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_customer WITH PRIVILEGED ACCESS as b on a~Customer = b~Customer
     WHERE a~AccountingDocument = '1600000009'    AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'  """""AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal
     AND a~FINANCIALACCOUNTTYPE =  'D'
     INTO @DATA(billto).
*     out->write( billto ).



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
     WHERE  a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025' """"""""AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal

     INTO @DATA(billto_add).
     data billto_addstr1 type string.

 CONCATENATE plant_add-HouseNumber plant_add-Floor plant_add-DistrictName plant_add-CityName plant_add-PostalCode plant_add-Region  plant_add-Country INTO billto_addstr1 SEPARATED BY space.

*     out->write( billto_add ).
     """""""""""""""""""""' ship to """""""""""""""""""""""""""""""""""""""""'
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
     WHERE  a~AccountingDocument = '1600000009'  AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'"""""""""AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal

     INTO @DATA(shipto_add).
*     out->write( shipto_add ).

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
  WHERE  a~AccountingDocument = '1600000009'   AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'"""""""AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal
  INTO @DATA(header1).

  """"""""""""""""""Invoice No."""""""""""""""""
   SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~DOCUMENTREFERENCEID
  FROM  i_accountingdocumentjournal  WITH PRIVILEGED ACCESS as a
  LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS as b on a~CompanyCode = b~CompanyCode
  WHERE  a~AccountingDocument = '1600000009'  AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'"""""""""AND a~CompanyCode =  @lv_company AND a~FiscalYear =  @lv_fiscal
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
  |<Billing_Customer_Address>{ billto_addstr1 }</Billing_Customer_Address>| &&
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
  |<Shipping_Customer_Address></Shipping_Customer_Address>| &&
  |<Phone_number1>{ shipto_add-TelephoneNumber1 }</Phone_number1>| &&
  |<Phone_number2>{ shipto_add-TelephoneNumber2 }</Phone_number2>| &&
  |<State></State>| &&
  |<GSTIN></GSTIN>| &&
  |<FSSAI_No></FSSAI_No>| &&
  |<PAN></PAN>| &&
  |</Shipto>| &&
  |<Invoice_No></Invoice_No>| &&
  |<Invoice_Date></Invoice_Date>| &&
  |<Reference_No></Reference_No>| &&
  |<Incoterms></Incoterms>| &&
  |<Vehical_no></Vehical_no>| &&
  |<Transporter_Name></Transporter_Name>| &&
  |<LR_No></LR_No>| &&
  |<LR_Date></LR_Date>| &&
  |<Mode_Of_Transport></Mode_Of_Transport>| &&
  |</Header>| .


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
  WHERE   a~AccountingDocument = '1600000009'  AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
  INTO TABLE @DATA(item).
*  out->write( item ).

LOOP AT item INTO DATA(wa_item).

SELECT SUM( a~QUANTITY )
 FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
 WHERE  a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
 INTO @DATA(Total_Qty).
* out->write( Total_Qty ).

SELECT SUM( a~AMOUNTINCOMPANYCODECURRENCY )
 FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
 WHERE   a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
 INTO @DATA(Total_Amount).
* out->write( Total_Amount ).

 DATA(lv_xml_item) =
 |<Line_item>| &&
 |<item>| &&
 |<Contract_no></Contract_no>| &&
 |<Item_Code>{ wa_item-material }</Item_Code>| &&
 |<Discription_Of_Goods>{ wa_item-ProductDescription }</Discription_Of_Goods>| &&
 |<Hsn_Code>{ wa_item-IN_HSNOrSACCode }</Hsn_Code>| &&
 |<Qty>{ wa_item-Quantity }</Qty>| &&
 |<Wgt_Kg></Wgt_Kg>| &&
 |<Uom>{ wa_item-BaseUnit }</Uom>| &&
 |<Rate_Per_Uom></Rate_Per_Uom>| &&
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
   WHERE a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
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

  WHERE a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  INTO @DATA(footer).
*  out->write( footer ).

   SELECT SINGLE
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~businessplace,
 a~DOCUMENTITEMTEXT       """"""""""""""""""""""'Remarks

  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
  WHERE a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  AND a~DEBITCREDITCODE = 'H'
  INTO @DATA(footerRemarks).
*  out->write( footerRemarks ).


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

  WHERE  a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
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
  WHERE  a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
 AND a~TransactionTypeDetermination IN ( 'JOI' , 'JOC' , 'JOS' )


  INTO TABLE @DATA(gst).

*  out->write( gst ).
DATA igst_Amount TYPE STRING.
DATA Sgst_Amount TYPE STRING.
DATA Cgst_Amount TYPE STRING.


  LOOP AT gst INTO DATA(wa_gst).

   if  wa_gst-TransactionTypeDetermination = 'JOI' .
       igst_amount = wa_gst-AmountInCompanyCodeCurrency.

       ELSEIF wa_gst-TransactionTypeDetermination = 'JOC'.
        cgst_amount = wa_gst-AmountInCompanyCodeCurrency.
        ELSEIF wa_gst-TransactionTypeDetermination = 'JOS'.
         sgst_amount = wa_gst-AmountInCompanyCodeCurrency.

  ENDIF.

  DATA(lv_wa_gst) =
   |<Gst>| &&
  |<igst_Amount>{ igst_amount }</igst_Amount>| &&
  |<Sgst_Amount>{ sgst_amount }</Sgst_Amount>| &&
  |<Cgst_Amount>{ cgst_amount }</Cgst_Amount>| &&
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

   WHERE  a~AccountingDocument = '1600000009' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
  AND a~ACCOUNTINGDOCUMENTITEMTYPE <> 'T' AND a~CostElement is NOT INITIAL
  AND a~AmountInCompanyCodeCurrency > 1
  INTO  @DATA(footerstr1).
*  out->write( footerstr1 ).


  DATA(lv_xml_footer) =
  |</Line_item>| &&
  |<Footer>| &&
  |<Branch></Branch>| &&
  |<Broker></Broker>| &&
  |<Remarks></Remarks>| &&
  |<Bank_Details></Bank_Details>| &&
  |<Ac_No></Ac_No>| &&
  |<Ifsc_No></Ifsc_No>| &&
  |<TaxAble_Value></TaxAble_Value> | &&
  |</Footer>|.

CONCATENATE lv_xml lv_xml_footer INTO lv_xml.

CONCATENATE lv_xml '</Form>' INTO lv_xml.
out->write( lv_xml ).
  ENDMETHOD.
ENDCLASS.
