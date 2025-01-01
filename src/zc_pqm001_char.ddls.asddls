@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '质量检验打印分类'
define root view entity ZC_PQM001_CHAR
  as projection on ZR_PQM001_CHAR
{
  key  InspectionLot,
  key  InspSpecInformationField2,
  key  InspectionCharacteristic,
       SelectedCodeSet,
       InspectionCharacteristicText,
       InspSpecInformationField1,
       InspSpecInformationField3,
       InspectionResultOriginalValue,
       InspectionValuationResult,
       InspectionResultText
}
