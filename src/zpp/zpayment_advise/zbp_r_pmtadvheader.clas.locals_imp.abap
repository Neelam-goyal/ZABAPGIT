CLASS lhc_PmtAdvheader DEFINITION INHERITING FROM cl_abap_behavior_handler.

PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR pmtadvheader RESULT result.

    METHODS earlynumbering_pmtamtbdsumm FOR NUMBERING
      IMPORTING entities FOR CREATE pmtadvheader\_PmtAmtBDSumm.

    METHODS earlynumbering_pmtamtdeduct FOR NUMBERING
      IMPORTING entities FOR CREATE pmtadvheader\_PmtAmtDeduct.

ENDCLASS.

CLASS lhc_PmtAdvheader IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_pmtamtbdsumm.
    READ ENTITIES OF zr_pmtadvheader IN LOCAL MODE
      ENTITY pmtadvheader BY \_PmtAmtBDSumm
        FIELDS ( ItemNo )
          WITH CORRESPONDING #( entities )
          RESULT DATA(entry_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entry_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR entry_line IN entry_lines USING KEY entity WHERE ( PaymentAdviseNumber = <entry_header>-PaymentAdviseNumber )
                                    NEXT max = COND posnr( WHEN entry_line-ItemNo > max
                                                           THEN entry_line-ItemNo
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Item No.
    LOOP AT <entry_header>-%target ASSIGNING FIELD-SYMBOL(<entry_line>).
      APPEND CORRESPONDING #( <entry_line> ) TO mapped-pmtadvbdsumm ASSIGNING FIELD-SYMBOL(<mapped_entry_line>).
      IF <entry_line>-ItemNo IS INITIAL.
        max_item_id += 10.
        <mapped_entry_line>-ItemNo = max_item_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_pmtamtdeduct.
    READ ENTITIES OF zr_pmtadvheader IN LOCAL MODE
      ENTITY pmtadvheader BY \_PmtAmtDeduct
        FIELDS ( ItemNo )
          WITH CORRESPONDING #( entities )
          RESULT DATA(entry_lines)
        FAILED failed.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entry_header>).
      " get highest item from lines
      DATA(max_item_id) = REDUCE #( INIT max = CONV posnr( '000000' )
                                    FOR entry_line IN entry_lines USING KEY entity WHERE ( PaymentAdviseNumber = <entry_header>-PaymentAdviseNumber )
                                    NEXT max = COND posnr( WHEN entry_line-ItemNo > max
                                                           THEN entry_line-ItemNo
                                                           ELSE max )
                                  ).
    ENDLOOP.

    "assign Item No.
    LOOP AT <entry_header>-%target ASSIGNING FIELD-SYMBOL(<entry_line>).
      APPEND CORRESPONDING #( <entry_line> ) TO mapped-pmtadvdeduct ASSIGNING FIELD-SYMBOL(<mapped_entry_line>).
      IF <entry_line>-ItemNo IS INITIAL.
        max_item_id += 10.
        <mapped_entry_line>-ItemNo = max_item_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
