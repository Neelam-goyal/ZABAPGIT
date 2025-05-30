CLASS zcl_fi_voucher_print_dr DEFINITION
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
        IMPORTING lv_belnr2       TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zfi_voucher_print/zfi_voucher_print'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_FI_VOUCHER_PRINT_DR IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

    SELECT SINGLE a~AccountingDocument,
                  a~PostingDate,
                  a~DocumentDate,
                  a~FinancialAccountType,
*                  a~Supplier,
*                  a~Customer,
                  d~DocumentReferenceID,
*                  a~AssignmentReference,
                  a~AccountingDocumentType
*                  b~CustomerName,
*                  c~SupplierName
     FROM I_OperationalAcctgDocItem AS a
*     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
*     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
     LEFT join i_journalentry as d on a~AccountingDocument = d~AccountingDocument and a~CompanyCode = d~CompanyCode and a~FiscalYear = d~FiscalYear
     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
       a~AccountingDocument =  @lv_belnr2 "'1300000014'
*       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
     INTO @DATA(wa).


         SELECT SINGLE
                  a~Supplier,
                  a~Customer,
                  a~AccountingDocumentType,
                  b~CustomerName,
                  c~SupplierName
     FROM I_OperationalAcctgDocItem AS a
     LEFT JOIN I_Customer AS b ON a~Customer = b~Customer
     LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
     LEFT join i_journalentry as d on a~AccountingDocument = d~AccountingDocument and a~CompanyCode = d~CompanyCode and a~FiscalYear = d~FiscalYear
     WHERE "( a~Supplier IS NOT INITIAL OR a~Customer IS NOT INITIAL )  AND
       a~AccountingDocument =  @lv_belnr2 "'1300000014'
       and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
     INTO @DATA(CustVen).


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
          WHERE AccountingDocument =  @lv_belnr2 "'1300000014'
          AND a~TransactionTypeDetermination NE 'AGX'
          AND a~TransactionTypeDetermination NE 'EGX'
          INTO TABLE @DATA(it_lines).





****** Variables ******
    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
   IF CustVen-Supplier IS NOT INITIAL AND CustVen-SupplierName IS NOT INITIAL.
    CONCATENATE: CustVen-Supplier CustVen-SupplierName INTO Vendor SEPARATED BY ' / '.
    endif.
    IF CustVen-Customer IS NOT INITIAL AND CustVen-CustomerName IS NOT INITIAL.
    DATA : Customer TYPE String.
*    CONCATENATE: wa-Customer wa-CustomerName INTO Customer SEPARATED BY space.
    CONCATENATE CustVen-Customer CustVen-CustomerName INTO Customer SEPARATED BY ' / '.
    endif.
* Header
    DATA(lv_xml) =    |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
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

    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD .
ENDCLASS.
