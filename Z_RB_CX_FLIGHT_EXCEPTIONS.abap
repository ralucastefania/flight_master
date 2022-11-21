class Z_RB_CX_FLIGHT_EXCEPTIONS definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  constants:
    begin of Z_RB_CX_FLIGHT_EXCEPTIONS,
      msgid type symsgid value 'Z_RB_FLIGHT_MESSAGES',
      msgno type symsgno value '002',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of Z_RB_CX_FLIGHT_EXCEPTIONS .
  constants:
    begin of WRONG_SEATS_VALUE,
      msgid type symsgid value 'Z_RB_FLIGHT_MESSAGES',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WRONG_SEATS_VALUE .
  constants:
    begin of WRONG_DATE_INTERVAL,
      msgid type symsgid value 'Z_RB_FLIGHT_MESSAGES',
      msgno type symsgno value '001',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WRONG_DATE_INTERVAL .
  constants:
    begin of PLANETYPE_REQUIRED,
      msgid type symsgid value 'Z_RB_FLIGHT_MESSAGES',
      msgno type symsgno value '003',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PLANETYPE_REQUIRED .
  constants:
    begin of CLASS_REQUIRED,
      msgid type symsgid value 'Z_RB_FLIGHT_MESSAGES',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CLASS_REQUIRED .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS Z_RB_CX_FLIGHT_EXCEPTIONS IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = Z_RB_CX_FLIGHT_EXCEPTIONS .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.