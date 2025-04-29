CLASS zdaily_dip_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
          INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDAILY_DIP_REPORT IMPLEMENTATION.


METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

*      DATA: lt_response    TYPE TABLE OF zdt_daily_input,
      DATA: lt_response    TYPE TABLE OF zcds_daily_dip_report,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

*      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        clear lx_no_sel_option.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_plant) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PDATE'.
          DATA(lt_Date) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

    select from zdt_daily_input  "zi_daily_input
        fields plant, pdate, product, tankno, tankdescription, tanksafecapacity, tankdipcm, qtymt, parcelunloaded,
               qtyunloaded, totalavlstock, bookstock, variance      "diptime
           where plant is NOT INITIAL
           into table @data(it)
           PRIVILEGED ACCESS.



********************************************************** LOOP's
      LOOP AT it INTO DATA(wa).
           ls_response-plant = wa-plant.
           ls_response-pdate = wa-pdate.
           ls_response-product = wa-product.
           ls_response-tankno = wa-tankno.
           ls_response-tankdescription = wa-tankdescription.
           ls_response-tanksafecapacity = wa-tanksafecapacity.
           ls_response-tankdipcm = wa-tankdipcm.
           ls_response-qtymt = wa-qtymt.
           ls_response-parcelunloaded = wa-parcelunloaded.
           ls_response-qtyunloaded = wa-qtyunloaded.
           ls_response-totalavlstock = wa-totalavlstock.
           ls_response-bookstock = wa-bookstock.
           ls_response-variance = wa-variance.

        APPEND ls_response TO lt_response.
      ENDLOOP.


      SORT lt_response BY plant.
      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).








*         " Build dynamic WHERE conditions
*      DATA: lt_where TYPE string_table,
*            lv_where TYPE string.
*
*      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
*        CASE ls_filter_cond-name.
*          WHEN 'PLANT'.
*            APPEND |PLANT IN @lt_filter_cond[ name = 'PLANT' ]-range| TO lt_where.
*          WHEN 'PDATE'.
*            APPEND |PDATE IN @lt_filter_cond[ name = 'PDATE' ]-range| TO lt_where.
*          " Add other fields as needed
*        ENDCASE.
*      ENDLOOP.
*
*      IF lt_where IS NOT INITIAL.
*        lv_where = REDUCE #( INIT text = ``
*                            FOR wa IN lt_where
*                            NEXT text = |{ text } { COND #( WHEN text IS INITIAL THEN `` ELSE 'AND' ) } { wa }| ).
*      ENDIF.
*
*      " Modified SELECT with WHERE clause
*      SELECT FROM zdt_daily_input
*        FIELDS *
*        WHERE (lv_where)
*        INTO TABLE @DATA(lt_data).
*
*      " Process results
*      LOOP AT lt_data INTO DATA(ls_data).
*        CLEAR ls_response.
*        MOVE-CORRESPONDING ls_data TO ls_response.
*        APPEND ls_response TO lt_response.
*      ENDLOOP.
*
*      " Handle pagination
*      IF lv_max_rows > 0.
*        lt_responseout = VALUE #( FOR ls_resp IN lt_response FROM lv_skip TO lv_max_rows
*                                ( ls_resp ) ).
*      ELSE.
*        lt_responseout = lt_response.
*      ENDIF.
*
*      io_response->set_total_number_of_records( lines( lt_response ) ).
*      io_response->set_data( lt_responseout ).


    ENDIF.
  ENDMETHOD.
ENDCLASS.
