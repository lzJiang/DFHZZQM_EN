CLASS zzcl_job_qm001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_job_qm001 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val  .

    et_parameters = VALUE #(
        ( selname = 'LOT'
          kind = if_apj_dt_exec_object=>select_option
          sign = 'I'
          option = 'EQ'
          low = '030000000052' )
      ).
    TRY.
        if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
      CATCH cx_root INTO DATA(job_scheduling_exception).
        IF 1 = 1.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
       ( selname        = 'LOT'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'N'
         length         = 12
         param_text     = '检验编号'
         changeable_ind = abap_true ) ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    DATA:s_lot TYPE RANGE OF i_insplotusagedecision-inspectionlot.

    LOOP AT it_parameters INTO DATA(l_parameter).
      CASE l_parameter-selname.
        WHEN 'LOT'.
          APPEND VALUE #( sign   = l_parameter-sign
                          option = l_parameter-option
                          low    = l_parameter-low
                          high   = l_parameter-high  ) TO s_lot.
      ENDCASE.
    ENDLOOP.



    SELECT inspectionlot
      FROM i_insplotusagedecision AS a
     WHERE a~insplotusagedecisionvaluation = 'A'
       AND a~insplotusgedcsnselectedset = 'ZUD03'
       AND a~inspectionlot IN @s_lot
      INTO TABLE @DATA(lt_data).

    CHECK lt_data IS NOT INITIAL.

    SELECT material,
           batch
      FROM i_inspectionlot AS a
      JOIN @lt_data AS b ON a~inspectionlot = b~inspectionlot
      INTO TABLE @DATA(lt_inspectionlot).

    "获取库存数据
    SELECT a~product,
           a~plant,
           a~storagelocation,
           a~batch,
           a~matlwrhsstkqtyinmatlbaseunit,
           a~materialbaseunit,
           c~unitofmeasurecommercialname
      FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'CNY' ) AS a
      JOIN @lt_inspectionlot AS b ON a~product = b~material
                                 AND a~batch = b~batch
      LEFT JOIN i_unitofmeasurecommercialname AS c ON a~materialbaseunit  =  c~unitofmeasure
                                                   AND c~language = 1
     WHERE a~valuationareatype = '1'
      AND a~inventorystocktype = '02'
      AND a~matlwrhsstkqtyinmatlbaseunit IS NOT INITIAL
     INTO TABLE @DATA(lt_stock).

    DATA:ls_req  TYPE zzs_mmi001_req,
         ls_head TYPE zzs_mmi001_head_in,
         ls_item TYPE zzs_mmi001_item_in,
         ls_resp TYPE zzs_rest_out.
    DATA:lv_text     TYPE string,
         lv_severity TYPE c LENGTH 1.

    TRY.
        DATA(l_log) = cl_bali_log=>create_with_header(
             header = cl_bali_header_setter=>create( object    = 'ZZ_ALO_API'
                                                     subobject = 'ZZ_ALO_API_SUB' ) ).

        LOOP AT lt_stock INTO DATA(ls_stock).
          CLEAR:ls_req,ls_head,ls_item.

          ls_head-goodsmovementcode = '04'.
          "过账日期
          ls_head-postingdate = sy-datum.

          ls_item-plant = ls_stock-plant.
          ls_item-storagelocation = ls_stock-storagelocation.
          ls_item-material = ls_stock-product.
          ls_item-batch = ls_stock-batch.
          ls_item-goodsmovementtype = '321'.
          ls_item-quantityinentryunit = ls_stock-matlwrhsstkqtyinmatlbaseunit.
          CONDENSE ls_item-quantityinentryunit NO-GAPS.
          ls_item-entryunit = ls_stock-unitofmeasurecommercialname.
          ls_item-issuingorreceivingplant = ls_stock-plant.
          ls_item-issuingorreceivingstorageloc = ls_stock-storagelocation.
          APPEND ls_item TO ls_req-req-item.
          ls_req-req-head = ls_head.

          CALL FUNCTION 'ZZFM_MM_001'
            EXPORTING
              i_req  = ls_req
            IMPORTING
              o_resp = ls_resp.

          CLEAR:lv_text,lv_severity.
          CASE ls_resp-msgty.
            WHEN 'S'.
              lv_severity = if_bali_constants=>c_severity_status.
              lv_text = |物料{ ls_stock-product }批次{ ls_stock-batch }成功创建凭证{ ls_resp-sapnum }|.
            WHEN 'E'.
              lv_severity = if_bali_constants=>c_severity_error.
              lv_text = |物料{ ls_stock-product }批次{ ls_stock-batch }过账失败：{ ls_resp-msgtx }|.
          ENDCASE.

          l_log->add_item( item = cl_bali_free_text_setter=>create(
                             severity = lv_severity
                             text = CONV #( lv_text ) ) ).
        ENDLOOP.


        cl_bali_log_db=>get_instance( )->save_log_2nd_db_connection( log = l_log
                                                                     assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime INTO DATA(l_runtime_exception).
        IF 1 = 1.
        ENDIF.
    ENDTRY.


  ENDMETHOD.

ENDCLASS.
