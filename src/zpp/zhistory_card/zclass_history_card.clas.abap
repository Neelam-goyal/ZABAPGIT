CLASS zclass_history_card DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider. " use for rap report
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLASS_HISTORY_CARD IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zhistory_card_cds,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH  cx_rap_query_filter_no_range INTO DATA(lv_cx_rap_query_filter).
          DATA(lv_catch)  = '1'.
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_catch = '1'.
      ENDTRY.

     LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_Plant) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'EQUIPMENT'.
          DATA(lt_Equipment) = ls_filter_cond-range[].
        ENDIF.

        "  IF ls_filter_cond-name = 'CalendarDate'.
        "   DATA(it_CalendarDate) = ls_filter_cond-range[].
        "ENDIF.
      ENDLOOP.

      SELECT
       FROM I_TECHNICALOBJECT  WITH PRIVILEGED ACCESS AS a
      LEFT JOIN I_Plant WITH PRIVILEGED ACCESS AS b ON a~MAINTENANCEPLANNINGPLANT = b~plant
     LEFT JOIN I_EquipmentTextDEX  WITH PRIVILEGED ACCESS AS d ON
     d~Equipment  = a~Equipment
     LEFT JOIN I_PMNotifMaintenanceData WITH PRIVILEGED ACCESS AS e ON
     e~Equipment  = D~Equipment
     LEFT JOIN i_maintenancenotification  WITH PRIVILEGED ACCESS AS f ON
     f~MaintenanceNotification  = e~MaintenanceNotification
     LEFT JOIN i_maintenanceorderdex  WITH PRIVILEGED ACCESS AS g ON
     g~MaintenanceNotification  = e~MaintenanceNotification
     FIELDS
      a~Equipment,                 "I_Equipment
      a~ManufacturerSerialNumber,  "I_Equipment
      a~ManufacturerPartTypeName,  "I_Equipment
      b~plant,                     "I_Plant
      d~EquipmentName,             " I_EquipmentTextDEX
      e~MaintenanceNotification,   " I_PMNotifMaintenanceData
      e~MalfunctionStartDate,      " I_PMNotifMaintenanceData
      e~MalfunctionStartTime ,      " I_PMNotifMaintenanceData
      e~MalfunctionEndDate,        " I_PMNotifMaintenanceData
      e~MalfunctionEndTime ,        " I_PMNotifMaintenanceData
      f~NotificationText,         "I_MAINTENANCENOTIFICATION
      g~MaintenanceOrder,          "I_MAINTENANCEORDERDEX
      g~MaintenanceOrderType     "I_MAINTENANCEORDERDEX
    "  h~CalendarDate              " I_CalendarDate
     WHERE
     b~plant IN @lt_plant
    AND a~Equipment in @lt_Equipment
*          a~Equipment IN ( '02AG1DG001','02AG1CW002' )
    AND b~plant IN ( '02AG','02BN','05SB' )
     INTO TABLE @DATA(it).

      LOOP AT it INTO DATA(wa).
        ls_response-Equipment = wa-Equipment.
        ls_response-EquipmentSerialNumber = wa-ManufacturerSerialNumber.
        ls_response-ManufacturerPartTypeName = wa-ManufacturerPartTypeName.
        ls_response-plant = wa-plant.
        ls_response-EquipmentName  = wa-EquipmentName.
        ls_response-Notification = wa-MaintenanceNotification.
        ls_response-NotificationText = wa-NotificationText.
        ls_response-MalfunctionStartDate = wa-MalfunctionStartDate.
        ls_response-MalfunctionStartTime  =  wa-MalfunctionStartTime.
        ls_response-MalfunctionEndDate = wa-MalfunctionEndDate.
        ls_response-MalfunctionEndTime = wa-MalfunctionEndTime.
        ls_response-NotificationText = wa-NotificationText.
        ls_response-MaintenanceOrder = wa-MaintenanceOrder.
        ls_response-MaintenanceOrderType = wa-MaintenanceOrderType.

        APPEND ls_response TO lt_response.
        CLEAR: wa, ls_response.
      ENDLOOP.
*     SORT lt_response BY plant.
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
