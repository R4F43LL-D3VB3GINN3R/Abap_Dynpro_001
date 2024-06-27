*----------------------------------------------------------------------*
***INCLUDE Z_HCM_TEST8_ACCESS_SCREEN_PO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module ACCESS_SCREEN_PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE access_screen_pbo OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  DATA: in_login TYPE zlogin, "Element Login
        in_pass TYPE zpass.   "Element Pass

  DATA: cl_admin TYPE REF TO cl_user. "Instance from Admin Class

  IF cl_admin IS INITIAL.
    CREATE OBJECT cl_admin.  "Object from Admin Class
  ENDIF.

  DATA: lv_lvl TYPE zlvl.    "Variable to receives the Level Access

  DATA: attempts TYPE i,     "Error Attempts of the user"
        attempts_num TYPE i. "Error Limit Attempts"

ENDMODULE.
