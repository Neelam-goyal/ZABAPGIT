CLASS ycl_account_statement_customer DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : template TYPE string .
    CLASS-DATA : tot_sum  TYPE string.

    TYPES : BEGIN OF struct,
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
        RAISING   cx_static_check,

      read_posts
        IMPORTING companycode      TYPE string
                  correspondence   TYPE string
                  accounttype      TYPE string
                  customer         TYPE string
                  lastdate         TYPE string
                  currentdate      TYPE string
                  profitcenter     TYPE string
                  confirmletterbox TYPE string

        RETURNING VALUE(result12)  TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.eu10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://btp-yvzjjpaz.authentication.eu10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
*    CONSTANTS  lc_template_name TYPE string VALUE 'FI_ACCOUNTSTATEMENT/FI_ACCOUNTSTATEMENT'.
*   CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT/ACCOUNTSTATEMENT'.
    CONSTANTS  lc_template_name TYPE string VALUE 'ACCOUNTSTATEMENT_NEW1/ACCOUNTSTATEMENT_NEW1'.
ENDCLASS.



CLASS YCL_ACCOUNT_STATEMENT_CUSTOMER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD .


  METHOD read_posts .

    DATA xsml TYPE string.
    DATA date2 TYPE string.
    DATA gv1 TYPE string .
    DATA gv2 TYPE string .
    DATA gv3 TYPE string .

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

    DATA var TYPE string .
    var   = |{ customer ALPHA = IN }|.
*    customer = var.


    IF Profitcenter = '' .

      SELECT  a~AccountingDocument ,
              a~OriginalReferenceDocument,
              a~DocumentDate,
              a~CompanyCode,
              a~AccountingDocumentType,
              a~FiscalYear,
              SUM( a~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
              a~DebitCreditCode ,
              a~TransactionTypeDetermination,
              a~financialaccounttype,
              a~WithholdingTaxAmount FROM i_operationalacctgdocitem AS a
              INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                     AND c~CompanyCode = a~CompanyCode
                                                     AND c~FiscalYear = a~FiscalYear
                                                     AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
       WHERE a~Customer = @var AND a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode
       AND a~AccountingDocumentType <> 'WL' AND a~SpecialGLCode <> 'F'
       GROUP BY a~AccountingDocument ,
              a~DocumentDate,
              a~CompanyCode,
              a~AccountingDocumentType,
              a~FiscalYear,
               a~DebitCreditCode ,
               a~TransactionTypeDetermination,
               a~financialaccounttype,
               a~OriginalReferenceDocument,
              a~WithholdingTaxAmount
       INTO TABLE @DATA(tab1).


      DATA gst1 TYPE string .
      DATA cin1 TYPE string .
      DATA pan1 TYPE string .
      DATA Register1 TYPE string .
      DATA Register2 TYPE string .
      DATA Register3 TYPE string .

      IF companycode   =  '1000' .

        gst1  = '08AAHCS2781A1ZH'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Reg. Off. F-483 To F-487 RIICO Growth Centre' .
        Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
        cin1 = 'L18101RJ2003PLC018359'.

      ELSEIF companycode   =  '2000' .

        gst1  = '08AABCM5293P1ZT'.
        pan1  = 'AABCM5293P'.
        Register1 = 'MODWAY SUITING PVT. LIMITED'.
        Register2 = 'Reg. Off. Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
        Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
        cin1 = 'U18108RJ1986PTC003788'.

      ENDIF.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    ELSEIF   Profitcenter <> '' .


      IF Profitcenter  = '0000110000'.
        gst1  = '23AAHCS2781A1ZP'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Spinning Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
        Register3 = ' Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
        cin1 = 'L18101RJ2003PLC018359'.
      ELSEIF Profitcenter  = '0000120000'.
        gst1  = '23AAHCS2781A1ZP'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Denim Division-I, B-24 To B-41 Jhanjharwada Industrial Area' .
        Register3 = 'Jhanjharwada, Neemuch - 458441, Madhya Pradesh, India'.
        cin1 = 'L18101RJ2003PLC018359'.
      ELSEIF Profitcenter  = '0000130000'.
        gst1  = '08AAHCS2781A1ZH'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Weaving Division-I, F-483 To F-487 RIICO Growth Centre' .
        Register3 = 'Hamirgarh, Bhilwara-311025, Rajasthan, India'.
        cin1 = 'L18101RJ2003PLC018359'.
      ELSEIF Profitcenter  = '0000131000'.
        gst1  = '23AAHCS2781A1ZP'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
        Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
        cin1 = 'L18101RJ2003PLC018359'.
      ELSEIF Profitcenter  = '0000140000'.
        gst1  = '23AAHCS2781A1ZP'.
        pan1  = 'AAHCS2781A'.
        Register1 = 'SWARAJ SUITING LIMITED'.
        Register2 = 'Process House-I, B-24 To B-41 Jhanjharwada Industrial Area' .
        Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
        cin1 = 'L18101RJ2003PLC018359'.
      ELSEIF Profitcenter  = '0000210000'.
        gst1  = '08AABCM5293P1ZT'.
        pan1  = 'AABCM5293P'.
        Register1 = 'MODWAY SUITING PVT. LIMITED'.
        Register2 = 'Weaving Division-I, 20th Km Stone, Chittorgarh Road' .
        Register3 = 'Takhatpura, Bhilwara-311025, Rajasthan, India'.
        cin1 = 'U18108RJ1986PTC003788'.
      ELSEIF Profitcenter  = '0000220000'.
        gst1  = '23AABCM5293P1Z1'.
        pan1  = 'AABCM5293P'.
        Register1 = 'MODWAY SUITING PVT. LIMITED'.
        Register2 = 'Weaving Division-II, B-24 To B-41 Jhanjharwada Industrial Area' .
        Register3 = 'Jhanjharwada, Neemuch-458441, Madhya Pradesh, India'.
        cin1 = 'U18108RJ1986PTC003788'.
      ENDIF.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      SELECT  a~AccountingDocument ,
                   a~OriginalReferenceDocument,
                   a~DocumentDate,
                   a~CompanyCode,
                   a~AccountingDocumentType,
                   a~FiscalYear,
                   SUM( a~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
                   a~DebitCreditCode ,
                   a~TransactionTypeDetermination,
                   a~financialaccounttype,
                   a~WithholdingTaxAmount FROM i_operationalacctgdocitem AS a
                   INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                          AND b~CompanyCode = a~CompanyCode
                                                          AND b~FiscalYear = a~FiscalYear )
                   INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                          AND c~CompanyCode = a~CompanyCode
                                                          AND c~FiscalYear = a~FiscalYear
                                                          AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
            WHERE a~Customer = @var AND a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode
            AND a~AccountingDocumentType <> 'WL' AND a~SpecialGLCode <> 'F' AND b~ProfitCenter = @profitcenter
            GROUP BY a~AccountingDocument ,
                   a~OriginalReferenceDocument,
                   a~DocumentDate,
                   a~CompanyCode,
                   a~AccountingDocumentType,
                   a~FiscalYear,
                    a~DebitCreditCode ,
                    a~TransactionTypeDetermination,
                    a~financialaccounttype,
                   a~WithholdingTaxAmount
            INTO TABLE @tab1.
    ENDIF.

    IF tab1 IS NOT INITIAL .
      READ TABLE tab1 INTO DATA(wa1) INDEX 1 .
    ENDIF .

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""OPENING BALANCE"""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF Profitcenter = '' .
      SELECT SUM( amountincompanycodecurrency )
         FROM i_operationalacctgdocitem
         WHERE Customer = @var AND
          CompanyCode = @companycode AND
          AccountingDocumentType NE 'GE' AND  AccountingDocumentType  NE 'WE' AND SpecialGLCode <> 'F'
          AND PostingDate LT @date3 INTO @DATA(opening).
    ELSEIF Profitcenter <> '' .

      SELECT SUM( a~amountincompanycodecurrency )
            FROM   i_operationalacctgdocitem AS a
            INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                         AND b~CompanyCode = a~CompanyCode
                                                         AND b~FiscalYear = a~FiscalYear
                                                          )
             WHERE a~Customer = @var AND
             a~CompanyCode = @companycode
             AND a~PostingDate LT @date3 AND b~ProfitCenter = @profitcenter
             AND a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE'
              AND a~SpecialGLCode <> 'F' INTO @opening.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""CLOSING BALANCE""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF Profitcenter = '' .
      SELECT SUM( amountincompanycodecurrency )
        FROM i_operationalacctgdocitem
        WHERE Customer = @var AND
         CompanyCode = @companycode AND
         AccountingDocumentType NE 'GE' AND AccountingDocumentType  NE 'WE' AND SpecialGLCode <> 'F'
         AND PostingDate LE @date2 INTO @DATA(closing_bal).
    ELSEIF  Profitcenter <> '' .
      SELECT SUM( a~amountincompanycodecurrency )
           FROM i_operationalacctgdocitem AS a
            INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                        AND b~CompanyCode = a~CompanyCode
                                                        AND b~FiscalYear = a~FiscalYear

                                                         )
           WHERE a~Customer = @var AND
            a~CompanyCode = @companycode AND
            a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
            AND a~PostingDate LE @date2 AND b~ProfitCenter = @profitcenter INTO @closing_bal.
    ENDIF.
    DATA(closing) =  closing_bal.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    SELECT SINGLE * FROM i_CUSTOMER  AS a
    LEFT OUTER JOIN I_BusinessPartnerBank AS b ON ( b~BusinessPartner = a~Customer )
    LEFT OUTER JOIN zcustomer_details AS c ON ( c~Customer = a~Customer )
    WHERE a~Customer = @var  INTO @DATA(Cust).
    DATA(lv_xml) =

      |<form1>| &&
      |<plantname>{ Register1 }</plantname>| &&
      |<address1>{ Register2 }</address1>| &&
      |<address2>{ Register3 }</address2>| &&
      |<address3></address3>| &&
      |<CINNO>{ cin1 }</CINNO>| &&
      |<GSTIN>{ gst1 }</GSTIN>| &&
      |<PAN>{ pan1 }</PAN>| &&
        |<LeftSide>| &&
         |<partyno>{ cust-a-CustomerName }</partyno>| &&
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

    DATA sum TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA sum1 TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA sum2 TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA TaxTds TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA Tds TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA DebitAmt TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

    SORT tab1 BY DocumentDate ASCENDING.
    LOOP AT tab1 INTO DATA(Wa2).


      SELECT SINGLE FROM i_journalentry
      FIELDS DocumentDate
        WHERE AccountingDocument = @Wa2-AccountingDocument AND CompanyCode = @Wa2-CompanyCode
        AND FiscalYear = @Wa2-FiscalYear INTO @DATA(tab2).

      SELECT SINGLE GLAccount FROM i_operationalacctgdocitem
           WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode
           AND AccountingDocument = @wa2-AccountingDocument  AND GLAccount <> '1850001003' AND GLAccount <> '3500001050'
           AND  ( AccountingDocumentItemType = '' OR AccountingDocumentItemType = 'R' ) AND  FinancialAccountType <> 'D' AND FinancialAccountType <> 'K'  INTO @DATA(gl).

      IF gl IS INITIAL .
        SELECT SINGLE customer AS GLAccount FROM i_operationalacctgdocitem
        WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode
        AND AccountingDocument = @wa2-AccountingDocument  AND FinancialAccountType = 'K'  INTO @gl.
      ENDIF.

      SELECT SINGLE * FROM I_GLAccountText
      WHERE GLAccount = @gl AND Language = 'E'
       INTO @DATA(tab7).


      IF tab7 IS INITIAL .
        SELECT SINGLE customername AS GLAccountLongName FROM i_customer
      WHERE customer = @gl INTO @tab7.
      ENDIF.

      DATA desc  TYPE string.

      desc = tab7-GLAccountLongName.



      IF Wa2-AccountingDocumentType = 'DZ'.

        SELECT SINGLE  AmountInCompanyCodeCurrency
                                    FROM i_operationalacctgdocitem
                                    WHERE accountingdocument = @wa2-accountingdocument
                                    AND GLAccount = '1850001003'
                                    AND CompanyCode = @wa2-CompanyCode
                                    AND FiscalYear = @wa2-FiscalYear
                                    INTO @DATA(amttds) .
      ENDIF.

      IF Wa2-DebitCreditCode = 'S' AND Wa2-AmountInCompanyCodeCurrency > 0.
        DATA(paisa) = Wa2-AmountInCompanyCodeCurrency  .
      ELSEIF

      Wa2-DebitCreditCode = 'H' OR Wa2-AmountInCompanyCodeCurrency < 0.
        DATA(paisa1) = Wa2-AmountInCompanyCodeCurrency .

      ENDIF.

      sum   =  sum + paisa + paisa1 + Wa2-WithholdingTaxAmount .
      sum1  = sum + opening.
      DebitAmt  =  paisa - Tds .

      IF  amttds <> 0.
        Tds  =  amttds  .
      ELSE .
        Tds = Wa2-WithholdingTaxAmount  .
      ENDIF.

      IF sum1 < 0 .
        sum2  =  sum1 * -1 .
      ELSE.
        sum2  = sum1 .
      ENDIF.


      IF wa2-AccountingDocumentType = 'DZ' AND wa2-FinancialAccountType = 'D'.

        DATA: CreditAmt TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency.
        CreditAmt  = ( paisa1 * -1 ).




      ELSE.
        IF paisa1 < 0 .
          CreditAmt  = ( paisa1 * -1 ) - Tds.
        ELSE.
          CreditAmt   =  paisa1 - Tds .
        ENDIF.

      ENDIF.




      TaxTds = TaxTds + Wa2-WithholdingTaxAmount .

***********************************************************************************************
      SELECT accountingdocument,
      SUM( AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency ,
       transactiontypedetermination, profitcenter, accountingdocumenttype, financialaccounttype
       FROM i_operationalacctgdocitem
       WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode
       AND AccountingDocument = @wa2-AccountingDocument AND AccountingDocumentType = @wa2-AccountingDocumentType
       GROUP BY
       accountingdocument,
       transactiontypedetermination,
       profitcenter,
       accountingdocumenttype,
       financialaccounttype
       INTO TABLE @DATA(tab).

      LOOP AT tab INTO DATA(wtab) .
        CASE wtab-TransactionTypeDetermination.
          WHEN 'JOS' OR 'JOC' OR 'JIS' OR 'JIC' .
            DATA(csgst) = wtab-AmountInCompanyCodeCurrency.
          WHEN 'JII' OR 'JIM'.
            DATA(Igst) = wtab-AmountInCompanyCodeCurrency.
          WHEN 'SKE'.
            DATA(cdrdvalue)  = wtab-AmountInCompanyCodeCurrency.
          WHEN 'WRX'.
            DATA(value)  = wtab-AmountInCompanyCodeCurrency.
          WHEN 'KBS' OR 'EGK' .
            IF wtab-AccountingDocumentType = 'RE' OR wtab-AccountingDocumentType = 'KR'.
              DATA(totelcredit)  = wtab-AmountInCompanyCodeCurrency.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      LOOP AT tab INTO wtab WHERE ProfitCenter <> '' AND TransactionTypeDetermination = ''  .

        DATA(valuesum) = wtab-AmountInCompanyCodeCurrency  .

*IF WTAB-AccountingDocumentType = 'DZ' AND WTAB-FINANCIALACCOUNTTYPE = 'S' AND WTAB-ProfitCenter <> ''.
*
*CreditAmt = WTAB-amountincompanycodecurrency + TDS.
*ENDIF.
      ENDLOOP.



*******************************************************************************************
      DATA(lv_xml2) =
          |<LopTab>| &&
          |<Row1>| &&
          |<docno>{ wa2-OriginalReferenceDocument+0(10) }</docno>| &&
          |<docdate>{ tab2  }</docdate>| &&
          |<particulars>{ desc  }</particulars>| &&
          |<doctype>{ Wa2-AccountingDocumentType }</doctype>| &&
          |<Value>{ valuesum }</Value>| &&
          |<cdrd>{ cdrdvalue }</cdrd>| &&
          |<IGST>{ Igst }</IGST>| &&
          |<CGST>{ csgst }</CGST>| &&
          |<SGST>{ csgst }</SGST>| &&
          |<Tdsamt>{ Tds }</Tdsamt>| &&
          |<debitamt>{ DebitAmt }</debitamt>| &&
          |<creditamt>{ CreditAmt }</creditamt>| &&
          |<Balance>{ sum2 }</Balance>| &&
          |</Row1>| &&
          |</LopTab>|.

      CONCATENATE xsml lv_xml2 INTO  xsml .
      CLEAR : paisa,paisa1,desc,sum2,DebitAmt,CreditAmt,Tds,wa2,tab2,amttds,gl,tab7,csgst,Igst,valuesum.

    ENDLOOP.
    DATA closingbl TYPE i_operationalacctgdocitem-AmountInCompanyCodeCurrency .


    closingbl = closing + TaxTds.

    DATA(lv_xml3) =
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

    CONCATENATE lv_xml xsml lv_xml3 INTO lv_xml .

    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
