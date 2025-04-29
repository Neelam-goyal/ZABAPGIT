CLASS zsales_contract_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider. " use for rap report
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsales_contract_class IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zsales_contract_cds,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH  cx_rap_query_filter_no_range INTO DATA(lv_cx_rap_query_filter).
          DATA(lv_catch)  = '1'.
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_catch = '1'.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_Plant) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'EQUIPMENT'.
          DATA(lt_Equipment) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'PURCHASEORDERBYCUSTOMER'.
          DATA(it_PURCHASEORDERBYCUSTOMER) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'SALESCONTRACT'.
          DATA(it_SALESCONTRACT) = ls_filter_cond-range[].
        ENDIF.

      ENDLOOP.

      SELECT
       FROM i_salescontract  WITH PRIVILEGED ACCESS AS a
       LEFT JOIN i_salescontractitem WITH PRIVILEGED ACCESS AS c
       ON a~salescontract = c~salescontract
       LEFT JOIN  i_plant WITH PRIVILEGED ACCESS AS d
       ON c~plant = d~plant
       LEFT JOIN  i_PRODUCT WITH PRIVILEGED ACCESS AS e
       ON c~Product  = e~Product
*        LEFT JOIN   i_salesdocumentitem WITH PRIVILEGED ACCESS AS j
*       ON c~SalesContract  = j~ReferenceSDDocument
*        LEFT JOIN   i_deliverydocumentitem WITH PRIVILEGED ACCESS AS i
*       ON j~ReferenceSDDocument  = i~ReferenceSDDocument
       FIELDS a~purchaseorderbycustomer,
             a~salescontract,
             a~overallsdprocessstatus,
             a~creationdate,
             a~salescontractvalidityenddate,
             a~incotermsclassification,

             c~SalesContractItem,
             c~plant,
             c~Product,
             c~salescontractitemtext,
             c~targetquantity,
             c~targetquantityunit,
             c~itemnetweight,
             c~itemweightunit,
             d~plantname,
             e~producttype,
             e~productgroup
*             h~actualdeliveryquantity
*             j~itemnetweight AS sale_order_net_wt
*             i~itemnetweight AS del_net_wt
              WHERE
       a~salescontract IN @it_SALESCONTRACT
   AND   c~plant IN @lt_Plant AND a~purchaseorderbycustomer IN @it_PURCHASEORDERBYCUSTOMER
     INTO TABLE @DATA(it).

      SELECT FROM i_salescontractpartner FIELDS
                   SalesContract,
                   partner,
                   fullname AS Bill_to_Party_Name,
                   fullname AS Sales_Employee_Name,
                   fullname AS Broker_Name
                   WHERE SalesContract IN @it_salescontract
                   AND PartnerFunction IN ( 'RE' ,'ZE','ES' )
                   INTO TABLE @DATA(it_salespartner) PRIVILEGED ACCESS.

      LOOP AT it INTO DATA(wa).
        ls_response-purchaseorderbycustomer = wa-purchaseorderbycustomer.
        ls_response-SalesContract = wa-SalesContract.
        ls_response-plant = wa-plant.
        ls_response-SalesContractItem = wa-SalesContractItem.

        READ TABLE it_salespartner INTO DATA(wa_partner) WHERE SalesContract = wa-SalesContract.
        IF wa_partner IS NOT INITIAL.
          ls_response-partner = wa_partner-Partner.
          ls_response-fullname = wa_partner-Bill_to_Party_Name.
          ls_response-FULLNAME_sales = wa_partner-Sales_Employee_Name.
          ls_response-FULLNAME_Broker = wa_partner-Broker_Name.
          CLEAR wa_partner.
        ENDIF.


        ls_response-overallsdprocessstatus = wa-overallsdprocessstatus.
        ls_response-creationdate = wa-creationdate.
        ls_response-salescontractvalidityenddate = wa-salescontractvalidityenddate.
        ls_response-incotermsclassification = wa-incotermsclassification.

        ls_response-material = wa-Product.
        ls_response-salescontractitemtext = wa-salescontractitemtext.
        ls_response-targetquantity = wa-targetquantity.
        ls_response-targetquantityunit = wa-targetquantityunit.
        ls_response-plantname = wa-plantname.
        ls_response-producttype = wa-producttype.
        ls_response-productgroup = wa-productgroup.
        ls_response-itemweightunit = wa-ItemWeightUnit.

        SELECT SINGLE FROM I_SalesDocumentitem AS a
        LEFT JOIN I_DeliveryDocumentItem AS b
        ON b~DeliveryDocument = a~SalesDocument AND b~DeliveryDocumentItem = a~SalesDocumentItem
        FIELDS a~salesdocument, a~salesdocumentitem, a~orderquantity AS sum_of_sales_order_qty,
        A~ItemNetWeight,
        b~ActualDeliveryQuantity, b~ItemNetWeight as itemnetwt_dlvry

        WHERE a~ReferenceSDDocument = @wa-SalesContract AND a~ReferenceSDDocumentItem = @wa-SalesContractItem
        INTO @DATA(WA_qty) PRIVILEGED ACCESS.


        ls_response-orderquantity = wa_qty-sum_of_sales_order_qty.
        ls_response-actualdeliveryquantity = wa_QTY-actualdeliveryquantity.
        ls_response-Contract_Balance_Quantity = wa-targetquantity - wa_qty-sum_of_sales_order_qty.
        ls_response-ITEMNETWEIGHT = wa-ItemNetWeight.
        ls_response-ITEMNETWEIGHT_so = wa_qty-ItemNetWeight.
        ls_response-ITEMNETWEIGHT_delivery = wa_qty-itemnetwt_dlvry.

        ls_response-ITEMNETWEIGHT_delivery = wa-ItemNetWeight - wa_qty-sum_of_sales_order_qty.

        APPEND ls_response TO lt_response.
        CLEAR: wa, ls_response , WA_qty.
      ENDLOOP.


*      SORT lt_response BY plant.
      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

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
