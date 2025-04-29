CLASS zcl_po_screen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PO_SCREEN IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZCDS_po ,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

*      DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
*      DATA(lt_parameters)  = io_request->get_parameters( ).
*      DATA(lt_fileds)  = io_request->get_requested_elements( ).
*      DATA(lt_sort)  = io_request->get_sort_elements( ).
*
*      TRY.
*          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
*        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
*      ENDTRY.

 TRY.
          DATA(lt_parameters)  = io_request->get_parameters( ).
          DATA(lt_fileds)  = io_request->get_requested_elements( ).
          DATA(lt_sort)  = io_request->get_sort_elements( ).


          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lx_no_sel_option.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PURCHASEORDER'.
          DATA(lt_PURCHASEORDER) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_COMPANYCODE) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'PURCHASINGORGANIZATION'.
          DATA(lt_PURCHASINGORGANIZATION) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
      a~PURCHASEORDER,
      a~COMPANYCODE,
      a~PURCHASINGORGANIZATION
      FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS AS a
      WHERE a~PurchaseOrder IN @lt_PURCHASEORDER
      AND a~CompanyCode IN @lt_COMPANYCODE
      AND a~PurchasingOrganization IN @lt_PURCHASINGORGANIZATION
      INTO TABLE @DATA(it_item).

      loop at it_item INTO DATA(wa).
      ls_response-PurchaseOrder = wa-PurchaseOrder.
      ls_response-CompanyCode = wa-CompanyCode .
      ls_response-PurchasingOrganization = wa-PurchasingOrganization.
      APPEND ls_response TO lt_response.
      clear wa.
      clear ls_response.

      ENDLOOP.




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

    ENDIF.
  ENDMETHOD.
ENDCLASS.
