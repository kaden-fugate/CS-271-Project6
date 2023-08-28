TITLE Low Level I/O Procedures	(Proj6_fugateka.asm)

; Author: Kaden Fugate
; Last Modified: August 18th, 2023
; OSU email address: fugateka@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6        Due Date: August 18th, 2023
; Description: This program will take 10 numbers from a user. With each number,
; the program will convert it from ASCII to an actual number. This involves validation
; as well. After the numbers are collected, the program will print out the valid numbers
; entered, their sum, and their average.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mIntro
;
; Description: this macro will display all of the introduction prompts
;
; Preconditions: none
;
; Receives:
; prompt_1: first prompt to print
; prompt_2: second prompt to print
; prompt_3: third prompt to print
; prompt_4: fourth prompt to print
;
; returns: none
; ----------------------------------------------------------------------------------
mIntro MACRO prompt_1,  prompt_2,  prompt_3,  prompt_4

    push    edx

    mov     edx,    prompt_1
    call    WriteString
    call    CrLf

    mov     edx,    prompt_2
    call    WriteString
    call    CrLf
    call    CrLf

    mov     edx,    prompt_3
    call    WriteString
    call    CrLf

    mov     edx,    prompt_4
    call    WriteString
    call    CrLf
    call    CrLf

    pop     edx

ENDM

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Description: this macro will receieve a prompt to get a string and a location
; to store a string. Using these, it will get a num from the user.
;
; Preconditions: none
;
; Receives:
; prompt_ptr: ptr to prompt to print to get users num
; output_ptr: ptr to where to store the users num
;
; returns: number stored at specified address
; ----------------------------------------------------------------------------------
mGetString  MACRO  prompt_ptr,  output_ptr

    push    ecx
    push    edx

    ; Load prompt to get user num
    mov     edx,    prompt_ptr
    call    WriteString

    ; Prepare eax and ecx for ReadString
    mov     edx,    output_ptr
    mov     ecx,    MAX_LEN
    dec     ecx

    call    ReadString

    pop     edx
    pop     ecx

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description: This function will display a string stored at the given mem address
;
; Preconditions: string must be stored
;
; Receives:
; str_ptr: address of string to be printed
;
; returns: none.
; ----------------------------------------------------------------------------------
mDisplayString  MACRO  str_ptr

    push    edx

    ; Load mem address of str to edx
    mov     edx,    str_ptr
    call    WriteString

    pop     edx

ENDM

MAX_LEN     =   13
HI          =   2147483647
LOOP_COUNT  =   10 ; adjust to change amount of time program asks for user number

.data
    
    title_prmpt BYTE    "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
    programmer  BYTE    "Written by: Kaden Fugate", 0
    instruct_1  BYTE    "Please provide 10 signed decimal integers.", 0
    instruct_2  BYTE    "Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
    prompt      BYTE    "Please enter a signed integer: ", 0
    error_msg   BYTE    "Your number was invalid. Please try again.", 0
    error_msg_2 BYTE    "Your number was too large. Please try again.", 0
    farewell    BYTE    "Thanks for using (and grading) my program!", 0

    ; variables to print array of nums
    nums_prompt BYTE    "You entered the following numbers: ", 0
    sum_prompt  BYTE    "The sum of these numbers is: ", 0
    avg_prompt  BYTE    "The average of these numbers is: ", 0
    space       BYTE    " ", 0

    string      BYTE    MAX_LEN DUP(?)
    new_string  BYTE    MAX_LEN DUP(?)
    string_len  DWORD   0

    ; vars for converting string to int
    is_valid    DWORD   0
    sign_flag   DWORD   0
    num         SDWORD  0

    ; array variables
    num_arr     SDWORD  LOOP_COUNT  DUP(?)
    sum         SQWORD  ?
    avg         SDWORD  ?

.code

main PROC

    ; introduce the program to the user
    mIntro      OFFSET  title_prmpt,    OFFSET  programmer, OFFSET  instruct_1, OFFSET  instruct_2
    
    ; set loop length and jump past clear vars section of code for first iteration
    ; load first idx of num_arr into edi for first iter
    mov     ecx,    LOOP_COUNT
    mov     edi,    OFFSET  num_arr 
    cld
    jmp     __beginning

; ------------------------------------------------------------
; this section of code will reset all used variables
; ------------------------------------------------------------
    __clear_vars:

    ; clear original string array
    push    MAX_LEN
    push    OFFSET  string
    call    ClearArray

    ; reset all variables used
    mov     eax,    0
    mov     edx,    OFFSET  sum
    mov     string_len, eax
    mov     is_valid,   eax
    mov     sign_flag,  eax
    mov     num,        eax
    mov     [edx],      eax
    mov     [edx+4],    eax

; ------------------------------------------------------------
; read a user input and store its integer value in the num_arr
; if it is valid. After this it will clear all the variables
; if more nums are to be gotten.
; ------------------------------------------------------------
    __beginning:

    ; lotsa parameters for the ReadVal procedure
    push    OFFSET  error_msg_2
    push    OFFSET  string_len
    push    OFFSET  is_valid
    push    OFFSET  error_msg
    push    OFFSET  sign_flag
    push    OFFSET  num
    push    OFFSET  string
    push    OFFSET  prompt
    call    ReadVal

    ; if num invalid, reset loop without decrementing ecx
    mov     eax,    is_valid
    cmp     eax,    0
    je      __clear_vars

    ; push string len onto the stack
    push    string_len

    ; if number valid, add to array
    cmp     sign_flag,  eax
    jne     __not_neg

    ; if sign flag true, negate number
    mov     eax,    num
    neg     eax
    mov     num,    eax

    __not_neg:
    mov     eax,    num
    stosd

    ; check if loop is over
    ; cant use loop because __get_num_loop is > 128 bytes away
    dec     ecx
    cmp     ecx,    0
    jne     __clear_vars

    ; get sum of array after loop ends
    push    OFFSET  avg
    push    OFFSET  sum
    push    LOOP_COUNT
    push    OFFSET  num_arr
    call    ArrayStats

    ; move esi to point to end of array
    push    eax
    mov     esi,    OFFSET  num_arr
    mov     eax,    LOOP_COUNT
    dec     eax
    mov     ebx,    4
    mul     ebx
    add     esi,    eax
    pop     eax

    ; set direction flag, init array count in ecx
    
    mov     ecx,    LOOP_COUNT

    call    CrLf
    mov     edx,    OFFSET  nums_prompt
    call    WriteString
    call    CrLf

; ------------------------------------------------------------
; this section of code will print all of the valid user nums
; ------------------------------------------------------------
    __display_loop:
    std
    lodsd

    ; if num negative, set sign flag, negate num
    cmp     eax,    0
    jge     __positive

    mov     edx,    1
    neg     eax

    __positive:

    ; get len of num
    pop     ebx

    ; Write current value
    push    edx
    push    eax
    push    ebx
    push    OFFSET  new_string
    call    WriteVal

    mov     edx,    OFFSET  space
    call    WriteString

    ; clear new_string array
    push    MAX_LEN
    push    OFFSET  new_string
    call    ClearArray

    loop    __display_loop

; ------------------------------------------------------------
; this section of code will display the sum neatly
; ------------------------------------------------------------
    call    CrLf
    call    CrLf
    mov     edx,    OFFSET  sum_prompt
    call    WriteString

    mov     ebx,    OFFSET  sum

    mov     eax,    [ebx]
    cmp     eax,    0
    jge     __pos_sum
    
    call    WriteInt
    jmp     __avg

    __pos_sum:

    call    WriteDec

    __avg:

    call    CrLf

; ------------------------------------------------------------
; this section of code will display the avg neatly
; ------------------------------------------------------------
    mov     edx,    OFFSET  avg_prompt
    call    WriteString

    mov     eax,    avg
    cmp     eax,    0
    jge     __pos_avg

    call    WriteInt
    jmp     __farewell

    __pos_avg:

    call    WriteDec

; display farewell message and end program
    __farewell:
    call    CrLf
    call    CrLf
    mov     edx,    OFFSET  farewell
    call    WriteString

	exit

main ENDP

; ---------------------------------------------------------------------------------
; Name: validate
;
; Description: this function will validate whether or not the string contains invalid
; chars. It will also set the sign_flag if num is negative
;
; Preconditions: none.
;
; Postconditions: sign_flag will be set if negative, is_valid will be set if valid
;
; Receives: 
; ebp+28 = ptr to first idx of ascii string
; ebp+32 = ptr to sign_flag
; ebp+36 = ptr to invalid char err msg
; ebp+40 = ptr to is_valid
;
; returns: sign_flag and is_valid will be set accordingly
; ----------------------------------------------------------------------------------
validate  PROC  USES  eax  ebx  ecx  edx  esi

    push    ebp
    mov     ebp,    esp
    pushf

    ; prepare to validate string
    mov     ecx,    0
    mov     esi,    [ebp+28]
    cld

    ; check if first char is sign
    lodsb
    cmp     al,     45
    jne     __not_neg

    ; if first byte '-', switch sign to 1 and move to next char in str
    push    ecx

    mov     ebx,    1
    mov     ecx,    [ebp+32]
    mov     [ecx],  ebx
    lodsb

    pop     ecx

    jmp     __validate_loop

    __not_neg:

    ; if first char '+', increment to next char
    cmp     al,     43
    jne     __validate_loop
    lodsb

    __validate_loop:

    ; check if string is ended and length of num is greater than 0
    cmp     al,     0
    jne     __check_range

    cmp     ecx,    0
    je      __invalid_char
    jmp     __valid
    
    __check_range:
    ; check that current char is within range 0 - 9
    cmp     al,     48
    jl      __invalid_char

    cmp     al,     57
    jg      __invalid_char
        
    ; move to next char
    inc     ecx
    lodsb
    jmp     __validate_loop

    __invalid_char:

    ; Write Error message to screen
    mov     edx,    [ebp+36]
    call    WriteString
    call    CrLf

    jmp     __end

    __valid:

    ; mark number as valid
    mov     ebx,    1
    mov     edx,    [[ebp+40]]
    mov     [edx],  ebx

    __end:

    popf
    pop     ebp
    ret     16

validate  ENDP

; ---------------------------------------------------------------------------------
; Name: getSum
;
; Description: This procedure will get the sum of a ASCII array
;
; Preconditions: none
;
; Postconditions: Summed num will be stored in num
;
; Receives:
; ebp+28 = ptr to first idx of str version of num
; ebp+32 = ptr to where to store num
; ebp+36 = value of sign flag
; ebp+40 = ptr to string_len
; ebp+44 = ptr to num too long err msg
; ebp+48 = ptr to is_valid
;
; returns: ASCII char array summed into single num
; ----------------------------------------------------------------------------------
getSum  PROC  USES  eax  ebx  ecx  edx  esi

    push    ebp
    mov     ebp,    esp
    pushf

    ; Prepare str to be summed
    mov     esi,    [ebp+28]
    cld
    lodsb

    cmp     al,     0
    je      __end_sum

    ; determine if sign needs to be checked
    push    eax
    mov     eax,    [ebp+36]
    cmp     eax,    0
    pop     eax
    je      __checked_sign

    ; check if sign present
    cmp     al,     45
    je     __increment

    cmp     al,     43
    jne     __checked_sign

    __increment:

    lodsb

    __checked_sign:

    ; convert ASCII char to int
    sub     al,    48

    ; multiply prev sum by 10 (move to left by 1 digit) then store sum * 10 in ebx
    push    eax

    mov     ecx,    [ebp+32]
    mov     eax,    [ecx]
    mov     ebx,    10
    mul     ebx
    mov     ebx,    eax

    pop     eax

    ; extend al to 32 bits, add to cur sum
    add     ebx,    eax
    mov     [ecx],  ebx

    ; if sum > 2,147,483,647, num invalid
    cmp     ebx,    HI
    jg      __num_too_large
    jo      __num_too_large

    ; increment str len
    mov     ecx,    [ebp+40]
    mov     ebx,    [ecx]
    inc     ebx
    mov     [ecx],  ebx

    push    [ebp+48]
    push    [ebp+44]
    push    [ebp+40]
    push    0
    push    [ebp+32]
    push    esi
    call    getSum

    jmp     __end_sum

    __num_too_large:
    
    ; display error message
    mov     edx,    [ebp + 44]
    call    WriteString
    call    CrLf

    ; set is_valid to 0
    mov     edx,    [ebp + 48]
    mov     ebx,    0
    mov     [edx],  ebx

    __end_sum:

    popf
    pop     ebp

    ret     24

getSum  ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: This procedure will get a user value, validate that it has no symbols,
; validate that the size is correct, then it will return it as converted to int.
;
; Preconditions: none
;
; Postconditions: num will hold the valid number
;
; Receives: 
; ebp+20 = ptr to prompt to get num
; ebp+24 = ptr to string to store num
; ebp+28 = ptr to var to store int num
; ebp+32 = ptr to sign_flag
; ebp+36 = ptr to error_msg
; ebp+40 = ptr to is_valid
; ebp+44 = ptr to string_len
; ebp+48 = ptr to err_msg_2
;
; returns: converted num, sign_flag, is_valid, string_len
; ----------------------------------------------------------------------------------
ReadVal  PROC  USES  eax  ebx  ecx  
    
    push    ebp
    mov     ebp,    esp
    pushf

    mov     eax,    [ebp+20]
    mov     ebx,    [ebp+24]

    mGetString      eax,    ebx

    ; validate will validate num and store in string
    push    [ebp+40]
    push    [ebp+36]
    push    [ebp+32]
    push    ebx
    call    validate

    ; check if num was valid or not
    push    eax
    mov     eax,    [ebp+40]
    mov     ecx,    [eax]
    cmp     ecx,    0
    pop     eax
    je      __invalid_num  

    ; get sum of num if it was valid
    push    [ebp+40]
    push    [ebp+48]
    push    [ebp+44]
    push    1
    push    [ebp+28]
    push    ebx
    call    getSum

    __invalid_num:

    popf
    pop     ebp

    ret     32

ReadVal  ENDP

; ---------------------------------------------------------------------------------
; Name: Writeval
;
; Description: This procedure will write a value given as a number into a string.
; After the value is stored as ASCII in string, mDisplayString will be called to
; print it.
;
; Preconditions: none
;
; Postconditions: new_string will hold the string in ASCII
;
; Receives:
; ebp+28 = ptr to first idx of new_str
; ebp+32 = len of number to write
; ebp+36 = value to be written
; ebp+40 = sign_flag value
;
; returns: num as str stored in new_string
; ----------------------------------------------------------------------------------
WriteVal  PROC  USES  eax  ebx  ecx  edx  edi

    push    ebp
    mov     ebp,    esp
    pushf

    mov     ecx,    [ebp+32]
    mov     ebx,    [ebp+40]

    __shift_edi:

    ; move empty string into esi and move to where null char will be
    std
    mov     edi,    [ebp + 28]
    add     edi,    ecx

    ; if negative sign present, jump an extra char to fit it at the front
    cmp     ebx,    1
    jne     __set_null_char
    inc     edi

    __set_null_char:
    mov     al,     0
    stosb

    ; move num to convert to ASCII to eax and perseve sign flag (ebx)
    mov     eax,    [ebp+36]
    push    ebx

    __division_loop:

    ; get ready for division
    mov     edx,    0
    mov     ebx,    10
    div     ebx

    ; convert digit to ASCII, move to string
    push    eax
    mov     eax,    edx
    add     eax,    48
    stosb
    pop     eax

    loop    __division_loop

    ; if negative sign present
    pop     ebx
    cmp     ebx,  1
    jne     __display

    ; then add '-' ASCII at first idx of 
    mov     al,     45
    stosb

    __display:

    mDisplayString  [ebp+28]

    popf
    pop     ebp

    ret     16

WriteVal  ENDP

; ---------------------------------------------------------------------------------
; Name: ClearArray
;
; Description: This will set an entire array to 0's
;
; Preconditions: none
;
; Postconditions: array will be empty
;
; Receives:
; ebp+20 = ptr to first idx of arr
; ebp+24 = array len
;
; returns: empty arr
; ----------------------------------------------------------------------------------
ClearArray  PROC  USES  eax  ecx  edi

    push    ebp
    mov     ebp,    esp
    pushf

    ; init variables, esi = array, ecx = array len
    mov     edi,    [ebp + 20]
    mov     ecx,    [ebp + 24]
    dec     ecx
    
    ; clear direction flag to move forward by 1 byte with stosb
    ; set eax as 0 to clear array
    cld
    mov     eax,    0

    __clear_loop:
    stosb      
    loop    __clear_loop

    popf
    pop     ebp
    ret     8

ClearArray  ENDP

; ---------------------------------------------------------------------------------
; Name: ArrayStats
;
; Description: This procedure will get the required stats of an array (sum and avg)
;
; Preconditions: Array must be filled
;
; Postconditions: sum and avg will contain their respective values
;
; Receives: 
; ebp+24 = ptr to first idx of arr
; ebp+28 = len of arr
; ebp+32 = ptr to sum
; ebp+36 = ptr to avg
;
; returns: sum in sum, avg in avg
; ----------------------------------------------------------------------------------
ArrayStats  PROC  USES  eax  ecx  edx  esi

    push    ebp
    mov     ebp,    esp
    pushf

    ; init vars, esi = array, ebx = sum, ecx = arr len
    mov     esi,    [ebp+24]
    mov     eax,    0
    mov     edx,    0
    mov     ecx,    [ebp+28]
    cld

    ; perserve ecx
    push    ecx
    __sum_loop:

    ; add element to sum then loop
    push    eax
    lodsd
    mov     ebx,    eax
    pop     eax
    add     eax,    ebx
    cdq

    loop    __sum_loop

    ; move sum into sum variable
    mov     ebx,    [ebp+32]
    mov     [ebx],  eax
    mov     edx,    0
    
    ; divide sum to find avg
    cdq
    pop     ecx
    idiv    ecx

    ; move avg to avg variable
    mov     ebx,    [ebp+36]
    mov     [ebx],  eax

    popf
    pop     ebp
    ret     16

ArrayStats  ENDP

END main