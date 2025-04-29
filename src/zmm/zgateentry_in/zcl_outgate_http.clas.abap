CLASS zcl_outgate_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS post_gate IMPORTING lv_companyCode TYPE string RETURNING VALUE(html) TYPE string.
ENDCLASS.



CLASS ZCL_OUTGATE_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req_method) = request->get_method( ).

    CASE req_method.

      WHEN CONV string( if_web_http_client=>post ).
        " Handle POST request

        DATA(lv_projorg) = request->get_form_field( `projorg` ).
*          response->set_text( post_gate( lv_projorg ) ).
        IF lv_projorg = 'A1AG'.
          TRY.
              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr = '26'
                  object      = 'ZROUTENTRY'
                IMPORTING
                  number      = DATA(nextnumber)
              ).
            CATCH cx_number_ranges INTO DATA(lx_number_ranges).
              DATA(lv_error_msg) = lx_number_ranges->get_text( ).
          ENDTRY.
          SHIFT nextnumber LEFT DELETING LEADING '0'.
          DATA: finaldata TYPE string.
          finaldata = nextnumber.
          response->set_text( finaldata ).
          CLEAR : nextnumber,finaldata,lx_number_ranges.
        ELSEIF lv_projorg = 'BNAL'.
          TRY.
              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr = '27'
                  object      = 'ZROUTENTRY'
                IMPORTING
                  number      = nextnumber
              ).
            CATCH cx_number_ranges INTO lx_number_ranges.
              lv_error_msg = lx_number_ranges->get_text( ).
          ENDTRY.
          SHIFT nextnumber LEFT DELETING LEADING '0'.
          finaldata = nextnumber.
          response->set_text( finaldata ).
          CLEAR : nextnumber,finaldata,lx_number_ranges.
        ELSEIF lv_projorg = 'EPIL'.
          TRY.
              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr = '28'
                  object      = 'ZROUTENTRY'
                IMPORTING
                  number      = nextnumber
              ).
            CATCH cx_number_ranges INTO lx_number_ranges.
              lv_error_msg = lx_number_ranges->get_text( ).
          ENDTRY.
          SHIFT nextnumber LEFT DELETING LEADING '0'.
          finaldata = nextnumber.
          response->set_text( finaldata ).
          CLEAR : nextnumber,finaldata,lx_number_ranges.
        ELSEIF lv_projorg = 'SBPL'.
          TRY.
              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr = '29'
                  object      = 'ZROUTENTRY'
                IMPORTING
                  number      = nextnumber
              ).
            CATCH cx_number_ranges INTO lx_number_ranges.
             lv_error_msg = lx_number_ranges->get_text( ).
          ENDTRY.
          SHIFT nextnumber LEFT DELETING LEADING '0'.
          finaldata = nextnumber.
          response->set_text( finaldata ).

        ELSE.
          response->set_text( 'Please Maintain Number sequence' ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD post_gate.
  ENDMETHOD.
ENDCLASS.
