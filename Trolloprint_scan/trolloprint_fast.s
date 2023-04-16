;-------------------------------------------------------------------------------------------------
;||||||||||||||||||||||||||||||||||| |||TROLLOPRINT|||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;======================================MAIN_FUNCTION==============================================
;-------------------------------------------------------------------------------------------------
;   Printtrl (stdcall) - it can call from C-program            
;-------------------------------------------------------------------------------------------------
;   Needs:                  format line in rdi, args (stack format)
;                                               rdi, rsi, rcx, rdx, r8, r9 + stack using
;                                                1    2    3    4    5   6...   
; 
;   Return:                 none
;   Destroy list:           rax, rbx, rcx, rdx, rdi, rsi, r8, r9
;-------------------------------------------------------------------------------------------------

section .text
global _printtrl_fast 
_printtrl_fast:  pop r12					            ; save return address

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
            mov	rsi, rbp                        ;                
            add rsi, 16                         ; get ptr to first arg   

            mov r11, print_buffer               ; curr pos in buf     

;_________________________________HANDLE FORMAT LINE______________________________________________

.next_sym:  mov ah, byte [rdi]
            cmp ah, 0                           ; check end of line
            je .finish                          ; end of print

            cmp ah, '%'                         ; check out %
            jne .sym

            inc rdi                             ; move to next sym in format line
            push r11                            ; save reg
            push rsi                            ; push args
            push rdi                            ;
            call handle_percent                 ; handle percent
            pop rdi                             ;
            pop rsi                             ;
            pop r11                             ; load saved reg
            add rsi, 8                          ; mov to next arg
            jmp .skip                           

.sym:       mov bl, ah                          ; copy into print-buffer
            mov byte [r11], bl                  ;

            mov rax, 1                          ; sym offset
            add rax, r11                        ;

.skip       mov r11, rax                        ; add handle_percent offset
            inc rdi   
;_________________________________________________________________________________________________
;
;   SOME USEFULL INFORMATION ABOUT THAT:
;
;   If the curr size of buffer is bigger than (capacity - 20), use syscall    
;_________________________________________________________________________________________________

            mov rax, 20                          
            add rax, r11
            cmp rax, buffer_end
            jb .skip_print

            call printing                       ; print it (now using syscall, not buffer)

.skip_print:

            jmp .next_sym                       ; mov until the end of line
;_________________________________________________________________________________________________

            ;EPILOGUE
.finish:    cmp r11, 0
            jbe .end_prnt

            call printing                       ; print it (now using syscall, not buffer)

.end_prnt:  mov rsp, rbp                        ; skip local data
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
;   Return:                 curr pos in buffer (rax)
;   Destroy list:           rax, rbx, rcx, rdx
;-------------------------------------------------------------------------------------------------

handle_percent:  
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
            pop rbp                             ; EPILOGUE 
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Printing
;-------------------------------------------------------------------------------------------------
;   Needs:                  none
;   Return:                 none
;   Destroy list:           rax, rbx, rcx, rdx, r11
;-------------------------------------------------------------------------------------------------

printing:   push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;

            mov rcx, r11
            sub rcx, print_buffer

            push rsi                            ; save regs value
            push rdi

            mov rsi, print_buffer               ; get ptr to text
            mov rdx, rcx                        ; get line len 
            mov rax, 1                          ; out text
            mov rdi, 1       
            syscall

            pop rdi                             ; load saved regs
            pop rsi

            mov r11, print_buffer

            mov rsp, rbp                        ; skip local data          
            pop rbp                             ; EPILOGUE 
            ret

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;   Printnum (in any base) 
;-------------------------------------------------------------------------------------------------
;   Needs:                  your number in rdi, base in rsi
;   Return:                 none
;   Destroy list:           rax, rcx, rdx, r8, r9
;-------------------------------------------------------------------------------------------------

printnum:   push rbp                            ; PROLOGUE 
            mov rbp, rsp                        ;
        
            ; GET ARGS
            mov rax, rdi                        ; get num
            mov rcx, rsi                        ; base (10-sys-count)

            xor rdx, rdx                        ; curr remainder (in standard num sys translation) 
            xor r9, r9                          ; num len

            mov r8, rbp                         ; curr pos in array
            sub r8, 9                           ; skip saved rbp and saved r11

            mov r10, rsi                        ; check out effective base
            dec r10                             ;
            and r10, rsi                        ;
            cmp r10, 0                          ;
            jne .std_case                       ; std case (without shr)
;_________________________________________________________________________________________________

            xor r11, r11                        ; find out pow
.del_two:   shr rcx, 1                          ;
            inc r11                             ;
            cmp rcx, 0                          ;
            ja .del_two                         ;
            dec r11                             ;

            mov rcx, r11                        ; find out base (like: 111111....) 
            xor rbx, rbx                        ;
.inc_base:  shl rbx, 1                          ;
            inc rbx                             ;
            Loop .inc_base                      ;

            xor rdx, rdx     

            mov rcx, r11                        ; get pow

            jmp .two_pow_case                   ; shift case                     
;_________________________________________________________________________________________________
;
;                                  standart numeral system
;_________________________________________________________________________________________________

.std_case:  mov rax, rdi 
            cmp rsi, 11                         ; find out need of sym representation
            jae .first_case1                    ;
            mov r10, .next_num12                ;
            jmp .next_num12                     ;

.first_case1:
            mov r10, .next_num11                
            jmp .next_num11          

.next_num11:
            div ecx
            cmp rdx, 10
            jb .num_case1

            sub rdx, 10                         ; sym representation case 
            add rdx, 'A'                        
            jmp .skip

.next_num12: 
            div ecx
.num_case1: add rdx, '0'                        ; num representation case
            jmp .skip
;_________________________________________________________________________________________________
;
;                                  2-pow numeral system
;_________________________________________________________________________________________________
;-------------------------------------------------------------------------------------------------
;   rcx - num of shifts
;   rbx - base remainder
;-------------------------------------------------------------------------------------------------
.two_pow_case:
            mov rax, rdi 
            cmp rsi, 11                         ; find out need of sym representation
            jae .first_case2                    ;
            mov r10, .next_num22                ;
            jmp .next_num22                     ;

.first_case2:
            mov r10, .next_num21  
            jmp .next_num21          

.next_num21:
            mov rdx, rax                        ; shift method
            and rdx, rbx                        ;
            shr rax, cl                         ;

            cmp rdx, 10
            jb .num_case2

            sub rdx, 10                         ; sym representation case 
            add rdx, 'A'                        
            jmp .skip

.next_num22: 
            mov rdx, rax                        ; shift method
            and rdx, rbx                        ;
            shr rax, cl                         ;

.num_case2: add rdx, '0'                        ; num representation case
            jmp .skip
;_________________________________________________________________________________________________
;
;                                   writing in number       
;_________________________________________________________________________________________________
                               
.skip:      mov byte [r8], dl
            dec r8                               ; mov to next number in our array
            inc r9
            xor rdx, rdx  
            cmp rax, 0
            jle .finish
            jmp r10                              ; repeat until nullify  
;_________________________________________________________________________________________________
;   
;                                    copy to buffer
;_________________________________________________________________________________________________

.finish     inc r8
            mov rcx, r9                         ; curr len
            mov r11, [rbp + 16]                 ; get ptr curr pos in buffer
            xor rax, rax                        ; return value (curr offset) 

.copy_bf:   mov bl, byte [r8]                   ; copy it
            mov byte [r11], bl                  ;
            inc r8                              ;
            inc r11                             ;
            inc rax                             ;
            Loop .copy_bf                       ;

            mov rsp, rbp                        ; EPILOGUE  
            pop rbp                            
            ret
;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------
;                                     JUMP TARGETS
;-------------------------------------------------------------------------------------------------

bin_case:               mov rdi, qword [rsi]                ; get curr num
                        mov rsi, 2                          ; curr base

                        push r11
                        call printnum                       ; call print num
                        pop r11
                        add rax, r11

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

char_case:              mov rbx, qword [rsi]                ; copy into print-buffer
                        mov byte [r11], bl                  ;
                           
                        mov rax, r11                        ; offset
                        inc rax                             ;

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

unsint_case:            mov rdi, qword [rsi]                ; get curr num
                        mov rsi, 10                         ; curr base

                        push r11
                        call printnum                       ; call print num
                        pop r11
                        add rax, r11

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

int_case:               mov rax, qword [rsi]                ; get curr num
                        movsx rdi, eax                      ;
                        xor rax, rax

                        cmp rdi, 0                          ; find out sign
                        jge .to_unsint
                        
                        dec rdi                             ; rdi = |rdi|
                        not rdi  

                        mov bl, '-'                         ;
                        mov byte [r11], bl                  ; copy sign '-'
                        inc r11                             ;

.to_unsint              mov rsi, 10                         ; curr base
                        push r11        
                        call printnum                       ; call print num
                        pop r11
                        add rax, r11

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

str_case:               mov rax, qword [rsi]                ; get ptr to line
                        xor rcx, rcx

.next_sym:              mov bl, byte [rax]

                        cmp bl, 0
                        je .end

                        mov byte [r11], bl 
                        inc r11                 
                        inc rax
                        inc rcx

                        push rax                            ; save regs

                        mov rax, 20                          
                        add rax, r11
                        cmp rax, buffer_end
                        jb .skip_print
                        xor rcx, rcx                        ; nullify curr len if we already print it!
                        call printing                       ; print it (now using syscall, not buffer)

.skip_print:            pop rax                             ; load saved regs
                        jmp .next_sym

.end                    mov rax, r11                        ; offset - curr line len

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

hex_case:               mov rdi, qword [rsi]                ; get curr num
                        mov rsi, 16                         ; curr base

                        push r11
                        call printnum                       ; call print num
                        pop r11
                        add rax, r11

                        jmp handle_percent.home

;-------------------------------------------------------------------------------------------------

octal_case:             mov rdi, qword [rsi]                ; get curr num
                        mov rsi, 8                          ; curr base

                        push r11
                        call printnum                       ; call print num
                        pop r11
                        add rax, r11

                        jmp handle_percent.home
                        
;-------------------------------------------------------------------------------------------------

empty_case:             jmp handle_percent.home

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------
;                                      JUMP TABLE
;-------------------------------------------------------------------------------------------------

section .data

jmp_table:              dq bin_case                         ;b
                        dq char_case                        ;c
                        dq int_case                         ;d
times ('o' - 'd' - 1)   dq empty_case
                        dq octal_case                       ;o
times ('s' - 'o' - 1)   dq empty_case
                        dq str_case                         ;s
times ('u' - 's' - 1)   dq empty_case
                        dq unsint_case                      ;u
times ('x' - 'u' - 1)   dq empty_case
                        dq hex_case                         ;x

;_________________________________________________________________________________________________
;
;                                      print buffer       
;_________________________________________________________________________________________________
print_buffer:  
times (500)             db 0  
buffer_end:       
;_________________________________________________________________________________________________

;-------------------------------------------------------------------------------------------------
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;-------------------------------------------------------------------------------------------------