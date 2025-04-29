@EndUserText.label: 'PLANNING REPORT'
@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZCLAS_DMR_REPO'
@UI.headerInfo: {typeName: 'Production'}
define custom entity ZDMR_CDS_REPO
{
      @EndUserText.label: 'MAINT ORDER'
      @UI.lineItem            : [{ position: 30, label: 'Maintenance Order' }]
      @UI.selectionField      : [{ position: 10 }]
      @Search.defaultSearchElement: true
      key maint_order             : abap.char(12);
      

///////////////////////////////////////////////////////////      
  @UI.hidden: true
  key Reservation             : abap.numc(10);
  @UI.hidden: true
  key ReservationItem         : abap.numc(4);
  @UI.hidden: true
  key ReservationType         : abap.char(1);
  @UI.hidden: true
  key MaintOrderConf          : abap.numc(10);
  @UI.hidden: true
  key MaintOrderConfCntrValue : abap.numc(10);
//   key MaintenanceOrder: abap.char(12);
  @UI.hidden: true
  key MaintenanceOrderOperation: abap.char(4);
  @UI.hidden: true
  key MaintenanceOrderSubOperation: abap.char(4);
///////////////////////////////////////////////////////////

  
      @EndUserText.label: 'PLANT'
      @UI.selectionField      : [{ position: 10 }]
      @UI.lineItem            : [{ position: 20, label: 'Plant' }]
            @Search.defaultSearchElement: true
      Plant                   : abap.char(4);

      @EndUserText.label: 'DATE'
      @UI.selectionField      : [{ position: 20 }]
      @UI.lineItem            : [{ position: 30, label: 'Maintenance Order Date' }]
//      select_date             : abap.dats(8);
        select_date             : abap.char(10);

      @EndUserText.label: 'ORDER TYPE'
      @UI.selectionField      : [{ position: 40 }]
      @UI.lineItem            : [{ position: 40, label: 'Maintenance Order Type' }]
      maint_order_type        : abap.char(4);
      
      @UI.lineItem           : [{ position: 50, label: 'Operation Number' }]
      operation_number        : abap.char(4);
      
      @UI.lineItem            : [{ position: 60, label: 'Remarks' }]
      Remarks                 : abap.char(40);

      @UI.lineItem            : [{ position: 70, label: 'Spare Consumed' }]
      sapare_consumed         : abap.char(40);

      @UI.lineItem          : [{ position: 80, label: 'Operation Description' }]
      operation_description : abap.char(40);
      
      @UI.lineItem          : [{ position: 90, label: 'Time Consumed' }]
      time_consumed         : abap.dec(10,1);
       
      @UI.lineItem          : [{ position: 90, label: 'Quantity' }]
      quantity              : abap.dec(10,3);
             
      @UI.lineItem          : [{ position: 100, label: 'Duration' }]
      work_unit             : abap.char(10);

}
