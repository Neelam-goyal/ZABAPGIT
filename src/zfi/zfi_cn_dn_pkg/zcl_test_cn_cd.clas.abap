CLASS zcl_test_cn_cd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_TEST_CN_CD IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "" header level data """"""""""""


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

    a~supplierinvoiceidbyinvcgparty  AS Footer

    FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
    LEFT JOIN  i_companycode WITH PRIVILEGED ACCESS AS b ON a~CompanyCode = b~CompanyCode
    LEFT JOIN  i_plant WITH PRIVILEGED ACCESS AS c ON a~Plant = c~Plant
    LEFT JOIN  i_address_2 WITH PRIVILEGED ACCESS AS d ON c~AddressID = d~AddressID
    LEFT JOIN  i_regiontext WITH PRIVILEGED ACCESS AS f ON d~Region = f~Region
    LEFT JOIN  i_supplier WITH PRIVILEGED ACCESS AS g ON a~InvoicingParty = g~Supplier
    LEFT JOIN i_businesspartnersupplier WITH PRIVILEGED ACCESS AS h ON a~InvoicingParty = h~BusinessPartner
    LEFT JOIN i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS i ON a~PurchaseOrder = i~PurchaseOrder
    WHERE   a~supplierinvoice = '5105600140' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'
    INTO @DATA(wa).
    DATA(lv_suplier) = wa-SupplierInvoice .
    DATA : lv_fiscal TYPE c LENGTH 4.
    lv_fiscal = wa-FiscalYear.
    DATA : lv_coc  TYPE c LENGTH 20.
    CONCATENATE  lv_suplier lv_fiscal INTO lv_coc.
    out->write( wa ).

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
     b~pan_no



      FROM I_SupplierInvoiceAPI01 WITH PRIVILEGED ACCESS AS a
      LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS AS b ON a~BusinessPlace = b~plant_code

      WHERE a~SupplierInvoice = '5105600140' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'
      INTO @DATA(waiopcds).

    out->write( waiopcds ) .


*    "" Header level """
*    SELECT SINGLE
*    a~businessplace,
*    a~companycode,
*    b~addressid,
*    c~region ,       "" state code
*    d~REGIONNAME       "" state
*    FROM  i_operationalacctgdocitem WITH PRIVILEGED ACCESS as a
*    LEFT JOIN i_plant WITH PRIVILEGED ACCESS as b on a~BusinessPlace = b~plant
*    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS as c on b~AddressID = c~AddressID
*    LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS as d on c~Region = d~Region
*    where a~originalreferencedocument = @lv_coc  ""and a~FiscalYear = '2024' and a~CompanyCode = 'BNAL'
*    INTO @DATA(waiopcds).
*
*    out->write( waiopcds ).


    ""item level data """""""""""
    SELECT
    a~supplierinvoice,
    a~purchaseorderitemmaterial,
    b~productdescription,
    c~consumptiontaxctrlcode,
    a~purchaseorderitemmaterial AS qty,
    a~purchaseorderquantityunit,
    a~supplierinvoiceitemamount

     FROM c_supplierinvoiceitemdex WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS AS b ON a~PurchaseOrderItemMaterial = b~Product
     LEFT JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS c ON a~PurchaseOrderItemMaterial = c~Product
     WHERE  a~supplierinvoice = '5105600140' AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2024'

     INTO TABLE @DATA(item).
    out->write( item ).

    """"GST""""""""""""

    SELECT
    a~Companycode,
    a~amountincompanycodecurrency,
    a~taxitemacctgdocitemref,
    a~accountingdocumentitemtype,
    a~transactiontypedetermination,
    a~accountingdocumentitem
     FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
   WHERE a~originalreferencedocument = @lv_coc  AND ( ( a~accountingdocumentitemtype = 'T' and a~transactiontypedetermination <> 'WIT' ) OR
    ( a~accountingdocumentitemtype <> 'T' and a~transactiontypedetermination = 'WIT' ) )
     INTO TABLE @DATA(gst).
     out->write( gst ).


    DATA(lv_xml) =
      |<Form>| &&
      |<Header>| &&
      |<company_name>{ wa-CompanyCodeName }</company_name>| &&
      |<Report_Description></Report_Description>| &&
      |<Debit_Credit_Node_No>{ wa-SupplierInvoice }</Debit_Credit_Node_No>| &&
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

      |<State_Code></State_Code>| &&

      |<GSTN_NO_Two>{ wa-TaxNumber3 }</GSTN_NO_Two>| &&
      |<Supplier_Name>{ wa-SupplierName }</Supplier_Name>| &&
      |<Address_Two>| &&
      |<Street_Nametwo>{ wa-StreetName }</Street_Nametwo>| &&
      |<City_Nametwo>{ wa-suppliercityname }</City_Nametwo>| &&
      |<Postal_Codetwo>{ wa-supplierpostalcode }</Postal_Codetwo>| &&
      |<Regiontwo>{ wa-supplierregion }</Regiontwo>| &&
      |<Countrytwo>{ wa-suppliercountry }</Countrytwo>| &&
      |</Address_Two>| &&
      |<state_Description>{ wa-statediscription }</state_Description>| &&
      |<State_Code_Two>{ wa-statecode }</State_Code_Two>| &&
      |<Pan_Number>{ wa-BusinessPartnerPanNumber }</Pan_Number>| &&

      |<Po_Number>{ wa-PurchaseOrder }</Po_Number>| &&
      |<Po_Date>{ wa-CreationDate }</Po_Date>| &&
      |<Migo_Number></Migo_Number>| &&
      |<Migo_Date></Migo_Date>| &&
      |<Vendor_Invoice_Number>{ wa-SupplierInvoiceIDByInvcgParty }</Vendor_Invoice_Number>| &&
      |<Vendor_Invoice_Date>{ wa-DocumentDate }</Vendor_Invoice_Date>| &&
      |</Header>| &&
      |<LineItem>|.  " Opening the LineItem tag

    LOOP AT item INTO DATA(wa_item).
      DATA(lv_xml_table) =
        |<item>| &&
        |<Sr_No></Sr_No>| &&
        |<Material_Code>{ wa_item-PurchaseOrderItemMaterial }</Material_Code>| &&
        |<Material_Description>{ wa_item-ProductDescription }</Material_Description>| &&
        |<HSN_Code>{ wa_item-ConsumptionTaxCtrlCode }</HSN_Code>| &&
        |<QTY>{ wa_item-PurchaseOrderItemMaterial }</QTY>| &&
        |<UOM>{ wa_item-PurchaseOrderQuantityUnit }</UOM>| &&
        |<Taxable_vl_Rej.hd_Chg>{ wa_item-SupplierInvoiceItemAmount }</Taxable_vl_Rej.hd_Chg>| &&
        |</item>|.
      CONCATENATE lv_xml lv_xml_table INTO lv_xml.  " Concatenate item information to the XML structure
    ENDLOOP.
    CONCATENATE lv_xml '</LineItem>'  INTO lv_xml.
    LOOP AT gst INTO DATA(wa_gst).
      DATA(lv_xml_gst) =
       |<gst>| &&
             |<Condition_type_T>{ wa_gst-AccountingDocumentItemType }</Condition_type_T>| &&
             |<Condition_jii_jis_jic>{ wa_gst-TransactionTypeDetermination }</Condition_jii_jis_jic>| &&
             |<TAXITEMACCTGDOCITEMREF>{ wa_gst-TaxItemAcctgDocItemRef }</TAXITEMACCTGDOCITEMREF>| &&
             |<Accounting_document_item>{ wa_gst-AccountingDocumentItem }</Accounting_document_item>| &&
             |<Gst_Amount>{ wa_gst-AmountInCompanyCodeCurrency }</Gst_Amount>| &&
             |</gst>|.
      CONCATENATE lv_xml lv_xml_gst INTO lv_xml.  " Concatenate gst data to the XML structure
    ENDLOOP.

    " Closing the tags properly
    CONCATENATE lv_xml  '</Form>' INTO lv_xml.  " Properly closing LineItem and Form tags

    out->write( lv_xml ).  " Output the final XML structure



  ENDMETHOD.
ENDCLASS.
