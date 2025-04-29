CLASS ztest_class_jv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

  TYPES: BEGIN OF ty_final,
           AccountingDocument      TYPE i_operationalacctgdocitem-AccountingDocument,
               GLAccount                 TYPE i_operationalacctgdocitem-GLAccount,
           CompanyCode             type i_operationalacctgdocitem-CompanyCode,
           AbsoluteAmountInCoCodeCrcy TYPE i_operationalacctgdocitem-AbsoluteAmountInCoCodeCrcy,
           SupplierName            TYPE i_supplier-SupplierName,
           CustomerName            TYPE i_customer-CustomerName,
           GLAccountLongName       TYPE I_GLAccountTextRawData-GLAccountLongName,
           DebitCreditCode         type i_operationalacctgdocitem-DebitCreditCode,
           DocumentItemText        type i_operationalacctgdocitem-DocumentItemText,
           AccountName TYPE STRING,
            DEBIT TYPE STRING,
            CREDIT TYPE STRING,
            REMARKS TYPE STRING,
            DebitRemarks TYPE STRING,
            CreditRemarks TYPE STRING,

       END OF ty_final.

      DATA: lt_final TYPE TABLE OF ty_final,
            wa_final TYPE ty_final.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS_JV IMPLEMENTATION.


method if_oo_adt_classrun~main.


*DATA(TEST) = '100000025'.
*      DATA VAR TYPE char10 .
*       VAR   = |{ TEST ALPHA = IN }|.
*OUT->write( VAR )  .

******************************* HEADER *****************************
    SELECT SINGLE
     FROM i_operationalacctgdocitem AS a
     LEFT JOIN I_CompanyCode AS b ON a~CompanyCode = b~CompanyCode
     left join i_address_2 as c on b~AddressID = c~AddressID
     fields b~CompanyCodeName,
            c~HouseNumber, c~StreetName, c~CityName, c~PostalCode, c~Region, c~Country,
            a~AccountingDocument, a~PostingDate, a~NetDueDate, a~DocumentDate , a~CompanyCode
     where a~AccountingDocument = '0100000003' "@LV_BELNR2
*      and   a~CompanyCode = @lv_companycode
     INTO @DATA(wa)
     privileged access.



******************************* LINE ITEM *****************************
DATA: lt_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

*************** SUPPLIER & CUSTOMER
SELECT
    a~AccountingDocument,
    a~GLAccount,
    a~AbsoluteAmountInCoCodeCrcy,
    a~DebitCreditCode,
    a~DocumentItemText,
    b~SupplierName,
    c~CustomerName
FROM i_operationalacctgdocitem AS a
LEFT JOIN i_supplier AS b ON a~Supplier = b~Supplier
LEFT JOIN i_customer AS c ON a~Customer = c~Customer
where a~AccountingDocument = '0100000003' "@LV_BELNR2
*    and   a~CompanyCode = @lv_companycode
    and DebitCreditCode IN ( 'S', 'H' )
INTO CORRESPONDING FIELDS OF TABLE @lt_final
privileged access.



***************** GLAccountLongName AND OTHER CONDITIONS.
LOOP AT lt_final INTO DATA(WA_TEST).

IF WA_TEST-suppliername IS INITIAL AND WA_TEST-customername IS INITIAL.
    SELECT single
        a~GLAccount,
        b~GLAccountLongName
    FROM i_operationalacctgdocitem AS a
    LEFT JOIN I_GLAccountTextRawData AS b ON a~GLAccount = b~GLAccount
    where a~AccountingDocument = '0100000003' "@LV_BELNR2
*     and   a~CompanyCode = @lv_companycode
    INTO (@wa_test-GLAccountLongName , @wa_test-GLAccount).
ENDIF.

**************************** DEBIT / DebitRemarks / CREDIT / CreditRemarks
       IF wa_test-DebitCreditCode = 'S'.
         WA_TEST-DEBIT = wa_test-absoluteamountincocodecrcy.
         WA_TEST-REMARKS = wa_test-documentitemtext.
       elseif wa_test-debitcreditcode = 'H'.
         WA_TEST-CREDIT = wa_test-absoluteamountincocodecrcy.
         WA_TEST-REMARKS = wa_test-documentitemtext.
      ENDIF.


IF WA_TEST-suppliername IS NOT INITIAL .
        wa_test-accountname = wa_test-suppliername.
elseif WA_TEST-customername IS NOT INITIAL .
        wa_test-accountname = wa_test-customername.
elseif WA_TEST-glaccountlongname IS NOT INITIAL.
        wa_test-accountname = wa_test-glaccountlongname.
endif.


MODIFY lt_final from wa_test.
clear: wa_test.

ENDLOOP.


************* VARIABLES
         DATA:  CompanyAddress1 TYPE String.
         DATA:  CompanyAddress2 TYPE String.

    CONCATENATE: wa-HouseNumber wa-StreetName INTO CompanyAddress1 SEPARATED BY space.
    CONCATENATE: wa-CityName '-' wa-StreetName wa-PostalCode wa-Region wa-Country INTO CompanyAddress2 SEPARATED BY space.


* Header
    DATA(lv_xml) =    |<Form>| &&
                      |<AccountingRow>| &&
                      |<InternalDocumentNode>| &&
                      |<CompanyName>{ wa-CompanyCodeName }</CompanyName>| &&
                      |<CompanyCode>{ wa-CompanyCode }</CompanyCode>| &&
                      |<CompanyAddress1>{ CompanyAddress1 }</CompanyAddress1>| &&
                      |<CompanyAddress2>{ CompanyAddress2 }</CompanyAddress2>| &&
                      |<DocumentNumber>{ wa-AccountingDocument }</DocumentNumber>| &&
                      |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
                      |<DueDate>{ wa-NetDueDate }</DueDate>| &&
*                      |<TransactionCode>{ wa-CustomerName }</TransactionCode>| &&
                      |<DocumentDate>{ wa-DocumentDate }</DocumentDate>| &&
                      |</InternalDocumentNode>| &&
                      |<Table>|.


* Item
    LOOP AT lt_final INTO DATA(wa_lines).

      DATA(lv_xml1) = |<tableDataRows>| &&
                   |<AccountCode>{ wa_lines-glaccount }</AccountCode>| &&
                   |<AccountNameDate>{ wa_lines-AccountName }</AccountNameDate>| &&
*                   |<Project>{  }</Project>| &&
                   |<Debit>{ wa_lines-DEBIT }</Debit>| &&
                   |<Credit>{ wa_lines-CREDIT }</Credit>| &&
                   |<Remarks>{ wa_lines-REMARKS }</Remarks>| &&
                   |</tableDataRows>| .

      CLEAR : wa_lines.
      CONCATENATE: lv_xml lv_xml1 INTO lv_xml.
    ENDLOOP.

    DATA(lv_xml2) = |</Table>| &&
                    |</AccountingRow>| &&
                    |</Form>|.
    CONCATENATE: lv_xml lv_xml2 INTO lv_xml.


ENDMETHOD.
ENDCLASS.
