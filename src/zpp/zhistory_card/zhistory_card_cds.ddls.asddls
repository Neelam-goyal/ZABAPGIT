@EndUserText.label: 'History Card Report'
@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS_HISTORY_CARD'
//@UI.headerInfo: {typeName: 'History Card'}


@UI.headerInfo:{
    typeName: 'History Card ',
    typeNamePlural : 'History Card Records'
}
define custom entity ZHISTORY_CARD_CDS

{
      @Consumption.valueHelpDefinition: [{ entity : { element: 'Equipment', name : 'I_TECHNICALOBJECT' } } ]

      @Search.defaultSearchElement: true
      @UI.selectionField       : [{ position: 20 }]
      @UI.lineItem             : [{ position: 20, label: 'Equipment' }]
  key Equipment                : abap.char(18);

      @UI.hidden               : true
  key Language                 : abap.char(02);
      @UI.lineItem             : [{ position: 120, label: 'Maintenance Order' }]
  key MaintenanceOrder         : abap.char(15);

      @UI.hidden               : true
  key MaintenanceNotification  : abap.char(15);

      @UI.lineItem             : [{ position: 140, label: 'Notification' }]
  key Notification             : abap.char(30);



      @Consumption.valueHelpDefinition: [{ entity : { element: 'Plant', name : 'I_Plant' } } ]

      @Search.defaultSearchElement: true
      @UI.selectionField       : [{ position: 10 }]
      @UI.lineItem             : [{ position: 10, label: 'Plant' }]
  key Plant                    : abap.char(4);
      //     @Consumption.filter: { selectionType: #RANGE}


      @Search.defaultSearchElement: true
      @UI.selectionField       : [{ position: 30 }]
      @UI.lineItem             : [{ position: 30, label: 'Calendar Date' }]
      CalendarDate             : abap.dats(8);

      @UI.lineItem             : [{ position: 40, label: ' Equipment Description' }]
      EquipmentName            : abap.char(20);


      @UI.lineItem             : [{ position: 50, label: ' Equipment Serial Number ' }]
      EquipmentSerialNumber    : abap.char(20);


      @UI.lineItem             : [{ position: 60, label: 'Model Number' }]
      ManufacturerPartTypeName : abap.char(30);


      @UI.lineItem             : [{ position: 70, label: 'Notification Description' }]
      NotificationText         : abap.char(30);

      @UI.lineItem             : [{ position: 80, label: 'Malfunction Start Date ' }]
      MalfunctionStartDate     : abap.dats(8);

      @UI.lineItem             : [{ position: 90, label: 'Malfunction Start Time ' }]
      MalfunctionStartTime     : abap.tims(6);

      @UI.lineItem             : [{ position: 100, label: 'Malfunction End Date ' }]
      MalfunctionEndDate       : abap.dats(8);

      @UI.lineItem             : [{ position: 110, label: 'Malfunction End time' }]
      MalfunctionEndTime       : abap.tims(6);

      @UI.lineItem             : [{ position: 130, label: 'Maintenance Order Type' }]
      MaintenanceOrderType     : abap.char(15);

}
