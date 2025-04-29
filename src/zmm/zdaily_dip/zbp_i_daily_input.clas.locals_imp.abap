CLASS lhc_Daily_Input DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR DailyInput RESULT result.

      METHODS calculateQuantities FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DailyInput~calculateQuantities.

      METHODS updateBookStock FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DailyInput~updateBookStock.

     METHODS validatePdate FOR VALIDATE ON SAVE
      IMPORTING keys FOR DailyInput~validatePdate.

     METHODS calculateParcelunloaded FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DailyInput~calculateParcelunloaded.

     METHODS calculateQtyunloaded FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DailyInput~calculateQtyunloaded.

*    METHODS validateplant FOR VALIDATE ON SAVE
*      IMPORTING keys FOR DailyInput~validateplant.
*
*    METHODS validatetankno FOR VALIDATE ON SAVE
*      IMPORTING keys FOR DailyInput~validatetankno.
*
*    METHODS validateproduct FOR VALIDATE ON SAVE                   " NOT WORKING
*      IMPORTING keys FOR DailyInput~validateproduct.

*    METHODS getTankDetails FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR DailyInput~getTankDetails.

*  METHODS autopopulatefields FOR DETERMINE ON MODIFY
*    IMPORTING keys FOR DailyInput~autopopulatefields.


ENDCLASS.

CLASS lhc_Daily_Input IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Implement authorization check if needed
  ENDMETHOD.




   METHOD calculateQtyunloaded.
    " Read the entities that need parcel calculation
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput
        FIELDS ( Plant Product Tankno )
        WITH CORRESPONDING #( keys )
      RESULT DATA(daily_inputs).

    " Process each record
    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
      " Get sum of billparqty from zgateentrylines
      SELECT SUM( billqty ) AS total_billqty
        FROM zgateentrylines
        WHERE plant = @<daily_input>-Plant
          AND sloc = @<daily_input>-Tankno
          AND productcode = @<daily_input>-Product
        INTO @DATA(lv_total_billqty).

      IF sy-subrc <> 0.
        lv_total_billqty = 0.
      ENDIF.

      " Format number with 3 decimal places
      DATA(lv_billunloaded_formatted) = |{ lv_total_billqty DECIMALS = 3 }|.

      " Update Parcelunloaded field
      MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
        ENTITY DailyInput
          UPDATE FIELDS ( Qtyunloaded )
          WITH VALUE #( (
            %tky = <daily_input>-%tky
            Qtyunloaded = lv_billunloaded_formatted
          ) ).

      " Add success message
      APPEND VALUE #( %msg = new_message(
          id       = 'ZDAILY_DIP'
          number   = '004'  " Ensure this message number exists in your message class
          severity = if_abap_behv_message=>severity-success
          v1      = 'Qtyunloaded updated successfully' )
          %element-Qtyunloaded = if_abap_behv=>mk-on
      ) TO reported-dailyinput.
    ENDLOOP.
  ENDMETHOD.




    METHOD calculateParcelunloaded.
    " Read the entities that need parcel calculation
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput
        FIELDS ( Plant Product Tankno )
        WITH CORRESPONDING #( keys )
      RESULT DATA(daily_inputs).

    " Process each record
    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
      " Get sum of billparqty from zgateentrylines
      SELECT SUM( billparqty ) AS total_parqty
        FROM zgateentrylines
        WHERE plant = @<daily_input>-Plant
          AND sloc = @<daily_input>-Tankno
          AND productcode = @<daily_input>-Product
        INTO @DATA(lv_total_parqty).

      IF sy-subrc <> 0.
        lv_total_parqty = 0.
      ENDIF.

      " Format number with 3 decimal places
      DATA(lv_parcelunloaded_formatted) = |{ lv_total_parqty DECIMALS = 3 }|.

      " Update Parcelunloaded field
      MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
        ENTITY DailyInput
          UPDATE FIELDS ( Parcelunloaded )
          WITH VALUE #( (
            %tky = <daily_input>-%tky
            Parcelunloaded = lv_parcelunloaded_formatted
          ) ).

      " Add success message
      APPEND VALUE #( %msg = new_message(
          id       = 'ZDAILY_DIP'
          number   = '004'  " Ensure this message number exists in your message class
          severity = if_abap_behv_message=>severity-success
          v1      = 'Parcelunloaded updated successfully' )
          %element-Parcelunloaded = if_abap_behv=>mk-on
      ) TO reported-dailyinput.
    ENDLOOP.
  ENDMETHOD.





*   METHOD validateplant.
*    " Read the plant values
*    READ ENTITIES OF ZI_DAILY_INPUT IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_master_data).
*
*    " Check each plant against i_plant view
*    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
*      SELECT SINGLE FROM i_plant
*        FIELDS plant
*        WHERE plant = @<ls_master_data>-Plant
*        INTO @DATA(ls_plant).
*
*      IF sy-subrc <> 0.
*        " Plant not found in i_plant view
*        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-DailyInput.
*        APPEND VALUE #( %tky = <ls_master_data>-%tky
*                       %msg = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-error
*                         text     = 'Plant does not exist in the system'
*                       )
*                       %element-plant = if_abap_behv=>mk-on ) TO reported-DailyInput.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.



*   METHOD validatetankno.
*    " Read the tank numbers and plants
*    READ ENTITIES OF ZI_DAILY_INPUT IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Tankno Plant )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_master_data).
*
*    " Check each tank number against i_storagelocation view
*    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
*      SELECT SINGLE FROM i_storagelocation
*        FIELDS StorageLocation
*        WHERE StorageLocation = @<ls_master_data>-Tankno
*          AND plant = @<ls_master_data>-Plant
*        INTO @DATA(ls_storage).
*
*      IF sy-subrc <> 0.
*        " Storage location not found or doesn't belong to the plant
*        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-dailyinput.
*        APPEND VALUE #( %tky = <ls_master_data>-%tky
*                       %msg = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-error
*                         text     = 'Storage location does not exist for this plant'
*                       )
*                       %element-tankno = if_abap_behv=>mk-on ) TO reported-dailyinput.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.



*  METHOD validateproduct.
*    " Read the product values
*    READ ENTITIES OF ZI_DAILY_INPUT IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Product Plant Tankno )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_master_data)
*      FAILED DATA(ls_failed)
*      REPORTED DATA(ls_reported).
*
*    " Validate entries
*    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<fs_master_data>).
*      SELECT SINGLE
*        FROM i_productstoragelocationbasic
*        fields Product
*        WHERE product = @<fs_master_data>-Product
*          AND plant = @<fs_master_data>-Plant
*          AND storagelocation = @<fs_master_data>-Tankno
*        INTO @DATA(lv_exists).
*
*      IF lv_exists <> abap_true.
*        APPEND VALUE #( %tky = <fs_master_data>-%tky ) TO failed-dailyinput.
*
*        APPEND VALUE #( %tky = <fs_master_data>-%tky
*                       %msg = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-error
*                         text     = 'Invalid Product for this Plant and Storage Location combination' )
*                       %element-product = if_abap_behv=>mk-on )
*          TO reported-dailyinput.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.







METHOD validatePdate.
    " Read the entities that need validation
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput
        FIELDS ( Plant Product Tankno Pdate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(daily_inputs).

    " Read tank master data for validity period
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput BY \_TankMaster
        FIELDS ( Plant Product Tankno Validitystartdate Validityenddate )
        WITH CORRESPONDING #( daily_inputs )
      RESULT DATA(tank_masters).

    " Process each record
    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
      " First check for duplicate entries (NEW LOGIC)
      SELECT COUNT( * )
        FROM zdt_daily_input
        WHERE plant = @<daily_input>-Plant
          AND product = @<daily_input>-Product
          AND tankno = @<daily_input>-Tankno
          AND pdate = @<daily_input>-Pdate
        INTO @DATA(lv_count).

      IF lv_count > 0.
        APPEND VALUE #( %tky = <daily_input>-%tky ) TO failed-dailyinput.
        APPEND VALUE #( %tky = <daily_input>-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = |Entry already exists for date { <daily_input>-Pdate DATE = USER }| )
                       %element-pdate = if_abap_behv=>mk-on )
          TO reported-dailyinput.
        CONTINUE.
      ENDIF.

      " Your existing validity period check
      " Find corresponding tank master entry
      READ TABLE tank_masters INTO DATA(tank_master)
        WITH KEY Plant = <daily_input>-Plant
                 Product = <daily_input>-Product
                 Tankno = <daily_input>-Tankno.

      IF sy-subrc = 0.
        " Check if pdate is within validity period
        IF <daily_input>-Pdate < tank_master-Validitystartdate OR
           <daily_input>-Pdate > tank_master-Validityenddate.
          " Add error message
          APPEND VALUE #( %msg = new_message(
              id       = 'ZDAILY_DIP'
              number   = '003'
              severity = if_abap_behv_message=>severity-error
              v1       = |Selected Date { <daily_input>-Pdate DATE = USER }|
              v2       = |Valid From: { tank_master-Validitystartdate DATE = USER }|
              v3       = |Valid To: { tank_master-Validityenddate DATE = USER }| )
              %element-Pdate = if_abap_behv=>mk-on
          ) TO reported-dailyinput.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



*  METHOD validatePdate.
*    " Read the entities that need validation
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Product Tankno Pdate )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Read tank master data for validity period
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput BY \_TankMaster
*        FIELDS ( Plant Product Tankno Validitystartdate Validityenddate )
*        WITH CORRESPONDING #( daily_inputs )
*      RESULT DATA(tank_masters).
*
*     " Process each record
*    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*      " Find corresponding tank master entry
*      READ TABLE tank_masters INTO DATA(tank_master)
*        WITH KEY Plant = <daily_input>-Plant
*                 Product = <daily_input>-Product
*                 Tankno = <daily_input>-Tankno.
*
*      IF sy-subrc = 0.
*        " Check if pdate is within validity period
*        IF <daily_input>-Pdate < tank_master-Validitystartdate OR
*           <daily_input>-Pdate > tank_master-Validityenddate.
*          " Add error message
*          APPEND VALUE #( %msg = new_message(
*              id       = 'ZDAILY_DIP'
*              number   = '003'
*              severity = if_abap_behv_message=>severity-error
*              v1       = |Selected Date { <daily_input>-Pdate DATE = USER }|
*              v2       = |Valid From: { tank_master-Validitystartdate DATE = USER }|
*              v3       = |Valid To: { tank_master-Validityenddate DATE = USER }| )
*              %element-Pdate = if_abap_behv=>mk-on
*          ) TO reported-dailyinput.
*        ENDIF.
*
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.



METHOD updateBookStock.
    " Read the entities that need stock update
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput
        FIELDS ( Plant Product Tankno )
        WITH CORRESPONDING #( keys )
      RESULT DATA(daily_inputs).

    " Get stock data for each record
    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
      SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit
        FROM I_StockQuantityCurrentValue_2( P_DisplayCurrency = 'INR' ) WITH PRIVILEGED ACCESS
        WHERE Plant = @<daily_input>-Plant
          AND Product = LPAD( @<daily_input>-Product, 18, '0' )
          AND StorageLocation = @<daily_input>-Tankno
          AND InventoryStockType = '01'    "Added condition for inventory stock type
        INTO @DATA(lv_stock_qty).

      IF sy-subrc = 0.
        " Update the BookStock field
        MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
          ENTITY DailyInput
            UPDATE FIELDS ( BookStock )
            WITH VALUE #( (
              %tky = <daily_input>-%tky
              BookStock = lv_stock_qty
            ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



*  METHOD updateBookStock.
*    " Read the entities that need stock update
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Product Tankno )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Get stock data for each record
*LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*  SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit
*    FROM I_StockQuantityCurrentValue_2( P_DisplayCurrency = 'INR' ) WITH PRIVILEGED ACCESS
*    WHERE Plant = @<daily_input>-Plant
*      AND Product = LPAD( @<daily_input>-Product, 18, '0' )
*      and StorageLocation = @<daily_input>-Tankno
*    INTO @DATA(lv_stock_qty).
*
*      IF sy-subrc = 0.
*        " Update the BookStock field
*        MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
*          ENTITY DailyInput
*            UPDATE FIELDS ( BookStock )
*            WITH VALUE #( (
*              %tky = <daily_input>-%tky
*              BookStock = lv_stock_qty
*            ) ).
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.




 METHOD calculateQuantities.
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput
        FIELDS ( Plant Tankno Tankdipcm Qtyunloaded BookStock )
        WITH CORRESPONDING #( keys )
      RESULT DATA(daily_inputs).

    " Read tank master data
    READ ENTITIES OF zi_daily_input IN LOCAL MODE
      ENTITY DailyInput BY \_TankMaster
        FIELDS ( Plant Capacitytype )
        WITH CORRESPONDING #( daily_inputs )
      RESULT DATA(tank_masters).

    " Process each record
    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
      READ TABLE tank_masters INTO DATA(tank_master) INDEX 1.
      IF sy-subrc = 0.
        TRY.
            " 1. Calculate Qty_MT (Tank Dip CM * Capacity Type)
            DATA(lv_qtymt) = COND decfloat34(
                WHEN <daily_input>-Tankdipcm IS NOT INITIAL AND tank_master-Capacitytype IS NOT INITIAL
                THEN CONV decfloat34( <daily_input>-Tankdipcm ) * CONV decfloat34( tank_master-Capacitytype )
                ELSE 0
            ).

            " 2. Calculate Total Available Stock (Qty MT + Qty to be Unloaded)
            DATA(lv_qtyunloaded) = COND decfloat34(
                WHEN <daily_input>-Qtyunloaded IS NOT INITIAL
                THEN CONV decfloat34( <daily_input>-Qtyunloaded )
                ELSE 0
            ).
            DATA(lv_totalstock) = lv_qtymt + lv_qtyunloaded.


"            3. Calculate Variance (Total Available Stock - Book Stock)
                   DATA(lv_variance) = COND decfloat34(
                WHEN <daily_input>-BookStock IS INITIAL OR <daily_input>-BookStock = 0
                THEN lv_totalstock  " If BookStock is empty or 0, variance is equal to total stock
                ELSE lv_totalstock - CONV decfloat34( <daily_input>-BookStock )
                ).

" Format numbers with 3 decimal places
DATA(lv_qtymt_formatted) = |{ lv_qtymt DECIMALS = 3 }|.
DATA(lv_totalstock_formatted) = |{ lv_totalstock DECIMALS = 3 }|.
DATA(lv_variance_formatted) = |{ lv_variance DECIMALS = 3 }|.


     " Update all calculated fields
            MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
              ENTITY DailyInput
                UPDATE FIELDS ( Qtymt Totalavlstock Variance )
                WITH VALUE #( (
                  %tky    = <daily_input>-%tky
                  Qtymt   = lv_qtymt_formatted
                  Totalavlstock = lv_totalstock_formatted
                  Variance = lv_variance_formatted
                ) ).

            " Add success message
            APPEND VALUE #( %msg = new_message(
                id       = 'ZDAILY_DIP'
                number  = '002'
                severity = if_abap_behv_message=>severity-success
                v1      = 'Calculations completed successfully' )
                %element-Variance = if_abap_behv=>mk-on
            ) TO reported-dailyinput.

        CATCH cx_root INTO DATA(lx_root).
            " Error handling
            APPEND VALUE #( %msg = new_message(
                id       = 'ZDAILY_DIP'
                number  = '001'
                severity = if_abap_behv_message=>severity-error
                v1      = lx_root->get_text( ) )
            ) TO reported-dailyinput.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.





*  METHOD calculateQuantities.
*    " Read all necessary fields
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Tankno Tankdipcm Qtyunloaded Diptime
*                Tanksafecapacity Parcelunloaded )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Read tank master data
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput BY \_TankMaster
*        FIELDS ( Plant Capacitytype )
*        WITH CORRESPONDING #( daily_inputs )
*      RESULT DATA(tank_masters).
*
*    " Process each record
*    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*      READ TABLE tank_masters INTO DATA(tank_master) INDEX 1.
*      IF sy-subrc = 0.
*        TRY.
*            " 1. Calculate Qty_MT (Tank Dip CM * Capacity Type)
*            DATA(lv_qtymt) = CONV decfloat34( <daily_input>-Tankdipcm ) *
*                            CONV decfloat34( tank_master-Capacitytype ).
*
*            " 2. Calculate Total Available Stock (Qty MT + Qty to be Unloaded)
*            DATA(lv_qtyunloaded) = COND decfloat34(
*                WHEN <daily_input>-Qtyunloaded IS NOT INITIAL
*                THEN CONV decfloat34( <daily_input>-Qtyunloaded )
*                ELSE 0
*            ).
*            DATA(lv_totalstock) = lv_qtymt + lv_qtyunloaded.
*
*            " 3. Calculate Variance (Total Available Stock - Tank SAP Book Stock@DipTime)
*            DATA(lv_diptime_stock) = COND decfloat34(
*                WHEN <daily_input>-Diptime IS NOT INITIAL
*                THEN CONV decfloat34( <daily_input>-Diptime )
*                ELSE 0
*            ).
*            DATA(lv_variance) = lv_totalstock - lv_diptime_stock.
*
*            " Format numbers with 3 decimal places
*            DATA(lv_qtymt_formatted) = |{ lv_qtymt DECIMALS = 3 }|.
*            DATA(lv_totalstock_formatted) = |{ lv_totalstock DECIMALS = 3 }|.
*            DATA(lv_variance_formatted) = |{ lv_variance DECIMALS = 3 }|.
*
*            " Update all calculated fields
*            MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
*              ENTITY DailyInput
*                UPDATE FIELDS ( Qtymt Totalavlstock Variance )
*                WITH VALUE #( (
*                  %tky    = <daily_input>-%tky
*                  Qtymt   = lv_qtymt_formatted
*                  Totalavlstock = lv_totalstock_formatted
*                  Variance = lv_variance_formatted
*                ) ).
*
*        CATCH cx_root INTO DATA(lx_root).
*            APPEND VALUE #( %msg = new_message(
*                id       = 'ZDAILY_DIP'
*                number  = '001'
*                severity = if_abap_behv_message=>severity-error
*                v1      = lx_root->get_text( ) )
*            ) TO reported-dailyinput.
*        ENDTRY.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.





*  METHOD getTankDetails.
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Product Tankno )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_daily_input).
*
*    LOOP AT lt_daily_input ASSIGNING FIELD-SYMBOL(<fs_daily_input>).
*      " Read tank master data
*      SELECT SINGLE storagelocationname, tanksafecapacity
*        FROM zi_tank_master_new
*        WHERE plant = @<fs_daily_input>-Plant
*          AND product = @<fs_daily_input>-Product
*          AND tankno = @<fs_daily_input>-Tankno
*        INTO (@DATA(lv_tankdesc), @DATA(lv_safecap)).
*
*      IF sy-subrc = 0.
*        MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
*          ENTITY DailyInput
*            UPDATE FIELDS ( Tankdescription Tanksafecapacity )
*            WITH VALUE #( (
*              %tky = <fs_daily_input>-%tky
*              Tankdescription = lv_tankdesc
*              Tanksafecapacity = lv_safecap
*            ) ).
*      ENDIF.
*    ENDLOOP.
*ENDMETHOD.



ENDCLASS.





















*CLASS lhc_Daily_Input DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR DailyInput RESULT result.
*
*      METHODS calculateQuantities FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR DailyInput~calculateQuantities.
*
*      METHODS updateBookStock FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR DailyInput~updateBookStock.
*
*     METHODS validatePdate FOR VALIDATE ON SAVE
*      IMPORTING keys FOR DailyInput~validatePdate.
*
*ENDCLASS.
*
*CLASS lhc_Daily_Input IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*    " Implement authorization check if needed
*  ENDMETHOD.
*
*
*  METHOD validatePdate.
*    " Read the entities that need validation
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Product Tankno Pdate )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Read tank master data for validity period
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput BY \_TankMaster
*        FIELDS ( Plant Product Tankno Validitystartdate Validityenddate )
*        WITH CORRESPONDING #( daily_inputs )
*      RESULT DATA(tank_masters).
*
*     " Process each record
*    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*      " Find corresponding tank master entry
*      READ TABLE tank_masters INTO DATA(tank_master)
*        WITH KEY Plant = <daily_input>-Plant
*                 Product = <daily_input>-Product
*                 Tankno = <daily_input>-Tankno.
*
*      IF sy-subrc = 0.
*        " Check if date is outside validity period
*        IF <daily_input>-Pdate < tank_master-Validitystartdate OR
*           <daily_input>-Pdate > tank_master-Validityenddate.
*
*          DATA(lv_msg_text) = COND #(
*            WHEN <daily_input>-Pdate < tank_master-Validitystartdate
*            THEN |Selected Date { <daily_input>-Pdate DATE = USER } | &&
*                 |is before validity period start date ({ tank_master-Validitystartdate DATE = USER })|
*            WHEN <daily_input>-Pdate > tank_master-Validityenddate
*            THEN |Selected Date { <daily_input>-Pdate DATE = USER } | &&
*                 |is after validity period end date ({ tank_master-Validityenddate DATE = USER })|
*          ).
*
*          APPEND VALUE #(
*            %tky = <daily_input>-%tky
*            %msg = new_message_with_text(
*              severity = if_abap_behv_message=>severity-error
*              text    = lv_msg_text
*            )
*          ) TO reported-dailyinput.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*
*  METHOD updateBookStock.
*    " Read the entities that need stock update
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Product Tankno )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Get stock data for each record
*LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*  SELECT SINGLE MatlWrhsStkQtyInMatlBaseUnit
*    FROM I_StockQuantityCurrentValue_2( P_DisplayCurrency = 'INR' ) WITH PRIVILEGED ACCESS
*    WHERE Plant = @<daily_input>-Plant
*      AND Product = LPAD( @<daily_input>-Product, 18, '0' )
*      and StorageLocation = @<daily_input>-Tankno
*    INTO @DATA(lv_stock_qty).
*
*      IF sy-subrc = 0.
*        " Update the BookStock field
*        MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
*          ENTITY DailyInput
*            UPDATE FIELDS ( BookStock )
*            WITH VALUE #( (
*              %tky = <daily_input>-%tky
*              BookStock = lv_stock_qty
*            ) ).
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*
*METHOD calculateQuantities.
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput
*        FIELDS ( Plant Tankno Tankdipcm Qtyunloaded BookStock )
*        WITH CORRESPONDING #( keys )
*      RESULT DATA(daily_inputs).
*
*    " Read tank master data
*    READ ENTITIES OF zi_daily_input IN LOCAL MODE
*      ENTITY DailyInput BY \_TankMaster
*        FIELDS ( Plant Capacitytype )
*        WITH CORRESPONDING #( daily_inputs )
*      RESULT DATA(tank_masters).
*
*    " Process each record
*    LOOP AT daily_inputs ASSIGNING FIELD-SYMBOL(<daily_input>).
*      READ TABLE tank_masters INTO DATA(tank_master) INDEX 1.
*      IF sy-subrc = 0.
*        TRY.
*            " 1. Calculate Qty_MT (Tank Dip CM * Capacity Type)
*            DATA(lv_qtymt) = COND decfloat34(
*                WHEN <daily_input>-Tankdipcm IS NOT INITIAL AND tank_master-Capacitytype IS NOT INITIAL
*                THEN CONV decfloat34( <daily_input>-Tankdipcm ) * CONV decfloat34( tank_master-Capacitytype )
*                ELSE 0
*            ).
*
*            " 2. Calculate Total Available Stock (Qty MT + Qty to be Unloaded)
*            DATA(lv_qtyunloaded) = COND decfloat34(
*                WHEN <daily_input>-Qtyunloaded IS NOT INITIAL
*                THEN CONV decfloat34( <daily_input>-Qtyunloaded )
*                ELSE 0
*            ).
*            DATA(lv_totalstock) = lv_qtymt + lv_qtyunloaded.
*
*
*"            3. Calculate Variance (Total Available Stock - Book Stock)
*                   DATA(lv_variance) = COND decfloat34(
*                WHEN <daily_input>-BookStock IS INITIAL OR <daily_input>-BookStock = 0
*                THEN lv_totalstock  " If BookStock is empty or 0, variance is equal to total stock
*                ELSE lv_totalstock - CONV decfloat34( <daily_input>-BookStock )
*                ).
*
*" Format numbers with 3 decimal places
*DATA(lv_qtymt_formatted) = |{ lv_qtymt DECIMALS = 3 }|.
*DATA(lv_totalstock_formatted) = |{ lv_totalstock DECIMALS = 3 }|.
*DATA(lv_variance_formatted) = |{ lv_variance DECIMALS = 3 }|.
*
*
*            " Update all calculated fields
*            MODIFY ENTITIES OF zi_daily_input IN LOCAL MODE
*              ENTITY DailyInput
*                UPDATE FIELDS ( Qtymt Totalavlstock Variance )
*                WITH VALUE #( (
*                  %tky    = <daily_input>-%tky
*                  Qtymt   = lv_qtymt_formatted
*                  Totalavlstock = lv_totalstock_formatted
*                  Variance = lv_variance_formatted
*                ) ).
*
*            " Add success message
*            APPEND VALUE #( %msg = new_message(
*                id       = 'ZDAILY_DIP'
*                number  = '002'
*                severity = if_abap_behv_message=>severity-success
*                v1      = 'Calculations completed successfully' )
*                %element-Variance = if_abap_behv=>mk-on
*            ) TO reported-dailyinput.
*
*        CATCH cx_root INTO DATA(lx_root).
*            " Error handling
*            APPEND VALUE #( %msg = new_message(
*                id       = 'ZDAILY_DIP'
*                number  = '001'
*                severity = if_abap_behv_message=>severity-error
*                v1      = lx_root->get_text( ) )
*            ) TO reported-dailyinput.
*        ENDTRY.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
