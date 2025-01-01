@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '质量检验打印抬头'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PQM001
  as select from    I_InspectionLot       as a
    left outer join zzt_qm_001            as b on a.InspectionLot = b.inspectionlot
    left outer join I_Product             as c on a.Material = c.Product
    left outer join I_Supplier            as e on a.InspLotSelectionSupplier = e.Supplier
    left outer join I_InspectionOperation as f on a.InspectionLot = f.InspectionLot


  association [0..*] to ZR_PQM001_class as _class on $projection.zzreflot = _class.InspectionLot

{
  key a.InspectionLot,
      b.zzreflot,
      a.InspectionLotObjectText,
      a.Material,
      a.Batch,
      @Semantics.quantity.unitOfMeasure: 'inspectionlotquantityunit'
      a.InspectionLotQuantity,
      a.InspectionLotQuantityUnit,
      a.InspLotSelectionSupplier,
      a.InspectionLotType,
      b.zzjyy,
      b.zzjyrq,
      b.zzbgrq,
      b.zzreportno,
      b.zznotesno,
      c.SizeOrDimensionText,
      e.SupplierName,
      f.OperationText,
      _class

}
