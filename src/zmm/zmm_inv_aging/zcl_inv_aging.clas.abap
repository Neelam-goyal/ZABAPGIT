CLASS zcl_inv_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INV_AGING IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZInv_aging_cds,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lv_CX_RAP_QUERY_FILTER).
          CLEAR lv_CX_RAP_QUERY_FILTER.
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          DATA(lv_catch) = '1'.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'PLANT'.
          DATA(ls_Plant) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'PRODUCT'.
          DATA(ls_Product) = ls_filter_cond-range[].
        ENDIF.

      ENDLOOP.



      """"""""""""""""""""""""""START OF SELECTION""""""""""""""""""""""""""""""""""""""""""

      SELECT FROM i_productplantbasic  AS a LEFT JOIN i_stockquantitycurrentvalue_2( p_displaycurrency = 'INR' ) AS b
               ON a~product = b~product AND a~plant = b~plant
*                         LEFT JOIN i_materialdocumentitem_2 AS c ON b~Product = c~Material AND b~Batch = c~Batch
        FIELDS
            a~plant , a~Product ,
            b~matlwrhsstkqtyinmatlbaseunit , b~stockvalueincccrcy , b~StorageLocation , b~Batch
*            c~PostingDate
            WHERE a~plant IN @ls_plant AND a~product IN @ls_product
            INTO TABLE @DATA(it_final).

      SELECT a~Plantname, a~plant
  FROM i_plant AS a
  INNER JOIN @it_final AS b ON a~plant = b~Plant
  INTO TABLE @DATA(it_name).


      SELECT a~Product, a~ProductDescription, b~StorageLocation
  FROM i_productdescription AS a
  LEFT JOIN i_productstoragelocationbasic AS b ON a~Product = b~product
  INNER JOIN @it_final AS c ON b~product = c~product AND b~Plant = c~plant
  INTO TABLE @DATA(it_des).


      SELECT a~batch, a~PostingDate, a~Material, a~StorageLocation
  FROM i_materialdocumentitem_2 AS a
  INNER JOIN @it_final AS b
    ON a~Material = b~Product
    AND a~Batch = b~batch
    AND a~StorageLocation = b~StorageLocation
        WHERE a~GoodsMovementType IN ( '101', '501', '561', '531' )
        INTO TABLE @DATA(it_date).



*      select from I_STOCKQUANTITYCURRENTVALUE_2( P_DISPLAYCURRENCY = 'INR' )
*      FIELDS MATLWRHSSTKQTYINMATLBASEUNIT , product
*      into table @data(it_temp).
*

      DATA : lv_date TYPE datum .
      lv_date = sy-datum.

      DATA : lv_diff TYPE i .


      LOOP AT it_final INTO DATA(wa_final).
        ls_response-Plant = wa_final-Plant.
        ls_response-product = wa_final-product.



        READ TABLE it_name INTO DATA(wa_name) WITH KEY plant = wa_final-plant.
        ls_response-plantname = wa_name-PlantName.
        CLEAR wa_name.

        READ TABLE it_des INTO DATA(wa_des) WITH KEY product = wa_final-Product.
        ls_response-productdescription = wa_des-ProductDescription.
        ls_response-storagelocation = wa_final-StorageLocation.
        CLEAR wa_des.

        READ TABLE it_date INTO DATA(wa_date) WITH KEY Material = wa_final-Product Batch = wa_final-Batch
                                                       StorageLocation = wa_final-StorageLocation.
        lv_diff =  lv_date - wa_date-PostingDate .
        CLEAR : wa_date.

        ls_response-totalstock = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
        ls_response-stockvalueincccrcy = wa_final-StockValueInCCCrcy.
        ls_response-batch = wa_final-Batch.



*        lv_diff = wa_final-PostingDate - lv_date.

        IF lv_diff > 1095.
          ls_response-qty1095 = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value1095 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 731 AND lv_diff <= 1095 ) .
          ls_response-qty731_1095 = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value731_1095 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 366 AND lv_diff <= 730 ).
          ls_response-qty366_730  = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value366_730 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 181 AND lv_diff <= 365 ).
          ls_response-qty181_365  = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value181_365 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 61 AND lv_diff <= 180 ).
          ls_response-qty61_180  = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value61_180 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 31 AND lv_diff <= 61 ).
          ls_response-qty31_61  = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value31_61 = wa_final-StockValueInCCCrcy.
        ELSEIF ( lv_diff > 0 AND lv_diff <= 31 ).
          ls_response-qty0_31  = wa_final-MatlWrhsStkQtyInMatlBaseUnit.
          ls_response-Value0_31 = wa_final-StockValueInCCCrcy.
        ENDIF.



        APPEND ls_response TO lt_response.
        CLEAR : lv_diff.
      ENDLOOP.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



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
