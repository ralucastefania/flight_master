*&---------------------------------------------------------------------*
*& Report Z_RB_FLIGHT_PROJECT_PHASE4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_rb_flight_project_phase4. 

DATA lt_db_flights TYPE TABLE OF zrb_flights.
DATA lr_alv TYPE REF TO cl_salv_table.
DATA lv_carrid TYPE s_carr_id. " workaround for flies initialisation bug
DATA lr_functions TYPE REF TO cl_salv_functions_list. "functions of alv toolbar
DATA lr_column TYPE REF TO cl_salv_column.
DATA lv_short_text TYPE scrtext_s.
DATA lv_med_text TYPE scrtext_m.
DATA lv_long_text TYPE scrtext_L.

"create the selection screen
"parameters are based on the selection criteria
SELECTION-SCREEN BEGIN OF BLOCK sel_flight
  WITH FRAME TITLE title.
  PARAMETERS:
    p_flfrom TYPE s_date VISIBLE LENGTH 20 DEFAULT '20130101',
    p_flto   TYPE s_date VISIBLE LENGTH 20 DEFAULT '20221029',
    p_carrid TYPE s_carr_id AS LISTBOX VISIBLE LENGTH 20 USER-COMMAND carrid DEFAULT 'LH',
    p_plntye TYPE s_planetye AS LISTBOX VISIBLE LENGTH 20,
    p_class  TYPE z_rb_flight_class AS LISTBOX VISIBLE LENGTH 20,
    p_minst  TYPE int4 VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK sel_flight.

INITIALIZATION.
  sy-title = TEXT-002.
  title = TEXT-001.
  lv_short_text = TEXT-003.
  lv_med_text = TEXT-003.
  lv_long_text = TEXT-004.

  z_rb_cl_flight_api=>set_airline_list( ).

*  p_carrid = 'AC'.  "tried as workaround for FORELLE case

  "initialize the airplanes list based on the default value of the airline
  z_rb_cl_flight_api=>set_plane_type_list(
    EXPORTING
      iv_carrid = p_carrid ).

  "change the airplanes list based on the event in the selection screen
  "connected with the event through user-command in the p_carrid

AT SELECTION-SCREEN.
  IF sy-ucomm = 'CARRID'.
    z_rb_cl_flight_api=>set_plane_type_list(
       EXPORTING
         iv_carrid = p_carrid ).
    CLEAR p_plntye.
  ENDIF.

START-OF-SELECTION.

  TRY.
      "select flights based on the chosen class
      z_rb_cl_flight_api=>get_flights(
        EXPORTING
          iv_date_from = p_flfrom
          iv_date_to   = p_flto
          iv_carrid    = p_carrid
          iv_plntye    = p_plntye
          iv_class     = p_class
          iv_minst     = p_minst
        IMPORTING
         et_flights   = lt_db_flights ).

      cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lr_alv
      CHANGING
        t_table      = lt_db_flights ).

      lr_column = lr_alv->get_columns( )->get_column( 'CARRID' ).

      lr_column->set_short_text( lv_short_text ).
      lr_column->set_medium_text( lv_med_text ).
      lr_column->set_long_text( lv_long_text ).

      lr_functions = lr_alv->get_functions( ).
      lr_functions->set_all( ).

      "Simon Agregation
      lr_alv->get_sorts( )->add_sort( columnname = 'FLDATE' subtotal = abap_true ).

      "display instance
      lr_alv->get_display_settings( )->set_list_header( |Flight Schedule - { lines( lt_db_flights ) } records| ). "set alv title
      lr_alv->get_display_settings( )->set_striped_pattern( if_salv_c_bool_sap=>true ).
      lr_alv->display( ).


    CATCH z_rb_cx_flight_exceptions INTO DATA(lr_ex).
      MESSAGE lr_ex->get_text( ) TYPE 'I'.

    CATCH cx_root INTO DATA(lr_ex_all).
      MESSAGE lr_ex_all->get_text( ) TYPE 'E'.

  ENDTRY.