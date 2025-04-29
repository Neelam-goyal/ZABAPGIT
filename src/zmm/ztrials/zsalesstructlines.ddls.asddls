@AbapCatalog.sqlViewName: 'Z_SALESSTRLINES'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Condition Lines'
@Analytics.dataCategory: #FACT
define view ZSALESSTRUCTLINES as 
select from I_BillingDocumentItem as bd
  left outer join I_BillingDocItemPrcgElmntBasic as ccgst on bd.BillingDocument = ccgst.BillingDocument and bd.BillingDocumentItem = ccgst.BillingDocumentItem and ccgst.ConditionType = 'JOCG'
  left outer join I_BillingDocItemPrcgElmntBasic as csgst on bd.BillingDocument = csgst.BillingDocument and bd.BillingDocumentItem = csgst.BillingDocumentItem and csgst.ConditionType = 'JOSG'
  left outer join I_BillingDocItemPrcgElmntBasic as cigst on bd.BillingDocument = cigst.BillingDocument and bd.BillingDocumentItem = cigst.BillingDocumentItem and cigst.ConditionType = 'JOIG'
  left outer join I_BillingDocItemPrcgElmntBasic as cround on bd.BillingDocument = cround.BillingDocument and bd.BillingDocumentItem = cround.BillingDocumentItem and cround.ConditionType = 'DRD1'
  left outer join I_BillingDocItemPrcgElmntBasic as ctcs1 on bd.BillingDocument = ctcs1.BillingDocument and bd.BillingDocumentItem = ctcs1.BillingDocumentItem and ctcs1.ConditionType = 'JTC1'
  left outer join I_BillingDocItemPrcgElmntBasic as ctcs2 on bd.BillingDocument = ctcs2.BillingDocument and bd.BillingDocumentItem = ctcs2.BillingDocumentItem and ctcs2.ConditionType = 'JTC2'
  left outer join I_BillingDocItemPrcgElmntBasic as ctcs3 on bd.BillingDocument = ctcs3.BillingDocument and bd.BillingDocumentItem = ctcs3.BillingDocumentItem and ctcs3.ConditionType = 'JTC3'
  left outer join I_BillingDocItemPrcgElmntBasic as ccd on bd.BillingDocument = ccd.BillingDocument and bd.BillingDocumentItem = ccd.BillingDocumentItem and ccd.ConditionType = 'ZCD1'
  left outer join I_BillingDocItemPrcgElmntBasic as cmargin on bd.BillingDocument = cmargin.BillingDocument and bd.BillingDocumentItem = cmargin.BillingDocumentItem and cmargin.ConditionType = 'ZDT1'
  left outer join I_BillingDocItemPrcgElmntBasic as cmarginqd on bd.BillingDocument = cmarginqd.BillingDocument and bd.BillingDocumentItem = cmarginqd.BillingDocumentItem and cmarginqd.ConditionType = 'ZDT2'
  left outer join I_BillingDocItemPrcgElmntBasic as cmargindt on bd.BillingDocument = cmargindt.BillingDocument and bd.BillingDocumentItem = cmargindt.BillingDocumentItem and cmargindt.ConditionType = 'ZDTD'
  left outer join I_BillingDocItemPrcgElmntBasic as cmarginic on bd.BillingDocument = cmarginic.BillingDocument and bd.BillingDocumentItem = cmarginic.BillingDocumentItem and cmarginic.ConditionType = 'ZICD'
  
{
  key bd.BillingDocument,
  key bd.BillingDocumentItem,
  bd.Product,
  ccgst.ConditionAmount as cgst,
  csgst.ConditionAmount as sgst,
  cigst.ConditionAmount as igst,
  cround.ConditionAmount as roundoff,
  ctcs1.ConditionAmount as tcsgoods,
  ctcs2.ConditionAmount as tcsother,
  ctcs3.ConditionAmount as tcsltc,
  ccd.ConditionAmount as cdamount,
  cmargin.ConditionAmount as margindisc,
  cmarginqd.ConditionAmount as marginqd,
  cmargindt.ConditionAmount as margindt,
  cmarginic.ConditionAmount as marginic
  
}

