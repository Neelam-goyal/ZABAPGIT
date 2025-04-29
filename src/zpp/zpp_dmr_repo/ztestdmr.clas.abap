CLASS ztestdmr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTESTDMR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT
      a~MaintOrderReferenceDate,
            a~maintenanceplant,
            a~MaintenanceOrder,
            a~MaintenanceOrderType,
            b~MaintenanceOrderOperation,
            b~operationdescription,
            c~Material,
            d~ConfirmationText

      FROM I_MaintenanceOrderDEX WITH PRIVILEGED ACCESS AS a
   INNER JOIN i_maintenanceorderoperationtp WITH PRIVILEGED ACCESS AS b ON a~MaintenanceOrder = b~MaintenanceOrder
   INNER JOIN i_maintordercomponentdex WITH PRIVILEGED ACCESS AS c ON  a~MaintenanceOrder = c~MaintenanceOrder
   INNER JOIN I_MaintOrdConfirmationCube WITH PRIVILEGED ACCESS AS d ON a~MaintenanceOrder = d~MaintenanceOrder

    WHERE    a~maintenanceplant = '02BN'
    INTO TABLE @DATA(item).
    out->write( item ).






  ENDMETHOD.
ENDCLASS.
