@EndUserText.label: '质量检验报告-修改弹窗'
define abstract entity ZA_QM001_PARMATER
{
  @EndUserText.label: '检验员'
  zzjyy      : zze_jyy;
  @EndUserText.label: '取样日期'
  zzJYRQ     : zze_jyrq;
  @EndUserText.label: '报告日期'
  zzbgrq     : abap.dats;
  @EndUserText.label: '报告单编号'
  zzreportno : abap.char(50);
  @EndUserText.label: '报告编号'
  zznotesno  : abap.char(50);

  @EndUserText.label: '参考检验编号'
  zzrefLot   : abap.numc(12);
}
