@EndUserText.label: 'Inspectionlot CDS'
@Search.searchable: false
@UI.headerInfo: {typeName: 'Inspectionlot'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZC_INSPECTION_LOT as select from I_InspectionLot
 association [0..1] to I_InspLotUsageDecision as _InspLotUsageDecision
    on $projection.InspectionLot = _InspLotUsageDecision.InspectionLot
{
    @UI.lineItem   : [{ position:1, label:'Inspection Lot' }]
    key InspectionLot,
    PurchasingDocument,
    Material,
    InspectionLotType,
 
    _InspLotUsageDecision.InspectionLotUsageDecisionCode,
    _InspLotUsageDecision
}
