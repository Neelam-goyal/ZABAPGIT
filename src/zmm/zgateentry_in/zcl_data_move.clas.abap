CLASS zcl_data_move DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
        INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DATA_MOVE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

   " First select the data
SELECT FROM zgateentrylines
  FIELDS
    gateentryno,
    gateitemno,
    documentqty,
    gateqty,
    gatevalue,
    billedparcelqy,
    itemwt
        WHERE 1 = 1
  INTO TABLE @DATA(lt_entries) PRIVILEGED ACCESS.

    IF sy-subrc = 0.
     DATA: lv_count TYPE i.

*      DATA: lt_updates TYPE TABLE OF zgateentrylines.
      " Process each record

      LOOP AT lt_entries ASSIGNING FIELD-SYMBOL(<entry>).

         UPDATE zgateentrylines SET
           poqty = @<entry>-documentqty,
           tgrnqty = @<entry>-gateqty,
           billqty = @<entry>-gatevalue,
           billparqty = @<entry>-billedparcelqy,
           itweight = @<entry>-itemwt
           WHERE gateentryno = @<entry>-gateentryno
           AND gateitemno = @<entry>-gateitemno.

        IF sy-subrc = 0.
          lv_count = lv_count + 1.
        ENDIF.
      ENDLOOP.

      IF lv_count > 0.
        out->write( |Data transfer completed successfully| ).
        out->write( |Number of records updated: { lv_count }| ).
      ELSE.
        out->write( |Error occurred during update| ).
      ENDIF.
    ELSE.
      out->write( |No data found in table| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
