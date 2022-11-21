class Z_RB_CL_FLIGHT_API definition
  public
  final
  create public .

public section.

  types:
    tt_sflight TYPE STANDARD TABLE OF zrb_flights .

  class-methods SET_AIRLINE_LIST .
  class-methods GET_FLIGHTS
    importing
      !IV_DATE_FROM type S_DATE
      !IV_DATE_TO type S_DATE
      !IV_CARRID type S_CARR_ID
      !IV_PLNTYE type S_PLANETYE
      !IV_CLASS type Z_RB_FLIGHT_CLASS
      !IV_MINST type INT4
    exporting
      !ET_FLIGHTS type TT_SFLIGHT
    raising
      Z_RB_CX_FLIGHT_EXCEPTIONS .
  class-methods SET_PLANE_TYPE_LIST
    importing
      !IV_CARRID type S_CARR_ID .
  PROTECTED SECTION.
private section.

  class-data GT_SFLIGHT type TT_SFLIGHT .

  class-methods LOAD_TABLE .
ENDCLASS.



CLASS Z_RB_CL_FLIGHT_API IMPLEMENTATION.


  METHOD get_flights.
    IF iv_date_from > iv_date_to.
      RAISE EXCEPTION TYPE z_rb_cx_flight_exceptions
        EXPORTING
          textid = z_rb_cx_flight_exceptions=>wrong_date_interval.
    ENDIF.

    IF iv_plntye is INITIAL.
 RAISE EXCEPTION TYPE z_rb_cx_flight_exceptions
        EXPORTING
          textid = z_rb_cx_flight_exceptions=>planetype_required.
    ENDIF.

    IF iv_class is INITIAL.
       RAISE EXCEPTION TYPE z_rb_cx_flight_exceptions
        EXPORTING
          textid = z_rb_cx_flight_exceptions=>class_required.
    ENDIF.

    IF iv_minst < 0.
      RAISE EXCEPTION TYPE z_rb_cx_flight_exceptions
        EXPORTING
          textid = z_rb_cx_flight_exceptions=>wrong_seats_value.
    ENDIF.

    "verify if the local buffer is loaded
    IF gt_sflight IS INITIAL.
      z_rb_cl_flight_api=>load_table( ).
    ENDIF.

    LOOP AT gt_sflight INTO DATA(ls_flight)
      WHERE  fldate >= iv_date_from AND
          fldate <= iv_date_to AND
          carrid = iv_carrid AND
          planetype = iv_plntye.
      "local variables iv_* are not recognised inisde the loop where clause)
      IF ( iv_class = 'E' AND ls_flight-free_e >= iv_minst ) OR
       ( iv_class = 'F' AND  ls_flight-free_f >= iv_minst ) OR
       ( iv_class = 'B' AND ls_flight-free_b >= iv_minst ) OR
       ( iv_class = 'N' AND ls_flight-free_total >= iv_minst ).
        APPEND ls_flight TO et_flights.
      ENDIF.
    ENDLOOP.

    IF et_flights IS INITIAL.
      RAISE EXCEPTION TYPE z_rb_cx_flight_exceptions
        EXPORTING
          textid = z_rb_cx_flight_exceptions=>z_rb_cx_flight_exceptions.
    ENDIF.

*     IF iv_class = 'E'.
*    SELECT * FROM sflight
*      WHERE fldate >= @iv_flfrom AND
*        fldate <= @iv_flto AND
*        carrid = @iv_carrid AND
*        planetype = @iv_plntye AND
*        seatsmax - seatsocc >= @iv_minst
*       INTO TABLE @ET_FLIGHTS.
*  ELSEIF p_class = 'F'.
*    SELECT * FROM sflight
*       WHERE fldate >= @iv_flfrom AND
*        fldate <= @iv_flto AND
*        carrid = @iv_carrid AND
*        planetype = @iv_plntye AND
*        seatsmax_f - seatsocc_f >= @iv_minst
*      INTO TABLE @ET_FLIGHTS.
*  ELSEIF p_class = 'B'.
*    SELECT * FROM sflight
*      WHERE fldate >= @iv_flfrom AND
*        fldate <= @iv_flto AND
*        carrid = @iv_carrid AND
*        planetype = @iv_plntye AND
*        seatsmax_b - seatsocc_b >= @iv_minst
*      INTO TABLE @ET_FLIGHTS.
*  ELSEIF p_class = 'N'.
*    SELECT * FROM sflight
*     WHERE fldate >= @iv_flfrom AND
*         fldate <= @iv_flto AND
*         carrid = @iv_carrid AND
*         planetype = @iv_plntye AND
*         seatsmax + seatsmax_f + seatsmax_b - seatsocc - seatsocc_b - seatsocc_f >= @iv_minst
*     INTO TABLE @ET_FLIGHTS.
*  ENDIF.

  ENDMETHOD.


  METHOD load_table.
    "create the buffer
    DATA ls_flights TYPE zrb_flights.

    SELECT sflight~fldate, sflight~connid, sflight~carrid, scarr~carrname, sflight~planetype, spfli~cityfrom,
       spfli~cityto, spfli~deptime, spfli~arrtime, sflight~price, sflight~currency, sflight~seatsmax,
       sflight~seatsocc, sflight~seatsmax_b, sflight~seatsocc_b, sflight~seatsmax_f, sflight~seatsocc_f
  FROM sflight
  INNER JOIN scarr
    ON sflight~carrid = scarr~carrid
  INNER JOIN spfli
    ON sflight~carrid = spfli~carrid AND sflight~connid = spfli~connid
  ORDER BY sflight~fldate, sflight~carrid
      INTO TABLE @DATA(lt_db_flights).

    CLEAR gt_sflight.
    LOOP AT lt_db_flights INTO DATA(ls_db_flight).
      READ TABLE gt_sflight WITH KEY fldate = ls_db_flight-fldate connid = ls_db_flight-connid carrid = ls_db_flight-carrid TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CLEAR ls_flights.
        MOVE-CORRESPONDING ls_db_flight TO ls_flights.
        ls_flights-free_f = ls_db_flight-seatsmax_f - ls_db_flight-seatsocc_f.
        ls_flights-free_b = ls_db_flight-seatsmax_b - ls_db_flight-seatsocc_b.
        ls_flights-free_e = ls_db_flight-seatsmax - ls_db_flight-seatsocc.
        ls_flights-free_total = ls_flights-free_e + ls_flights-free_f + ls_flights-free_b.
        APPEND ls_flights TO gt_sflight.
      ENDIF.

    ENDLOOP.
    "SELECT * FROM sflight INTO TABLE @gt_sflight.
  ENDMETHOD.


  METHOD set_airline_list.
    DATA ls_airline TYPE vrm_value.
    DATA lt_airline_list TYPE vrm_values.

    "verify if the buffer is loaded
    IF gt_sflight IS INITIAL.
      z_rb_cl_flight_api=>load_table( ).
    ENDIF.

    LOOP AT gt_sflight INTO DATA(ls_flight).

      READ TABLE lt_airline_list WITH KEY key = ls_flight-carrid TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CLEAR ls_airline. "initialize the structure
        ls_airline-key = ls_flight-carrid.
        ls_airline-text = ls_flight-carrname.
        APPEND ls_airline TO lt_airline_list.
      ENDIF.

    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES' "it creates the connection between table and parameter
      EXPORTING
        id              = 'p_carrid'
        values          = lt_airline_list
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
  ENDMETHOD.


  METHOD set_plane_type_list.
    DATA ls_plane_type TYPE vrm_value.
    DATA lt_plane_type_list TYPE vrm_values.

    "verify if the buffer is loaded
    IF gt_sflight IS INITIAL.
      z_rb_cl_flight_api=>load_table( ).
    ENDIF.

    "SELECT planetype FROM sflight WHERE carrid = @iv_carrid INTO TABLE @DATA(lt_db_plane_types). "initially read from saplane table
    LOOP AT gt_sflight INTO DATA(ls_plane_types) WHERE carrid = iv_carrid.

      READ TABLE lt_plane_type_list WITH KEY key = ls_plane_types-planetype TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CLEAR ls_plane_type. "initialize the structure
        ls_plane_type-key = ls_plane_types-planetype.
        ls_plane_type-text = ls_plane_types-planetype.
        APPEND ls_plane_type TO lt_plane_type_list.
      ENDIF.

    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES' "it creates the connection between table and parameter
      EXPORTING
        id              = 'p_plntye'
        values          = lt_plane_type_list
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.
  ENDMETHOD.
ENDCLASS.