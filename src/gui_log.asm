default rel
bits 64
%include "winconst.inc"
global gui_log_init
global gui_log_shutdown
global gui_log_write
global gui_log_write_dec
global gui_log_last_error
global gui_log_if_null
global gui_log_fatal
global gui_log_install_filter
extern CreateFileA
extern WriteFile
extern CloseHandle
extern GetLastError
extern SetFilePointer
extern SetUnhandledExceptionFilter
extern MessageBoxA
extern ExitProcess
section .data
    g_log_handle   dq 0
    log_name       db "guiasm.log", 0
    crlf           db 13, 10
    err_fatal_t    db "GuiASM - Erreur", 0
    exc_prefix     db "[EXCEPTION] code=0x", 0
    eq_err         db " GetLastError=0x", 0
    filter_on      db "[SYS] Session demarree, filtre exceptions actif", 0
    exc_hint_av    db " (violation acces memoire)", 0
    exc_hint_ill   db " (instruction illegale)", 0
    exc_hint_stk   db " (depassement pile)", 0
    exc_hint_other db " (voir guiasm.log)", 0
section .bss
    g_log_buf      resb 512
    g_log_digits   resb 16
section .text
gui_log_init:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 64
    lea  rcx, [rel log_name]
    mov  edx, GENERIC_WRITE
    mov  r8d, FILE_SHARE_READ
    xor  r9d, r9d
    mov  dword [rsp+32], OPEN_ALWAYS
    mov  dword [rsp+40], FILE_ATTRIBUTE_NORMAL
    mov  qword [rsp+48], 0
    call CreateFileA
    cmp  rax, INVALID_HANDLE_VALUE
    je   .out
    mov  [rel g_log_handle], rax
    mov  rcx, rax
    xor  edx, edx
    xor  r8d, r8d
    mov  r9d, FILE_END
    call SetFilePointer
    lea  rcx, [rel filter_on]
    call gui_log_write
.out:
    mov  rsp, rbp
    pop  rbp
    ret
gui_log_shutdown:
    mov  rcx, [rel g_log_handle]
    test rcx, rcx
    jz   .done
    call CloseHandle
    mov  qword [rel g_log_handle], 0
.done:
    ret
gui_log_write:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  qword [rsp+40], rcx
    mov  rcx, [rel g_log_handle]
    test rcx, rcx
    jz   .skip
    cmp  rcx, INVALID_HANDLE_VALUE
    je   .skip
    mov  rsi, [rsp+40]
    xor  eax, eax
.len:
    cmp  byte [rsi+rax], 0
    je   .got
    inc  eax
    jmp  .len
.got:
    test eax, eax
    jz   .nl
    mov  r8d, eax
    mov  rdx, rsi
    lea  r9, [rel g_log_digits]
    mov  qword [rsp+32], 0
    call WriteFile
.nl:
    mov  rcx, [rel g_log_handle]
    lea  rdx, [rel crlf]
    mov  r8d, 2
    lea  r9, [rel g_log_digits]
    mov  qword [rsp+32], 0
    call WriteFile
.skip:
    mov  rsp, rbp
    pop  rbp
    ret
log_append_hex8:
    mov  ecx, 8
.h:
    mov  edx, eax
    shr  eax, 4
    and  edx, 0xF
    cmp  dl, 9
    jbe  .d
    add  dl, 'A'-10
    jmp  .s
.d:
    add  dl, '0'
.s:
    dec  ecx
    mov  [rdi+rcx], dl
    test ecx, ecx
    jnz  .h
    add  rdi, 8
    ret
log_copy_str:
    test al, al
    jz   .done
    mov  [rdi], al
    inc  rsi
    inc  rdi
    mov  al, [rsi]
    jmp  log_copy_str
.done:
    ret
log_append_exc_hint:
    cmp  ebx, 0xC0000005
    je   .av
    cmp  ebx, 0xC000001D
    je   .ill
    cmp  ebx, 0xC00000FD
    je   .stk
    lea  rsi, [rel exc_hint_other]
    jmp  .cp
.av:
    lea  rsi, [rel exc_hint_av]
    jmp  .cp
.ill:
    lea  rsi, [rel exc_hint_ill]
    jmp  .cp
.stk:
    lea  rsi, [rel exc_hint_stk]
.cp:
    mov  al, [rsi]
    call log_copy_str
    ret
log_append_dec:
    push rdi
    lea  rdi, [rel g_log_digits]
    xor  eax, eax
    mov  ecx, 16
    rep  stosb
    pop  rdi
    lea  rsi, [rel g_log_digits+15]
    mov  byte [rsi], 0
    mov  eax, ebx
    test eax, eax
    jnz  .dl
    dec  rsi
    mov  byte [rsi], '0'
    jmp  .cpd
.dl:
    test eax, eax
    jz   .cpd
    dec  rsi
    xor  edx, edx
    mov  r8d, 10
    div  r8d
    add  dl, '0'
    mov  [rsi], dl
    jmp  .dl
.cpd:
    mov  al, [rsi]
    mov  [rdi], al
    inc  rsi
    inc  rdi
    test al, al
    jnz  .cpd
    ret
gui_log_write_dec:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rcx
    mov  ebx, edx
    lea  rdi, [rel g_log_buf]
    mov  rcx, rsi
.str:
    mov  al, [rcx]
    mov  [rdi], al
    inc  rcx
    inc  rdi
    test al, al
    jnz  .str
    mov  byte [rdi], ' '
    inc  rdi
    call log_append_dec
    mov  byte [rdi], 0
    lea  rcx, [rel g_log_buf]
    call gui_log_write
    add  rsp, 48
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
gui_log_last_error:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rcx
    call GetLastError
    mov  ebx, eax
    lea  rdi, [rel g_log_buf]
    mov  al, [rsi]
.s1:
    call log_copy_str
    lea  rsi, [rel eq_err]
    mov  al, [rsi]
.s2:
    call log_copy_str
    mov  eax, ebx
    call log_append_hex8
    mov  byte [rdi], 0
    lea  rcx, [rel g_log_buf]
    call gui_log_write
    add  rsp, 48
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
gui_log_if_null:
    test rdx, rdx
    jnz  .ok
    push rcx
    call gui_log_write
    pop  rcx
    mov  eax, 1
    ret
.ok:
    xor  eax, eax
    ret
gui_log_fatal:
    push rbp
    mov  rbp, rsp
    push rbx
    and  rsp, -16
    sub  rsp, 48
    mov  rbx, rcx
    mov  rcx, rbx
    call gui_log_write
    xor  ecx, ecx
    mov  rdx, rbx
    lea  r8, [rel err_fatal_t]
    mov  r9d, MB_OK | MB_ICONERROR
    call MessageBoxA
    call gui_log_shutdown
    mov  ecx, 1
    call ExitProcess
gui_log_install_filter:
    lea  rcx, [rel GuiExceptionFilter]
    call SetUnhandledExceptionFilter
    ret
GuiExceptionFilter:
    push rbp
    mov  rbp, rsp
    push rbx
    and  rsp, -16
    sub  rsp, 48
    test rcx, rcx
    jz   .pass
    mov  rdx, [rcx]
    test rdx, rdx
    jz   .pass
    mov  ebx, [rdx]
    lea  rdi, [rel g_log_buf]
    lea  rsi, [rel exc_prefix]
    mov  al, [rsi]
.s3:
    call log_copy_str
    mov  eax, ebx
    call log_append_hex8
    call log_append_exc_hint
    mov  byte [rdi], 0
    lea  rcx, [rel g_log_buf]
    call gui_log_write
    xor  ecx, ecx
    lea  rdx, [rel g_log_buf]
    lea  r8, [rel err_fatal_t]
    mov  r9d, MB_OK | MB_ICONERROR
    call MessageBoxA
    call gui_log_shutdown
    mov  ecx, 1
    call ExitProcess
.pass:
    xor  eax, eax
    mov  rsp, rbp
    pop  rbx
    pop  rbp
    ret
