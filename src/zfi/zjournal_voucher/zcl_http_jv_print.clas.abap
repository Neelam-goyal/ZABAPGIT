CLASS zcl_http_jv_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
          INTERFACES if_http_service_extension.
          CLASS-DATA : comp TYPE string.

          class-DATA : user_belnr TYPE string.
          CLASS-DATA: VAR1 TYPE i_operationalacctgdocitem-AccountingDocument.

  PROTECTED SECTION.
  PRIVATE SECTION.
           METHODS: get_html RETURNING VALUE(html) TYPE string.
           METHODS: post_html IMPORTING lv_belnr TYPE string
                                        lv_companycode TYPE string
                    RETURNING VALUE(html)  TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_JV_PRINT IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Accounting Document</title> \n| &&
  |<form action="/sap/bc/http/sap/ZHTTP_JV_PRINT" method="POST">\n| &&
  |<H2>Accounting Document</H2> \n| &&
  |<label for="fname">Accounting Document:  </label> \n| &&
  |<input type="text" id="belnr" name="belnr" required ><br><br> \n| &&
  |<label for="fname"> Company Code:  </label> \n| &&
  |<input type="text" id="lv_companycode" name="lv_companycode" required ><br><br> \n| &&
  |<input type="submit" value="Submit"> \n| &&
  |</form> | &&
  |</body> \n| &&
  |</html> | .

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.


    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_JV_PRINT?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).
  " Handle POST request
        DATA(lv_belnr) = request->get_form_field( `belnr` ).
                comp = request->get_form_field( `lv_companycode` ).
                response->set_text( post_html( lv_belnr = lv_belnr lv_companycode = comp ) ).


        Data: lv_belnr2 TYPE string.

       DATA:  VAR1 TYPE i_operationalacctgdocitem-AccountingDocument.
       VAR1 = lv_belnr.
       VAR1   = |{ VAR1 ALPHA = IN }|.
       user_belnr = lv_belnr.
       user_belnr =  VAR1.

        SELECT SINGLE FROM i_operationalacctgdocitem
      FIELDS AccountingDocument
      WHERE  AccountingDocument = @user_belnr AND CompanyCode = @comp
      INTO @lv_belnr2.


        IF lv_belnr2 IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_jv_print_dr=>read_posts( lv_belnr2 = user_belnr  lv_companycode = comp ).
              IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF' ).
              ELSE.
*                DATA(html) = |<html> | &&
*                               |<body> | &&
*                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
*                               | </body> | &&
*                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Document No does not exist.' ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Accounting Document</title> \n| &&
   |<form action="/sap/bc/http/sap/ZHTTP_JV_PRINT" method="Get">\n| &&
   |<H2>Accounting Document Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
