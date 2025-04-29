@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Gate Entry Header Projection View'
@ObjectModel.semanticKey: [ 'Gateentryno' ]
@Search.searchable: true
define root view entity ZC_GateEntryHeader 
  provider contract transactional_query
  as projection on ZR_GateEntryHeader as GateEntryHeader
{
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.90 
    @UI.connectedFields: [{label: 'Token Number'}]
    @EndUserText.label : 'Token No.'
    key Gateentryno,
    @UI.connectedFields: [{label: 'Entry Date'}]
    @EndUserText.label : 'Entry Date'
    Entrydate,
    Plant,
    @EndUserText.label : 'Gate Outward'
    Gateoutward,
    @EndUserText.label : 'Entry Type'
    Entrytype,
    Gateentrytypedesc,
    @EndUserText.label : 'Operator Name'
    Operatorname,
    @EndUserText.label : 'Transport Mode'
    Transportmode,
    @EndUserText.label : 'GR Date'
    Grdate,
    @EndUserText.label : 'GR No.'
    Grno,
    @EndUserText.label : 'Vehicle No.'
    Vehicleno,
    Vehrepdate,
    Vehreptime,
    Gateindate,
    Gateintime,
    Transportername,
    Drivername,
    Driverlicenseno,
    Driverno,
    Gateoutdate,
    Gateouttime,
    Remarks,
    Grosswt,
    Tarewt,
    Netwt,
    Slipno,
    Totallines,
    Cancelled,
    @EndUserText.label : 'Invoice No.'
    Invoiceno,
    @EndUserText.label : 'Invoice Date'
    Invoicedate,
    Lrno,
    Lrdate,
    @EndUserText.label : 'Gate No.'
    Gateno,
    Billamount,   
    Purpose,
    Weighbridgereq,
    Preweight,
    Presamplereq,
    Vehiclergnno,
    Insurancevalidity,
    Insuranceno,
    Pucvalidity,
    Pucno,
    Carryingcapacity,
    Transporterbulitylr,
    Looseiteminbody,
    Looseitemincabn,
    Fcno,
    Fcvalidity,
    Alcoholconditiondriver,
    Stocktransferinv,
    Refdocno,
    Wbrgslipno,
    Supewaybillno,
    Supdlchallan, 
    Stocktransferchallan,
    Vehicleinsurance,
    Vehiclerc,
    Vehiclepuc,
    Drvierlicense,
    Transporterlr,
    Automaticweighbridge,
    QCrequired,
    QCnotrequired,
    QCconfirmed,
    Manualweighbridge,
    Dedicatedforedibleoil,
    Paintoutsidethebody,
    Presenceofrust,
    Presenceofmoisture,
    Presenceofsmell,
    Presenceofforeignmatter,
    Sealprovisionattop,
    Sealprovisionatbottom,
    Weatherforloading,
    QCaccept,
    QCreject,
    Vehacceptasbuyer,
    Tokenincomplete,
    Tokencomplete,
    Allowgateentry,
    Disallowgateentry,
    Supplierinvoice,
    Fitnesscertificate,
    Reasonrejection,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GATETIMEDIFF'
    @EndUserText.label: 'Time Difference'
    virtual Timedifference : abap.int2,
    /* Associations */
    _GateEntryLines : redirected to composition child ZC_GateEntryLines,
    _GateBillingLines : redirected to composition child ZC_BILLINGLINES
  
}
