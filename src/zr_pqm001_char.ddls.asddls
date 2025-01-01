@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@EndUserText.label: '质量检验打印特征'
define root view entity ZR_PQM001_CHAR
  as select from    I_InspectionCharacteristic as a
    left outer join I_InspectionResult         as b on  a.InspectionLot               = b.InspectionLot
                                                    and a.InspPlanOperationInternalID = b.InspPlanOperationInternalID
                                                    and a.InspectionCharacteristic    = b.InspectionCharacteristic
    left outer join I_InspectionLotValueHelp   as f on  a.InspectionLot            = f.InspectionLot
                                                    and a.InspectionCharacteristic = f.InspectionCharacteristic
{
  key  a.InspectionLot,
  key  f.InspSpecInformationField2,
  key  a.InspectionCharacteristic,
       a.SelectedCodeSet,
       case  f.InspSpecInformationField1
       when '厂家提供报告' then concat(a.InspectionCharacteristicText,'   *')
       when '第三方检测机构提供' then concat(a.InspectionCharacteristicText,'   #')
       else a.InspectionCharacteristicText end   as InspectionCharacteristicText,

       f.InspSpecInformationField1,
       f.InspSpecInformationField3,
       case b.InspectionResultOriginalValue
       when ' ' then '合格'
       when '0' then '未检出'
       else b.InspectionResultOriginalValue  end as InspectionResultOriginalValue,
       b.InspectionValuationResult,
       b.InspectionResultText
}
