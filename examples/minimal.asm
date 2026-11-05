default rel
bits 64
%include "gui.inc"
section .data
    title db "Hello GuiASM", 0
    lbl   db "100% assembleur", 0
    btn   db "OK", 0
    bye   db "Merci d'utiliser GuiASM !", 0
section .text
global main
extern ExitProcess
main:
    GUI_MAIN_ENTER
    GUI_INIT
    GUI_WINDOW title, 420, 200
    GUI_LABEL  1, lbl, 30, 40, 300, 24
    GUI_BUTTON 2, btn, 150, 90, 100, 32
    GUI_ON 2, on_ok
    GUI_RUN
    GUI_SHUTDOWN
    xor  ecx, ecx
    call ExitProcess
    GUI_MAIN_LEAVE
on_ok:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    GUI_MSGBOX bye, title
    call gui_quit
    mov  rsp, rbp
    pop  rbp
    ret
