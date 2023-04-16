;-------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||| |||TROLLOPRINT|||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;======================================MAIN_FUNCTION==============================================
;-------------------------------------------------------------------------------------------------
;   Printtrl (stdcall) - it can call from C-program            
;-------------------------------------------------------------------------------------------------
;   Needs:                  format line in rdi, args (stack format)
;                                               rdi, rsi, rcx r8, r9 + stack using
;                                                1    2    3   4   5      6...   
; 
;   Return:                 none
;   Destroy list:           rax, rbx, rcx, rdx, rdi, rsi, r8, r9
;-------------------------------------------------------------------------------------------------

section .text
global _printtrl_slow
_printtrl_slow:  pop r12					            ; save return address

            ;PROLOGUE

            ;Push first 6 funct arguments into stack (other already in it!)
            push r9								
            push r8					
            push rcx
            push rdx
            push rsi 																					
            push rdi 																					
            push rbp								 	
            mov rbp, rsp  

            mov rdi, [rbp + 8]                  ; get ptr to format line
            mov	rsi, rbp                                   
            add rsi, 16                         ; get ptr to first arg                 

.next_sym:  mov ah, byte [rdi]
            cmp ah, 0                           ; check end of line
            je .finish                          ; end of print

            cmp ah, '%'                         ; check out %
            jne .sym

            inc rdi                             ; move to next sym in format line
            push rsi                            ; push args
            push rdi
            call _handle_percent                ; Handle percent
            add rsp, 16                         ; clear stk
            jmp .skip                           

.sym:       push rsi                            ; save regs value
            push rdi

            mov rsi, rdi                        ; get ptr to str
            mov rdx, 1                          ; get line len 
            mov rax, 1                          ; syswrite
            mov rdi, 1                          ; stdout
            syscall

            pop rdi                             ; load saved regs
            pop rsi

.skip       inc rdi
            jmp .next_sym                       ; mov until the end of line

            ;EPILOGUE
.finish:    mov rsp, rbp                        ; skip local data
            pop rbp
            add rsp, 48                         ; clear stack from args

            push r12
            ret

;=================================================================================================
;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Handle percent 
;-------------------------------------------------------------------------------------------------
;   Needs:                  curr ptr to format line, ptr to args
;   Return:                 none
;   Destroy list:           rax, rbx, rcx, rdx
;-------------------------------------------------------------------------------------------------

_handle_percent:  
            push rbp                             ; PROLOGUE 
            mov rbp, rsp                         ;

            mov rdi, [rbp + 16]                  ; get ptr curr pos into format line
            mov	rsi, [rbp + 24]                  ; get ptr to args

            xor rax, rax
            mov al, byte [rdi]                   ; get curr format

            ;SUPER PUPER JUMP TABLE
            
            cmp al, 'x'
            ja .home
            
            sub al, 'b'
            jmp [jmp_table + rax*8]             ; inderect transit

.home:      mov rsp, rbp                        ; skip local data          
            pop rbp                             ; PROLOGUE 
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Print unsint 
;-------------------------------------------------------------------------------------------------
;   Needs:                  your number in stack
;   Return:                 none
;   Destroy list:           rax, rcx, rdx, r8, r9
;-------------------------------------------------------------------------------------------------
 
_printunsint:  
            push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;

            sub rsp, 15                         ; reserve 15 bytes in stack

            mov rax, [rbp+16]                   ; get num
            mov ecx, 10                         ; base (10-sys-count)
            xor rdx, rdx

            xor r9, r9                          ; num len
            mov r8, rbp                         ; curr pos in array
            dec r8

; translate num to line

.next_num:  div ecx
            add rdx, '0'                        ; save num
            mov byte [r8], dl
            dec r8                              ; mov to next number in our array
            inc r9
            xor rdx, rdx  
            cmp rax, 0
            ja .next_num                        ; repeat until nullify

            inc r8
            mov rcx, r9

            mov rsi, r8                         ; get ptr to text
            mov rdx, r9                         ; get line len 
            mov rax, 1                          ; out text
            mov rdi, 1       
            syscall 

            mov rsp, rbp                        ; PROLOGUE  
            pop rbp                            
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Print int 
;-------------------------------------------------------------------------------------------------
;   Needs:                  your number in stack
;   Return:                 none
;   Destroy list:           rax, rcx, rdx, r8, r9
;-------------------------------------------------------------------------------------------------
 
_printint:  
            push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;

            mov rax, [rbp+16]                   ; get num
            cmp rax, 0                          ; find out sign
            jge .to_unsint
            
            dec rax                             ; rax = |rax|
            not rax  

            push rbx                            ; save regs                         
            push rax

            mov bl, '-'
            movzx rbx, bl                       ; print -
            push rbx

            mov rsi, rsp                        ; get ptr to text
            mov rdx, 1                          ; get line len 
            mov rax, 1                          ; out text
            mov rdi, 1       
            syscall

            add rsp, 8
            pop rax                             ; load saved regs
            pop rbx                             

.to_unsint: push rax
            call _printunsint                   ; print unsigned
            add rax, 8

            mov rsp, rbp                        ; PROLOGUE  
            pop rbp                            
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Print hex
;-------------------------------------------------------------------------------------------------
;   Needs:                  your number in stack
;   Return:                 none
;   Destroy list:           rax, rcx, rdx, r8, r9
;-------------------------------------------------------------------------------------------------
 
_printhex:  
            push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;

            sub rsp, 15                         ; reserve 15 bytes in stack

            mov rax, [rbp+16]                   ; get num
            xor rdx, rdx

            xor r9, r9                          ; num len
            mov r8, rbp                         ; curr pos in array
            dec r8

; translate num to line

.next_num:  mov rdx, rax
            and rdx, 15                         ; get base
            shr rax, 4

            cmp rdx, 10
            jae .sym_case

            add rdx, '0'                        ; num case
            jmp .skip

.sym_case:  sub rdx, 10
            add rdx, 'A'
                                    
.skip       mov byte [r8], dl                   ; transform to sym
            dec r8                              ; mov to next number in our array
            inc r9
            xor rdx, rdx  
            cmp rax, 0
            ja .next_num  

            inc r8
            mov rcx, r9

            mov rsi, r8                         ; get ptr to text
            mov rdx, r9                         ; get line len 
            mov rax, 1                          ; out text
            mov rdi, 1       
            syscall 

            mov rsp, rbp                        ; PROLOGUE  
            pop rbp                            
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Print bin  
;-------------------------------------------------------------------------------------------------
;   Needs:                  your number in stack
;   Return:                 none
;   Destroy list:           rax, rcx, rdx, r8, r9
;-------------------------------------------------------------------------------------------------
 
_printbin:  
            push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;

            sub rsp, 15                         ; reserve 15 bytes in stack

            mov rax, [rbp+16]                   ; get num
            xor rdx, rdx

            xor r9, r9                          ; num len
            mov r8, rbp                         ; curr pos in array
            dec r8

; translate num to line

.next_num:  mov rdx, rax
            and rdx, 1                          ; base
            shr rax, 1

            add rdx, '0'                        ; save num
            mov byte [r8], dl                   ; translate to sym
            dec r8                              ; mov to next number in our array
            inc r9
            xor rdx, rdx  
            cmp rax, 0
            ja .next_num  

            inc r8
            mov rcx, r9

            mov rsi, r8                         ; get ptr to text
            mov rdx, r9                         ; get line len 
            mov rax, 1                          ; out text
            mov rdi, 1       
            syscall 

            mov rsp, rbp                        ; PROLOGUE  
            pop rbp                            
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;                                     JUMP TARGETS
;-------------------------------------------------------------------------------------------------

section .text

bin_case:               push rsi                            ; save regs value
                        push rdi

                        xor eax, eax
                        mov rax, qword [rsi]                ; get curr num
                        push rax
                        call _printbin                      ; call print num
                        add rsp, 8                          ; clear stk

                        pop rdi                             ; load saved regs
                        pop rsi
                        add rsi, 8

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

char_case:              push rsi                            ; save regs value
                        push rdi

                        mov rdx, 1                          ; get line len 
                        mov rax, 1                          ; syswrite
                        mov rdi, 1                          ; stdout
                        syscall

                        pop rdi                             ; load saved regs
                        pop rsi
                        add rsi, 8

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

unsint_case:            push rsi                            ; save regs value
                        push rdi

                        mov rax, qword [rsi]                ; get curr num
                        push rax
                        call _printunsint                   ; call print num
                        add rsp, 8                          ; clear stk

                        pop rdi                             ; load saved regs
                        pop rsi
                        add rsi, 8

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

int_case:               push rsi                            ; save regs value
                        push rdi

                        mov rax, qword [rsi]                ; get curr num
                        movsx rax, eax

                        push rax
                        call _printint                      ; call print num
                        add rsp, 8                          ; clear stk

                        pop rdi                             ; load saved regs
                        pop rsi
                        add rsi, 8

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

str_case:               mov rax, [rsi]                      ; get ptr to line

.next_sym:              mov bh, byte [rax]
                        cmp bh, 0
                        je .end

                        push rsi                            ; save regs value
                        push rdi
                        push rax

                        mov rsi, rax
                        mov rdx, 1                          ; get line len 
                        mov rax, 1                          ; syswrite
                        mov rdi, 1                          ; stdout
                        syscall

                        pop rax
                        pop rdi                             ; load saved regs
                        pop rsi
                        inc rax

                        jmp .next_sym

.end                    add rsi, 8                          ; skip ptr

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

hex_case:               push rsi                            ; save regs value
                        push rdi

                        mov rax, qword [rsi]                ; get curr num
                        push rax
                        call _printhex                      ; call print num
                        add rsp, 8                          ; clear stk

                        pop rdi                             ; load saved regs
                        pop rsi
                        add rsi, 8

                        jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------

empty_case:             jmp _handle_percent.home

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;                                      JUMP TABLE
;-------------------------------------------------------------------------------------------------

section .data

jmp_table:
                        dq bin_case                         ;b
                        dq char_case                        ;c
                        dq int_case                         ;d
times ('o' - 'd' - 1)   dq empty_case
                        dq unsint_case                      ;o
times ('s' - 'o' - 1)   dq empty_case
                        dq str_case                         ;s
times ('x' - 's' - 1)   dq empty_case
                        dq hex_case                         ;x

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------