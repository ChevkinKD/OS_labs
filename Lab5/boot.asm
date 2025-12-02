org 0x7C00

boot:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    mov ax, 3
    int 0x10


    mov ah, 6
    xor al, al
    mov bh, 0x12      
    mov cx, 0
    mov dx, 0x184F
    int 0x10

   
    mov si, logo_line1
    call print
    call newline
    
    mov si, logo_line2
    call print
    call newline
    
    mov si, logo_line3
    call print
    call newline
    
    mov si, msg_welcome
    call print
    call newline
    
    mov si, msg_ask_name
    call print
    mov di, name_buf
    call read
    
    mov si, msg_hello
    call print
    mov si, name_buf
    call print
    call newline
    
game_start:
    mov si, msg_game_rules
    call print
    call newline
    
    mov ah, 0
    int 0x1A
    and dx, 0x000F
    inc dx
    cmp dx, 10
    jbe .ok
    sub dx, 6
.ok:
    mov [secret], dl
    
    mov byte [attempts], 0

guess_loop:
    inc byte [attempts]
    
    mov si, msg_guess
    call print

    mov ah, 0
    int 0x16

    mov ah, 0x0E
    mov bl, 0x0C      
    int 0x10
    call newline

    sub al, '0'
    mov bl, al

    mov al, [secret]
    cmp bl, al
    je guessed_right
    jl guess_too_low
    jg guess_too_high

guess_too_low:
    mov si, msg_too_low
    call print
    call newline
    jmp guess_loop

guess_too_high:
    mov si, msg_too_high
    call print
    call newline
    jmp guess_loop

guessed_right:
    mov si, msg_correct
    call print

    mov al, [attempts]
    add al, '0'
    mov ah, 0x0E
    mov bl, 0x0C      
    int 0x10
    
    mov si, msg_attempts
    call print
    call newline

    mov si, msg_play_again
    call print
    
    mov ah, 0
    int 0x16

    mov ah, 0x0E
    int 0x10
    call newline
    
    cmp al, 'y'
    je game_start
    cmp al, 'Y'
    je game_start

    call newline
    mov si, msg_goodbye
    call print
    mov si, name_buf
    call print
    mov si, msg_exit
    call print

    cli
    hlt
    jmp $

; ========== ФУНКЦИИ ==========

print:
    pusha
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0C     
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

newline:
    pusha
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    popa
    ret

read:
    mov cx, 0
.loop:
    mov ah, 0
    int 0x16
    cmp al, 13
    je .done
    cmp al, 8
    je .backspace
    cmp cx, 10
    jge .loop
    mov ah, 0x0E
    mov bl, 0x0C      
    int 0x10
    stosb
    inc cx
    jmp .loop
.backspace:
    cmp cx, 0
    je .loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.done:
    mov al, 0
    stosb
    call newline
    ret

; ========== ДАННЫЕ ==========

logo_line1: db ' _      _   __ ', 0
logo_line2: db '/  |_| / \ /_ ', 0
logo_line3: db '\_ | | \_/ __/', 0

msg_welcome:      db 'Guess Number Game', 0
msg_ask_name:     db 'Name: ', 0
msg_hello:        db 'Hello ', 0
msg_game_rules:   db 'Guess 1-10', 0  
msg_guess:        db 'Try: ', 0
msg_too_low:      db 'Low', 0
msg_too_high:     db 'High', 0
msg_correct:      db 'Win! Tries: ', 0
msg_attempts:     db '', 0
msg_play_again:   db 'Again? y/n: ', 0
msg_goodbye:      db 'Bye ', 0
msg_exit:         db '!', 0

name_buf:   times 11 db 0
secret:     db 0
attempts:   db 0

times 510-($-$$) db 0
dw 0xAA55