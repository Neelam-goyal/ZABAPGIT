CLASS zcl_pay_voucher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PAY_VOUCHER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_pay_voucher,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

      TRY.
          DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lo_error).
          DATA(lv_msg) = lo_error->get_text( ).
      ENDTRY.
      DATA(lt_parameters)  = io_request->get_parameters( ).
      DATA(lt_fileds)  = io_request->get_requested_elements( ).
      DATA(lt_sort)  = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          DATA(lv_error_msg) = lx_no_sel_option->get_text( ).
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
          DATA(lt_acc_doc) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_ccode) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
          DATA(lt_fiscal) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'POSTINGDATE'.
          DATA(lt_po_dt) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.



      SELECT
      accountingdocument,
      companycode,
      fiscalyear,
      postingdate
      FROM i_accountingdocumentjournal
      WHERE accountingdocument IN @lt_acc_doc
      AND companycode IN @lt_ccode
      AND fiscalyear IN @lt_fiscal
      AND postingdate IN @lt_po_dt
      INTO TABLE @DATA(it).
      SORT it BY accountingdocument ASCENDING.
      DELETE ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS .
      LOOP AT it INTO DATA(wa).
        ls_response-accountingdocument = wa-accountingdocument.
        ls_response-companycode = wa-companycode.
        ls_response-fiscalyear = wa-fiscalyear.
        ls_response-postingdate = wa-postingdate.
        APPEND ls_response TO lt_response.
        CLEAR ls_response.

      ENDLOOP.




      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.

      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
        CLEAR ls_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
