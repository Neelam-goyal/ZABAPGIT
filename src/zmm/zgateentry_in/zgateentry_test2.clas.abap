CLASS zgateentry_test2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZGATEENTRY_TEST2 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DELETE FROM zgateentryheader.
    DELETE FROM zgateentrylines.
    out->write( 'All entries deleted from ZGATEENTRYHEADER and ZGATEENTRYLINES.' ).
  ENDMETHOD.
ENDCLASS.
