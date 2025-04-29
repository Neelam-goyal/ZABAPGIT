*CLASS zcl_veh_token_xml1 DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.
*
*
*
*CLASS zcl_veh_token_xml1 IMPLEMENTATION.
*ENDCLASS.

CLASS zcl_veh_token_xml1 DEFINITION
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
        IMPORTING
                  lv_gateentry    TYPE string
*                  lv_fiscalyear         TYPE string
*                  lv_Companycode        TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zvehicle_token/zvehicle_token'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_VEH_TOKEN_XML1 IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

*    TYPES : BEGIN OF ty_st,
*              bill_no      TYPE i_accountingdocumentjournal-Clearingaccountingdocument,
*              gross_amt    TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
*              pay_prev     TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
*              tds          TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
*              net_amt      TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
*              invoice_date TYPE i_accountingdocumentjournal-PostingDate,
*              invoice_no   TYPE i_accountingdocumentjournal-Accountingdocument,
**      total_gross_amt type i_accountingdocumentjournal-Debitamountintranscrcy,
*
*            END OF ty_st.

    SELECT  SINGLE FROM zgateentryheader
    FIELDS gateentryno, driverlicenseno, drivername, transportmode, gateindate,gateintime, vehiclergnno, transportername, driverno, plant,
    stocktransferchallan,vehicleno,stocktransferinv,supewaybillno,vehicleinsurance,drvierlicense,refdocno,supdlchallan,vehiclerc,transporterlr,vehiclepuc,supplierinvoice
    WHERE gateentryno = @lv_gateentry
    INTO @DATA(lv_final).

    if lv_final is NOT INITIAL.
        SELECT  SINGLE FROM ztable_plant
        FIELDS comp_code, plant_name1
        WHERE plant_code = @lv_final-plant
        INTO @DATA(lv_plant).

   endif.

   data: compname type string.
   data: compaddress type string.
   data: lv_date type string.
   data: lv_time1 type string.
   data: lv_collect type string.

 concatenate lv_final-gateindate+6(2) lv_final-gateindate+4(2) lv_final-gateindate+0(4) into lv_date
    SEPARATED BY '/'.
 concatenate lv_final-gateintime+0(2) lv_final-gateintime+2(2) lv_final-gateintime+4(2) into lv_time1
    SEPARATED BY ':'.

 CONCATENATE lv_date lv_time1 into data(lv_time) SEPARATED BY space.


if lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X' and lv_final-vehiclerc = 'X' and lv_final-transporterlr = 'X' and lv_final-vehiclepuc = 'X' and lv_final-supplierinvoice = 'X'.
    lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan,Vehicle RC,Transporter LR,Vehicle PUC,Supplier Invoice'.
elseif lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X' and lv_final-supplierinvoice = 'X'.
    lv_collect = 'Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan,Supplier Invoice'.
elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-vehicleinsurance = 'X'
 and lv_final-vehiclerc = 'X' and lv_final-transporterlr = 'X' and lv_final-vehiclepuc = 'X' .
    lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Vehicle Insurance,Vehicle RC,Transporter LR,Vehicle PUC'.
 elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X' and lv_final-vehiclerc = 'X' and lv_final-transporterlr = 'X'  and lv_final-vehiclepuc = 'X' .
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan,Vehicle RC,Transporter LR,Vehicle PUC'.
 elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X' and lv_final-vehiclerc = 'X' and lv_final-transporterlr = 'X'.
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan,Vehicle RC,Transporter LR'.
 elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X' and lv_final-vehiclerc = 'X'.
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan,Vehicle RC'.
  elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' and lv_final-supdlchallan = 'X'.
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No,Supplier DL Challan'.
  elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'
and lv_final-refdocno = 'X' .
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License,Reference Document No'.
   elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X' and lv_final-drvierlicense = 'X'.
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance,Driver License'.
   elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X' and lv_final-vehicleinsurance = 'X'.
   lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill,Vehicle Insurance'.
  elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' and lv_final-supewaybillno = 'X'.
     lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice,Supplier E-way Bill'.
  elseif lv_final-refdocno = 'X' and lv_final-transporterlr = 'X' AND LV_FINAL-supplierinvoice = 'X'.
    LV_COLLECT = 'Reference Document No,Transporter LR,Supplier Invoice'.
  elseif lv_final-refdocno = 'X' AND LV_FINAL-supplierinvoice = 'X'.
    LV_COLLECT = 'Reference Document No,Supplier Invoice'.
    elseif lv_final-stocktransferchallan = 'X' and lv_final-stocktransferinv = 'X' .
     lv_collect = 'Stock Transfer Challan,Stock Transfer Invoice'.
     elseif lv_final-drvierlicense = 'X' and lv_final-transporterlr = 'X' and lv_final-supplierinvoice = 'X' ..
     lv_collect = 'Driver License,Transporter LR,Supplier Invoice'.
     elseif ( lv_final-drvierlicense = 'X' and lv_final-transporterlr = 'X' ) or lv_final-supplierinvoice = 'X' ..
     lv_collect = 'Driver License,Transporter LR'.
    elseif lv_final-stocktransferchallan = 'X' .
     lv_collect = 'Stock Transfer Challan'.
     elseif lv_final-stocktransferinv = 'X' .
     lv_collect = 'Stock Transfer Invoice'.
      elseif lv_final-refdocno = 'X' .
     lv_collect = 'Reference Document No'.
      elseif lv_final-supewaybillno = 'X' .
     lv_collect = 'Supplier E-way Bill'.
      elseif lv_final-supdlchallan = 'X' .
     lv_collect = 'Supplier DL Challan'.
      elseif lv_final-vehicleinsurance = 'X' .
     lv_collect = 'Vehicle Insurance'.
      elseif lv_final-vehiclerc = 'X' .
     lv_collect = 'Vehicle RC'.
      elseif lv_final-vehiclepuc = 'X' .
     lv_collect = 'Vehicle PUC'.
     elseif lv_final-drvierlicense = 'X' .
     lv_collect = 'Driver License'.
     elseif lv_final-supplierinvoice = 'X' .
     lv_collect = 'Supplier Invoice'.
      elseif lv_final-transporterlr = 'X' .
     lv_collect = 'Transporter LR'.
  endif.

   if lv_plant-comp_code = 'BNAL'.
     compname = 'BN AGRITECH LTD'.
     compaddress = 'SURVEY NO 406/1, 406/2, 407, BHIMASAR, BHIMASAR, ANJAR, KACHCHH-370240 IN'.
    ELSEif lv_plant-comp_code = 'A1AG'.
     compname = 'A1 AGRI GLOBAL LTD'.
     compaddress =  'F-5, SITE B, MATHURA INDUSTRIAL AREA, MATHURA, MATHURA TAHSIL, MATHURA, UTTAR PRADESH-281005'.
     ELSEif lv_plant-comp_code = 'SBPL'.
     compname = 'SALASAR BALAJI OVERSEAS PVT LTD'.
     compaddress = 'E-6, SITE B, UPSIDC INDUSTRIAL AREA'.
     ELSEif lv_plant-comp_code = 'EPIL'.
     compname = 'EPITOME INDUSTRIES LTD'.
     compaddress = 'LS NO. 498/1, 498, 497 & 485, LAKHAPAR,, ANJAR, KACHCHH, GUJARAT, 370110'.
   endif.

    DATA(lv_xml) = |<Form>| &&
                   |<TokenNo>{ lv_final-gateentryno }</TokenNo>| &&
                   |<Plant>{ lv_final-plant }</Plant>| &&
                   |<PlantName>{ lv_plant-plant_name1 }</PlantName>| &&
                   |<CompanyName>{ compname }</CompanyName>| &&
                   |<CompanyAddress>{ compaddress }</CompanyAddress>| &&
                   |<TransType>{ ' ' }</TransType>| &&
                   |<VendorCity>{ ' ' }</VendorCity>| &&
                   |<DriverLic>{ lv_final-driverlicenseno }</DriverLic>| &&
                   |<DriverName>{ lv_final-drivername }</DriverName>| &&
                   |<DocumentsCollected>{ ' ' }</DocumentsCollected>| &&
                   |<DocumentsCollected1>{ ' ' }</DocumentsCollected1>| &&
                   |<ModeOfTransport>{ lv_final-transportmode }</ModeOfTransport>| &&
                   |<GateDateTime>{ lv_time }</GateDateTime>| &&
                   |<DailySeqNo>{ ' ' }</DailySeqNo>| &&
                   |<VehicleRegnNo>{ lv_final-vehicleno }</VehicleRegnNo>| &&
                   |<Transporter>{ lv_final-transportername }</Transporter>| &&
                   |<DriverMob>{ lv_final-driverno }</DriverMob>| &&
                   |<Collected>{ lv_collect }</Collected>| &&
                   |<SecurityOff>{ ' ' }</SecurityOff>| &&
                   |<Temp1>{ ' ' }</Temp1>| &&
                   |<Temp2>{ ' ' }</Temp2>| &&
                   |<Temp3>{ ' ' }</Temp3>| &&
                   |</Form>|.


    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
