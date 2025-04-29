@EndUserText.label: 'inspection Lot Usage Decision TP'
@Search.searchable: false
@UI.headerInfo: {typeName: 'Inspection lot Decision'}
@AccessControl.authorizationCheck: #NOT_REQUIRED

define view entity ZC_INSPLOTUSAGE as select from I_InspLotUsageDecision
{
    key InspectionLot,
    InspectionLotUsageDecisionCode
    
}
