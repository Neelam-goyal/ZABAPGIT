CLASS ZCL_HTTP_PO_HANDLER DEFINITION
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
                po_num     TYPE string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_HTTP_PO_HANDLER IMPLEMENTATION.


METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Purchase order </title> \n| &&
  |<form action="{ url }" method="POST">\n| &&
  |<H2> BNN Purchase Order Print</H2> \n| &&
  |<label for="fname">Purchase Order:  </label> \n| &&
  |<input type="text" id="po_num" name="po_num" required ><br><br> \n| &&
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
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_PO_HANDLER?sap-client=080'.

    DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
    DATA(po) = request->get_form_field( `purchaseorder` ).
*      DATA(doc) = request->get_form_field( `document` ).
*      DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
*      DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).


    CASE request->get_method( ).

WHEN CONV string( if_web_http_client=>get ).
 response->set_text( get_html( ) ).
  WHEN CONV string( if_web_http_client=>post ).
        DATA(lv_po1) = request->get_form_field( `po_num` ).




        SELECT SINGLE FROM I_purchaseorderapi01 AS a
        FIELDS
        a~PurchaseOrder
        WHERE a~PurchaseOrder = @lv_po1
        INTO @DATA(lv_po).


        IF lv_po IS NOT INITIAL.

          TRY.

                DATA(pdf) = zcl_po_drv_class=>read_posts( po_num = lv_po1 ) .

           IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF something Problem' ).

*            response->set_text( pdf ).
              ELSE.
                DATA(html) = |<html> | &&
                               |<body> | &&
                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&

                               | </body> | &&
                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf ).
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( 'Invoice No does not exist.' ).
        ENDIF.

    ENDCASE.
     ENDMETHOD.


    METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Purchase Order </title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Purchase Order  Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .

  ENDMETHOD.
ENDCLASS.
