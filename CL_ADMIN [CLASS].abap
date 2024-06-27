*----------------------------------------------------------------------*
***INCLUDE Z_CL_USER.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class CL_USER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS cx_application_error DEFINITION "Defines the new exception class
  INHERITING FROM cx_static_check. "It inherits the static verification of exceptions
  PUBLIC SECTION.
    DATA: error_message TYPE string. "Variable to receive the message
    "Contructor method accepts a string parameter
    METHODS: constructor IMPORTING !error_message TYPE string.
ENDCLASS.

CLASS cx_application_error IMPLEMENTATION.
  METHOD constructor. "The method calls a string message
    super->constructor( ).
    me->error_message = error_message.
  ENDMETHOD.
ENDCLASS.

CLASS cl_user DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS:

    "----------------------------------------------

      "Method to hash login and password
      hash_logon
        IMPORTING
          login_adm TYPE zlogin    "Login to screen 0001
          pass_adm  TYPE zpass     "Pass to screen 0001
        EXPORTING
          hashed_login TYPE zlogin "Login hashed to screen 0001
          hashed_pass TYPE  zpass  "Pass hashed to screen 0001
        RAISING
          cx_abap_message_digest
          cx_application_error,

     "----------------------------------------------

      "Method to validate login access
      access_admin
        IMPORTING
          login_adm TYPE zlogin  "Login hashed to screen 0001
          pass_adm  TYPE zpass   "Pass hashed to screen 0001
        EXPORTING
          lvl       TYPE zlvl    "Exports the lvl access from the employee
        RAISING
          cx_application_error,  "Add the custom exception here

     "----------------------------------------------

       "Method to generate a random user key
       generate_key
        EXPORTING
          lv_newkey TYPE zkey_admin "Export the random key
        RAISING
           cx_application_error,  "Add the custom exception here

     "----------------------------------------------

       "Method to register a new admin
       insert_admin
        EXPORTING
          login_adm TYPE zlogin "Login hashed to screen 0021
          pass_adm TYPE zpass   "Pass hashed to screen 0021
          lvl TYPE zlvl         "Level Access hashes to screen 0021
       RAISING
          cx_application_error.  " Add the custom exception here

      "----------------------------------------------

  PRIVATE SECTION.

    TYPES: BEGIN OF wa_admin,       "Work Area to admin database
        key        TYPE zkey_admin, "Id Employee
        login      TYPE zlogin,     "Nickname Employee
        pass       TYPE zpass,      "Password Employee
        start_date TYPE begda,      "Hiring Date
        end_date   TYPE endda,      "Dismissal Date
        lvl_access TYPE zlvl,       "Level Access
    END OF wa_admin.

    DATA: lt_admin TYPE TABLE OF zraadmin, "Internal Table Admin
          ls_admin LIKE LINE OF lt_admin.  "Structure Line

    DATA: lvl TYPE zlvl. "Variable to receive the Level Access

ENDCLASS.

CLASS cl_user IMPLEMENTATION.

  METHOD hash_logon. "Method to hash login and password

    "Imports: login_adm, pass_adm
    "Exports: hashed_login, hashed_pass

    DATA: result1 TYPE string, "Result from hashed login
          result2 TYPE string. "Result from hashed pass

    DATA: login_str TYPE string, "Receives a char and turn to string
          pass_str  TYPE string. "Receives a char and turn to string

    login_str = login_adm. "Login Char -> ToString
    pass_str  = pass_adm.  "Pass Char -> ToString

    "----------------------------------------------------------

    "Method to hash the login
    TRY.
    cl_abap_message_digest=>calculate_hash_for_char(
      EXPORTING
        if_algorithm = 'SHA512'
        if_data      = login_str "Send the string login
      IMPORTING
        ef_hashstring = result1  "Receive the login hashed
    ).
    "Method to hash the password
    cl_abap_message_digest=>calculate_hash_for_char(
      EXPORTING
        if_algorithm = 'SHA512'
        if_data      = pass_str "Send the string pass
      IMPORTING
        ef_hashstring = result2 "Receive the pass hashed
    ).
    CATCH cx_abap_message_digest INTO DATA(lx_message_digest).
      RAISE EXCEPTION TYPE cx_application_error
        EXPORTING
          error_message = 'Encrypt Error Data.'.
    ENDTRY.

    "----------------------------------------------------------

    hashed_login = result1. "Export it: Login String ->ToChar
    hashed_pass  = result2. "Export it: Login Pass ->ToChar

  ENDMETHOD.

  METHOD access_admin. "Method to validade login access"

    "Imports: login_adm, pass_adm
    "Exports: lvl

    "Variables to receive the hashed Login from method above.
    DATA: new_login TYPE zlogin,
          new_pass TYPE zpass.
    TRY.
      me->hash_logon( "Call the self-method to hash login and pass
        EXPORTING
          login_adm  = login_adm "Send the login char
          pass_adm   = pass_adm  "Send the pass char
        IMPORTING
          hashed_login = new_login "Login Hashed
          hashed_pass  = new_pass  "Pass Hashed
      ).
    CATCH cx_abap_message_digest INTO DATA(lx_message_digest).
      " Handle the exception (e.g., log the error, set default values, etc.)
      RETURN. " Exit the method if hashing fails
    ENDTRY.

    SELECT SINGLE *           "Select a single line
      FROM zraadmin           "From the admin table
      INTO ls_admin           "Into structure line
      WHERE login = new_login "where the login hashed and the pass hashed...
      AND pass = new_pass.    "are in the table

      IF sy-subrc = 0.             "if the login and pass are found...
        lvl = ls_admin-lvl_access. "variable receives the data
      ENDIF.

ENDMETHOD.

METHOD generate_key. "Method to generate a random user key

  "Export lv_newkey"

      DATA: lv_uid TYPE string. "String to receive the random string

      CALL FUNCTION 'GENERAL_GET_RANDOM_STRING' "System function to generate a random string
       EXPORTING
         number_chars        = 8       "Number of characters
       IMPORTING
         random_string       = lv_uid. "String takes random string
      
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_application_error
          EXPORTING
            error_message = 'Error generating key string'.
      ENDIF.

      DATA: lv_random_number TYPE i. "Integer to receive the random number

      CALL FUNCTION 'QF05_RANDOM_INTEGER'
       EXPORTING
         ran_int_max         = 999             "Max Range Number
         ran_int_min         = 1               "Min Range Number
       IMPORTING
         ran_int             = lv_random_number "Integer takes the random number
       EXCEPTIONS
         invalid_input       = 1
         OTHERS              = 2.
      
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE cx_application_error
          EXPORTING
            error_message = 'Error generating key number'.
      ENDIF.

      DATA: lv_randomchar TYPE string.  "String to receive the value returned by the function
      lv_randomchar = lv_random_number. "String takes the number Int->ToChar

      CONCATENATE lv_randomchar lv_uid INTO lv_newkey. "Number and String concatenateds

ENDMETHOD.

METHOD insert_admin. "Method to register a new admin

  "Exporting login_adm, pass_adm, lvl.

  DATA: key_access TYPE zkey_admin.  "Lvl Access to receive the value of the returned function.

  me->generate_key(
    IMPORTING
      lv_newkey = key_access ). "Random number/string concatenateds returned

  "Variables to receive the hashed Login from method above.
    DATA: new_login TYPE zlogin,
          new_pass TYPE zpass.
    TRY.
      me->hash_logon( "Call the self-method to hash login and pass
        EXPORTING
          login_adm  = login_adm "Send the login char
          pass_adm   = pass_adm  "Send the pass char
        IMPORTING
          hashed_login = new_login "Login Hashed
          hashed_pass  = new_pass  "Pass Hashed
      ).
    CATCH cx_abap_message_digest INTO DATA(lx_message_digest).
      " Handle the exception (e.g., log the error, set default values, etc.)
      RETURN. " Exit the method if hashing fails
    ENDTRY.

    DATA: in_datenow TYPE erdat,  "Hiring Date
          in_end_date TYPE endda. "Dismissal Date

    in_datenow = sy-datum.    "Hiring Date takes the datenow
    in_end_date = '00000000'. "Dismissal Date receives the custom value.

    "Fill the Structure
    ls_admin-key_adm    = key_access.  "Random Key
    ls_admin-login      = new_login.   "Hashed Login
    ls_admin-pass       = new_pass.    "Hashed Password
    ls_admin-start_date = in_datenow.  "Datenow
    ls_admin-end_date   = in_end_date. "Default Date
    ls_admin-lvl_access = lvl.         "Lvl Access

    APPEND ls_admin TO lt_admin. "Append Structure to Internal Table

    MODIFY zraadmin FROM TABLE lt_admin. "Modify the Transparent Table from Internal Table.

    "Clear the fields
    CLEAR login_adm.
    CLEAR pass_adm.
    CLEAR lvl.

ENDMETHOD.

ENDCLASS.
