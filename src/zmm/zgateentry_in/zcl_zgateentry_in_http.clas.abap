CLASS zcl_zgateentry_in_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZGATEENTRY_IN_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
*   DATA(lv_plant) = request->get_form_field( 'Plant' ).
*   if lv_plant = 'A1AG'.
    CASE request->get_method( ).
      WHEN CONV string( if_web_http_client=>get ).
        TRY.
            cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr = '21'
                object      = 'ZRGATENUM'
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
    ENDCASE.
*    endif.
  ENDMETHOD.
ENDCLASS.
