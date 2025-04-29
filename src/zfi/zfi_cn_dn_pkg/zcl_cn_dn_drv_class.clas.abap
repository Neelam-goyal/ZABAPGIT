CLASS zcl_cn_dn_drv_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*   INTERFACES if_oo_adt_classrun.
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
    CONSTANTS lc_template_name TYPE string VALUE 'Zbndebitcredit/Zdebitcredit'.
**    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_CN_DN_DRV_CLASS IMPLEMENTATION.


 METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

   ENDMETHOD.


    METHOD read_posts .

*    "" header level data """"""""""""
     SELECT SINGLE
    a~companycode,
    a~fiscalyear,
     a~plant,
     c~addressid,
    "" first box ""
    a~supplierinvoice,
    a~postingdate,
    b~companycodeName,
    d~housenumber,
    d~floor,
    d~districtname,
    d~cityname,
    d~postalcode,
    d~region,
    d~country,
*    f~regionname,
*    f~region AS region1,
""layout secondbox"""

    a~invoicingparty,
     g~taxnumber3,
    g~suppliername,
    g~streetname,    "" supplier add
    g~postalcode AS supplierpostalcode,
    g~cityname AS suppliercityname,
    g~country AS suppliercountry,
    g~region AS supplierregion,
    f~regionname AS statediscription,
    g~region AS statecode,
    h~businesspartnerpannumber,

    """" third layoutbox """""

    a~purchaseorder,
    i~creationdate,
    a~supplierinvoiceidbyinvcgparty,
    a~documentdate,
    """Footer level """"

    a~supplierinvoiceidbyinvcgparty  as Footer
    FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
     LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS AS b ON a~CompanyCode = b~CompanyCode
   LEFT JOIN  i_plant WITH PRIVILEGED ACCESS AS c ON a~Plant = c~Plant
*    LEFT JOIN  i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS k ON k~BusinessPlace = c~plant

    LEFT JOIN  i_address_2 WITH PRIVILEGED ACCESS AS d ON c~AddressID = d~AddressID
    LEFT JOIN  i_supplier WITH PRIVILEGED ACCESS AS g ON a~InvoicingParty = g~Supplier
    LEFT JOIN  i_regiontext WITH PRIVILEGED ACCESS AS f ON g~Region = f~Region and f~Country = g~Country
    LEFT JOIN i_businesspartnersupplier WITH PRIVILEGED ACCESS AS h ON a~InvoicingParty = h~BusinessPartner
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS i ON a~PurchaseOrder = i~PurchaseOrder
*    WHERE   a~supplierinvoice = @cleardoc
    WHERE a~supplierinvoice = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code "" AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'
    INTO @DATA(wa).


SELECT SINGLE FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
        LEFT JOIN I_PLANT WITH PRIVILEGED ACCESS AS B ON B~Plant = A~Plant
        LEFT JOIN I_ADDRESS_2 WITH PRIVILEGED ACCESS AS C ON C~AddressID = B~AddressID
        LEFT JOIN I_REGIONTEXT WITH PRIVILEGED ACCESS AS D ON D~Region = C~Region
        FIELDS D~RegionName , a~SupplierInvoice , a~FiscalYear , a~CompanyCode
        WHERE  a~supplierinvoice = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
        INTO @DATA(WA_VENDOR_STATE).


     SELECT SINGLE
*     a~businessplace,
     a~companycode,
     b~plant_name1,
     b~address1,
     b~address2,
     b~city,
     b~district,
     b~state_code1,
     b~state_name,
     b~pin,
     b~country,
     b~cin_no,
     b~gstin_no,
     b~pan_no,
     b~email,
     b~fssai_no,
     c~materialdocument,
     c~documentdate
      FROM C_SUPPLIERINVOICEITEMDEX WITH PRIVILEGED ACCESS AS a
      LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~plant = b~plant_code
      LEFT JOIN i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS c on a~PurchaseOrder = c~PurchaseOrder and a~FiscalYear = c~MaterialDocumentYear
*      WHERE a~SupplierInvoice = @cleardoc " '5105600140' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'
      WHERE a~supplierinvoice = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
      INTO @DATA(waiopcds).

    data(lv_suplier) = wa-SupplierInvoice .
    data : lv_fiscal TYPE c LENGTH 4.
           lv_fiscal = wa-FiscalYear.
          data : lv_coc  type c LENGTH 20.
    CONCATENATE  lv_suplier lv_fiscal INTO lv_coc.

       DATA : Corp_off TYPE string.
         CONCATENATE waiopcds-address1 waiopcds-address2
                INTO Corp_off SEPARATED BY space.

REPLACE ALL OCCURRENCES OF ',,' IN corp_off WITH ','.
REPLACE all OCCURRENCES OF ',' IN corp_off WITH ''.
*REPLACE ALL OCCURRENCES OF '  ' IN corp_off WITH ' '.

   CONCATENATE Corp_off  waiopcds-district ',' waiopcds-city ',' waiopcds-state_name ',' waiopcds-Country '-' waiopcds-pin
            INTO Corp_off SEPARATED BY space.



*************************************************************** REMARKS ***************************
 SELECT SINGLe FROM i_operationalacctgdocitem as a
    FIELDS a~DocumentItemText, a~CompanyCode, a~FiscalYear, a~OriginalReferenceDocument
        WHERE a~OriginalReferenceDocument = @lv_coc AND a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
            and a~FinancialAccountType = 'K'
            into @data(lt_remarks) PRIVILEGED ACCESS .

SELECT SINGLE FROM i_operationalacctgdocitem as a
    FIELDS a~DebitCreditCode, a~CompanyCode, a~FiscalYear, a~OriginalReferenceDocument
        WHERE a~OriginalReferenceDocument = @lv_coc AND a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
              and a~DebitCreditCode in ( 'S', 'H' )
            into @data(Rpt_desc) PRIVILEGED ACCESS .

************************************************************* FSSAI ( ISSUED TO )
SELECT SINGLE FROM C_supplierinvoicedex AS A
    LEFT JOIN i_bupaidentification AS B ON A~InvoicingParty = B~BusinessPartner
        FIELDS B~BPIdentificationNumber
     WHERE a~supplierinvoice = @supplier_invoice AND a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
            AND B~BPIdentificationType = 'FSSAI'
        INTO @DATA(ISSUE_FSSAI).



*DATA: conc TYPE string.
*DATA : supp TYPE string .
*DATA : fisc TYPE string .
*          supp =  supplier_invoice .
*          fisc = wa_remarks-FiscalYear.
*          CONCATENATE supp fisc INTO conc.
*
*   SELECT SINGLe FROM i_operationalacctgdocitem as a
*    FIELDS  a~DocumentItemText
*        WHERE a~OriginalReferenceDocument = @conc AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
*            and a~FinancialAccountType = 'K'
*            into @data(lt_remarks).





 ""item level data """""""""""
    SELECT
    a~supplierinvoice,
    a~purchaseorderitemmaterial,
    a~QUANTITYINPURCHASEORDERUNIT,
    b~productdescription,
    c~consumptiontaxctrlcode,
    a~purchaseorderitemmaterial AS qty,
    a~purchaseorderquantityunit,
    a~supplierinvoiceitemamount,
    d~NetPriceAmount,
    A~COMPANYCODE,
    A~FiscalYear,
    a~SUPPLIERINVOICEITEM

     FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS b ON a~PurchaseOrderItemMaterial = b~Product
     LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c ON a~PurchaseOrderItemMaterial = c~Product and a~plant = c~plant
     left join i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS as d on a~PurchaseOrder = d~PurchaseOrder and a~PurchaseOrderItem = d~PurchaseOrderItem
*     WHERE  a~supplierinvoice = @cleardoc   ""AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'
WHERE a~supplierinvoice = @supplier_invoice AND  a~FiscalYear = @fiscal_year AND a~CompanyCode = @Company_code
     INTO TABLE @DATA(item).

SORT item BY supplierinvoice purchaseorderitemmaterial.
DELETE ADJACENT DUPLICATES FROM item COMPARING supplierinvoice purchaseorderitemmaterial .

DATA: conc TYPE string.
DATA : supp TYPE string .
DATA : fisc TYPE string .
          supp =  supplier_invoice .
          fisc =  fiscal_year.
          CONCATENATE supp fisc INTO conc.
*

   """""""""""""""""""""""""""""""""""""""""""""""""""""""" """"cGST""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   SELECT FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency,
     a~AccountingDocument,
     a~CompanyCode,
     a~FiscalYear,
   a~TAXITEMACCTGDOCITEMREF,
   A~OriginalReferenceDocument,
    a~transactiontypedetermination
    WHERE a~OriginalReferenceDocument = @conc AND A~AccountingDocumentItemType = 'T' AND
     a~transactiontypedetermination  = 'JIC' AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    INTO TABLE @DATA(it_cgst_amt).



   """""""""""""""""""""""""""""""""""""""""""""""""""""""" """"SGST""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   SELECT FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency,
     a~AccountingDocument,
     a~CompanyCode,
     a~FiscalYear,
     a~TAXITEMACCTGDOCITEMREF,
A~OriginalReferenceDocument,
    a~transactiontypedetermination
    WHERE a~OriginalReferenceDocument = @conc AND A~AccountingDocumentItemType = 'T' AND
     a~transactiontypedetermination  = 'JIS' AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    INTO TABLE @DATA(it_sgst_amt).




   """""""""""""""""""""""""""""""""""""""""""""""""""""""" """"IGST""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   SELECT FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency,
     a~AccountingDocument,
     a~CompanyCode,
     a~FiscalYear,
     A~OriginalReferenceDocument,
    a~TAXITEMACCTGDOCITEMREF,
    a~transactiontypedetermination
    WHERE a~OriginalReferenceDocument = @conc AND A~AccountingDocumentItemType = 'T' AND
     a~transactiontypedetermination  = 'JII' AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    INTO TABLE @DATA(it_igst_amt).


     """"""""'roundoff*****************

     SELECT
   a~amountincompanycodecurrency
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
WHERE a~originalreferencedocument = @lv_coc   AND a~amountincompanycodecurrency < 1 AND a~amountincompanycodecurrency > -1
     INTO  @DATA(gst1).
ENDSELECT.

"""""""""""""""""""""""""""""""""""""""""""""""""""""'''''''''''' for tds """"""""""""""""""""""""""""""""""""""'''''''''''

  SELECT SINGLE FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency
     WHERE a~OriginalReferenceDocument = @conc AND
     a~transactiontypedetermination  = 'WIT' AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    INTO  @DATA(tds_amt).







       DATA(lv_xml) =
      |<Form>| &&
      |<Header>| &&
      |<company_CODE>{ waiopcds-CompanyCode }</company_CODE>| &&
      |<company_name>{ wa-CompanyCodeName }</company_name>| &&
      |<Corp_Offc>{ Corp_off }</Corp_Offc>| &&
      |<Report_Description>{ Rpt_desc-DebitCreditCode }</Report_Description>| &&
      |<Debit_Credit_Node_No>{ wa-SupplierInvoice }</Debit_Credit_Node_No>| &&
      |<email>{ waiopcds-email }</email>| &&
      |<Pan>{ waiopcds-pan_no }</Pan>| &&
      |<Gstno>{ waiopcds-gstin_no }</Gstno>| &&
      |<Fssai>{ waiopcds-fssai_no }</Fssai>| &&
      |<Date>{ wa-PostingDate }</Date>| &&
      |<GSTN_NO>{ waiopcds-gstin_no }</GSTN_NO>| &&
      |<Address_onebox>| &&
      |<plant_name1>{ waiopcds-plant_name1 }</plant_name1>| &&
      |<Address1>{ waiopcds-address1 }</Address1>|  &&
      |<Address2>{ waiopcds-address2 }</Address2>| &&
      |<City_Name>{ waiopcds-city }</City_Name>| &&
      |<State_code1>{ waiopcds-state_code1 }</State_code1>| &&
      |<State_Name>{ waiopcds-state_name }</State_Name>| &&
      |<Pin>{ waiopcds-pin }</Pin>| &&
      |<Country>{ waiopcds-country }</Country>| &&
      |<Cin_no>{ waiopcds-cin_no }</Cin_no>| &&
      |<Pan_no>{ waiopcds-pan_no }</Pan_no>| &&
      |</Address_onebox>| &&
*      |<State>{ waiopcds-RegionName }</State>| &&
*      |<State_Code>{ waiopcds-Region }</State_Code>| &&
      |<Remarks>{ lt_remarks-DocumentItemText }</Remarks>| &&
      |<GSTN_NO_Two>{ wa-TaxNumber3 }</GSTN_NO_Two>| &&
      |<Supplier_Name>{ wa-SupplierName }</Supplier_Name>| &&
      |<Address_Two>| &&
      |<Street_Nametwo>{ wa-StreetName }</Street_Nametwo>| &&
      |<City_Nametwo>{ wa-suppliercityname }</City_Nametwo>| &&
      |<Postal_Codetwo>{ wa-supplierpostalcode }</Postal_Codetwo>| &&
      |<Regiontwo>{ wa-statediscription }</Regiontwo>| &&
      |<Countrytwo>{ wa-suppliercountry }</Countrytwo>| &&
      |</Address_Two>| &&
      |<state_Description>{ wa-statediscription }</state_Description>| &&
      |<State_Code_Two>{ wa-statecode }</State_Code_Two>| &&
      |<State_Code_vendor>{ WA_VENDOR_STATE-RegionName }</State_Code_vendor>| &&
      |<Pan_Number>{ wa-BusinessPartnerPanNumber }</Pan_Number>| &&
      |<Fssai_Issue>{ ISSUE_FSSAI }</Fssai_Issue>| &&
      |<Po_Number>{ wa-PurchaseOrder }</Po_Number>| &&
      |<Po_Date>{ wa-CreationDate }</Po_Date>| &&
      |<Migo_Number>{ waiopcds-MaterialDocument }</Migo_Number>| &&
      |<Migo_Date>{ waiopcds-DocumentDate }</Migo_Date>| &&
      |<Vendor_Invoice_Number>{ wa-SupplierInvoiceIDByInvcgParty }</Vendor_Invoice_Number>| &&
      |<Vendor_Invoice_Date>{ wa-DocumentDate }</Vendor_Invoice_Date>| &&
      |<round_off>{ gst1 }</round_off>| &&
      |<TCS>{ tds_amt }</TCS>| &&
      |</Header>| &&
      |<LineItem>|.  " Opening the LineItem tag

    LOOP AT item INTO DATA(wa_item).
      DATA(lv_xml_table) =
        |<item>| &&
        |<Sr_No></Sr_No>| &&
        |<Material_Code>{ wa_item-PurchaseOrderItemMaterial }</Material_Code>| &&
        |<Material_Description>{ wa_item-ProductDescription }</Material_Description>| &&
        |<HSN_Code>{ wa_item-ConsumptionTaxCtrlCode }</HSN_Code>| &&
        |<QTY>{ wa_item-QuantityInPurchaseOrderUnit }</QTY>| &&
        |<UOM>{ wa_item-PurchaseOrderQuantityUnit }</UOM>| &&
        |<Taxable_vl_Rej.hd_Chg>{ wa_item-SupplierInvoiceItemAmount }</Taxable_vl_Rej.hd_Chg>| &&
        |<Rate_Unit>{ wa_item-NetPriceAmount }</Rate_Unit>| .


      READ TABLE it_cgst_amt INTO DATA(wa_camt) WITH KEY
     OriginalReferenceDocument = conc  CompanyCode = wa_item-CompanyCode  FiscalYear = wa_item-FiscalYear TAXITEMACCTGDOCITEMREF = wa_item-SUPPLIERINVOICEITEM.

      DATA(lv_cgstAmt) =
            |<cgstAmt>{ wa_camt-amountincompanycodecurrency }</cgstAmt>|.

      READ TABLE it_sgst_amt INTO DATA(wa_samt) WITH KEY OriginalReferenceDocument = conc  CompanyCode = wa_item-CompanyCode  FiscalYear = wa_item-FiscalYear TAXITEMACCTGDOCITEMREF = wa_item-SUPPLIERINVOICEITEM.
      DATA(lv_sgstAmt) =
              |<sgstAmt>{ wa_samt-AmountInCompanyCodeCurrency }</sgstAmt>|.


      READ TABLE it_igst_amt INTO DATA(wa_iamt) WITH KEY OriginalReferenceDocument = conc  CompanyCode = wa_item-CompanyCode  FiscalYear = wa_item-FiscalYear TAXITEMACCTGDOCITEMREF = wa_item-SUPPLIERINVOICEITEM .
      DATA(lv_igstAmt) =
              |<igstAmt>{ wa_iamt-AmountInCompanyCodeCurrency }</igstAmt>|.
     CLEAR : wa_camt, wa_iamt, wa_samt.

      CONCATENATE lv_xml lv_xml_table lv_cgstamt lv_sgstamt  lv_igstamt  '|</item>|' INTO lv_xml.
      CLEAR wa_camt.
      CLEAR wa_samt.
      CLEAR wa_iamt.
*        CLEAR wa_uamt.
      CLEAR wa_ITEM.


    ENDLOOP.
    CONCATENATE lv_xml '</LineItem>'  INTO lv_xml.


    " Closing the tags properly
    CONCATENATE lv_xml  '</Form>' INTO lv_xml.

REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

   CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).


  ENDMETHOD.
ENDCLASS.
