@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: '质量检验打印分类'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PQM001_CLASS
  as projection on ZR_PQM001_class
{
  key InspectionLot,
  key InspSpecInformationField2,
      _char : redirected to ZC_PQM001_CHAR
}
