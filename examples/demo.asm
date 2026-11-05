default rel
bits 64
%include "gui.inc"
%define ID_SUBTITLE   9
%define ID_TITLE      10
%define ID_NAME_LBL   11
%define ID_NAME       12
%define ID_HELLO      13
%define ID_CHECK      14
%define ID_THEME      15
%define ID_LIST_LBL   16
%define ID_LIST       17
%define ID_COMBO_L    18
%define ID_COMBO      19
%define ID_STATUS     20
%define ID_CLEAR      21
%define ID_QUIT       22
%define ID_GROUP      23
%define ID_HINT       24
%define HDR_H         108
section .data
    win_title    db "GuiASM - Bibliotheque GUI NASM Win64", 0
    txt_sub      db "Interface 100 % assembleur pour vos projets NASM", 0
    txt_title    db "GuiASM", 0
    txt_name_lbl db "Pseudo NASM :", 0
    txt_name     db "developpeur", 0
    txt_hello    db "Saluer", 0
    txt_check    db "Mode avance (ASM pur)", 0
    txt_theme    db "Palette", 0
    txt_list_lbl db "Syntaxes :", 0
    txt_combo_l  db "Experience :", 0
    txt_status   db "Pret. Cliquez sur Saluer ou Effacer.", 0
    txt_clear    db "Effacer", 0
    txt_quit     db "Fermer", 0
    txt_group    db "Formulaire", 0
    txt_hint     db "Aucun C/C++ requis : seulement NASM + GuiASM.", 0
    item_nasm    db "NASM (Intel)", 0
    item_fasm    db "FASM", 0
    item_gas     db "GAS (GNU)", 0
    item_masm    db "MASM (Microsoft)", 0
    lvl_debutant db "Debutant", 0
    lvl_inter    db "Intermediaire", 0
    lvl_expert   db "Expert NASM", 0
    msg_hello_p  db "Salut, ", 0
    msg_hello_s  db " ! Bienvenue dans GuiASM.", 0
    msg_title    db "GuiASM", 0
    msg_pro      db "Mode avance active.", 0
    msg_nopro    db "Mode avance desactive.", 0
    msg_theme    db "Palette mise a jour.", 0
    msg_empty    db "Saisissez un pseudo dans le champ.", 0
    status_ok    db "Salutation envoyee.", 0
    status_clr   db "Champ efface.", 0
    paint_tag    db "Dessine en NASM + GDI", 0
    paint_foot   db "NASM Win64  |  user32 + gdi32", 0
    name_empty   db 0
    log_demo_start db "[DEMO] Demarrage", 0
    log_demo_win   db "[DEMO] Fenetre OK", 0
    log_demo_wid   db "[DEMO] Widgets OK", 0
    log_demo_ui    db "[DEMO] Interface construite", 0
    log_demo_run   db "[DEMO] Entree boucle GUI_RUN", 0
    log_demo_hello db "[DEMO] Handler Saluer", 0
    log_demo_clear db "[DEMO] Handler Effacer", 0
    log_fatal_win  db "CreateWindowExA a echoue. Voir guiasm.log", 0
section .bss
    name_buf     resb 128
    greet_buf    resb 200
    theme_idx    resd 1
section .text
global main
extern ExitProcess
extern gui_get_hfont_title
extern gui_select_font
extern gui_restore_font
extern gui_log_write
extern gui_log_fatal
extern gui_log_init
extern gui_log_install_filter
main:
    GUI_MAIN_ENTER
    call gui_log_init
    GUI_INIT
    GUI_LOG log_demo_start
    lea  rcx, [win_title]
    mov  edx, 920
    mov  r8d, 640
    mov  r9d, CW_USEDEFAULT
    sub  rsp, 48
    mov  dword [rsp+32], CW_USEDEFAULT
    call gui_window_create
    add  rsp, 48
    test rax, rax
    jnz  .win_ok
    lea  rcx, [log_fatal_win]
    call gui_log_fatal
.win_ok:
    GUI_LOG log_demo_win
    GUI_LABEL ID_SUBTITLE, txt_sub, 28, HDR_H + 14, 640, 22
    GUI_GROUPBOX ID_GROUP, txt_group, 24, HDR_H + 48, 500, 248
    GUI_LABEL ID_NAME_LBL, txt_name_lbl, 44, HDR_H + 82, 130, 22
    GUI_EDIT  ID_NAME, txt_name, 180, HDR_H + 78, 320, 28
    GUI_BUTTON ID_HELLO, txt_hello, 44, HDR_H + 124, 150, 36
    GUI_BUTTON ID_CLEAR, txt_clear, 206, HDR_H + 124, 120, 36
    GUI_BUTTON ID_THEME, txt_theme, 340, HDR_H + 124, 120, 36
    GUI_CHECKBOX ID_CHECK, txt_check, 44, HDR_H + 176, 280, 24
    GUI_LABEL ID_HINT, txt_hint, 44, HDR_H + 210, 460, 22
    GUI_LABEL ID_STATUS, txt_status, 28, 588, 620, 24
    GUI_BUTTON ID_QUIT, txt_quit, 800, 578, 96, 36
    GUI_LOG log_demo_wid
    mov  dword [theme_idx], 0
    GUI_ON ID_HELLO, on_hello
    GUI_ON ID_CLEAR, on_clear
    GUI_ON ID_CHECK, on_check
    GUI_ON ID_THEME, on_theme
    GUI_ON ID_QUIT,  on_quit
    GUI_ON_PAINT on_paint
    GUI_ON_CLOSE on_close
    GUI_LOG log_demo_ui
    GUI_LOG log_demo_run
    GUI_RUN
    GUI_SHUTDOWN
    xor  ecx, ecx
    call ExitProcess
    GUI_MAIN_LEAVE
on_hello:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 64
    GUI_LOG log_demo_hello
    mov  ecx, ID_NAME
    lea  rdx, [name_buf]
    mov  r8d, 127
    call gui_get_text
    test eax, eax
    jz   .empty
    lea  rdi, [greet_buf]
    lea  rsi, [msg_hello_p]
    call str_copy
    lea  rsi, [name_buf]
    call str_append
    lea  rsi, [msg_hello_s]
    call str_append
    lea  rcx, [greet_buf]
    lea  rdx, [msg_title]
    call gui_msgbox
    mov  ecx, ID_STATUS
    lea  rdx, [status_ok]
    call gui_set_text
    jmp  .done
.empty:
    lea  rcx, [msg_empty]
    lea  rdx, [msg_title]
    mov  r8d, MB_OK | MB_ICONWARNING
    call gui_msgbox_ex
.done:
    mov  rsp, rbp
    pop  rbp
    ret
on_clear:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    GUI_LOG log_demo_clear
    mov  ecx, ID_NAME
    lea  rdx, [name_empty]
    call gui_set_text
    mov  ecx, ID_STATUS
    lea  rdx, [status_clr]
    call gui_set_text
    mov  ecx, ID_NAME
    call gui_set_focus
    mov  rsp, rbp
    pop  rbp
    ret
on_check:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  ecx, ID_CHECK
    call gui_get_check
    test eax, eax
    jz   .off
    lea  rcx, [msg_pro]
    jmp  .show
.off:
    lea  rcx, [msg_nopro]
.show:
    lea  rdx, [msg_title]
    call gui_msgbox
    mov  rsp, rbp
    pop  rbp
    ret
on_theme:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  eax, [theme_idx]
    inc  eax
    cmp  eax, 4
    jb   .ok
    xor  eax, eax
.ok:
    mov  [theme_idx], eax
    xor  ecx, ecx
    call gui_invalidate
    mov  ecx, ID_STATUS
    lea  rdx, [msg_theme]
    call gui_set_text
    mov  rsp, rbp
    pop  rbp
    ret
on_quit:
    call gui_quit
    ret
on_close:
    xor  eax, eax
    ret
on_paint:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    and  rsp, -16
    sub  rsp, 128
    mov  rbx, rcx
    mov  eax, [theme_idx]
    cmp  eax, 1
    je   .c1
    cmp  eax, 2
    je   .c2
    cmp  eax, 3
    je   .c3
    mov  r12d, 0x003D2B6B
    mov  r13d, 0x005A3D8F
    jmp  .hdr
.c1:
    mov  r12d, 0x004A3728
    mov  r13d, 0x006B4F3A
    jmp  .hdr
.c2:
    mov  r12d, 0x00303030
    mov  r13d, 0x00484848
    jmp  .hdr
.c3:
    mov  r12d, 0x002D4A8C
    mov  r13d, 0x004169E1
.hdr:
    mov  rcx, rbx
    xor  edx, edx
    xor  r8d, r8d
    mov  r9d, 920
    mov  dword [rsp+32], HDR_H
    mov  dword [rsp+40], r12d
    call gui_fill_rect
    mov  rcx, rbx
    xor  edx, edx
    mov  r8d, 54
    mov  r9d, 920
    mov  dword [rsp+32], 54
    mov  dword [rsp+40], r13d
    call gui_fill_rect
    mov  rcx, rbx
    xor  edx, edx
    mov  r8d, HDR_H
    mov  r9d, 920
    mov  dword [rsp+32], 560
    mov  dword [rsp+40], 0x00F4F6FA
    call gui_fill_rect
    mov  rcx, rbx
    xor  edx, edx
    mov  r8d, 560
    mov  r9d, 920
    mov  dword [rsp+32], 32
    mov  dword [rsp+40], 0x002D3142
    call gui_fill_rect
    call gui_get_hfont_title
    mov  r12, rax
    test r12, r12
    jz   .no_title_font
    mov  rcx, rbx
    mov  rdx, r12
    call gui_select_font
    mov  r13, rax
    mov  rcx, rbx
    lea  rdx, [txt_title]
    mov  r8d, 28
    mov  r9d, 34
    mov  dword [rsp+32], 0x00FFFFFF
    call gui_draw_text
    mov  rcx, rbx
    mov  rdx, r13
    call gui_restore_font
.no_title_font:
    mov  rcx, rbx
    lea  rdx, [paint_tag]
    mov  r8d, 28
    mov  r9d, 72
    mov  dword [rsp+32], 0x00E8EAF0
    call gui_draw_text
    mov  rcx, rbx
    lea  rdx, [paint_foot]
    mov  r8d, 28
    mov  r9d, 596
    mov  dword [rsp+32], 0x00555566
    call gui_draw_text
    lea  rsp, [rbp-24]
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp
    ret
str_copy:
    push rax
.cp:
    mov  al, [rsi]
    mov  [rdi], al
    inc  rsi
    inc  rdi
    test al, al
    jnz  .cp
    dec  rdi
    pop  rax
    ret
str_append:
    push rax
.sk:
    cmp  byte [rdi], 0
    je   .ap
    inc  rdi
    jmp  .sk
.ap:
    mov  al, [rsi]
    mov  [rdi], al
    inc  rsi
    inc  rdi
    test al, al
    jnz  .ap
    dec  rdi
    pop  rax
    ret
