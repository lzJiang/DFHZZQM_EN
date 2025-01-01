@EndUserText.label: '质量检验报告管理平台'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QM001'
@UI: {
        headerInfo: { typeName: '质量检验报告管理平台', typeNamePlural: '质量检验报告管理平台',
                      title: { value: 'InspectionLot' },
                      description: { value: 'InspectionLotObjectText' }
                    }
}
@Search.searchable: true
define root custom entity ZC_RQM001
{

      @UI.facet                     : [ { id            :'Basis',
                                        purpose       :#STANDARD,
                                        type          :#IDENTIFICATION_REFERENCE,
                                        label         :'基本信息',
                                        position      : 10 },
                                        { id:        'item',
                                          purpose:    #STANDARD,
                                         type:       #LINEITEM_REFERENCE,
                                         targetElement: '_item',
                                         position:        20 ,
                                         label:        '检验指标特性结果'}
                                      ]


      @UI.lineItem                  : [ { position: 10,  importance: #HIGH } ]
      @UI.identification            : [ { position: 10 } ]
      @Search.defaultSearchElement  : true
      @UI.selectionField            : [ { position: 10 } ]
      @EndUserText.label            : '检验批号'
  key InspectionLot                 : abap.numc(12); //检验批号

      @UI.lineItem                  : [ { position: 20 } ]
      @UI.identification            : [ { position: 20 } ]
      @UI.selectionField            : [ { position: 20 } ]
      @EndUserText.label            : '工厂'
      @ObjectModel.text.element     : [ 'PlantName' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PLANT', element: 'Plant' } } ]
      Plant                         : werks_d;

      @UI.hidden                    : true
      PlantName                     : abap.char( 20 );

      @UI.lineItem                  : [ { position: 30 } ]
      @UI.identification            : [ { position: 30 } ]
      @UI.selectionField            : [ { position: 30 } ]
      @EndUserText.label            : '检验类型'
      @ObjectModel.text.element     : [ 'InspectionLotTypeText' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_InspectionLotTypeText', element: 'InspectionLotType' } } ]
      InspectionLotType             : abap.char( 10 );

      @UI.hidden                    : true
      InspectionLotTypeText         : abap.char( 20 );

      @UI.lineItem                  : [ { position: 40 } ]
      @UI.identification            : [ { position: 40 } ]
      @UI.selectionField            : [ { position: 40 } ]
      @EndUserText.label            : '采购订单号'
      PurchasingDocument            : ebeln;

      @UI.lineItem                  : [ { position: 50 } ]
      @UI.identification            : [ { position: 50 } ]
      @EndUserText.label            : '供应商'
      @ObjectModel.text.element     : [ 'SupplierName' ]
      InspLotSelectionSupplier      : lifnr;

      @UI.hidden                    : true
      SupplierName                  : abap.char( 40 );

      @UI.lineItem                  : [ { position: 60 } ]
      @UI.identification            : [ { position: 60 } ]
      @EndUserText.label            : '供应商批次'
      BatchBySupplier               : abap.char( 20 );

      @UI.lineItem                  : [ { position: 70 } ]
      @UI.identification            : [ { position: 70 } ]
      @EndUserText.label            : '生产订单号'
      ManufacturingOrder            : aufnr;

      @UI.lineItem                  : [ { position: 80 } ]
      @UI.identification            : [ { position: 80 } ]
      @UI.selectionField            : [ { position: 80 } ]
      @EndUserText.label            : '物料号'
      @ObjectModel.text.element     : [ 'InspectionLotObjectText' ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      Material                      : matnr;

      @UI.hidden                    : true
      InspectionLotObjectText       : maktx;

      @UI.lineItem                  : [ { position: 90 } ]
      @UI.identification            : [ { position: 90 } ]
      @EndUserText.label            : '规格'
      SizeOrDimensionText           : abap.char( 20 );

      @UI.lineItem                  : [ { position: 100 } ]
      @UI.identification            : [ { position: 100 } ]
      @EndUserText.label            : '批数量'
      @Semantics.quantity.unitOfMeasure: 'InspectionLotQuantityUnit'
      InspectionLotQuantity         : menge_d;

      @UI.hidden                    : true
      InspectionLotQuantityUnit     : meins;

      @UI.lineItem                  : [ { position: 110 } ]
      @UI.identification            : [ { position: 110 } ]
      @EndUserText.label            : '库存地点'
      @ObjectModel.text.element     : [ 'StorageLocationName' ]
      BatchStorageLocation          : lgort_d;

      @UI.hidden                    : true
      StorageLocationName           : abap.char( 20 );

      @UI.lineItem                  : [ { position: 120 } ]
      @UI.identification            : [ { position: 120 } ]
      @EndUserText.label            : '入库批\生产批'
      Batch                         : charg_d;

      @UI.lineItem                  : [ { position: 130 } ]
      @UI.identification            : [ { position: 130 } ]
      @EndUserText.label            : '合格数量'
      @Semantics.quantity.unitOfMeasure: 'InspectionLotQuantityUnit'
      InspLotQtyToFree              : menge_d;

      @UI.lineItem                  : [ { position: 140 } ]
      @UI.identification            : [ { position: 140 } ]
      @EndUserText.label            : '不合格数量'
      @Semantics.quantity.unitOfMeasure: 'InspectionLotQuantityUnit'
      InspLotQtyReturnedToSupplier  : menge_d;

      @UI.lineItem                  : [ { position: 150 } ]
      @UI.identification            : [ { position: 150 } ]
      @EndUserText.label            : '报废数量'
      @Semantics.quantity.unitOfMeasure: 'InspectionLotQuantityUnit'
      InspLotQtyToScrap             : menge_d;

      @UI.lineItem                  : [ { position: 160 } ]
      @UI.identification            : [ { position: 160 } ]
      @ObjectModel.text.element     : [ 'InspLotUsageDecisionText' ]
      @EndUserText.label            : '决策结果'
      InspLotUsageDecisionValuation : abap.char( 10 );

      @UI.hidden                    : true
      InspLotUsageDecisionText      : abap.char( 10 );

      @UI.lineItem                  : [ { position: 170 } ]
      @UI.identification            : [ { position: 170 } ]
      @EndUserText.label            : '生产日期'
      ManufactureDate               : abap.dats;

      @UI.lineItem                  : [ { position: 180 },
                                        { type: #FOR_ACTION, dataAction: 'zzchange', label: '更改行项目'}
                                        ]
      @UI.identification            : [ { position: 180 },
                                        { position: 10 ,type: #FOR_ACTION, dataAction: 'zzchange', label: '更改行项目'} ]
      @EndUserText.label            : '检验员'
      zzjyy                         : abap.char( 10 );

      @UI.lineItem                  : [ { position: 190 } ]
      @UI.identification            : [ { position: 190 } ]
      @EndUserText.label            : '取样日期'
      zzjyrq                        : abap.dats;

      @UI.lineItem                  : [ { position: 191 } ]
      @UI.identification            : [ { position: 191 } ]
      @EndUserText.label            : '报告日期'
      zzbgrq                        : abap.dats;

      @UI.lineItem                  : [ { position: 192 } ]
      @UI.identification            : [ { position: 192 } ]
      @EndUserText.label            : '报告单编号'
      zzreportno                    : abap.char(50);

      @UI.lineItem                  : [ { position: 193 } ]
      @UI.identification            : [ { position: 193 } ]
      @EndUserText.label            : '报告编号'
      zznotesno                     : abap.char(50);
      @UI.lineItem                  : [ { position: 194 } ]
      @UI.identification            : [ { position: 194 } ]
      @EndUserText.label            : '参考检验编号'
      zzreflot                      : abap.numc(12);
      @UI.lineItem                  : [ { position: 200 } ,
                                        { type: #FOR_ACTION, dataAction: 'zzpdf', label: '生成检验报告'}]
      @UI.identification            : [ { position: 200 },
                                        { position: 20 ,type: #FOR_ACTION, dataAction: 'zzpdf', label: '生成检验报告'} ]
      @EndUserText.label            : '质检报告'
      @Semantics.largeObject        : { mimeType : 'pdf_type', fileName : 'pdf_name', contentDispositionPreference : #ATTACHMENT }
      pdf_file                      : zzeattachment;
      pdf_name                      : abap.char(128);
      @Semantics.mimeType           : true

      pdf_type                      : abap.char(128);
      @UI.lineItem                  : [ { position: 210 } ,
                                        { type: #FOR_ACTION, dataAction: 'zzsend', label: '推送BPM'}]
      @UI.identification            : [ { position: 210 },
                                        { position: 30 , type: #FOR_ACTION, dataAction: 'zzsend', label: '推送BPM'} ]
      @EndUserText.label            : '推送BPM'
      if_send                       : abap_boolean;

      @ObjectModel.filter.enabled   : false
      _item                         : association [0..*] to ZC_RQM001_CHAR on _item.InspectionLot = $projection.InspectionLot;
}
