CLASS zcl_materials_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIALS_LIST IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF ZMaterials_List_cds,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          DATA(lv_catch) = '1'.
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
        CATCH cx_rap_query_filter_no_range INTO lx_no_sel_option.
          lv_catch = '1'.
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

      SELECT FROM i_product AS a LEFT JOIN i_productdescription AS b ON
                   a~product = b~product
                 LEFT JOIN i_productplantbasic AS c ON a~product = c~Product
                 LEFT JOIN i_productsalesdelivery AS d ON d~Product = a~Product
                 LEFT JOIN i_productstoragelocationbasic AS e ON e~product = a~product AND c~plant = e~Plant
*                 LEFT JOIN i_productvaluation AS f ON f~Product = c~product
                 LEFT JOIN i_productsupplyplanning AS h ON h~product = c~Product AND h~plant = c~Plant
            FIELDS
            a~product , a~ProductType , a~BaseUnit , a~productoldid ,
            a~GrossWeight , a~NetWeight , a~CreationDate , a~ProductGroup ,
            a~CrossPlantStatus , a~SalesStatus , a~salesstatusvaliditydate,
            b~ProductDescription ,
            c~Plant , c~ProcurementType , c~consumptiontaxctrlcode ,
            d~productsalesorg , d~productdistributionchnl ,
            e~storagelocation ,
            h~MRPType , h~MRPGroup , h~MRPResponsible , h~LotSizingProcedure , h~ReorderThresholdQuantity ,
            h~SafetyStockQuantity , h~MaximumStockQuantity , h~MinimumSafetyStockQuantity ,
            c~AvailabilityCheckType , c~ProfileCode, c~IsMarkedForDeletion , h~MinimumLotSizeQuantity
            WHERE c~Product IN @ls_product AND c~plant IN @ls_plant
            INTO TABLE @DATA(it_final).

      IF ( it_final[] IS NOT INITIAL ).
        SELECT FROM i_productdescription AS a LEFT JOIN i_productsalesdelivery AS b ON a~Product = b~Product
        LEFT JOIN @it_final AS c ON a~Product = c~Product
         FIELDS a~ProductDescription , a~product , b~accountdetnproductgroup
         INTO TABLE @DATA(it_desc).

        SELECT FROM i_plant AS a
        LEFT JOIN @it_final AS b ON a~Plant = b~Plant
         FIELDS PlantName , a~Plant
         INTO TABLE @DATA(it_plant).

        SELECT FROM i_producttypetext AS a
        LEFT JOIN @it_final AS b ON a~ProductType = b~ProductType
        FIELDS materialtypename , a~ProductType
        INTO TABLE @DATA(it_type).

        SELECT a~hasposttoinspectionstock, a~Product, a~Plant
          FROM i_productinsptypesetting AS a
          INNER JOIN @it_final AS b ON a~Product = b~Product AND a~Plant = b~Plant
        INTO TABLE @DATA(it_qm).


        SELECT a~Product, a~inventoryvaluationprocedure, a~ValuationClass,
        b~ValuationClassDescription
       FROM I_ProductValuationBasic AS a
       LEFT JOIN I_Prodvaluationclasstxt AS b ON a~ValuationClass = b~ValuationClass
        INNER JOIN @it_final AS c ON a~Product = c~Product
        INTO TABLE @DATA(it_val).


        SELECT a~inventoryvaluationprocedure, a~movingaverageprice, a~product, a~standardprice
          FROM I_ProductValuationBasic AS a
          INNER JOIN @it_final AS b ON a~product = b~product  " Add plant condition if needed
          WHERE a~inventoryvaluationprocedure IN ( 'S', 'V' )
          INTO TABLE @DATA(it_price).

      ENDIF.

*      SELECT FROM I_ProductGroupText
*      FIELDS MaterialGroupText , MaterialGroup
*      FOR ALL ENTRIES IN @it_final
*      WHERE MaterialGroup = @it_final-ProductGroup
*      INTO TABLE @DATA(it_grp).




      LOOP AT it_final INTO DATA(wa_final).

        READ TABLE it_plant INTO DATA(wa_plant) WITH KEY plant = wa_final-Plant.
        ls_response-plantname = wa_plant-PlantName.
        CLEAR : wa_plant.

        READ TABLE it_type INTO DATA(wa_type) WITH KEY ProductType = wa_final-ProductType.
        ls_response-materialtypename = wa_type-MaterialTypeName.
        CLEAR : wa_type.

*        READ TABLE it_grp INTO DATA(wa_grp) WITH KEY MaterialGroup = wa_final-ProductGroup.
*        ls_response-materialgrouptext = wa_grp-MaterialGroupText.
*        CLEAR wa_type .

        READ TABLE it_qm INTO DATA(wa_qm) WITH KEY product = wa_final-product plant = wa_final-plant.
        ls_response-hasposttoinspectionstock = wa_qm-hasposttoinspectionstock.
        CLEAR : wa_qm.

        READ TABLE it_desc INTO DATA(wa_des) WITH KEY Product = wa_final-Product.
        ls_response-accountdetnproductgroup = wa_des-accountdetnproductgroup .
        CLEAR : wa_des.

        READ TABLE it_val INTO DATA(wa_val) WITH KEY product = wa_final-Product.
        ls_response-valuationclass = wa_val-valuationclass .
        ls_response-inventoryvaluationprocedure = wa_val-inventoryvaluationprocedure .
        ls_response-valuationclassdescription = wa_val-valuationclassdescription .
        CLEAR : wa_val.

        READ TABLE it_price INTO DATA(wa_price) WITH KEY product = wa_final-product
                                                 inventoryvaluationprocedure = 'V'.
        IF sy-subrc = 0.
          ls_response-standardprice = wa_price-MovingAveragePrice.
          CLEAR : wa_price.
        ENDIF.

        READ TABLE it_price INTO DATA(wa_price1) WITH KEY product = wa_final-product
                                                 inventoryvaluationprocedure = 'S'.
        IF sy-subrc = 0.
          ls_response-standardprice = wa_price1-standardprice.
          CLEAR : wa_price1.
        ENDIF.



        ls_response-product = wa_final-Product.
        ls_response-producttype = wa_final-ProductType.
        ls_response-baseunit = wa_final-BaseUnit.
        ls_response-productoldid = wa_final-productoldid.
        ls_response-productdescription = wa_final-ProductDescription.
        ls_response-plant = wa_final-plant.
        ls_response-creationdate = wa_final-CreationDate.
        ls_response-productgroup = wa_final-ProductGroup.
        ls_response-grossweight = wa_final-GrossWeight.
        ls_response-netweight = wa_final-NetWeight.
        ls_response-productdistributionchnl = wa_final-productdistributionchnl .
        ls_response-productsalesorg = wa_final-productsalesorg.
        ls_response-storagelocation = wa_final-StorageLocation.
        ls_response-procurementtype = wa_final-procurementtype.
        ls_response-mrptype = wa_final-MRPType.
        ls_response-mrpgroup = wa_final-MRPgroup.
        ls_response-mrpresponsible = wa_final-MRPResponsible.
        ls_response-lotsizingprocedure = wa_final-lotsizingprocedure.
        ls_response-reorderthresholdquantity = wa_final-reorderthresholdquantity.
        ls_response-safetystockquantity = wa_final-SafetyStockQuantity.
        ls_response-maximumstockquantity = wa_final-MaximumStockQuantity.
        ls_response-minimumlotsizequantity = wa_final-MinimumLotSizeQuantity.
        ls_response-availabilitychecktype = wa_final-AvailabilityCheckType.
        ls_response-profilecode = wa_final-ProfileCode.
        ls_response-crossplantstatus = wa_final-CrossPlantStatus.
        ls_response-ismarkedfordeletion = wa_final-IsMarkedForDeletion.
        ls_response-salesstatus = wa_final-SalesStatus.
        ls_response-salesstatusvaliditydate = wa_final-SalesStatusValidityDate.
        ls_response-consumptiontaxctrlcode = wa_final-consumptiontaxctrlcode .





        APPEND ls_response TO lt_response.
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
