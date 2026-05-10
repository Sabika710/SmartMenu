; Hotel Management System - NASM COM format with order saving
; Compile: nasm project.asm -o project.com
; Run in DOSBox: project.com
; Orders saved to: orders.txt

org 100h

section .data

; Welcome Page
welcomeMsgTop    db 10,13,"                   ******************************************$"
welcomeMsg1      db 10,13,"                   **                 Welcome              **$"
welcomeMsg2      db 10,13,"                   **                    To                **$"
welcomeMsg3      db 10,13,"                   **               Order Now!!!           **$"
welcomeMsg4      db 10,13,"                   **                  System              **$"
welcomeMsgBottom db 10,13,"                   ******************************************$"

chooseOption1        db 10,13,"                    Schedule---$"
chooseOption2        db 10,13,"                    Enter Your Choice: $"
scheduleOptionPrompt db 10,13,"                          Enter 1 to Display Schedule: $"
peakItemPrompt       db 10,13,"                            Peak Your Item: $"
quantityPrompt       db 10,13,"                            Enter Quantity: $"
invalidInputMsg      db 10,13,"                        Invalid Input !! Rerun the Program$"
totalPriceMsg        db 10,13,"                            Total Price: $"
addotherItems        db 10,13,"                    Will you want to add items from other menus?$"
menuOption1          db 10,13,"                    1. Back to Schedule$"
menuOption2          db 10,13,"                    2. Exit$"
newline              db 10,13,"$"

scheduleList1   db 10,13,"                        1. Breakfast$"
scheduleList2   db 10,13,"                        2. Lunch$"
scheduleList3   db 10,13,"                        3. Dinner$"
scheduleList4   db 10,13,"                        4. Hi Tea$"

breakfastHeader db 10,13,"                      *** Breakfast List ***$"
breakfastItem1  db 10,13,"                    1. Half Fry         50/-$"
breakfastItem2  db 10,13,"                    2. Omelet           50/-$"
breakfastItem3  db 10,13,"                    3. Bread            50/-$"
breakfastItem4  db 10,13,"                    4. Pratha           50/-$"

lunchHeader     db 10,13,"                      *** Lunch List ***$"
lunchItem1      db 10,13,"                    1. Mixed Veg Soup   100/-$"
lunchItem2      db 10,13,"                    2. Veg Chow Mein    100/-$"
lunchItem3      db 10,13,"                    3. Egg Fried Rice   100/-$"
lunchItem4      db 10,13,"                    4. Spring Rolls     100/-$"

dinnerHeader    db 10,13,"                      *** Dinner List ***$"
dinnerItem1     db 10,13,"                    1. Veg Fried Rice   200/-$"
dinnerItem2     db 10,13,"                    2. Chkn Manchurian  200/-$"
dinnerItem3     db 10,13,"                    3. Sweet Sour Fish  200/-$"
dinnerItem4     db 10,13,"                    4. Sweet Sour Chkn  200/-$"

teaHeader       db 10,13,"                      *** High Tea List ***$"
teaItem1        db 10,13,"                    1. Savory Sandwiches 20/-$"
teaItem2        db 10,13,"                    2. Scones            20/-$"
teaItem3        db 10,13,"                    3. Pastries & Cakes  20/-$"
teaItem4        db 10,13,"                    4. Tea               20/-$"

byeMsg1         db 10,13,"                Thanks for using our service$"
byeMsg2         db 10,13,"                Enjoy your Meal!$"

; ---- File saving variables ----
filename    db "orders.txt", 0          ; output file name (null-terminated)
fileHandle  dw 0                        ; stores the file handle after open

; Order record written to file for each order:
; "Order: Menu=X Item=X Qty=X Total=XX0/-", 13, 10
orderRecord db "Order: Menu=", 0
menuChar    db "? ", 0
itemLabel   db "Item=", 0
itemChar    db "? ", 0
qtyLabel    db "Qty=", 0
qtyChar     db "? ", 0
totalLabel  db "Total=", 0
totalH      db "?", 0
totalL      db "?0/-", 13, 10, 0
recordEnd   db 0                        ; sentinel (not used, just padding)

; Temporary storage so CalcAndPrint can remember what was ordered
savedMenu   db 0    ; '1'=Breakfast '2'=Lunch '3'=Dinner '4'=Tea
savedItem   db 0    ; '1'-'4'
savedQty    db 0    ; digit character

section .text

start:
    ; Open (append) or create orders.txt
    mov ah, 3Dh         ; open existing file
    mov al, 1           ; write-only
    mov dx, filename
    int 21h
    jnc .fileOpened     ; if no carry, file opened ok
    ; File doesn't exist yet — create it
    mov ah, 3Ch
    mov cx, 0
    mov dx, filename
    int 21h
.fileOpened:
    mov [fileHandle], ax

    ; Seek to end so we append, not overwrite
    mov ah, 42h         ; lseek
    mov al, 2           ; from end of file
    mov bx, [fileHandle]
    xor cx, cx
    xor dx, dx
    int 21h

    ; Print welcome
    mov ah, 9
    mov dx, welcomeMsgTop
    int 21h
    mov dx, welcomeMsg1
    int 21h
    mov dx, welcomeMsg2
    int 21h
    mov dx, welcomeMsg3
    int 21h
    mov dx, welcomeMsg4
    int 21h
    mov dx, welcomeMsgBottom
    int 21h
    mov dx, newline
    int 21h

    mov dx, scheduleOptionPrompt
    int 21h
    mov ah, 1
    int 21h
    sub al, 48

    cmp al, 1
    jne .notSched
    jmp Schedule
.notSched:
    jmp Invalid

; -----------------------------------------------
Schedule:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, chooseOption1
    int 21h
    mov dx, scheduleList1
    int 21h
    mov dx, scheduleList2
    int 21h
    mov dx, scheduleList3
    int 21h
    mov dx, scheduleList4
    int 21h
    mov dx, chooseOption2
    int 21h

    mov ah, 1
    int 21h
    sub al, 48

    ; Save menu choice as ASCII char
    mov [savedMenu], al     ; store raw digit (1-4)

    cmp al, 1
    jne .chk2
    jmp Breakfast
.chk2:
    cmp al, 2
    jne .chk3
    jmp Lunch
.chk3:
    cmp al, 3
    jne .chk4
    jmp Dinner
.chk4:
    cmp al, 4
    jne .invalid
    jmp Tea
.invalid:
    jmp Invalid

; -----------------------------------------------
Breakfast:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, breakfastHeader
    int 21h
    mov dx, newline
    int 21h
    mov dx, breakfastItem1
    int 21h
    mov dx, breakfastItem2
    int 21h
    mov dx, breakfastItem3
    int 21h
    mov dx, breakfastItem4
    int 21h
    mov dx, peakItemPrompt
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov [savedItem], al

    cmp al, 1
    je .doFifty
    cmp al, 2
    je .doFifty
    cmp al, 3
    je .doFifty
    cmp al, 4
    je .doFifty
    jmp Invalid
.doFifty:
    mov bl, 5
    jmp CalcAndPrint

; -----------------------------------------------
Lunch:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, lunchHeader
    int 21h
    mov dx, newline
    int 21h
    mov dx, lunchItem1
    int 21h
    mov dx, lunchItem2
    int 21h
    mov dx, lunchItem3
    int 21h
    mov dx, lunchItem4
    int 21h
    mov dx, peakItemPrompt
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov [savedItem], al

    cmp al, 1
    je .doHundred
    cmp al, 2
    je .doHundred
    cmp al, 3
    je .doHundred
    cmp al, 4
    je .doHundred
    jmp Invalid
.doHundred:
    mov bl, 10
    jmp CalcAndPrint

; -----------------------------------------------
Dinner:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, dinnerHeader
    int 21h
    mov dx, newline
    int 21h
    mov dx, dinnerItem1
    int 21h
    mov dx, dinnerItem2
    int 21h
    mov dx, dinnerItem3
    int 21h
    mov dx, dinnerItem4
    int 21h
    mov dx, peakItemPrompt
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov [savedItem], al

    cmp al, 1
    je .doTwo
    cmp al, 2
    je .doTwo
    cmp al, 3
    je .doTwo
    cmp al, 4
    je .doTwo
    jmp Invalid
.doTwo:
    mov bl, 20
    jmp CalcAndPrint

; -----------------------------------------------
Tea:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, teaHeader
    int 21h
    mov dx, newline
    int 21h
    mov dx, teaItem1
    int 21h
    mov dx, teaItem2
    int 21h
    mov dx, teaItem3
    int 21h
    mov dx, teaItem4
    int 21h
    mov dx, peakItemPrompt
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov [savedItem], al

    cmp al, 1
    je .doTwenty
    cmp al, 2
    je .doTwenty
    cmp al, 3
    je .doTwenty
    cmp al, 4
    je .doTwenty
    jmp Invalid
.doTwenty:
    mov bl, 2
    jmp CalcAndPrint

; -----------------------------------------------
CalcAndPrint:
    push bx

    mov ah, 9
    mov dx, quantityPrompt
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov [savedQty], al      ; save quantity digit

    pop bx
    mul bl                  ; AX = qty * factor
    aam                     ; AH = tens, AL = units

    mov ch, ah
    mov cl, al
    add ch, 48
    add cl, 48

    ; Print total price to screen
    mov ah, 9
    mov dx, totalPriceMsg
    int 21h

    mov ah, 2
    mov dl, ch
    int 21h
    mov dl, cl
    int 21h
    mov dl, '0'
    int 21h
    mov dl, '/'
    int 21h
    mov dl, '-'
    int 21h

    ; ---- Save order to file ----
    ; Fill in the placeholders in orderRecord strings
    mov al, [savedMenu]
    add al, 48              ; convert back to ASCII digit
    mov [menuChar], al

    mov al, [savedItem]
    add al, 48
    mov [itemChar], al

    mov al, [savedQty]
    add al, 48
    mov [qtyChar], al

    mov [totalH], ch        ; ch/cl already have ASCII digits
    mov [totalL], cl
    ; patch totalL: it's "?0/-\r\n" — second byte is '0', already correct

    ; Write each part of the record using INT 21h AH=40h
    mov bx, [fileHandle]

    ; "Order: Menu="
    mov ah, 40h
    mov cx, 12
    mov dx, orderRecord
    int 21h

    ; menu digit + space
    mov ah, 40h
    mov cx, 2
    mov dx, menuChar
    int 21h

    ; "Item="
    mov ah, 40h
    mov cx, 5
    mov dx, itemLabel
    int 21h

    ; item digit + space
    mov ah, 40h
    mov cx, 2
    mov dx, itemChar
    int 21h

    ; "Qty="
    mov ah, 40h
    mov cx, 4
    mov dx, qtyLabel
    int 21h

    ; qty digit + space
    mov ah, 40h
    mov cx, 2
    mov dx, qtyChar
    int 21h

    ; "Total="
    mov ah, 40h
    mov cx, 6
    mov dx, totalLabel
    int 21h

    ; totalH digit (tens of price)
    mov ah, 40h
    mov cx, 1
    mov dx, totalH
    int 21h

    ; totalL digit + "0/-\r\n"  (5 bytes: digit, '0', '/', '-', CR, LF)
    mov ah, 40h
    mov cx, 6
    mov dx, totalL
    int 21h
    ; ---- End file save ----

    ; Ask continue or exit
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, addotherItems
    int 21h
    mov dx, menuOption1
    int 21h
    mov dx, menuOption2
    int 21h
    mov dx, chooseOption2
    int 21h

    mov ah, 1
    int 21h
    sub al, 48

    cmp al, 1
    jne .chkExit
    jmp Schedule
.chkExit:
    cmp al, 2
    jne .fallInvalid
    jmp Exit
.fallInvalid:
    jmp Invalid

; -----------------------------------------------
Invalid:
    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, invalidInputMsg
    int 21h

Exit:
    ; Close the file
    mov ah, 3Eh
    mov bx, [fileHandle]
    int 21h

    mov ah, 9
    mov dx, newline
    int 21h
    mov dx, byeMsg1
    int 21h
    mov dx, byeMsg2
    int 21h
    mov dx, newline
    int 21h

    mov ah, 4ch
    int 21h
