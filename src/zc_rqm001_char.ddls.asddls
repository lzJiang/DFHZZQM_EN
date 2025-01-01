@EndUserText.label: '检验指标特性结果'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QM001'
@UI: {
        headerInfo: { typeName: '检验指标特性结果', typeNamePlural: '检验指标特性结果',
                      title: { value: 'InspectionCharacteristic' },
                      description: { value: 'InspectionCharacteristicText' }
                    }
}
@Search.searchable: true
define custom entity ZC_RQM001_CHAR
{
      @UI.facet                     : [ { id            :'Basis',
                                   purpose       :#STANDARD,
                                   type          :#IDENTIFICATION_REFERENCE,
                                   label         :'基本信息',
                                   position      : 10 }]


      @UI.lineItem                  : [ { position: 10,  importance: #HIGH } ]
      @UI.identification            : [ { position: 10 } ]
      @Search.defaultSearchElement  : true
      @UI.selectionField            : [ { position: 10 } ]
      @EndUserText.label            : '检验批号'
  key InspectionLot                 : abap.numc(12); //检验批号

      @UI.lineItem                  : [ { position: 13 } ]
      @UI.identification            : [ { position: 13 } ]
      @EndUserText.label            : '检验特征编号'
  key InspectionCharacteristic      : abap.numc(4);

      @UI.lineItem                  : [ { position: 20,  importance: #HIGH } ]
      @UI.identification            : [ { position: 20 } ]
      @UI.selectionField            : [ { position: 20 } ]
      @EndUserText.label            : '检验项目代码'
      SelectedCodeSet               : abap.char(8);
      @UI.lineItem                  : [ { position: 30 } ]
      @UI.identification            : [ { position: 30 } ]
      @UI.selectionField            : [ { position: 30 } ]
      @EndUserText.label            : '检验项目描述'
      InspectionCharacteristicText  : abap.char(40);
      @UI.lineItem                  : [ { position: 11 } ]
      @UI.identification            : [ { position: 11 } ]
      @EndUserText.label            : '检验类型'
      InspSpecInformationField2     : abap.char(20);
      @UI.lineItem                  : [ { position: 12 } ]
      @UI.identification            : [ { position: 12 } ]
      @EndUserText.label            : '报告来源'
      InspSpecInformationField1     : abap.char(20);

      @UI.lineItem                  : [ { position: 40 } ]
      @UI.identification            : [ { position: 40 } ]
      @EndUserText.label            : '检验项目要求'
      InspSpecInformationField3     : abap.char(40);

      @UI.lineItem                  : [ { position: 50 } ]
      @UI.identification            : [ { position: 50 } ]
      @EndUserText.label            : '检验结果'
      @ObjectModel.text.element     : [ 'InspectionResultStatusText' ]
      InspectionResultOriginalValue : abap.char(10);

      @UI.hidden                    : true
      InspectionResultStatusText    : abap.char(20);

      @UI.lineItem                  : [ { position: 50 } ]
      @UI.identification            : [ { position: 50 } ]
      @EndUserText.label            : '单项判定'
      @ObjectModel.text.element     : [ 'InspectionValuationResultText' ]
      InspectionValuationResult     : abap.char(20);

      @UI.hidden                    : true
      InspectionValuationResultText : abap.char(20);

      @UI.lineItem                  : [ { position: 60 } ]
      @UI.identification            : [ { position: 60 } ]
      @EndUserText.label            : '此项特殊检验'
      InspectionResultText          : abap.char(20);
}
