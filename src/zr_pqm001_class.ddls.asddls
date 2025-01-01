@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@EndUserText.label: '质量检验打印分类'
define root view entity ZR_PQM001_class
  as select from I_InspectionLotValueHelp
  association [0..*] to ZR_PQM001_CHAR as _char on  _char.InspectionLot             = $projection.InspectionLot
                                                and _char.InspSpecInformationField2 = $projection.InspSpecInformationField2
{
  key InspectionLot,
  key InspSpecInformationField2,
      _char
}
group by
  InspectionLot,
  InspSpecInformationField2
