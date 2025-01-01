@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '质量检验打印抬头'
define root view entity ZC_PQM001
  provider contract transactional_query
  as projection on ZR_PQM001
{
  key InspectionLot,
      zzreflot,
      InspectionLotObjectText,
      Material,
      Batch,
      @Semantics.quantity.unitOfMeasure: 'inspectionlotquantityunit'
      InspectionLotQuantity,

      InspectionLotQuantityUnit,
      InspLotSelectionSupplier,
      InspectionLotType,
      zzjyy,
      zzjyrq,
      zzbgrq,
      zzreportno,
      zznotesno,
      SizeOrDimensionText,
      SupplierName,
      OperationText,
      _class : redirected to ZC_PQM001_CLASS
}
