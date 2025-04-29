CLASS zcl_test_daily_input DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS ZCL_TEST_DAILY_INPUT IMPLEMENTATION.


   METHOD if_oo_adt_classrun~main.
*    TRY.
*        " Delete specific record
*        DELETE FROM zdt_daily_input
*          WHERE plant = '45SB'
*            AND product = '2000000077'
*            AND tankno = 'X001'.
*
*        IF sy-subrc = 0.
*          out->write( |Record deleted successfully. { sy-dbcnt } rows affected.| ).
*          COMMIT WORK.
*        ELSE.
*          out->write( |No matching record found for deletion.| ).
*        ENDIF.
*
*        " Verify deletion by selecting data
*        SELECT FROM zdt_daily_input
*               FIELDS *
*               WHERE plant = '45SB'
*                 AND product = '2000000077'
*                 AND tankno = 'X001'
*               INTO TABLE @DATA(lt_check_data).
*
*        IF lines( lt_check_data ) > 0.
*          out->write( |Warning: Records still exist after deletion:| ).
*          out->write( lt_check_data ).
*        ELSE.
*          out->write( |Verification: No matching records found in table.| ).
*        ENDIF.
*
*        " Show all remaining records
*        SELECT FROM zdt_daily_input
*               FIELDS *
*               INTO TABLE @DATA(lt_all_data).
*
*        out->write( |Total records remaining in table: { lines( lt_all_data ) }| ).
*        out->write( lt_all_data ).
*
*      CATCH cx_root INTO DATA(lx_root).
*        out->write( |Error occurred: { lx_root->get_text( ) }| ).
*    ENDTRY.
  ENDMETHOD.
ENDCLASS.
