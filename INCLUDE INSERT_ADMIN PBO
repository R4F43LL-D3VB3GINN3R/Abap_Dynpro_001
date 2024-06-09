*----------------------------------------------------------------------*
***INCLUDE Z_BEFORE_INSERT_ADMIN.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module BEFORE_INSERT_PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE before_insert_pbo OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.~

  DATA: in_nickname   TYPE zlogin, "Admin Login
        in_password   TYPE zpass,  "Admin Pass
        in_lvl_access TYPE zlvl.   "Admin lvl

  IF cl_admin IS INITIAL.    "Instace from Admin Class
    CREATE OBJECT cl_admin.  "Object from Admin Class
  ENDIF.

ENDMODULE.
