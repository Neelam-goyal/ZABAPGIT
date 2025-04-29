CLASS ztest_class_history_card DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTEST_CLASS_HISTORY_CARD IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT
          FROM I_Equipment  WITH PRIVILEGED ACCESS AS a
*        LEFT JOIN I_Plant WITH PRIVILEGED ACCESS AS b ON a~plant = b~plant
        LEFT JOIN I_EquipmentTextDEX  WITH PRIVILEGED ACCESS AS d ON
        d~Equipment  = a~Equipment
        LEFT JOIN I_PMNotifMaintenanceData WITH PRIVILEGED ACCESS AS e ON
        e~Equipment  = a~Equipment
        LEFT JOIN i_maintenancenotification  WITH PRIVILEGED ACCESS AS f ON
        f~MaintenanceNotification  = e~MaintenanceNotification
        LEFT JOIN i_maintenanceorderdex  WITH PRIVILEGED ACCESS AS g ON
        g~MaintenanceNotification  = e~MaintenanceNotification
        FIELDS
         a~Equipment,                 "I_Equipment
         a~ManufacturerSerialNumber,  "I_Equipment
         a~ManufacturerPartTypeName,  "I_Equipment
*         A~plant,                     "I_Plant
         d~EquipmentName,             " I_EquipmentTextDEX
         e~MaintenanceNotification,   " I_PMNotifMaintenanceData
         e~MalfunctionStartDate,      " I_PMNotifMaintenanceData
         e~MalfunctionStartTime ,      " I_PMNotifMaintenanceData
         e~MalfunctionEndDate,        " I_PMNotifMaintenanceData
         e~MalfunctionEndTime ,       " I_PMNotifMaintenanceData
         f~NotificationText ,      "I_MAINTENANCENOTIFICATION
         g~MaintenanceOrder,          "I_MAINTENANCEORDERDEX
         g~MaintenanceOrderType     "I_MAINTENANCEORDERDEX
       " h~CalendarDate              " I_CalendarDate
*       WHERE        B~plant IN ( '02AG','02BN','05SB' )
        INTO TABLE @DATA(item).

    out->write( item ).
  ENDMETHOD.
ENDCLASS.
