CLASS yaccount_statement_customer_cl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES : BEGIN OF ty_final,
              document                     TYPE i_operationalacctgdocitem-accountingdocument,
              OriginalReferenceDocument    TYPE i_operationalacctgdocitem-OriginalReferenceDocument,
              postingdate                  TYPE i_operationalacctgdocitem-postingdate,
              accountingdocumenttype       TYPE i_operationalacctgdocitem-accountingdocumenttype,
              companycode                  TYPE i_operationalacctgdocitem-companycode,
              fiscalyear                   TYPE i_operationalacctgdocitem-fiscalyear,
              material                     TYPE i_operationalacctgdocitem-product,
              quantity                     TYPE i_operationalacctgdocitem-quantity,
              baseunit                     TYPE i_operationalacctgdocitem-baseunit,
              amountintransactioncurrency  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              CashDiscountAmount           TYPE i_operationalacctgdocitem-CashDiscountAmount,
              transactiontypedetermination TYPE i_operationalacctgdocitem-transactiontypedetermination,
              debitcreditcode              TYPE i_operationalacctgdocitem-debitcreditcode,
              joi                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              joc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              jos                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              jtc                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              wth                          TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              deb_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              cre_amt                      TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              closing_bal                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              taxableamt                   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              taxableamtc                  TYPE i_operationalacctgdocitem-amountintransactioncurrency,
              remarks                      TYPE i_operationalacctgdocitem-documentitemtext,
              businessplace                TYPE i_operationalacctgdocitem-businessplace,
            END OF ty_final.

    CLASS-DATA : BEGIN OF w_head,
                   opening_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
                   closing_bal   TYPE i_operationalacctgdocitem-amountintransactioncurrency,
                   value         TYPE i_operationalacctgdocitem-customer,
                   cusvssupp(25) TYPE c,
                   tds(25)       TYPE c,
                 END OF w_head.

    CLASS-DATA : BEGIN OF wa_add1,
                   name               TYPE i_supplier-supplierfullname,
                   taxnumber3         TYPE i_supplier-taxnumber3,
                   customer           TYPE i_supplier-customer,
                   telephonenumber1   TYPE i_supplier-phonenumber1,
                   organizationname1  TYPE i_address_2-organizationname1,
                   organizationname2  TYPE i_address_2-organizationname2,
                   organizationname3  TYPE i_address_2-organizationname3,
                   housenumber        TYPE i_address_2-housenumber,
                   streetname         TYPE i_address_2-streetname,
                   streetprefixname1  TYPE i_address_2-streetprefixname1,
                   streetprefixname2  TYPE i_address_2-streetprefixname2,
                   streetsuffixname1  TYPE i_address_2-streetsuffixname1,
                   streetsuffixname2  TYPE i_address_2-streetsuffixname2,
                   districtname       TYPE i_address_2-districtname,
                   cityname           TYPE i_address_2-cityname,
                   addresssearchterm1 TYPE i_address_2-addresssearchterm1,
                   postalcode         TYPE i_supplier-postalcode,
                   regionname         TYPE i_regiontext-regionname,
                 END OF wa_add1.

    CLASS-DATA :BEGIN OF wa_add,
                  var1(80)  TYPE c,
                  var2(80)  TYPE c,
                  var3(80)  TYPE c,
                  var4(80)  TYPE c,
                  var5(80)  TYPE c,
                  var6(80)  TYPE c,
                  var7(80)  TYPE c,
                  var8(80)  TYPE c,
                  var9(80)  TYPE c,
                  var10(80) TYPE c,
                  var11(80) TYPE c,
                  var12(80) TYPE c,
                  var13(80) TYPE c,
                  var14(80) TYPE c,
                  var15(80) TYPE c,
                END OF wa_add.

    CLASS-DATA : it_final TYPE TABLE OF ty_final,
                 wa_final TYPE ty_final.

    CLASS-METHODS :

      read_posts
         IMPORTING companycode     TYPE string
                  correspondence   TYPE string
                  accounttype      TYPE string
                  customer         TYPE string

                  lastdate         TYPE string
                  currentdate      TYPE string
                  profitcenter    TYPE string
                  confirmletterbox TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.

   CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW10/ACCOUNTSTATEMENT_NEW10'..
ENDCLASS.



CLASS YACCOUNT_STATEMENT_CUSTOMER_CL IMPLEMENTATION.


  METHOD read_posts .

    DATA rec TYPE string.
    DATA xsml TYPE string.
    DATA date2 TYPE string.
    DATA gv1 TYPE string .
    DATA gv2 TYPE string .
    DATA gv3 TYPE string .
    DATA close_bal TYPE   i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

    gv3 = currentdate+6(4)  .
    gv2 = currentdate+3(2)  .
    gv1 = currentdate+0(2)  .

    CONCATENATE gv3 gv2 gv1   INTO date2.

    DATA date3 TYPE string.
    DATA gv4 TYPE string .
    DATA gv5 TYPE string .
    DATA gv6 TYPE string .

    gv6 = lastdate+6(4)  .
    gv5 = lastdate+3(2)  .
    gv4 = lastdate+0(2)  .

    CONCATENATE gv6 gv5 gv4  INTO date3.

    DATA var TYPE string.
    var   = |{ customer ALPHA = IN }|.
*       customer = VAR.

    "  ********************************************CUSTOMER ADDERSSS********************************************88

    w_head-cusvssupp = 'Customer'.
    w_head-value = 'D'.
    w_head-tds = 'TDS Re.'.
    SELECT SINGLE
          b~taxnumber3,
          b~customer,
          b~telephonenumber1,
          c~organizationname1,
          c~organizationname2,
          c~organizationname3,
          c~housenumber,
          c~streetname,
          c~streetprefixname1,
          c~streetprefixname2,
          c~streetsuffixname1,
          c~streetsuffixname2,
          c~districtname,
          c~cityname,
          c~postalcode,
          c~addresssearchterm1,
          d~regionname
          FROM  i_customer AS b
          LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON ( c~addressid = b~addressid )
          LEFT JOIN i_regiontext AS d ON ( d~region = b~region AND d~language = 'E' AND d~country = 'IN' )
          WHERE customer = @var INTO CORRESPONDING FIELDS OF @wa_add1.

    wa_add-var1 = wa_add1-organizationname1.
    wa_add-var2 = wa_add1-organizationname2.
    wa_add-var3 = wa_add1-organizationname3.
*      DATA(coname) = zseparate_address=>separate( CHANGING var = wa_add ).

    wa_add-var1 = wa_add1-housenumber.
    wa_add-var2 = wa_add1-streetname.
    wa_add-var3 = wa_add1-streetprefixname1.
    wa_add-var4 = wa_add1-streetprefixname2.
    wa_add-var5 = wa_add1-streetsuffixname1.
    wa_add-var6 = wa_add1-streetsuffixname2.
*      DATA(streetno) = zseparate_address=>separate( CHANGING var = wa_add ).

    wa_add-var1 = wa_add1-cityname.
*    wa_add-var2 = wa_add1-districtname.
    wa_add-var3 = wa_add1-postalcode.
*      DATA(city) = zseparate_address=>separate( CHANGING var = wa_add ).

    "  ********************************************CUSTOMER ADDERSSS********************************************88

    "  ********************************************IT TABLE*****************************************************88
    IF Profitcenter IS NOT INITIAL .
      SELECT
             a~accountingdocument,
             a~OriginalReferenceDocument,
             a~postingdate,
             a~accountingdocumenttype,
             a~companycode,
             a~fiscalyear,
             a~product,
             SUM( a~amountintransactioncurrency ) AS amountintransactioncurrency,
             SUM( a~CashDiscountAmount ) AS  CashDiscountAmount,
             a~debitcreditcode,
             a~baseunit,
             a~quantity

             FROM i_operationalacctgdocitem AS a
             INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                      AND c~CompanyCode = a~CompanyCode
                                                      AND c~FiscalYear = a~FiscalYear
                                                      AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
             WHERE a~companycode = @companycode
             AND    a~customer     = @var
             AND    a~financialaccounttype = 'D'
             AND a~SpecialGLCode <> 'F'
             AND ( a~PostingDate >= @date3 ) AND ( a~PostingDate <= @date2 )
             AND a~AccountingDocumentType <> 'AB'
             GROUP BY
             a~accountingdocument,
             a~OriginalReferenceDocument,
             a~postingdate,
             a~accountingdocumenttype,
             a~companycode,
             a~fiscalyear,
             a~product,
             a~debitcreditcode,
             a~baseunit,
             a~quantity
               INTO TABLE @DATA(it_tab) .

      DATA gst1 TYPE string .
      DATA cin1 TYPE string .
      DATA pan1 TYPE string .
      DATA Register1 TYPE string .
      DATA Register2 TYPE string .
      DATA Register3 TYPE string .

      SELECT SINGLE
      a~address1,
      a~address2,
      a~city,
      a~STATE_Name,
      a~pin,
      a~country,
      a~GSTin_No,
      a~PAN_No,
      a~Cin_No
      FROM ztable_plant AS a
      WHERE a~comp_code = @companycode
      AND   a~plant_code = @profitcenter
      INTO  @DATA(Plant_address).

      DATA(lv_plant_address) = |{ Plant_address-address1 }, { Plant_address-address2 }, { Plant_address-city }, { Plant_address-state_name }, { Plant_address-pin }, { Plant_address-country }|.




*     IF companycode   =  '1000' .
*
*     gst1  = '08AAHCS2781A1ZH'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Reg. Off. F-483 To F-487 RIICO Growth Centre' .
*     Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*
*     elseif companycode   =  '2000' .
*
*     gst1  = '08AABCM5293P1ZT'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Reg. Off. Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
*     Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*
*     ENDIF.
* ELSE.

*  IF Profitcenter  = '0000110000'.
*    gst1  = '23AAHCS2781A1ZP'.
*    pan1  = 'AAHCS2781A'.
*    Register1 = 'SWARAJ SUITING LIMITED'.
*    Register2 = 'Spinning Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*    Register3 = ' Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
*    cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000120000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Denim Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000130000'.
*     gst1  = '08AAHCS2781A1ZH'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Weaving Division-I, F-483 To F-487 RIICO Growth Centre' .
*     Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000131000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000140000'.
*     gst1  = '23AAHCS2781A1ZP'.
*     pan1  = 'AAHCS2781A'.
*     Register1 = 'SWARAJ SUITING LIMITED'.
*     Register2 = 'Process House-I, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'L18101RJ2003PLC018359'.
*    elseif Profitcenter  = '0000210000'.
*     gst1  = '08AABCM5293P1ZT'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
*     Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*    elseif Profitcenter  = '0000220000'.
*     gst1  = '23AABCM5293P1Z1'.
*     pan1  = 'AABCM5293P'.
*     Register1 = 'MODWAY SUITING PVT. LIMITED'.
*     Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
*     Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
*     cin1 = 'U18108RJ1986PTC003788'.
*    ENDIF.

      SELECT   a~accountingdocument,
                 a~OriginalReferenceDocument,
                 a~postingdate,
                 a~accountingdocumenttype,
                 a~companycode,
                 a~fiscalyear,
                 a~product,
                 SUM( a~amountintransactioncurrency ) AS amountintransactioncurrency,
                 SUM( a~CashDiscountAmount ) AS  CashDiscountAmount,
                 a~debitcreditcode,
                 a~baseunit,
                 a~quantity
                 FROM i_operationalacctgdocitem AS a
                   INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                          AND b~CompanyCode = a~CompanyCode
                                                          AND b~FiscalYear = a~FiscalYear )
                   INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                          AND c~CompanyCode = a~CompanyCode
                                                          AND c~FiscalYear = a~FiscalYear
                                                          AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
                 WHERE a~companycode = @companycode
                 AND   a~customer   = @var
                 AND   a~financialaccounttype = 'D'
                 AND a~SpecialGLCode <> 'F'
                 AND a~PostingDate GE @date3 AND a~PostingDate LE @date2
                 AND a~AccountingDocumentType <> 'AB'
      "          AND B~ProfitCenter = @profitcenter
            GROUP BY
                 a~accountingdocument,
                 a~OriginalReferenceDocument,
                 a~postingdate,
                 a~accountingdocumenttype,
                 a~companycode,
                 a~fiscalyear,
                 a~product,
                 a~debitcreditcode,
                 a~baseunit,
                 a~quantity
            INTO TABLE @it_tab.
    ENDIF.
    SORT it_tab BY  accountingdocument  DebitCreditCode .  " billingdocument
    DELETE ADJACENT DUPLICATES FROM it_tab COMPARING  accountingdocument  DebitCreditCode FiscalYear. " billingdocument

    "  ********************************************IT TABLE******************************************************88

    "  ********************************************LINE ITEM TABLE***********************************************88

    IF it_tab IS NOT INITIAL.
      SELECT product,
             quantity,
             baseunit,
             billingdocument ,
             a~accountingdocument,
             accountingdocumentitem,
             amountintransactioncurrency,
             CashDiscountAmount,
             transactiontypedetermination,
             debitcreditcode,
             withholdingtaxamount,
             costcenter,
             a~accountingdocumenttype,
             a~financialaccounttype,
             HouseBank,
             glaccount
             FROM i_operationalacctgdocitem AS a
             INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                    AND c~CompanyCode = a~CompanyCode
                                                    AND c~FiscalYear = a~FiscalYear
                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
             FOR ALL ENTRIES IN @it_tab
             WHERE a~companycode          = @it_tab-companycode
               AND a~fiscalyear           = @it_tab-fiscalyear
               AND a~accountingdocument   = @it_tab-accountingdocument
               AND a~PostingDate GE @date3 AND a~PostingDate LE @date2

               INTO TABLE @DATA(it_tab2) .
    ENDIF.

    "  ********************************************LINE ITME ************************************************88

    "  ********************************************OPENING AMT***********************************************88

    SELECT SUM( amountintransactioncurrency )
    FROM i_operationalacctgdocitem AS a
    INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                    AND c~CompanyCode = a~CompanyCode
                                                    AND c~FiscalYear = a~FiscalYear
                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
           WHERE a~companycode = @companycode
             AND a~customer  = @var
             AND a~postingdate LT @date3
             AND a~AccountingDocumentType NE 'GE' AND  a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'

    INTO @w_head-opening_bal.

    "  ********************************************OPENING AMT***********************************************88
    SORT it_tab  BY postingdate accountingdocument .

    DATA(opening) = w_head-opening_bal.

    SELECT SINGLE * FROM i_CUSTOMER  AS a
    LEFT OUTER JOIN I_BusinessPartnerBank AS b ON ( b~BusinessPartner = a~Customer )
    LEFT OUTER JOIN zcustomer_details AS c ON ( c~Customer = a~Customer )
    WHERE a~Customer = @var  INTO @DATA(Cust).
    DATA(lv_xml) =

   |<form1>| &&
   |<plantname>{ Register1 }</plantname>| &&
   |<address1>{ lv_plant_address }</address1>| &&
   |<CINNO>{ Plant_address-cin_no }</CINNO>| &&
   |<GSTIN>{ Plant_address-gstin_no }</GSTIN>| &&
   |<PAN>{ Plant_address-pan_no }</PAN>| &&
   |<LeftSide>| &&
   |<partyno>{ cust-a-CustomerName }</partyno>| &&
    |<ccode>({ customer })</ccode>| &&
      |<companyCode>{ companyCode }</companyCode>| &&
   |<partyno2>{ cust-c-StreetPrefixName1 }</partyno2>| &&
   |<partyno3>{ cust-c-StreetPrefixName2 }</partyno3>| &&
   |<partyadd>{ cust-a-CityName }-{ cust-a-PostalCode }</partyadd>| &&
   |<partyadd1>{ cust-a-TaxNumber3 }</partyadd1>| &&
   |<PHNNO>{ cust-c-TelephoneNumber1 }</PHNNO>| &&
   |<EMAIL>{ cust-c-EmailAddress }</EMAIL>| &&
   |<Subform7/>| &&
   |</LeftSide>| &&
   |<RightSide>| &&
   |<date></date>| &&
   |<openingbl>{ opening }</openingbl>| &&
   |<TransporterName></TransporterName>| &&
   |<FromDate>{ lastdate }</FromDate>| &&
   |<ToDate>{ currentdate }</ToDate>| &&
   |<Page>| &&
   |<HaderData>| &&
   |<RightSide>| &&
   |<StationNo></StationNo>| &&
   |</RightSide>| &&
   |</HaderData>| &&
   |</Page>| &&
   |</RightSide>| &&
   |<BankDetail>| &&
   |<BankName>{ cust-b-BankName }</BankName>| &&
   |<AccountNo>{  cust-b-BankAccount }</AccountNo>| &&
   |<IFSC>{ cust-b-SWIFTCode }</IFSC>| &&
   |</BankDetail>| &&
   |<chk_mark>{ confirmletterbox }</chk_mark>| .


    LOOP AT it_tab INTO DATA(wa_tab).

      wa_final-document = wa_tab-accountingdocument.
      wa_final-postingdate                 = wa_tab-postingdate.
      wa_final-accountingdocumenttype      = wa_tab-accountingdocumenttype.
      wa_final-amountintransactioncurrency = wa_tab-amountintransactioncurrency.
      wa_final-CashDiscountAmount           =  wa_tab-CashDiscountAmount.
      wa_final-debitcreditcode             = wa_tab-debitcreditcode.
      wa_final-originalreferencedocument   =  wa_tab-OriginalReferenceDocument.
      wa_final-companycode                 =  wa_tab-CompanyCode.
      wa_final-fiscalyear                   =  wa_tab-FiscalYear.

      IF wa_final-DebitCreditCode = 'S' AND wa_final-amountintransactioncurrency > 0.
        wa_final-deb_amt =  wa_tab-amountintransactioncurrency.
      ELSEIF

      wa_tab-DebitCreditCode = 'H' OR wa_final-amountintransactioncurrency < 0.
        wa_final-cre_amt =  wa_tab-amountintransactioncurrency.

      ENDIF.


      SELECT SINGLE a~baseunit ,
                    b~productdescription
                             FROM i_operationalacctgdocitem AS a
                             INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                    AND c~CompanyCode = a~CompanyCode
                                                    AND c~FiscalYear = a~FiscalYear
                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
                             INNER JOIN i_productdescription AS b ON ( b~product = a~product AND b~language = 'E' )
                             WHERE a~accountingdocument = @wa_tab-accountingdocument
                             AND a~CompanyCode = @wa_tab-CompanyCode
                             AND a~FiscalYear = @wa_tab-FiscalYear
                             AND a~product <> ''
                             INTO (@wa_final-baseunit,@wa_final-material) .

      IF wa_tab-AccountingDocumentType = 'RV'.

        wa_final-material = ''.

      ENDIF.
      IF wa_final-material IS INITIAL.

        SELECT SINGLE a~glaccount ,
                      b~glaccountlongname
                               FROM i_operationalacctgdocitem AS a
                               INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                    AND c~CompanyCode = a~CompanyCode
                                                    AND c~FiscalYear = a~FiscalYear
                                                    AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
                               INNER JOIN i_glaccounttext  AS b ON ( b~glaccount = a~glaccount AND b~language = 'E' )
                               WHERE a~accountingdocument = @wa_tab-accountingdocument
                               AND a~CompanyCode = @wa_tab-CompanyCode
                               AND a~FiscalYear = @wa_tab-FiscalYear
                               AND a~glaccount <> ''
                               INTO @DATA(gl_desc) .
        wa_final-material = gl_desc-glaccountlongname.

      ENDIF.

      LOOP AT it_tab2 INTO DATA(wa_tab2) WHERE accountingdocument = wa_tab-accountingdocument  .
        wa_final-quantity = wa_final-quantity + wa_tab2-quantity.
        CASE wa_tab2-transactiontypedetermination.
          WHEN  'JOI' OR 'JII' OR 'JIM'.
            wa_final-joi = wa_final-joi + wa_tab2-amountintransactioncurrency.
          WHEN  'JOC' OR 'JIC'.
            wa_final-joc = wa_final-joc + wa_tab2-amountintransactioncurrency.
          WHEN  'JOS' OR 'JIS'.
            wa_final-jos = wa_final-jos + wa_tab2-amountintransactioncurrency.
          WHEN  'JTC' .
            wa_final-jtc = wa_final-jtc + wa_tab2-amountintransactioncurrency.
          WHEN  'WTH' OR 'WIT'.
            wa_final-wth = wa_final-wth + wa_tab2-amountintransactioncurrency.
        ENDCASE.

        IF ( wa_tab2-AccountingDocumentType = 'RV' OR wa_tab2-AccountingDocumentType = 'SA' )
        AND wa_tab2-FinancialAccountType  = 'S' AND wa_tab2-transactiontypedetermination = ''.
          wa_final-taxableamt = wa_final-taxableamt + wa_tab2-amountintransactioncurrency.
        ELSEIF
        wa_tab-AccountingDocumentType = 'DZ' AND ( wa_tab2-HouseBank <> '' OR wa_tab2-GLAccount = '2200001800' OR wa_tab2-GLAccount = '2200001900' OR wa_tab2-GLAccount = '2200002000' OR wa_tab2-GLAccount = '2200002100' ).
          wa_final-taxableamt = wa_final-taxableamt + wa_tab2-amountintransactioncurrency.
        ELSEIF
        wa_tab-AccountingDocumentType <> 'DZ' AND ( wa_tab2-TransactionTypeDetermination =  'AGD' OR wa_tab2-TransactionTypeDetermination = 'BSX' OR wa_tab2-TransactionTypeDetermination = 'WRX'
         OR  wa_tab2-TransactionTypeDetermination = 'PRD' ).
          wa_final-taxableamt = wa_final-taxableamt + wa_tab2-amountintransactioncurrency.
        ENDIF.

      ENDLOOP.

      wa_final-closing_bal =  opening + wa_final-cre_amt + wa_final-deb_amt .
      w_head-closing_bal =  opening + wa_final-cre_amt + wa_final-deb_amt .
      opening =  opening + wa_final-cre_amt + wa_final-deb_amt .
      APPEND wa_final TO it_final.
      CLEAR wa_final.

    ENDLOOP.


    CLEAR rec.
    LOOP AT it_final INTO wa_final.

      rec = rec + 1.
      DATA(count) = lines( it_final ).

      SELECT SINGLE GLAccount FROM i_operationalacctgdocitem AS a
      INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                         AND c~CompanyCode = a~CompanyCode
                                                         AND c~FiscalYear = a~FiscalYear
                                                         AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
           WHERE  a~FiscalYear = @wa_final-FiscalYear AND a~CompanyCode = @wa_final-CompanyCode
           AND a~AccountingDocument = @wa_final-document  AND a~GLAccount <> '1850001003' AND GLAccount <> '3500001050'
           AND  ( a~AccountingDocumentItemType = '' OR a~AccountingDocumentItemType = 'R' ) AND  a~FinancialAccountType <> 'D' AND a~FinancialAccountType <> 'K'  INTO @DATA(gl).

      IF gl IS INITIAL .
        SELECT SINGLE customer AS GLAccount FROM i_operationalacctgdocitem AS a
        INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                        AND c~CompanyCode = a~CompanyCode
                                                        AND c~FiscalYear = a~FiscalYear
                                                        AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
        WHERE  a~FiscalYear = @wa_final-FiscalYear AND a~CompanyCode = @wa_final-CompanyCode
        AND a~AccountingDocument = @wa_final-document  AND a~FinancialAccountType = 'D'  AND a~Customer <> @var INTO @gl.
      ENDIF.

      SELECT SINGLE * FROM I_GLAccountText
      WHERE GLAccount = @gl AND Language = 'E'
       INTO @DATA(tab7).

      SELECT SINGLE  AmountInCompanyCodeCurrency , GLAccount FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS
      WHERE AccountingDocument = @wa_final-document AND CompanyCode = @wa_final-companycode
      AND FiscalYear = @wa_final-fiscalyear
      AND ( ( GLAccount BETWEEN '2700001000'  AND '2700001100' )  OR GLAccount = '1850001003' )
        INTO @DATA(tds).

      IF wa_final-wth = 0 .
        wa_final-wth = tds-AmountInCompanyCodeCurrency.
      ENDIF.

      IF tab7 IS INITIAL .
        SELECT SINGLE customername AS GLAccountLongName FROM i_customer
      WHERE customer = @gl INTO @tab7.
      ENDIF.

      DATA desc  TYPE string.

      desc = tab7-GLAccountLongName.


      SELECT SINGLE DocumentDate FROM I_OperationalAcctgDocItem
   WHERE AccountingDocument = @wa_final-document AND CompanyCode = @wa_final-CompanyCode
   AND FiscalYear = @wa_final-FiscalYear INTO @DATA(invdt).


      lv_xml = lv_xml &&

         |<LopTab>| &&
         |<Row1>| &&
         |<docno>{ wa_final-OriginalReferenceDocument+0(10) }</docno>| &&
         |<invoicedate>{ invdt }</invoicedate>| &&
         |<docdate>{ wa_final-postingdate+6(2) }.{ wa_final-postingdate+4(2) }.{ wa_final-postingdate+0(4) }</docdate>| &&
         |<particulars>{ desc  }</particulars>| &&
         |<doctype>{ wa_final-AccountingDocumentType }</doctype>| &&
         |<Value>{ wa_final-taxableamt }</Value>| &&
         |<cdrd>{ wa_final-CashDiscountAmount }</cdrd>| &&
         |<IGST>{ wa_final-joi }</IGST>| &&
         |<CGST>{ wa_final-joc }</CGST>| &&
         |<SGST>{ wa_final-jos }</SGST>| &&
         |<Tdsamt>{ wa_final-wth }</Tdsamt>| &&
         |<debitamt>{ wa_final-deb_amt }</debitamt>| &&
         |<creditamt>{ wa_final-cre_amt }</creditamt>| &&
         |<Balance>{ wa_final-closing_bal }</Balance>| &&
         |</Row1>| &&
         |</LopTab>|.

      IF rec = count.
        close_bal = wa_final-closing_bal.
      ENDIF.


      CLEAR:gl,desc,wa_final,tab7,tds.
    ENDLOOP.

    DATA closingbl TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .


    closingbl = close_bal .

    lv_xml = lv_xml &&
        |<Subform3>| &&
        |<Table3>| &&
           |<Row1>| &&
             |<closingbl>{ closingbl }</closingbl>| &&
          |</Row1>| &&
       |</Table3>| &&
       |</Subform3>| &&
       |<Subform2>| &&
       |<SIGN></SIGN>| &&
       |<preparedby></preparedby>| &&
       |</Subform2>| &&
       |</form1>| .

    DATA:res TYPE string.
    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = res ).
    CONCATENATE result12 res INTO result12.
    CONDENSE result12 NO-GAPS.
  ENDMETHOD.
ENDCLASS.
