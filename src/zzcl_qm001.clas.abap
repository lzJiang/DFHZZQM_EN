CLASS zzcl_qm001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    METHODS get_data
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.

    METHODS get_data_item
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_qm001 IMPLEMENTATION.

  METHOD get_data.

    DATA: lt_result TYPE TABLE OF zc_rqm001,
          ls_result TYPE zc_rqm001.

    DATA:r_lot TYPE RANGE OF zc_rqm001-inspectionlot.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range
*       过滤器
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'INSPECTIONLOT'.
              r_lot = CORRESPONDING #( ls_filter-range ).

          ENDCASE.
        ENDLOOP.

*       获取数据
        SELECT a~inspectionlot,
               a~plant,
               f~plantname,
               a~inspectionlottype,
               g~inspectionlottypetext,
               a~purchasingdocument,
               a~insplotselectionsupplier,
               e~suppliername,
               a~manufacturingorder,
               a~material,
               a~inspectionlotobjecttext,
               c~sizeordimensiontext,
               a~inspectionlotquantity,
               a~inspectionlotquantityunit,
               a~batchstoragelocation,
               h~storagelocationname,
               a~batch,
               a~insplotqtytofree,
               a~insplotqtyreturnedtosupplier,
               a~insplotqtytoscrap,
               d~insplotusagedecisionvaluation,


               b~zzjyy,
               b~zzjyrq,
               b~zzbgrq,
               b~zzreflot,
               b~zzreportno,
               b~zznotesno,
               b~if_send,
               b~pdf_name,
               b~pdf_file,
               b~pdf_type
          FROM i_inspectionlot AS a
          LEFT OUTER JOIN zzt_qm_001 AS b ON a~inspectionlot = b~inspectionlot
          LEFT OUTER JOIN i_product AS c ON  a~material = c~product
          LEFT OUTER JOIN i_insplotusagedecision AS d ON a~inspectionlot = d~inspectionlot
          LEFT OUTER JOIN i_supplier AS e ON a~insplotselectionsupplier = e~supplier
          LEFT OUTER JOIN i_plant AS f ON a~plant = f~plant
          LEFT OUTER JOIN i_inspectionlottypetext AS g ON a~inspectionlottype = g~inspectionlottype
                                                      AND g~language = @sy-langu
          LEFT OUTER JOIN i_storagelocation AS h ON a~plant = h~plant
                                                AND a~batchstoragelocation = h~storagelocation

         WHERE a~inspectionlot IN @r_lot
          INTO CORRESPONDING FIELDS OF TABLE @lt_result.

        "供应商批次
        SELECT a~material,                      "#EC CI_FAE_NO_LINES_OK
               a~plant,
               a~batch,
               a~batchbysupplier,
               a~manufacturedate
          FROM i_batchdistinct AS a
           FOR ALL ENTRIES IN @lt_result
         WHERE a~material = @lt_result-material
           AND a~plant = @lt_result-plant
           AND a~batch = @lt_result-batch
           INTO TABLE @DATA(lt_batchdistinct).
        SORT lt_batchdistinct BY material plant batch.


        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).

          "供应商批次
          READ TABLE lt_batchdistinct INTO DATA(ls_batchdistinct) WITH KEY material = <fs_result>-material
                                                                           plant = <fs_result>-plant
                                                                           batch = <fs_result>-batch BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_result>-batchbysupplier = ls_batchdistinct-batchbysupplier.
            <fs_result>-manufacturedate = ls_batchdistinct-manufacturedate.
          ENDIF.


          CASE <fs_result>-insplotusagedecisionvaluation.
            WHEN 'A'.
              <fs_result>-insplotusagedecisiontext = '已接收'.
            WHEN 'B'.
              <fs_result>-insplotusagedecisiontext = '已拒绝'.
          ENDCASE.
        ENDLOOP.

        SORT lt_result BY inspectionlot.

*&---====================2.数据获取后，select 排序/过滤/分页/返回设置
*&---设置过滤器
        zzcl_query_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_result ).
*&---设置记录总数
        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.
*&---设置排序
        zzcl_query_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_result ).
*&---设置按页查询
        zzcl_query_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_result ).
*&---返回数据
        io_response->set_data( lt_result ).

      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD get_data_item.

    DATA: lt_result TYPE TABLE OF zc_rqm001_char,
          ls_result TYPE zc_rqm001_char.

    DATA:r_lot TYPE RANGE OF zc_rqm001-inspectionlot.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range
*       过滤器
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'INSPECTIONLOT'.
              r_lot = CORRESPONDING #( ls_filter-range ).

          ENDCASE.
        ENDLOOP.

*       获取数据
        SELECT a~inspectionlot,
               a~inspectioncharacteristic,
               a~selectedcodeset,
               a~inspectioncharacteristictext,
               f~inspspecinformationfield1,
               f~inspspecinformationfield2,
               f~inspspecinformationfield3,
               "b~inspectionresultoriginalvalue,
               CASE b~inspectionresultoriginalvalue
               WHEN ' ' THEN '合格'
               WHEN '0' THEN '未检出'
                  ELSE b~inspectionresultoriginalvalue  END AS inspectionresultoriginalvalue,
               b~inspectionvaluationresult,
               b~inspectionresulttext


         FROM i_inspectioncharacteristic AS a
         LEFT JOIN i_inspectionresult AS b ON a~inspectionlot = b~inspectionlot
                                        AND a~inspplanoperationinternalid = b~inspplanoperationinternalid
                                        AND a~inspectioncharacteristic = b~inspectioncharacteristic
         LEFT JOIN i_inspectionlotvaluehelp AS f ON  a~inspectionlot = f~inspectionlot
                                                AND  a~inspectioncharacteristic = f~inspectioncharacteristic
         WHERE a~inspectionlot IN @r_lot
        INTO CORRESPONDING FIELDS OF TABLE @lt_result.

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
          CASE <fs_result>-inspectionvaluationresult.
            WHEN 'A'.
              <fs_result>-inspectionvaluationresulttext = '已接收'.
            WHEN 'R'.
              <fs_result>-inspectionvaluationresulttext = '已拒绝'.
          ENDCASE.

*          CASE <fs_result>-inspectionresultoriginalvalue.
*            WHEN ''.
*              <fs_result>-inspectionresultoriginalvalue = '合格'.
*            WHEN '0'.
*              <fs_result>-inspectionresultoriginalvalue = '未检出'.
*          ENDCASE.
        ENDLOOP.


*&---====================2.数据获取后，select 排序/过滤/分页/返回设置
*&---设置过滤器
        zzcl_query_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_result ).
*&---设置记录总数
        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.
*&---设置排序
        zzcl_query_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_result ).
*&---设置按页查询
        zzcl_query_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_result ).
*&---返回数据
        io_response->set_data( lt_result ).

      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
*       rap 接口查询，选择处理
    TRY.
        CASE io_request->get_entity_id(  ).
          WHEN 'ZC_RQM001'.
            get_data( io_request  = io_request
                      io_response = io_response ).

          WHEN 'ZC_RQM001_CHAR'.
            get_data_item( io_request  = io_request
                      io_response = io_response ).
        ENDCASE.
      CATCH cx_rap_query_provider INTO DATA(lx_query).
        RETURN.
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
        RETURN.
      CATCH cx_sy_open_sql_db.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
