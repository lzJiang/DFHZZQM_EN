CLASS lhc_qm001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR qm001 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR qm001 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ qm001 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK qm001.

    METHODS zzchange FOR MODIFY
      IMPORTING keys FOR ACTION qm001~zzchange  RESULT result.
    METHODS zzpdf FOR MODIFY
      IMPORTING keys FOR ACTION qm001~zzpdf RESULT result.
    METHODS zzsend FOR MODIFY
      IMPORTING keys FOR ACTION qm001~zzsend RESULT result.

ENDCLASS.

CLASS lhc_qm001 IMPLEMENTATION.

  METHOD get_instance_features.


    SELECT *
      FROM zzt_qm_001
       FOR ALL ENTRIES IN @keys
     WHERE inspectionlot = @keys-%key-inspectionlot
      INTO TABLE @DATA(lt_qm_001).

    LOOP AT lt_qm_001 INTO DATA(ls_qm_001).

      APPEND VALUE #(
              %tky-inspectionlot     = ls_qm_001-inspectionlot
              %action-zzsend = COND #( WHEN ls_qm_001-pdf_name = ''
                                       THEN if_abap_behv=>fc-o-disabled
                                       ELSE if_abap_behv=>fc-o-enabled   )

      ) TO result.
    ENDLOOP.

*
*    result = VALUE #( FOR file IN files
*                   ( %tky                           = file-%tky
*                     %action-zzchange =  if_abap_behv=>fc-o-disabled
*                   )
*                   ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD zzchange.
    DATA:lt_qm001 TYPE TABLE OF zzt_qm_001,
         ls_qm001 TYPE zzt_qm_001.


    LOOP AT keys INTO DATA(key).
      CLEAR:ls_qm001.
      SELECT SINGLE *
        FROM zzt_qm_001
        WHERE inspectionlot = @key-%key-inspectionlot
        INTO @ls_qm001.
      IF sy-subrc <> 0.
        ls_qm001-inspectionlot = key-%key-inspectionlot.
      ENDIF.
      IF key-%param-zzjyy IS NOT INITIAL.
        ls_qm001-zzjyy = key-%param-zzjyy.
      ENDIF.
      IF key-%param-zzjyrq IS NOT INITIAL.
        ls_qm001-zzjyrq = key-%param-zzjyrq.
      ENDIF.
      IF key-%param-zzbgrq IS NOT INITIAL.
        ls_qm001-zzbgrq = key-%param-zzbgrq.
      ENDIF.
      IF key-%param-zzreportno IS NOT INITIAL.
        ls_qm001-zzreportno = key-%param-zzreportno.
      ENDIF.
      IF key-%param-zznotesno IS NOT INITIAL.
        ls_qm001-zznotesno = key-%param-zznotesno.
      ENDIF.

      IF key-%param-zzreflot <> 0.
        ls_qm001-zzreflot = key-%param-zzreflot.
      ENDIF.

      IF ls_qm001-zzreflot = 0.
        ls_qm001-zzreflot = ls_qm001-inspectionlot.
      ENDIF.

      APPEND ls_qm001 TO lt_qm001.
    ENDLOOP.


    MODIFY zzt_qm_001 FROM TABLE @lt_qm001.

    LOOP AT lt_qm001 INTO ls_qm001.
      APPEND VALUE #(
      %tky-inspectionlot = ls_qm001-inspectionlot
      %param = CORRESPONDING #( ls_qm001 )
      ) TO result.

      APPEND VALUE #( %tky-inspectionlot = ls_qm001-inspectionlot
                      %msg = new_message(
                      id       = 'ZGL01'
                      number   = 000
                      severity = if_abap_behv_message=>severity-success
                      v1       = '修改成功'
                     )
                 )  TO reported-qm001.
    ENDLOOP.

  ENDMETHOD.

  METHOD zzpdf.
    DATA:lt_qm001 TYPE TABLE OF zzt_qm_001,
         ls_qm001 TYPE zzt_qm_001.

    LOOP AT keys INTO DATA(key).
      CLEAR:ls_qm001.
      SELECT SINGLE *
        FROM zzt_qm_001
        WHERE inspectionlot = @key-%key-inspectionlot
        INTO @ls_qm001.
      IF sy-subrc <> 0.
        ls_qm001-inspectionlot = key-%key-inspectionlot.
        ls_qm001-zzreflot = ls_qm001-inspectionlot.
        MODIFY zzt_qm_001 FROM @ls_qm001.

      ELSE.
        IF ls_qm001-zzreflot = 0.
          ls_qm001-zzreflot = ls_qm001-inspectionlot.
          UPDATE zzt_qm_001 SET zzreflot = @ls_qm001-zzreflot
                          WHERE inspectionlot = @ls_qm001-inspectionlot.
        ENDIF.
      ENDIF.



      "打印处理
      SELECT SINGLE *                         "#EC CI_ALL_FIELDS_NEEDED
        FROM zr_zt_print_config
       WHERE templatename = 'QM001'
        INTO @DATA(ls_template).

      TRY.
          " 获取模板数据服务，数据
          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( CONV zzeservice( ls_template-servicedefinitionname ) ).
          DATA(lt_keys)     = lo_fdp_util->get_keys( ).
          LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_keys>).
            <fs_keys>-value = key-%key-inspectionlot.
          ENDLOOP.

          DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).

          DATA(lv_xml_string) =  /ui2/cl_json=>raw_to_string( EXPORTING iv_xstring = lv_xml ).

          DATA:lv_options TYPE cl_fp_ads_util=>ty_gs_options_pdf.
          lv_options-trace_level = 4.
          cl_fp_ads_util=>render_pdf( EXPORTING
                                         iv_locale     = 'en_US'
                                         iv_xdp_layout = ls_template-template
                                         iv_xml_data   = lv_xml
                                         is_options    = lv_options
                                      IMPORTING
                                         ev_pdf        = DATA(lv_pdf) ).

          ls_qm001-pdf_file = lv_pdf.
        CATCH cx_fp_fdp_error INTO DATA(lx_fdp).
          IF 1 = 1.
          ENDIF.
        CATCH cx_fp_ads_util INTO DATA(lx_ads).
          IF 1 = 1.
          ENDIF.
      ENDTRY.

      ls_qm001-pdf_type = 'application/pdf'.
      ls_qm001-pdf_name = |{ ls_qm001-inspectionlot }{ sy-datum }{ sy-uzeit }.pdf|.

      APPEND ls_qm001 TO lt_qm001.
    ENDLOOP.


    MODIFY zzt_qm_001 FROM TABLE @lt_qm001.

    LOOP AT lt_qm001 INTO ls_qm001.
      APPEND VALUE #(
      %tky-inspectionlot = ls_qm001-inspectionlot
      %param = CORRESPONDING #( ls_qm001 )
      ) TO result.

      APPEND VALUE #( %tky-inspectionlot = ls_qm001-inspectionlot
                      %msg = new_message(
                      id       = 'ZGL01'
                      number   = 000
                      severity = if_abap_behv_message=>severity-success
                      v1       = '质检报告生成成功'
                     )
                 )  TO reported-qm001.

    ENDLOOP.
  ENDMETHOD.

  METHOD zzsend.

    TYPES: BEGIN OF ty_head.
    TYPES:
      applicantid              TYPE string,
      applicantname            TYPE string,
      createtime               TYPE string,
      deptcode                 TYPE string,
      deptname                 TYPE string,
      reportnumber             TYPE string,
      material                 TYPE string,
      plant                    TYPE string,
      inspectionlotobjecttext  TYPE string,
      insplotselectionsupplier TYPE string,
      inspectionlotquantity    TYPE p LENGTH 10 DECIMALS 3,
      sampledate               TYPE string,
      inspectiondate           TYPE string,
      filename                 TYPE string,
      attachment               TYPE string.
    TYPES END OF ty_head.
    TYPES:BEGIN OF ty_formdata,
            proc_sap_inspectionreport TYPE ty_head,
          END OF ty_formdata.
    TYPES:BEGIN OF ty_send,
            processname TYPE string,
            action      TYPE string,
            comment     TYPE string,
            draft       TYPE abap_bool,
            existtaskid TYPE string,
            formdata    TYPE ty_formdata,
          END OF ty_send.

    DATA:ls_send TYPE ty_send.

    DATA:lt_qm001 TYPE TABLE OF zzt_qm_001,
         ls_qm001 TYPE zzt_qm_001.
    "推送处理
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'QM002'.
    DATA:lv_data TYPE string.
    DATA:lv_msgty TYPE bapi_mtype,
         lv_msgtx TYPE bapi_msg,
         lv_resp  TYPE string.
    DATA:lv_severity TYPE  if_abap_behv_message=>t_severity.
    DATA:lt_mapping TYPE /ui2/cl_json=>name_mappings.
    "获取调用类
    SELECT SINGLE zzcname
      FROM zr_vt_rest_conf
     WHERE zznumb = @lv_numb
      INTO @lv_oref.
    CHECK lv_oref IS NOT INITIAL.
*&--调用实例化接口
    DATA:lo_oref TYPE REF TO object.


    lt_mapping = VALUE #(
               ( abap = 'ProcessName'                    json = 'ProcessName'            )
               ( abap = 'Action'                         json = 'Action'                 )
               ( abap = 'Comment'                        json = 'Comment'                )
               ( abap = 'Draft'                          json = 'Draft'                  )
               ( abap = 'ExistTaskID'                    json = 'ExistTaskID'            )
               ( abap = 'FormData'                       json = 'FormData'               )
               ( abap = 'Proc_SAP_InspectionReport'      json = 'Proc_SAP_InspectionReport'    )
               ( abap = 'ApplicantId'                    json = 'ApplicantId'                  )
               ( abap = 'ApplicantName'                  json = 'ApplicantName'            )
               ( abap = 'CreateTime'                     json = 'CreateTime'               )
               ( abap = 'DeptCode'                       json = 'DeptCode'    )
               ( abap = 'DeptName'                       json = 'DeptName'  )

               ( abap = 'ReportNumber'                   json = 'ReportNumber'      )
               ( abap = 'Plant'                          json = 'Plant'      )
               ( abap = 'Material'                       json = 'Material'      )
               ( abap = 'InspectionLotObjectText'        json = 'InspectionLotObjectText'      )
               ( abap = 'InspLotSelectionSupplier'       json = 'InspLotSelectionSupplier'      )
               ( abap = 'InspectionLotQuantity'          json = 'InspectionLotQuantity'      )
               ( abap = 'SampleDate'                     json = 'SampleDate'      )
               ( abap = 'InspectionDate'                 json = 'InspectionDate'      )
               ( abap = 'FileName'                       json = 'FileName'      )
               ( abap = 'Attachment'                      json = 'Attachment'      )

               ).

    "获取推送人ID
    DATA(lv_s4_userid) = cl_abap_context_info=>get_user_technical_name( ).
    SELECT SINGLE *
             FROM i_businessuservh WITH PRIVILEGED ACCESS
            WHERE userid = @lv_s4_userid
             INTO @DATA(ls_businessuser).
    DATA(lv_email) = ls_businessuser-defaultemailaddress.
    SPLIT lv_email AT '@' INTO TABLE DATA(lt_email).
    IF sy-subrc = 0.
      READ TABLE lt_email INTO DATA(ls_email) INDEX 1.
      DATA(lv_bpmuseraccount) = to_lower( ls_email ).
    ENDIF.
    IF sy-sysid = 'NMW' OR sy-sysid = 'NO1'.
      lv_bpmuseraccount = 'kongxiangyi'.
    ENDIF.


    LOOP AT keys INTO DATA(key).
      CLEAR:ls_qm001.
      SELECT SINGLE *
        FROM zzt_qm_001
        WHERE inspectionlot = @key-%key-inspectionlot
        INTO @ls_qm001.


      CLEAR:ls_send,lv_data,lv_resp,lv_msgty,lv_msgtx.
      "整理推送数据
      ls_send-processname = |质检报告盖章申请流程|.
      ls_send-action = |提交|.
      ls_send-comment = ||.
      ls_send-draft = ||.
      ls_send-existtaskid = ||.

      "底表检验数据
      SELECT SINGLE
             inspectionlot,
             plant,
             material,
             inspectionlotobjecttext,
             insplotselectionsupplier,
             inspectionlotquantity
        FROM i_inspectionlot
       WHERE inspectionlot = @key-%key-inspectionlot
        INTO @DATA(ls_lot).
      MOVE-CORRESPONDING ls_lot TO ls_send-formdata-proc_sap_inspectionreport.
   " CONDENSE ls_send-formdata-proc_sap_inspectionreport-inspectionlotquantity NO-GAPS.
      "提交人数据
      DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
      ls_send-formdata-proc_sap_inspectionreport-applicantid = lv_bpmuseraccount.
      ls_send-formdata-proc_sap_inspectionreport-createtime = |{ lv_date+0(4) }-{ lv_date+4(2) }-{ lv_date+6(2) }|.

      "自建表数据
      "报告单编号
      ls_send-formdata-proc_sap_inspectionreport-reportnumber = ls_qm001-zzreportno.
      "取样日期
      ls_send-formdata-proc_sap_inspectionreport-sampledate =
      |{ ls_qm001-zzjyrq+0(4) }-{ ls_qm001-zzjyrq+4(2) }-{ ls_qm001-zzjyrq+6(2) }|.
      "报告日期
      ls_send-formdata-proc_sap_inspectionreport-inspectiondate =
      |{ ls_qm001-zzbgrq+0(4) }-{ ls_qm001-zzbgrq+4(2) }-{ ls_qm001-zzbgrq+6(2) }|.
      "报告文件名
      ls_send-formdata-proc_sap_inspectionreport-filename = |{ ls_lot-inspectionlotobjecttext }【检测报告】.pdf|.

      "BASE64文件
      ls_send-formdata-proc_sap_inspectionreport-attachment =
            xco_cp=>xstring( ls_qm001-pdf_file )->as_string( xco_cp_binary=>text_encoding->base64
                  )->value.

      "传入数据转JSON
      lv_data = /ui2/cl_json=>serialize(
            data          = ls_send
            pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
            name_mappings = lt_mapping ).
*&--调用实例化接口

      lt_ptab = VALUE #( ( name  = 'IV_NUMB' kind  = cl_abap_objectdescr=>exporting value = REF #( lv_numb ) ) ).
      TRY .
          CREATE OBJECT lo_oref TYPE (lv_oref) PARAMETER-TABLE lt_ptab.
          CALL METHOD lo_oref->('OUTBOUND')
            EXPORTING
              iv_data  = lv_data
            CHANGING
              ev_resp  = lv_resp
              ev_msgty = lv_msgty
              ev_msgtx = lv_msgtx.
        CATCH cx_root INTO DATA(lr_root).
          IF 1 = 1 .
          ENDIF.
      ENDTRY.

      CASE lv_msgty.
        WHEN 'S'.
          ls_qm001-if_send = 'X'.
          lv_severity =  if_abap_behv_message=>severity-success.
          lv_msgtx = '推送成功！'.
        WHEN 'E'.
          lv_severity =  if_abap_behv_message=>severity-error.
          lv_msgtx = '推送失败：' && lv_msgtx.
      ENDCASE.

      FREE lo_oref.


      APPEND VALUE #( %tky-inspectionlot = ls_qm001-inspectionlot
                      %param = CORRESPONDING #( ls_qm001 )
      ) TO result.


      APPEND VALUE #( %tky-inspectionlot = ls_qm001-inspectionlot
                      %msg = new_message(
                      id       = 'ZGL01'
                      number   = 000
                      severity = lv_severity
                      v1       = lv_msgtx
                     )
                 )  TO reported-qm001.


      APPEND ls_qm001 TO lt_qm001.
    ENDLOOP.


    MODIFY zzt_qm_001 FROM TABLE @lt_qm001.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_rqm001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_rqm001 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
