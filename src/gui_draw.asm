default rel
bits 64
%include "winconst.inc"
global gui_fill_rect
global gui_draw_text
global gui_draw_line
global gui_set_bg_color
global gui_rgb
global gui_get_client_dc
global gui_release_dc
global gui_select_font
global gui_restore_font
extern gui_window_get
extern GetDC
extern ReleaseDC
extern CreateSolidBrush
extern DeleteObject
extern FillRect
extern SetTextColor
extern SetBkMode
extern TextOutA
extern CreatePen
extern SelectObject
extern MoveToEx
extern LineTo
section .bss
    g_user_bg resd 1
section .text
gui_rgb:
    movzx eax, cl
    and   edx, 0xFF
    and   r8d, 0xFF
    shl   edx, 8
    shl   r8d, 16
    or    eax, edx
    or    eax, r8d
    ret
gui_set_bg_color:
    mov  [g_user_bg], ecx
    ret
gui_select_font:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call SelectObject
    mov  rsp, rbp
    pop  rbp
    ret
gui_restore_font:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call SelectObject
    mov  rsp, rbp
    pop  rbp
    ret
gui_get_client_dc:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_window_get
    mov  rcx, rax
    call GetDC
    mov  rsp, rbp
    pop  rbp
    ret
gui_release_dc:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rcx
    call gui_window_get
    mov  rcx, rax
    mov  rdx, rsi
    call ReleaseDC
    add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_fill_rect:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    and  rsp, -16
    sub  rsp, 80
    mov  [rsp+48], rcx
    mov  dword [rsp+56], edx
    mov  dword [rsp+60], r8d
    mov  dword [rsp+64], r9d
    mov  eax, [rbp+0x30]
    mov  dword [rsp+68], eax
    mov  ecx, [rbp+0x38]
    call CreateSolidBrush
    mov  rsi, rax
    mov  eax, [rsp+56]
    mov  dword [rsp+0], eax
    mov  eax, [rsp+60]
    mov  dword [rsp+4], eax
    mov  eax, [rsp+56]
    add  eax, [rsp+64]
    mov  dword [rsp+8], eax
    mov  eax, [rsp+60]
    add  eax, [rsp+68]
    mov  dword [rsp+12], eax
    mov  rcx, [rsp+48]
    lea  rdx, [rsp]
    mov  r8, rsi
    call FillRect
    mov  rcx, rsi
    call DeleteObject
    lea  rsp, [rbp-16]
    pop  rsi
    pop  rbx
    pop  rbp
    ret
gui_draw_text:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  [rsp+0], rcx
    mov  [rsp+8], rdx
    mov  dword [rsp+16], r8d
    mov  dword [rsp+20], r9d
    mov  rcx, [rsp+0]
    mov  edx, [rbp+0x30]
    call SetTextColor
    mov  rcx, [rsp+0]
    mov  edx, TRANSPARENT
    call SetBkMode
    mov  rsi, [rsp+8]
    xor  eax, eax
.len:
    cmp  byte [rsi+rax], 0
    je   .got
    inc  eax
    jmp  .len
.got:
    mov  dword [rsp+32], eax
    mov  rcx, [rsp+0]
    mov  edx, [rsp+16]
    mov  r8d, [rsp+20]
    mov  r9, rsi
    call TextOutA
    lea  rsp, [rbp-16]
    pop  rsi
    pop  rbx
    pop  rbp
    ret
gui_draw_line:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    and  rsp, -16
    sub  rsp, 80
    mov  [rsp+48], rcx
    mov  dword [rsp+56], edx
    mov  dword [rsp+60], r8d
    mov  dword [rsp+64], r9d
    mov  eax, [rbp+0x30]
    mov  dword [rsp+68], eax
    mov  ecx, PS_SOLID
    mov  edx, [rbp+0x40]
    test edx, edx
    jnz  .has_w
    mov  edx, 1
.has_w:
    mov  r8d, [rbp+0x38]
    call CreatePen
    mov  rsi, rax
    mov  rcx, [rsp+48]
    mov  rdx, rsi
    call SelectObject
    mov  rdi, rax
    mov  rcx, [rsp+48]
    mov  edx, [rsp+56]
    mov  r8d, [rsp+60]
    xor  r9, r9
    call MoveToEx
    mov  rcx, [rsp+48]
    mov  edx, [rsp+64]
    mov  r8d, [rsp+68]
    call LineTo
    mov  rcx, [rsp+48]
    mov  rdx, rdi
    call SelectObject
    mov  rcx, rsi
    call DeleteObject
    lea  rsp, [rbp-24]
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
