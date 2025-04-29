CLASS zcl_test_vt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_VT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA : ab TYPE c LENGTH 20 VALUE 'Vishal'.

    DATA : d1 TYPE datum VALUE '20250210'.
    DATA : d2 TYPE datum VALUE '20241210'.
    DATA : d3 TYPE i .

    d3 = d1 - d2 .

    out->write( d3 ) .

  ENDMETHOD.
ENDCLASS.
