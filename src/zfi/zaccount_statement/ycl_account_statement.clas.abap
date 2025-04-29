CLASS ycl_account_statement DEFINITION
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



CLASS YCL_ACCOUNT_STATEMENT IMPLEMENTATION.


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
                a~DocumentDate,
                a~CompanyCode,
                a~AccountingDocumentType,
                a~FiscalYear,
                SUM( a~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
                a~DebitCreditCode ,
                a~WithholdingTaxAmount,
                a~transactiontypedetermination,
                SUM( a~CashDiscountAmount ) AS CashDiscountAmount  FROM i_operationalacctgdocitem AS a
         INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                       AND c~CompanyCode = a~CompanyCode
                                                       AND c~FiscalYear = a~FiscalYear
                                                       AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
        WHERE a~Supplier = @var AND a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode AND a~SpecialGLCode NE 'F'
        AND ( a~AccountingDocumentType = 'RE' OR a~AccountingDocumentType = 'KR' OR a~AccountingDocumentType = 'AA'
           OR a~AccountingDocumentType = 'KG' OR a~AccountingDocumentType = 'K6' OR a~AccountingDocumentType = 'KZ'
           OR a~AccountingDocumentType = 'AA' OR a~AccountingDocumentType = 'SA' OR a~AccountingDocumentType = 'KC'
           OR a~AccountingDocumentType = 'RK' OR a~AccountingDocumentType = 'ZA' OR a~AccountingDocumentType = 'UE'
           OR a~AccountingDocumentType = 'KA' )
           AND ( a~FinancialAccountType = 'K' )
                 GROUP BY a~AccountingDocument ,
                a~DocumentDate,
                a~CompanyCode,
                a~AccountingDocumentType,
                a~FiscalYear,
                a~DebitCreditCode ,
                a~WithholdingTaxAmount,
                a~transactiontypedetermination

        INTO TABLE @DATA(tab1).

      DATA gst1 TYPE string .
      DATA cin1 TYPE string .
      DATA pan1 TYPE string .
      DATA Register1 TYPE string .
      DATA Register2 TYPE string .
      DATA Register3 TYPE string .

      IF companycode   =  '' .

        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.

      ELSEIF companycode   =  '' .

        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.

      ENDIF.
    ELSEIF  Profitcenter <> '' .

      IF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ELSEIF Profitcenter  = ''.
        gst1  = ''.
        pan1  = ''.
        Register1 = ''.
        Register2 = '' .
        Register3 = ''.
        cin1 = ''.
      ENDIF.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      SELECT  a~AccountingDocument ,
                  a~DocumentDate,
                  a~CompanyCode,
                  a~AccountingDocumentType,
                  a~FiscalYear,
                  SUM( a~AmountInCompanyCodeCurrency )  AS AmountInCompanyCodeCurrency,
                  a~DebitCreditCode ,
                  a~WithholdingTaxAmount,
                  a~transactiontypedetermination,
                  SUM( a~CashDiscountAmount ) AS CashDiscountAmount FROM i_operationalacctgdocitem AS a
                  INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                         AND b~CompanyCode = a~CompanyCode
                                                         AND b~FiscalYear = a~FiscalYear )
                 INNER JOIN I_JournalEntry  AS c ON (  c~AccountingDocument = a~AccountingDocument
                                                         AND c~CompanyCode = a~CompanyCode
                                                         AND c~FiscalYear = a~FiscalYear
                                                         AND c~IsReversal <> 'X' AND c~IsReversed <> 'X' )
                    WHERE a~Supplier = @var AND a~PostingDate GE @date3 AND a~PostingDate LE @date2 AND a~CompanyCode = @companycode AND a~SpecialGLCode NE 'F'
          AND ( a~AccountingDocumentType = 'RE' OR a~AccountingDocumentType = 'KR' OR a~AccountingDocumentType = 'AA'
             OR a~AccountingDocumentType = 'KG' OR a~AccountingDocumentType = 'K6' OR a~AccountingDocumentType = 'KZ'
             OR a~AccountingDocumentType = 'AA' OR a~AccountingDocumentType = 'SA' OR a~AccountingDocumentType = 'KC'
             OR a~AccountingDocumentType = 'RK' OR a~AccountingDocumentType = 'ZA' OR a~AccountingDocumentType = 'UE'
             OR a~AccountingDocumentType = 'KA' )
              AND b~ProfitCenter = @profitcenter
                   GROUP BY a~AccountingDocument ,
                  a~DocumentDate,
                  a~CompanyCode,
                  a~AccountingDocumentType,
                  a~FiscalYear,
                  a~DebitCreditCode ,
                  a~WithholdingTaxAmount,
                  a~transactiontypedetermination

          INTO TABLE @tab1.

    ENDIF.

    IF tab1 IS NOT INITIAL .
      READ TABLE tab1 INTO DATA(wa1) INDEX 1 .
    ENDIF .

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""OPENING BALANCE"""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF Profitcenter = '' .

      SELECT SUM( amountincompanycodecurrency )
         FROM i_operationalacctgdocitem AS a  WHERE a~Supplier = @var AND
          a~CompanyCode = @companycode  AND
          a~AccountingDocumentType NE 'GE' AND  a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
          AND a~PostingDate LT @date3 INTO @DATA(opening).

    ELSEIF Profitcenter <> '' .

      SELECT SUM( a~amountincompanycodecurrency )
             FROM i_operationalacctgdocitem AS a
                 INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                          AND b~CompanyCode = a~CompanyCode
                                                          AND b~FiscalYear = a~FiscalYear )
             WHERE a~Supplier = @var AND
              a~CompanyCode = @companycode AND
              a~AccountingDocumentType NE 'GE' AND  a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
              AND a~PostingDate LT @date3 AND b~ProfitCenter = @profitcenter INTO @opening.

    ENDIF.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""CLOSING BALANCE""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF profitcenter = '' .

      SELECT SUM( amountincompanycodecurrency )
         FROM i_operationalacctgdocitem AS a
         WHERE a~Supplier = @var AND
          a~CompanyCode = @companycode  AND
          a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
          AND a~PostingDate LE @date2 INTO @DATA(closing_bal).

    ELSEIF profitcenter <> '' .

      SELECT SUM( a~amountincompanycodecurrency )
      FROM i_operationalacctgdocitem AS a
      INNER JOIN zjournalentry_item AS b ON (  b~AccountingDocument = a~AccountingDocument
                                                   AND b~CompanyCode = a~CompanyCode
                                                   AND b~FiscalYear = a~FiscalYear )
      WHERE a~Supplier = @var AND
       a~CompanyCode = @companycode AND
       a~AccountingDocumentType NE 'GE' AND a~AccountingDocumentType  NE 'WE' AND a~SpecialGLCode <> 'F'
       AND a~PostingDate LE @date2 AND b~ProfitCenter = @profitcenter INTO @closing_bal.

    ENDIF.

    DATA(closing) =  closing_bal.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SELECT SINGLE * FROM i_supplier AS a
    LEFT OUTER  JOIN I_SuplrBankDetailsByIntId AS b ON ( b~Supplier = a~Supplier  )
     LEFT OUTER  JOIN  I_Bank_2 AS f ON ( f~BankInternalID = b~Bank  )  WHERE a~Supplier = @var  INTO @DATA(supplier).
*   SELECT SINGLE * FROM ZSUPPLIER_DETAILS where Supplier = @var  into @DATA(email).

    """""""""""""""""""""""""""""""""""""""""""""""Address"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
 |<partyno>{ supplier-a-SupplierName }</partyno>| &&
*   |<partyno2>{ email-StreetPrefixName1 }</partyno2>| &&
*   |<partyno3>{ email-StreetPrefixName2 }</partyno3>| &&
 |<partyadd>{ supplier-a-CityName }-{ supplier-a-PostalCode }</partyadd>| &&
 |<partyadd1>{ supplier-a-TaxNumber3 }</partyadd1>| &&
*   |<PHNNO>{ email-PhoneNumber1 }</PHNNO>| &&
*   |<EMAIL>{ email-EmailAddress }</EMAIL>| &&
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
    |<BankName>{ supplier-f-BankName }</BankName>| &&
    |<AccountNo>{ supplier-b-BankAccount }</AccountNo>| &&
    |<IFSC>{ supplier-b-Bank }</IFSC>| &&
    |</BankDetail>| &&
    |<chk_mark>{ confirmletterbox }</chk_mark>| .

    DATA sum TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA sum1 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA sum2 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

    DATA TaxTds TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    DATA Tds TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

    SORT tab1 BY DocumentDate ASCENDING.
    LOOP AT tab1 INTO DATA(Wa2).

      SELECT SINGLE AmountInCompanyCodeCurrency FROM i_operationalacctgdocitem
      WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode AND TransactionTypeDetermination = 'WIT'
      AND AccountingDocument = @wa2-AccountingDocument AND AccountingDocumentType = @wa2-AccountingDocumentType
      INTO @Wa2-WithholdingTaxAmount.

********************************************************************
      SELECT accountingdocument, AmountInCompanyCodeCurrency, transactiontypedetermination, profitcenter, accountingdocumenttype
       FROM i_operationalacctgdocitem
      WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode
      AND AccountingDocument = @wa2-AccountingDocument AND AccountingDocumentType = @wa2-AccountingDocumentType
       INTO TABLE @DATA(tab).

      LOOP AT tab INTO DATA(wtab) .
        DATA csgst TYPE p DECIMALS 2.
        DATA Sgct TYPE p DECIMALS 2.
        DATA Igst TYPE p DECIMALS 2.
        DATA cdrdvalue TYPE p DECIMALS 2.
        DATA value TYPE p DECIMALS 2.
        DATA totelcredit TYPE p DECIMALS 2.


        CASE wtab-TransactionTypeDetermination.
          WHEN 'JIC' .
            csgst  = csgst +  wtab-AmountInCompanyCodeCurrency.
          WHEN 'JIS' .
            Sgct   = Sgct +  wtab-AmountInCompanyCodeCurrency.
          WHEN 'JII' OR 'JIM'.
            Igst = Igst + wtab-AmountInCompanyCodeCurrency.
          WHEN 'SKE'.
            cdrdvalue  =  cdrdvalue + wtab-AmountInCompanyCodeCurrency.
          WHEN 'WRX' OR 'AGD' OR 'BSX'  OR 'PRD' OR 'RKA' OR 'ANL' OR 'PK2'.
            value  = value + wtab-AmountInCompanyCodeCurrency.
          WHEN 'KBS' OR 'EGK' .
            IF wtab-AccountingDocumentType = 'RE' OR wtab-AccountingDocumentType = 'KR'.
              totelcredit  = totelcredit +  wtab-AmountInCompanyCodeCurrency.
            ENDIF.
        ENDCASE.

      ENDLOOP.


      LOOP AT tab INTO wtab WHERE ProfitCenter <> '' AND TransactionTypeDetermination = ''  .

        DATA(valuesum) = wtab-AmountInCompanyCodeCurrency.


      ENDLOOP.

      IF wtab-AccountingDocumentType = 'RE'  OR wtab-AccountingDocumentType = 'KG'.
        valuesum = value .
      ENDIF.

      IF valuesum = 0.
        valuesum = value.
      ENDIF.

*************************************************************************
      SELECT SINGLE FROM i_journalentry
      FIELDS DocumentReferenceID,DocumentDate
      WHERE AccountingDocument = @Wa2-AccountingDocument AND CompanyCode = @Wa2-CompanyCode
      AND FiscalYear = @Wa2-FiscalYear INTO @DATA(tab2).

      SELECT SINGLE GLAccount FROM i_operationalacctgdocitem
      WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode AND AccountingDocument = @wa2-AccountingDocument AND AccountingDocumentType = @wa2-AccountingDocumentType
      AND GLAccount NE '2500001000' AND GLAccount NE '2500002000' AND GLAccount NE '2500003000' AND GLAccount NE '2500004000'
      AND GLAccount NE '2700001010' AND GLAccount NE '2700001020' AND GLAccount NE '2700001030' AND GLAccount NE '2700001040'
      AND GLAccount NE '2700001050' AND GLAccount NE '2700001060' AND GLAccount NE '2700001070'
      AND GLAccount NE '2700001080' AND GLAccount NE '2700001090' AND GLAccount NE '2700001100'
      AND GLAccount NE '2700002000' AND GLAccount NE '2700004000' AND GLAccount NE '2700004010' AND GLAccount NE '2700004020' AND GLAccount NE '2700004030'
      AND GLAccount NE '2700004500' AND GLAccount NE '2700004510' AND GLAccount NE '2700004520' AND GLAccount NE '3500001410'
      AND AccountingDocumentItemType <> 'T' INTO @DATA(gl).

      IF gl IS INITIAL .
        SELECT SINGLE supplier AS GLAccount FROM i_operationalacctgdocitem
        WHERE  FiscalYear = @wa2-FiscalYear AND CompanyCode = @wa2-CompanyCode
        AND AccountingDocument = @wa2-AccountingDocument  AND FinancialAccountType = 'K'  INTO @gl.
      ENDIF.

      SELECT SINGLE GLAccountLongName FROM I_GLAccountText
      WHERE GLAccount = @gl AND Language = 'E'
      INTO @DATA(tab7).

      IF tab7 IS INITIAL .
        SELECT SINGLE suppliername AS GLAccountLongName FROM i_supplier
      WHERE supplier = @gl INTO @tab7.
      ENDIF.


      IF Wa2-DebitCreditCode = 'S' AND Wa2-AmountInCompanyCodeCurrency > 0.
        DATA paisa TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
        DATA cdpaisa TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
        DATA tdsdebit TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .

        IF wa2-AccountingDocumentType = 'KZ' .
          paisa = Wa2-AmountInCompanyCodeCurrency .
*    PAISA = Wa2-AmountInCompanyCodeCurrency + Wa2-cashdiscountamount .
          cdpaisa = Wa2-AmountInCompanyCodeCurrency.
          tdsdebit = Wa2-WithholdingTaxAmount .
        ELSE.
          paisa = Wa2-AmountInCompanyCodeCurrency - Wa2-cashdiscountamount .
*    PAISA = Wa2-AmountInCompanyCodeCurrency + Wa2-cashdiscountamount .
          cdpaisa = Wa2-AmountInCompanyCodeCurrency.
          tdsdebit = Wa2-WithholdingTaxAmount .
        ENDIF.

      ELSEIF
      Wa2-DebitCreditCode = 'H' OR Wa2-AmountInCompanyCodeCurrency < 0 .
        DATA paisa1 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
        paisa1 = Wa2-AmountInCompanyCodeCurrency .
      ENDIF.

      DATA desc TYPE string .
      IF Wa2-AccountingDocumentType = 'RE' OR Wa2-AccountingDocumentType = 'UE'  .

        desc = 'PURCHASE'.

      ELSEIF Wa2-AccountingDocumentType = 'KC'.
        desc = 'CREDIT NOTE'.

      ELSEIF Wa2-AccountingDocumentType = 'KG' OR Wa2-AccountingDocumentType = 'ZA' OR Wa2-AccountingDocumentType = 'RK'.
        desc = 'DEBIT NOTE'.

      ELSE.
        desc = tab7.

      ENDIF.


      sum   =  sum + cdpaisa + paisa1 + tdsdebit  .
      sum1  = sum + opening.
      TaxTds = TaxTds + Wa2-WithholdingTaxAmount .

      IF sum1 < 0 .
        sum2  =  sum1 * -1 .
      ELSE.
        sum2  = sum1 .
      ENDIF.

      IF paisa1 < 0 .
        DATA paisa2 TYPE  i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
        paisa2  =  ( paisa1 + Wa2-WithholdingTaxAmount ) * -1  .
      ELSEIF paisa1 > 0.
        paisa2   =  paisa1 + Wa2-WithholdingTaxAmount  .
      ENDIF.

      IF Wa2-WithholdingTaxAmount  < 0 .
        Tds  =  Wa2-WithholdingTaxAmount  * 1 .
      ELSE.
        Tds  = Wa2-WithholdingTaxAmount  .
      ENDIF.


      IF valuesum = 0.
        valuesum = paisa2 .
        IF valuesum = 0.
          valuesum =  paisa.
        ENDIF.
      ENDIF.
      IF totelcredit = 0 .
        totelcredit = paisa2.
      ENDIF.

      DATA(lv_xml2) =
     |<LopTab>| &&
       |<Row1>| &&
          |<docno>{ Tab2-DocumentReferenceID }</docno>| &&
          |<docdate>{ tab2-DocumentDate  }</docdate>| &&
          |<particulars>{ desc  }</particulars>| &&
          |<doctype>{ Wa2-AccountingDocumentType }</doctype>| &&
          |<Value>{ valuesum }</Value>| &&
          |<cdrd>{ cdrdvalue }</cdrd>| &&
          |<IGST>{ Igst }</IGST>| &&
          |<CGST>{ csgst }</CGST>| &&
          |<SGST>{ Sgct }</SGST>| &&
          |<Tdsamt>{ Tds }</Tdsamt>| &&
          |<tcs></tcs>| &&
          |<debitamt>{ paisa }</debitamt>| &&
          |<creditamt>{ totelcredit }</creditamt>| &&
          |<Balance>{ sum2 }</Balance>| &&
       |</Row1>| &&
       |</LopTab>|.

      CONCATENATE xsml lv_xml2 INTO  xsml .
      CLEAR : paisa,paisa1,desc,paisa2,tdsdebit,gl,tab7,tab2,Wa2,Tds, cdpaisa, csgst, Sgct,Igst, cdrdvalue,value,valuesum,totelcredit.

    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " data(closingbl) = CLOSING + TaxTds.
    DATA closingbl TYPE   i_operationalacctgdocitem-AmountInCompanyCodeCurrency .
    closingbl = closing .

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
