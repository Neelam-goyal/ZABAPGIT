CLASS ztest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

      SELECT SINGLE a~AccountingDocument,
                  a~PostingDate,
                  a~DocumentDate,
                  a~FinancialAccountType,
                  a~Supplier,
                  a~CompanyCode,
                  a~Customer,
                  d~DocumentReferenceID,
*                  a~AssignmentReference,
                  a~AccountingDocumentType,
                  b~CustomerName,
                  c~SupplierName
     FROM I_OperationalAcctgDocItem AS a
     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
     LEFT join i_journalentry as d on a~AccountingDocument = d~AccountingDocument and a~CompanyCode = d~CompanyCode and a~FiscalYear = d~FiscalYear
     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
       a~AccountingDocument = '1900000000' "@lv_belnr2 "'1300000014'
       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
     INTO @DATA(wa).

*
*     SELECT SINGLE CompanyCode
*     FROM I_OperationalAcctgDocItem
*     where I_OperationalAcctgDocItem~AccountingDocument = @WA-AccountingDocument
*     INTO @DATA(wa2).


****** Item ******
*    SELECT a~GLAccount , a~AmountInCompanyCodeCurrency, a~DocumentItemText, b~GLAccountName ,
*           c~CostCenter , c~CostCenterName , d~ProfitCenter , d~ProfitCenterName
*    FROM I_OperationalAcctgDocItem AS a
**    LEFT JOIN i_cnsldtnglaccountvh AS b ON a~GLAccount = b~GLAccount
*    Left JOIN I_GLACCOUNTTEXTRAWDATA AS b ON a~GLAccount = b~GLAccount
*    LEFT JOIN i_costcentertext AS c ON a~CostCenter = c~CostCenter AND c~Language = 'E'
*    LEFT JOIN i_profitcentertext AS d ON a~ProfitCenter = d~ProfitCenter AND d~Language = 'E'
*    WHERE AccountingDocument =  @lv_belnr2 "'1300000014'
*    INTO TABLE @DATA(it_lines).

   SELECT a~GLAccount , a~AmountInCompanyCodeCurrency , a~DocumentItemText, a~GLAccountName, a~TransactionTypeDetermination,
          a~CostCenter , a~CostCenterName , a~ProfitCenter , a~ProfitCenterName
          FROM zcdsVoucher AS a
          WHERE AccountingDocument = '4900000009' "@lv_belnr2 "'1300000014'
          AND a~TransactionTypeDetermination NE 'AGX'
          AND a~TransactionTypeDetermination NE 'EGX'
          INTO TABLE @DATA(it_lines).





****** Variables ******
    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
   IF wa-Supplier IS NOT INITIAL AND wa-SupplierName IS NOT INITIAL.
    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY ' / '.
    endif.
    IF wa-Customer IS NOT INITIAL AND wa-CustomerName IS NOT INITIAL.
    DATA : Customer TYPE String.
*    CONCATENATE: wa-Customer wa-CustomerName INTO Customer SEPARATED BY space.
    CONCATENATE wa-Customer wa-CustomerName INTO Customer SEPARATED BY ' / '.
    endif.
* Header
    DATA(lv_xml) =    |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
                      |<CompanyCode>{ wa-CompanyCode }</CompanyCode>| &&
*                      |<AccountingDocument> 1233 </AccountingDocument>| &&
                      |<AccountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
                      |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
                      |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
                      |<DocumentReferenceID>{ wa-DocumentReferenceID }</DocumentReferenceID>| && "0002000004
                      |<DocumentDate>{ wa-DocumentDate }</DocumentDate>| &&
                      |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
                      |<Vendor>{ Vendor }</Vendor>| &&
                      |<Customer>{ Customer }</Customer>| &&
*                      |<CustomerName>{ wa-CustomerName }</CustomerName>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.

* Item
    LOOP AT it_lines INTO DATA(wa_lines).
      DATA(lv_xml1) = |<tableDataRows>| &&
                   |<GLAccount>{ wa_lines-GLAccount }</GLAccount>| &&
                   |<GLAccountName>{ wa_lines-GLAccountName }</GLAccountName>| &&
*                   |<GLAccountName> A/P - Capital Goods </GLAccountName>| &&
                   |<ProfitCenter>{ wa_lines-ProfitCenter }</ProfitCenter>| &&
                   |<ProfitCenterDescription>{ wa_lines-ProfitCenterName }</ProfitCenterDescription>| &&
                   |<CostCenter>{ wa_lines-CostCenter }</CostCenter>| &&
                   |<CostCenterDescription>{ wa_lines-CostCenterName }</CostCenterDescription>| &&
                   |<AmountInCompanyCodeCurrency>{ wa_lines-AmountInCompanyCodeCurrency }</AmountInCompanyCodeCurrency>| &&
                   |<DebitAmountInCoCodeCrcy>{ wa_lines-AmountInCompanyCodeCurrency }</DebitAmountInCoCodeCrcy>| &&
                   |<Narration>{ wa_lines-DocumentItemText }</Narration>| &&
                   |</tableDataRows>| .

      CLEAR : wa_lines.
      CONCATENATE: lv_xml lv_xml1 INTO lv_xml.
    ENDLOOP.
    DATA(lv_xml2) = |</Table>| &&
                    |</AccountingRow>| &&
                    |</Form>|.
    CONCATENATE: lv_xml lv_xml2 INTO lv_xml.

*    CALL METHOD zcl_ads_print=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
