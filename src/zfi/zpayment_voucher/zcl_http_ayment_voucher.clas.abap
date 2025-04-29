CLASS zcl_http_ayment_voucher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                lv_Accountingdocument TYPE string
                lv_fiscalyear type string
                lv_Companycode type string

      RETURNING VALUE(html)  TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_AYMENT_VOUCHER IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Outgoing Payment Voucher</title> \n| &&
*  |<form action="{ url }" method="POST">\n| &&
  |<form action="/sap/bc/http/sap/ZHTTP_PAYMENT_VOUCHER_SRV?sap-client=080" method="POST">\n| &&
  |<H2>BN Print</H2> \n| &&
  |<label for="fname">Accounting Document </label> \n| &&
  |<input type="text" id="lv_Accountingdocument" name="lv_Accountingdocument" required ><br><br> \n| &&
  |<label for="fname">Fiscal Year</label> \n| &&
  |<input type="text" id="lv_fiscalyear" name="lv_fiscalyear" required ><br><br> \n| &&
   |<label for="fname">Company Code</label> \n| &&
  |<input type="text" id="lv_Companycode" name="lv_Companycode" required ><br><br> \n| &&
  |<input type="submit" value="Submit"> \n| &&
  |</form> | &&
  |</body> \n| &&
  |</html> | .





  ENDMETHOD.


METHOD if_http_service_extension~handle_request.

*    DATA(req) = request->get_form_fields(  ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
*
*    DATA json TYPE string .
*    DATA salesorderno TYPE string.
*    DATA salesorder TYPE n LENGTH 10.
*
*    salesorderno = VALUE #( req[ name = 'salesorderno' ]-value OPTIONAL ) .
*
*    json =  VALUE #( req[ name = 'json' ]-value OPTIONAL ) .
*    salesorder = salesorderno .
*
*    SELECT SINGLE * FROM i_salesdocumentitem WITH PRIVILEGED ACCESS WHERE salesdocument = @salesorder
*    INTO @DATA(check).
*    IF check IS NOT INITIAL .
*      DATA(pdf2) = ywk_or_print_class=>read_posts( salesorderno = salesorderno ) .
*    ELSE .
*      pdf2 = 'Error Please Check Plant'.
*    ENDIF.
    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_PAYMENT_VOUCHER_SRV?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(ac) = request->get_form_field( `lv_Accountingdocument` ).
        DATA(yr) = request->get_form_field( `lv_fiscalyear` ).
        DATA(cc) = request->get_form_field( `lv_Companycode` ).

        TRANSLATE cc to UPPER CASE.


        SELECT SINGLE FROM i_accountingdocumentjournal
        FIELDS Accountingdocument WHERE AccountingDocument = @ac and FiscalYear = @yr and CompanyCode = @cc
        INTO @DATA(lv_ac).

        IF lv_ac IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_xml_driver=>read_posts( lv_Accountingdocument = ac  lv_fiscalyear = yr lv_Companycode = cc ) .

*            response->set_text( pdf ).

              DATA(html) = |{ pdf }|.



              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( pdf ).
             CATCH cx_static_check INTO DATA(er).

          html = |Accounting Document does not exist: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      html = |Accounting Document not found|.

    ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Outgoing Payment Voucher</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>BN print</H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
