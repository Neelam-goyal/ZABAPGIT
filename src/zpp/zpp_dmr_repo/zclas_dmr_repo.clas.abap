CLASS zclas_dmr_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLAS_DMR_REPO IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zdmr_cds_repo,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).



      " Handle Search
      DATA(lv_search_string) = io_request->get_search_expression( ).
      DATA: lv_search_clause TYPE string.
      IF lv_search_string IS NOT INITIAL.
        " Create WHERE condition for search
        lv_search_clause = |AND ( UPPER( a~MaintenanceOrder ) LIKE UPPER( '%{ lv_search_string }%' ) |.
        lv_search_clause = |{ lv_search_clause } OR UPPER( b~OperationDescription ) LIKE UPPER( '%{ lv_search_string }%' ) )|.
      ENDIF.


      TRY.
          DATA(lt_clause) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
        clear lx_no_range.
      ENDTRY.

      DATA(lt_parameter) = io_request->get_parameters( ).
      DATA(lt_fields)    = io_request->get_requested_elements( ).
      DATA(lt_sort)      = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
        clear lx_no_sel_option.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_Plant) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = 'MAINT_ORDER'.
          DATA(lt_order) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = 'SELECT_DATE'.
          DATA(lt_date) = ls_filter_cond-range[].
          ELSEIF ls_filter_cond-name = 'MAINT_ORDER_TYPE'.
          DATA(lt_ordertype) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.


      SELECT
       FROM I_MaintenanceOrderDEX  AS a
         LEFT JOIN i_maintenanceorderoperationtp AS b ON a~MaintenanceOrder = b~MaintenanceOrder
         LEFT JOIN i_maintordercomponentdex AS c ON a~MaintenanceOrder = c~MaintenanceOrder AND c~MaintenanceOrderOperation = b~MaintenanceOrderOperation
                                                    AND c~GoodsMovementType = '261'
         LEFT JOIN I_MaintOrdConfirmationCube AS d ON a~MaintenanceOrder = d~MaintenanceOrder AND d~MaintenanceOrderOperation = c~MaintenanceOrderOperation
*         LEFT JOIN i_maintordercomponentdex AS e ON e~MaintenanceOrder = d~MaintenanceOrder
*                                            AND e~MaintenanceOrderOperation = d~MaintenanceOrderOperation
*                                            AND e~GoodsMovementType = '261'
             FIELDS
                     a~MaintOrderReferenceDate, a~maintenanceplant, a~MaintenanceOrder, a~MaintenanceOrderType,
                     b~MaintenanceOrderOperation, b~operationdescription,
                     c~Reservation, c~ReservationItem, c~ReservationType, c~Material, c~QuantityWithdrawnInBaseUnit,
                     d~MaintOrderConf, d~MaintOrderConfCntrValue, d~ConfirmationText, d~actualworkquantity, d~ActualWorkQuantityUnit
*                     e~QuantityWithdrawnInBaseUnit
       WHERE a~maintenanceplant IN @lt_plant
         AND a~MaintenanceOrder IN @lt_order
         AND a~MaintOrderReferenceDate IN @lt_date
         AND a~MaintenanceOrderType IN @lt_ordertype
       INTO TABLE @DATA(it).

*      DELETE ADJACENT DUPLICATES FROM it COMPARING ALL FIELDS.

      SORT it BY MaintenanceOrder MaintenanceOrderOperation.

      LOOP AT it INTO DATA(wa).
        ls_response-Plant = wa-MaintenancePlant.
*        ls_response-select_date = wa-MaintOrderReferenceDate.
        ls_response-select_date = |{ wa-MaintOrderReferenceDate+6(2) }.{ wa-MaintOrderReferenceDate+4(2) }.{ wa-MaintOrderReferenceDate(4) }|.
        ls_response-maint_order = |{ wa-MaintenanceOrder ALPHA = OUT }|.
        ls_response-maint_order_type = wa-MaintenanceOrderType.
        ls_response-operation_number = wa-MaintenanceOrderOperation.
        ls_response-operation_description = wa-OperationDescription.
        ls_response-Reservation = wa-Reservation.
        ls_response-ReservationItem = wa-ReservationItem.
        ls_response-ReservationType = wa-ReservationType.
        ls_response-sapare_consumed = wa-Material.
        ls_response-MaintOrderConf = wa-MaintOrderConf.
        ls_response-MaintOrderConfCntrValue = wa-MaintOrderConfCntrValue.
        ls_response-Remarks = wa-ConfirmationText.
        ls_response-MaintenanceOrderOperation = wa-MaintenanceOrderOperation.
        ls_response-time_consumed = wa-ActualWorkQuantity.
        ls_response-quantity = wa-QuantityWithdrawnInBaseUnit.
        ls_response-work_unit = wa-ActualWorkQuantityUnit.

        APPEND ls_response TO lt_response.
        CLEAR: wa, ls_response.
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
