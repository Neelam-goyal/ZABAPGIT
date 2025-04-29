CLASS lhc_Master DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Master RESULT result.

    METHODS getstoragelocations FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Master~getstoragelocations.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR Master~validateplant.

    METHODS validatetankno FOR VALIDATE ON SAVE
      IMPORTING keys FOR Master~validatetankno.

    METHODS validateproduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR Master~validateproduct.

   METHODS validatecapacity FOR VALIDATE ON SAVE
      IMPORTING keys FOR Master~validatecapacity.

  METHODS getmaterialdescription FOR DETERMINE ON MODIFY
  IMPORTING keys FOR Master~getmaterialdescription.

ENDCLASS.

CLASS lhc_Master IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


METHOD getMaterialDescription.
  " Read the product values
  READ ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
    ENTITY Master
      FIELDS ( Product )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_master_data).

  " Process records with product values
  LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
    " Create search pattern
    DATA(lv_search_pattern) = '%' && <ls_master_data>-Product.

    SELECT FROM i_productdescription
      FIELDS productdescription,
             product
      WHERE product LIKE @lv_search_pattern
      INTO TABLE @DATA(lt_product_desc).

    IF sy-subrc = 0.
      " Process each matching record
      LOOP AT lt_product_desc INTO DATA(ls_product_desc).
        " Remove leading zeros from product
        DATA(lv_formatted_product) = ls_product_desc-product.
        SHIFT lv_formatted_product LEFT DELETING LEADING '0'.

        " Compare formatted product with tank master product
        IF lv_formatted_product = <ls_master_data>-Product.
          " Update the material description
          MODIFY ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
            ENTITY Master
              UPDATE FIELDS ( Materialdescription )
              WITH VALUE #( (
                %tky    = <ls_master_data>-%tky
                Materialdescription = ls_product_desc-productdescription
              ) ).
          EXIT. " Exit loop once we find a match
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDMETHOD.




  METHOD validatecapacity.
    " Read the capacity values
    READ ENTITIES OF zi_tank_master_new IN LOCAL MODE
      ENTITY Master
        FIELDS ( Tanksafecapacity Tankmaximumcapacity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_master_data).

    " Check each record's capacities
    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
      " Check if safe capacity is greater than maximum capacity
      IF <ls_master_data>-Tanksafecapacity > <ls_master_data>-Tankmaximumcapacity.
        " Safe capacity exceeds maximum capacity
        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-master.

        APPEND VALUE #( %tky = <ls_master_data>-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = |Tank Safe Capacity ({ <ls_master_data>-Tanksafecapacity }) cannot be greater than Tank Maximum Capacity ({ <ls_master_data>-Tankmaximumcapacity })| )
                       %element-tanksafecapacity = if_abap_behv=>mk-on
                       %element-tankmaximumcapacity = if_abap_behv=>mk-on )
          TO reported-master.
      ENDIF.

      " Also check if capacities are negative
      IF <ls_master_data>-Tanksafecapacity < 0 OR <ls_master_data>-Tankmaximumcapacity < 0.
        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-master.

        APPEND VALUE #( %tky = <ls_master_data>-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = 'Tank capacities cannot be negative' )
                       %element-tanksafecapacity = if_abap_behv=>mk-on
                       %element-tankmaximumcapacity = if_abap_behv=>mk-on )
          TO reported-master.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.




  METHOD validateplant.
    " Read the plant values
    READ ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
      ENTITY Master
        FIELDS ( Plant )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_master_data).

    " Check each plant against i_plant view
    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
      SELECT SINGLE FROM i_plant
        FIELDS plant
        WHERE plant = @<ls_master_data>-Plant
        INTO @DATA(ls_plant).

      IF sy-subrc <> 0.
        " Plant not found in i_plant view
        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-master.
        APPEND VALUE #( %tky = <ls_master_data>-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = 'Plant does not exist in the system'
                       )
                       %element-plant = if_abap_behv=>mk-on
                       ) TO reported-master.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



   METHOD validatetankno.
    " Read the tank numbers and plants
    READ ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
      ENTITY Master
        FIELDS ( Tankno Plant )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_master_data).

    " Check each tank number against i_storagelocation view
    LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
      SELECT SINGLE FROM i_storagelocation
        FIELDS StorageLocation
        WHERE StorageLocation = @<ls_master_data>-Tankno
          AND plant = @<ls_master_data>-Plant
        INTO @DATA(ls_storage).

      IF sy-subrc <> 0.
        " Storage location not found or doesn't belong to the plant
        APPEND VALUE #( %tky = <ls_master_data>-%tky ) TO failed-master.
        APPEND VALUE #( %tky = <ls_master_data>-%tky
                       %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = 'Storage location does not exist for this plant'
                       )
                       %element-tankno = if_abap_behv=>mk-on
                       ) TO reported-master.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.




  METHOD validateproduct.
**    " Read the product values
*    READ ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
*      ENTITY Master
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
*        APPEND VALUE #( %tky = <fs_master_data>-%tky ) TO failed-master.
*
*        APPEND VALUE #( %tky = <fs_master_data>-%tky
*                       %msg = new_message_with_text(
*                         severity = if_abap_behv_message=>severity-error
*                         text     = 'Invalid Product for this Plant and Storage Location combination' )
*                       %element-product = if_abap_behv=>mk-on
*                        %msg_duration = 5 )
*          TO reported-master.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.




  METHOD getStorageLocations.
   " Read the plant values
  READ ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
    ENTITY Master
      FIELDS ( Plant Tankno )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_master_data).

  " Process records with plant values
  LOOP AT lt_master_data ASSIGNING FIELD-SYMBOL(<ls_master_data>).
    " Read storage locations for the plant
    SELECT FROM i_storagelocation
      FIELDS storagelocation,
             storagelocationname
      WHERE plant = @<ls_master_data>-Plant and
            StorageLocation = @<ls_master_data>-Tankno
      INTO TABLE @DATA(lt_storage_locations).

    IF sy-subrc = 0.
      " Get the first storage location
      READ TABLE lt_storage_locations INTO DATA(ls_storage_loc) INDEX 1.
      IF sy-subrc = 0.
        " Prepare the update
        MODIFY ENTITIES OF ZI_TANK_MASTER_NEW IN LOCAL MODE
          ENTITY Master
            UPDATE FIELDS ( Storagelocationname )
            WITH VALUE #( (
              %tky    = <ls_master_data>-%tky
              Storagelocationname = ls_storage_loc-storagelocationname
            ) ).
      ENDIF.
    ENDIF.
  ENDLOOP.
  ENDMETHOD.


ENDCLASS.
