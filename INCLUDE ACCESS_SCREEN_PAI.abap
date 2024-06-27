*----------------------------------------------------------------------*
***INCLUDE Z_HCM_TEST8_ACCESS_SCREEN_PI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ACCESS_SCREEN_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE access_screen_pai INPUT.

   attempts_num = 3. "Setting the number of attempts

  "Strings are lower case in the Database
    TRANSLATE in_login TO LOWER CASE.
    TRANSLATE in_pass  TO LOWER CASE.

  CASE okcode0001.    "Case button is pressed...
    WHEN 'FCT_LOGIN'. "When the button login is pressed...

      cl_admin->access_admin(    "Call access method admin
          EXPORTING
            login_adm = in_login "Send the login writen
            pass_adm = in_pass   "Send the pass writen
          IMPORTING
            lvl = lv_lvl ).      "Receive the lvl access

      IF lv_lvl = 'S'.              "If the access is Super User...
        CALL SCREEN '0002'.         "Call Admin Menu
      ELSEIF lv_lvl = 'A' or lv_lvl = 'B' or lv_lvl = 'C'. "If the access is any other...
        CALL SCREEN '0003'.         "Call Main Menu
      ELSE.                         "If the access not exists...
        attempts = attempts + 1.    "Increment the attempts number
        IF attempts = attempts_num. "If the attempts number is = error attempts
           LEAVE PROGRAM.           "Close Program
        ENDIF.
        "Display Message showing the number of the attempts.
        MESSAGE |'Errors: { attempts_num }/' { attempts } | TYPE 'S' DISPLAY LIKE 'I'.
      ENDIF.
    WHEN'FCT_EXIT1'.  "When the button exit is pressed...
       LEAVE PROGRAM. "Close Program
    ENDCASE.
ENDMODULE.
