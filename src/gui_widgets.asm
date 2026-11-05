default rel
bits 64
%include "winconst.inc"
global gui_button
global gui_label
global gui_edit
global gui_checkbox
global gui_groupbox
global gui_listbox
global gui_combobox
global gui_widget
global gui_get_check
global gui_set_check
global gui_list_add
global gui_list_clear
global gui_list_sel
global gui_combo_add
global gui_combo_clear
global gui_combo_sel
global gui_combo_getsel
extern gui_window_get
extern gui_get_hinstance
extern gui_register_hwnd
extern gui_apply_font
extern gui_get_hwnd_by_id
extern CreateWindowExA
extern SendMessageA
section .data
    cls_button   db "BUTTON", 0
    cls_static   db "STATIC", 0
    cls_edit     db "EDIT", 0
    cls_listbox  db "LISTBOX", 0
    cls_combobox db "COMBOBOX", 0
    empty_str    db 0
section .text
create_ctl:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    and  rsp, -16
    sub  rsp, 128
    mov  r12d, ecx
    mov  r13, rdx
    mov  r14d, r8d
    mov  r15d, r9d
    mov  ebx, [rbp+0x30]
    mov  edi, [rbp+0x38]
    mov  rsi, [rbp+0x40]
    mov  eax, [rbp+0x48]
    mov  dword [rbp-4], eax
    mov  eax, [rbp+0x50]
    mov  dword [rbp-8], eax
    test r13, r13
    jnz  .has_txt
    lea  r13, [empty_str]
.has_txt:
    call gui_window_get
    mov  [rsp+0], rax
    call gui_get_hinstance
    mov  [rsp+8], rax
    mov  ecx, [rbp-8]
    mov  rdx, rsi
    mov  r8, r13
    mov  r9d, [rbp-4]
    or   r9d, WS_CHILD | WS_VISIBLE
    mov  dword [rsp+32], r14d
    mov  dword [rsp+40], r15d
    mov  dword [rsp+48], ebx
    mov  dword [rsp+56], edi
    mov  rax, [rsp+0]
    mov  [rsp+64], rax
    mov  eax, r12d
    mov  [rsp+72], rax
    mov  rax, [rsp+8]
    mov  [rsp+80], rax
    mov  qword [rsp+88], 0
    call CreateWindowExA
    mov  rsi, rax
    mov  ecx, r12d
    mov  rdx, rsi
    call gui_register_hwnd
    mov  rcx, rsi
    call gui_apply_font
    mov  rax, rsi
    lea  rsp, [rbp-56]
    pop  r15
    pop  r14
    pop  r13
    pop  r12
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
%macro WIDGET 3
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 80
    mov  eax, [rbp+0x30]
    mov  dword [rsp+32], eax
    mov  eax, [rbp+0x38]
    mov  dword [rsp+40], eax
    lea  rax, [%1]
    mov  [rsp+48], rax
    mov  dword [rsp+56], %2
    mov  dword [rsp+64], %3
    call create_ctl
    mov  rsp, rbp
    pop  rbp
    ret
%endmacro
gui_button:
    WIDGET cls_button, WS_TABSTOP|BS_PUSHBUTTON, 0
gui_label:
    WIDGET cls_static, SS_LEFT, 0
gui_edit:
    WIDGET cls_edit, WS_TABSTOP|ES_LEFT|ES_AUTOHSCROLL, WS_EX_CLIENTEDGE
gui_checkbox:
    WIDGET cls_button, WS_TABSTOP|BS_AUTOCHECKBOX, 0
gui_groupbox:
    WIDGET cls_button, BS_GROUPBOX, 0
gui_listbox:
    WIDGET cls_listbox, WS_TABSTOP|WS_VSCROLL|LBS_NOTIFY, WS_EX_CLIENTEDGE
gui_combobox:
    WIDGET cls_combobox, WS_TABSTOP|CBS_DROPDOWNLIST|WS_VSCROLL, 0
gui_widget:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 80
    mov  eax, [rbp+0x30]
    mov  dword [rsp+32], eax
    mov  eax, [rbp+0x38]
    mov  dword [rsp+40], eax
    mov  rax, [rbp+0x40]
    mov  [rsp+48], rax
    mov  eax, [rbp+0x48]
    mov  dword [rsp+56], eax
    mov  eax, [rbp+0x50]
    mov  dword [rsp+64], eax
    call create_ctl
    mov  rsp, rbp
    pop  rbp
    ret
gui_get_check:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .z
    mov  rcx, rax
    mov  edx, BM_GETCHECK
    xor  r8d, r8d
    xor  r9d, r9d
    call SendMessageA
    jmp  .d
.z: xor  eax, eax
.d: add  rsp, 48
    pop  rbp
    ret
gui_set_check:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  esi, edx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, BM_SETCHECK
    mov  r8d, esi
    xor  r9d, r9d
    call SendMessageA
.d: add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_list_add:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rdx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, LB_ADDSTRING
    xor  r8d, r8d
    mov  r9, rsi
    call SendMessageA
.d: add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_list_clear:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, LB_RESETCONTENT
    xor  r8d, r8d
    xor  r9d, r9d
    call SendMessageA
.d: add  rsp, 48
    pop  rbp
    ret
gui_list_sel:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .z
    mov  rcx, rax
    mov  edx, LB_GETCURSEL
    xor  r8d, r8d
    xor  r9d, r9d
    call SendMessageA
    jmp  .d
.z: mov  eax, -1
.d: add  rsp, 48
    pop  rbp
    ret
gui_combo_add:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rdx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, CB_ADDSTRING
    xor  r8d, r8d
    mov  r9, rsi
    call SendMessageA
.d: add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_combo_clear:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, CB_RESETCONTENT
    xor  r8d, r8d
    xor  r9d, r9d
    call SendMessageA
.d: add  rsp, 48
    pop  rbp
    ret
gui_combo_sel:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  esi, edx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .d
    mov  rcx, rax
    mov  edx, CB_SETCURSEL
    mov  r8d, esi
    xor  r9d, r9d
    call SendMessageA
.d: add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_combo_getsel:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .z
    mov  rcx, rax
    mov  edx, CB_GETCURSEL
    xor  r8d, r8d
    xor  r9d, r9d
    call SendMessageA
    jmp  .d
.z: mov  eax, -1
.d: add  rsp, 48
    pop  rbp
    ret
