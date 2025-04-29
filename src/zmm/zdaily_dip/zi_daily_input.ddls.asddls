@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'INTERFACE VIEW FOR DAILY DIP INPUT'
//@ObjectModel.query.implementedBy: 'ABAP:ZDAILY_DIP_REPORT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_DAILY_INPUT as select from zdt_daily_input
    association [0..1] to ZI_TANK_MASTER_NEW as _TankMaster
        on  $projection.Plant  = _TankMaster.Plant
        and  $projection.Product  = _TankMaster.Product
        and  $projection.Tankno  = _TankMaster.Tankno
//   association [0..*] to zgateentrylines as _GateEntry  
//        on  $projection.Plant = _GateEntry.plant
//        and $projection.Tankno = _GateEntry.sloc
//        and $projection.Product = _GateEntry.productcode           
{ 
  key plant as Plant,
  key tankno as Tankno,
  key product as Product, 
  key pdate as Pdate, 
    tankdescription as Tankdescription,
    tanksafecapacity as Tanksafecapacity,
    tankdipcm as Tankdipcm,
    
    parcelunloaded as Parcelunloaded,
    qtyunloaded as Qtyunloaded,
    
    
////     Calculated Qty MT
    case 
        when tankdipcm is not initial and _TankMaster.Capacitytype is not initial
        then cast( tankdipcm * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) 
                  as abap.dec(13,3) )
        else cast( 0 as abap.dec(13,3) )
    end as Qtymt,

////     Calculated Total Available Stock    
    case
        when qtyunloaded is not initial
        then cast( 
             tankdipcm * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) + qtyunloaded
             as abap.dec(13,3) )
        else cast( 
             tankdipcm * cast( _TankMaster.Capacitytype as abap.dec(13,3) )
             as abap.dec(13,3) )
    end as Totalavlstock,
    
    
    
//     Calculated Qty MT
//    case 
//        when tankdipcm is not initial and _TankMaster.Capacitytype is not initial
//        then cast( cast( tankdipcm as abap.dec(13,3) ) * 
//                  cast( _TankMaster.Capacitytype as abap.dec(13,3) ) 
//                  as abap.dec(13,3) )
//        else cast( 0 as abap.dec(13,3) )
//    end as Qtymt,
    
////     Calculated Total Available Stock
//    case
//        when qtyunloaded is not initial
//        then cast( 
//             cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) + cast( qtyunloaded as abap.dec(13,3) )
//             as abap.dec(13,3) )
//        else cast( 
//             cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) )
//             as abap.dec(13,3) )
//    end as Totalavlstock,
    
////    diptime as Diptime,
    bookstock as BookStock,
    
    
      // Modified Variance calculation to handle empty BookStock
    cast(
        case
            when tankdipcm is not initial and _TankMaster.Capacitytype is not initial
            then
                case
                    when qtyunloaded is not initial
                    then cast(
                        case
                            when bookstock is initial or bookstock = 0
                            then cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) + cast( qtyunloaded as abap.dec(13,3) )
                            else ( cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) + cast( qtyunloaded as abap.dec(13,3) ) ) - cast( bookstock as abap.dec(13,3) )
                        end as abap.dec(13,3)
                    )
                    else cast(
                        case
                            when bookstock is initial or bookstock = 0
                            then cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) )
                            else ( cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) ) - cast( bookstock as abap.dec(13,3) )
                        end as abap.dec(13,3)
                    )
                end
            else cast( 0 as abap.dec(13,3) )
        end as abap.dec(13,3)
    ) as Variance,
    
    
////        // Variance calculation - simplified
////    cast( 
////        case 
////            when bookstock is not initial 
////            then cast( 
////                case
////                    when qtyunloaded is not initial
////                    then cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) ) + cast( qtyunloaded as abap.dec(13,3) )
////                    else cast( tankdipcm as abap.dec(13,3) ) * cast( _TankMaster.Capacitytype as abap.dec(13,3) )
////                end - cast( bookstock as abap.dec(13,3) )
////                as abap.dec(13,3) )
////            else 0
////        end as abap.dec(13,3)
////    ) as Variance,
 
    
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _TankMaster
} 




    
//define root view entity ZI_DAILY_INPUT as select from zdt_daily_input
//{
//    key plant as Plant,
//    pdate as Pdate,
//    product as Product,
//    tankno as Tankno,
//    tankdescription as Tankdescription,
//    tanksafecapacity as Tanksafecapacity,
//    tankdipcm as Tankdipcm,
//    qtymt as Qtymt,   
//    parcelunloaded as Parcelunloaded,
//    qtyunloaded as Qtyunloaded,
//    totalavlstock as Totalavlstock,
////    diptime as Diptime,
//    variance as Variance,
//    @Semantics.user.createdBy: true
//  created_by as CreatedBy,
//  @Semantics.systemDateTime.createdAt: true
//  created_at as CreatedAt,
//  @Semantics.user.localInstanceLastChangedBy: true
//  last_changed_by as LastChangedBy,
//  @Semantics.systemDateTime.localInstanceLastChangedAt: true
//  last_changed_at as LastChangedAt,
//  
//   _TankMaster
//}
