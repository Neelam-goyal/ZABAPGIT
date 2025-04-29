CLASS zcl_po_test  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CLASS-DATA: access_token TYPE string.
    CLASS-DATA: xml_file TYPE string.
    CLASS-DATA: var1 TYPE vbeln.

    TYPES:
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS lv1_url TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'.
    CONSTANTS lv2_url TYPE string VALUE 'https://bn-dev-jpiuus30.authentication.jp10.hana.ondemand.com/oauth/token'.
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zmm_po_dom/zmm_po_dom'.
ENDCLASS.



CLASS ZCL_PO_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
SELECT SINGLE
     a~PURCHASEORDER ,
     a~Companycode ,
     a~creationdate,
      a~INCOTERMSCLASSIFICATION,
     a~INCOTERMSLOCATION1,
     b~companycodename ,
     c~plant ,
     e~streetname,
     e~cityname,
     e~postalcode,
     e~region,
     e~country,
     f~emailaddress,
     d~plantcustomer,
     d~plantname,
     e~taxnumber3 ,
     e~telephonenumber1,
     i~regionname,
   e~customername,
     j~countryname

*



     FROM i_purchaseorderapi01 AS a
     LEFT JOIN i_companycode AS b ON a~companycode = b~companycode
     LEFT JOIN I_PurchaseOrderItemAPI01 AS c ON a~PURCHASEORDER = c~PURCHASEORDER
     LEFT JOIN i_plant AS d ON c~plant = d~plant
*     LEFT JOIN i_address_2 AS e ON d~addressid = e~addressid
     LEFT JOIN i_customer AS e ON  d~plantcustomer = e~customer

     LEFT JOIN i_addressemailaddress_2 with PRIVILEGED ACCESS AS f ON d~addressid = f~addressid
     LEFT JOIN i_regiontext AS i ON e~region = i~region AND e~country = i~country
     LEFT JOIN i_countrytext as j ON e~Country = j~country
     WHERE a~PURCHASEORDER = '3200000007'
     INTO  @DATA(wa_head).

*    out->write( wa_head ).

    DATA : cin TYPE string.

    IF  wa_head-CompanyCode EQ 'BNAL'.

      cin = 'U01403DL2011PLC301179'.
    ELSEIF wa_head-CompanyCode EQ 'SBPL'.
      cin = 'U15490UP2020PTC128250'.
    ELSEIF wa_head-CompanyCode EQ 'A1AG'.
      cin = 'U51909DL2020PTC366017'.
    ELSEIF wa_head-CompanyCode EQ 'EPIL'.
      cin = 'U15549DL2022PLC402614'.

    ENDIF.
     DATA: comp_add1 TYPE string,
          comp_add2 TYPE string.
    DATA: pan        TYPE string,
          state_code TYPE string.

    comp_add1 = wa_head-streetname.

*     if comp_add1  is not INITIAL.
*     CONCATENATE comp_add1  ','  into comp_add1 SEPARATED BY space.
*     endif.
*
      if wa_head-cityname  is not INITIAL.
    CONCATENATE comp_add1  wa_head-cityname INTO comp_add1 SEPARATED BY space.
    endif.

    if wa_head-RegionName is not initial.
    CONCATENATE  comp_add2  wa_head-RegionName  INTO comp_add2 SEPARATED BY space.
    endif.

    if wa_head-CountryName is not initial.
    CONCATENATE comp_add2 ',' wa_head-CountryName INTO comp_add2 SEPARATED BY space.
    endif.


    if wa_head-PostalCode is not initial.
    CONCATENATE comp_add2 ',' wa_head-postalcode INTO comp_add2 SEPARATED BY space.
    endif.

    pan = wa_head-taxnumber3+2(10).
    state_code = wa_head-taxnumber3+0(2).


*    out->write( wa_head ).









    " Fetch header data
     SELECT SINGLE
        a~PurchaseOrder,
        a~PurchaseOrderdate,
       c~HouseNumber,
        c~StreetName,
        c~CityName,
        c~StreetPrefixName1,
        c~StreetPrefixName2,
        C~DistrictName ,
        c~CityName AS cn,
        c~country,
 a~paymentterms,
      d~customername,
         d~postalcode,
        d~taxnumber3,
        e~RegionName,
        h~CreationDate
        from i_purchaseorderapi01 AS a
       LEFT JOIN i_customer  WITH PRIVILEGED ACCESS AS d ON d~Customer = a~Customer

       LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS AS c ON c~addressid = d~addressid
      LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS e ON e~region = d~region
      LEFT JOIN i_supplierquotationtp WITH PRIVILEGED ACCESs AS h ON h~Supplier = a~Supplier
      WHERE a~PurchaseOrder = '3200000007'
      INTO  @DATA(wa_ship).

 SELECT SINGLE FROM i_purchaseorderapi01 AS a
    LEFT JOIN i_supplier WITH PRIVILEGED ACCESS  AS b ON a~Supplier = b~Supplier
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON b~AddressID = c~AddressID
    LEFT JOIN i_Businesspartner AS g ON g~BusinessPartner = b~Supplier
    LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS d ON c~Region = d~Region AND c~Country = d~Country
    FIELDS
    B~TaxNumber3,
    c~HouseNumber,
    c~streetname,
      g~businesspartnername,
    c~streetprefixname1,
    c~streetprefixname2,
    c~cityname,
    c~postalcode,
    c~districtname,
    c~country,
    b~SupplierName,
    d~RegionName,
    a~INCOTERMSCLASSIFICATION,
     a~INCOTERMSLOCATION1
    WHERE a~PurchaseOrder = '3200000007'
    INTO @DATA(lv_address) .

"supplier address/vendor
DATA: lv_supp_add TYPE string.
    lv_supp_add = lv_address-HouseNumber.
 CONCATENATE lv_supp_add  lv_address-StreetName lv_address-StreetPrefixName1 lv_address-StreetPrefixName2
      lv_address-CityName  lv_address-RegionName lv_address-Country lv_address-PostalCode
     INTO lv_supp_add SEPARATED BY spACE.
 out->write( lv_supp_add  ).


"customer data/bill to
DATA: lv_customer_add TYPE string.
   lv_customer_add = wa_ship-HouseNumber.
 CONCATENATE lv_customer_add wa_ship-StreetName  wa_ship-StreetPrefixName1
    wa_ship-StreetPrefixName2 wa_ship-CityName  wa_ship-RegionName  wa_Ship-country wa_ship-PostalCode
     INTO lv_customer_add SEPARATED BY spACE.

"for items details
SELECT

     b~PurchaseOrder,
       c~ProductName,    " des of goods
       b~baseunit,       " uom
       B~OrderQuantity,   "order qty
       B~netpriceamount,
       B~DocumentCurrency,
      C~product,
      b~netamount,
        B~taxcode,
       B~PurchaseOrderItem,
       B~purchasingdocumentdeletioncode
        FROM i_purchaseorderapi01   WITH PRIVILEGED ACCESS  AS a
      LEFT JOIN I_PurchaseOrderItemAPI01 AS b ON b~PurchaseOrder = a~PurchaseOrder
     LEFT JOIN i_producttext AS c ON c~Product = b~Material
     WHERE a~PurchaseOrder = '3200000007'
     INTO TABLE @DATA(it_item).

"for rate
SELECT a~PurchaseOrder,
       b~PurchaseOrder AS po_item,
       b~PurchaseOrderItem,
       e~ConditionType,
      e~conditionrateamount
  FROM I_PurchaseOrderAPI01 AS a
  LEFT JOIN I_PurchaseOrderItemAPI01 AS b
    ON a~PurchaseOrder = b~PurchaseOrder
  LEFT JOIN i_purordpricingelementtp_2  AS e  " Corrected view name
    ON b~PurchaseOrder = e~PurchaseOrder
    AND b~PurchaseOrderItem = e~PurchaseOrderItem
  WHERE a~PurchaseOrder = '3200000007' and (   e~ConditionType = 'PMP0' or  e~ConditionType = 'PPR0' )
    INTO TABLE @DATA(rate).




 """""""""""""""""" discount """"""""""""""""""""""""""
    SELECT a~PurchaseOrder,
       b~PurchaseOrder AS po_item,
       b~PurchaseOrderItem,
       e~ConditionType,
       e~conditionrateamount
  FROM I_PurchaseOrderAPI01 AS a
  LEFT JOIN I_PurchaseOrderItemAPI01 AS b
    ON a~PurchaseOrder = b~PurchaseOrder
  LEFT JOIN i_purordpricingelementtp_2  AS e  " Corrected view name
    ON b~PurchaseOrder = e~PurchaseOrder
    AND b~PurchaseOrderItem = e~PurchaseOrderItem
  WHERE a~PurchaseOrder = '3200000007' and  ( e~ConditionType = 'ZDCP' OR e~ConditionType = 'ZDCQ' )
   INTO TABLE @DATA(disc).



    """"""""""""""""""""""""""""""""""IGST rate & amount""""""""""""

    SELECT a~PurchaseOrder,
  b~PurchaseOrder AS po_item,
  b~PurchaseOrderItem,
  e~conditionrateamount,
  e~conditionamount
  FROM I_PurchaseOrderAPI01 AS a
  LEFT JOIN I_PurchaseOrderItemAPI01 AS b ON a~PurchaseOrder = b~PurchaseOrder
  LEFT JOIN i_purordpricingelementtp_2 AS e ON b~PurchaseOrder = e~PurchaseOrder AND b~PurchaseOrderItem = e~PurchaseOrderItem
              AND e~conditiontype = 'JOIG'
              WHERE a~PurchaseOrder = '3200000007'
  INTO TABLE @DATA(igst).

DATA(lv_xml) = |<Form>| &&
                   |<purchaseorder>| &&

        |<companyName>{ wa_head-companycode }</companyName>| &&
          |<companyAd1>{ comp_add1 }</companyAd1>| &&
          |<companyAd2>{ comp_add2 }</companyAd2>| &&

    |<phone>{ wa_head-telephonenumber1 }</phone>| &&
    |<pan>{ pan }</pan>| &&
    |<gst>{ wa_head-taxnumber3 }</gst>| &&
    |<cin>{ cin }</cin>| &&
    |<suppliername>{ lv_address-suppliername }</suppliername>| &&
                   |<PoNumber>{ wa_ship-PurchaseOrder }</PoNumber>| &&
                   |<customername>{ wa_ship-customername }</customername>| &&
                   |<PurchaseDate>{ wa_ship-PurchaseOrderdate }</PurchaseDate>| &&
                   |<SupplierAdress>{ lv_supp_add }</SupplierAdress>| &&
                   |<CustomerAdress>{ lv_customer_add }</CustomerAdress>| &&
                   |<CUSTOMERGST>{ wa_ship-TaxNumber3 }</CUSTOMERGST>| &&
                   |<SUPPLIERGST>{ LV_ADDRESS-TaxNumber3 }</SUPPLIERGST>| &&
                     |<INCOTERMSLOCATION1>{ LV_ADDRESS-INCOTERMSLOCATION1 }</INCOTERMSLOCATION1>| &&
                     |<Paymentterms>{ wa_ship-Paymentterms }</Paymentterms>| &&
                     |<INCOTERMSCLASSIFICATION>{ LV_ADDRESS-INCOTERMSCLASSIFICATION }</INCOTERMSCLASSIFICATION>| &&
                   |<vendorstatename>{ lv_address-RegionName }</vendorstatename>| &&
                   |<customerstatename>{ wa_ship-RegionName }</customerstatename>| &&
                   |</purchaseorder>| &&
                   |<item>|.
  DATA(num) = 0.
  num = num + 1.


LOOP AT it_item INTO DATA(wa_item).
 DATA(lv_xml2) =
        |<tableDataRows>| &&
        |<siNo>{ num }</siNo>| &&
         |<ProductName>{ wa_item-ProductName }</ProductName>| &&
          |<PURCHASEORDER>{ wa_item-PurchaseOrder }</PURCHASEORDER>| &&
         |<PURCHASEORDERITEM>{ wa_item-PurchaseOrderItem }</PURCHASEORDERITEM>| &&
        |<umo>{ wa_item-BaseUnit }</umo>| &&
         |<OrderQuantity>{ wa_item-OrderQuantity }</OrderQuantity>| &&
          |<netamount>{ wa_item-netamount }</netamount>| &&
        |<Itemcode>{ wa_item-Product }</Itemcode>| .

        READ TABLE rate INTO DATA(wa_rate) WITH KEY purchaseorder = wa_item-purchaseorder PurchaseOrderItem = wa_item-PurchaseOrderItem.
      DATA(lv_rate) =
        |<rate>{ wa_rate-conditionrateamount }</rate>|.
      READ TABLE disc INTO DATA(wa_disc) WITH KEY purchaseorder = wa_item-purchaseorder PurchaseOrderItem = wa_item-PurchaseOrderItem.
      DATA(lv_disc) =
      |<disc>{ wa_disc-conditionrateamount }</disc>|.
*for igst rate
    READ TABLE igst INTO DATA(wa_igst) WITH KEY purchaseorder = wa_item-purchaseorder PurchaseOrderItem = wa_item-PurchaseOrderItem.
      DATA(lv_joig) =
      |<igstRate>{ wa_igst-conditionrateamount }</igstRate>| .

      CONCATENATE lv_xml lv_xml2 lv_rate lv_disc lv_joig   '|</tableDataRows>|' '</item>' '</Form>'  INTO lv_xml.

    ENDLOOP.


    " Close XML structure
*    CONCATENATE lv_xml  lv_rate lv_disc  lv_joig  '</item>' '</Form>' INTO lv_xml.


  REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.



    " Output final XML
   out->write( lv_xml ).


    ENDMETHOD.
ENDCLASS.
