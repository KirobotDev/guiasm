%ifndef GUI_INC
%define GUI_INC
%include "winconst.inc"
extern gui_init
extern gui_shutdown
extern gui_window_create
extern gui_window_get
extern gui_run
extern gui_quit
extern gui_button
extern gui_label
extern gui_edit
extern gui_checkbox
extern gui_groupbox
extern gui_listbox
extern gui_combobox
extern gui_widget
extern gui_on_command
extern gui_on_paint
extern gui_on_close
extern gui_on_timer
extern gui_on_keydown
extern gui_on_mousemove
extern gui_on_lbutton
extern gui_msgbox
extern gui_msgbox_ex
extern gui_set_text
extern gui_get_text
extern gui_get_check
extern gui_set_check
extern gui_enable
extern gui_show
extern gui_set_focus
extern gui_invalidate
extern gui_set_timer
extern gui_kill_timer
extern gui_get_hwnd_by_id
extern gui_list_add
extern gui_list_clear
extern gui_list_sel
extern gui_combo_add
extern gui_combo_clear
extern gui_combo_sel
extern gui_combo_getsel
extern gui_fill_rect
extern gui_draw_text
extern gui_draw_line
extern gui_set_bg_color
extern gui_rgb
extern gui_get_client_dc
extern gui_release_dc
extern gui_get_hfont_title
extern gui_select_font
extern gui_restore_font
extern gui_log_write
extern gui_log_write_dec
extern gui_log_last_error
extern gui_log_fatal
extern ExitProcess
%macro GUI_LOG 1
    lea  rcx, [rel %1]
    call gui_log_write
%endmacro
%macro GUI_MAIN_ENTER 0
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 64
%endmacro
%macro GUI_MAIN_LEAVE 0
    mov  rsp, rbp
    pop  rbp
%endmacro
%macro GUI_INIT 0
    call gui_init
%endmacro
%macro GUI_WINDOW 3-5
    lea  rcx, [rel %1]
    mov  edx, %2
    mov  r8d, %3
    %if %0 == 3
        mov  r9d, CW_USEDEFAULT
        sub  rsp, 48
        mov  dword [rsp+32], CW_USEDEFAULT
        call gui_window_create
        add  rsp, 48
    %else
        mov  r9d, %4
        sub  rsp, 48
        mov  dword [rsp+32], %5
        call gui_window_create
        add  rsp, 48
    %endif
%endmacro
%macro GUI_BUTTON 6
    mov  ecx, %1
    lea  rdx, [rel %2]
    mov  r8d, %3
    mov  r9d, %4
    sub  rsp, 64
    mov  dword [rsp+32], %5
    mov  dword [rsp+40], %6
    call gui_button
    add  rsp, 64
%endmacro
%macro GUI_LABEL 6
    mov  ecx, %1
    lea  rdx, [rel %2]
    mov  r8d, %3
    mov  r9d, %4
    sub  rsp, 64
    mov  dword [rsp+32], %5
    mov  dword [rsp+40], %6
    call gui_label
    add  rsp, 64
%endmacro
%macro GUI_EDIT 6
    mov  ecx, %1
    lea  rdx, [rel %2]
    mov  r8d, %3
    mov  r9d, %4
    sub  rsp, 64
    mov  dword [rsp+32], %5
    mov  dword [rsp+40], %6
    call gui_edit
    add  rsp, 64
%endmacro
%macro GUI_CHECKBOX 6
    mov  ecx, %1
    lea  rdx, [rel %2]
    mov  r8d, %3
    mov  r9d, %4
    sub  rsp, 64
    mov  dword [rsp+32], %5
    mov  dword [rsp+40], %6
    call gui_checkbox
    add  rsp, 64
%endmacro
%macro GUI_GROUPBOX 6
    mov  ecx, %1
    lea  rdx, [rel %2]
    mov  r8d, %3
    mov  r9d, %4
    sub  rsp, 64
    mov  dword [rsp+32], %5
    mov  dword [rsp+40], %6
    call gui_groupbox
    add  rsp, 64
%endmacro
%macro GUI_LISTBOX 5
    mov  ecx, %1
    xor  edx, edx
    mov  r8d, %2
    mov  r9d, %3
    sub  rsp, 64
    mov  dword [rsp+32], %4
    mov  dword [rsp+40], %5
    call gui_listbox
    add  rsp, 64
%endmacro
%macro GUI_COMBOBOX 5
    mov  ecx, %1
    xor  edx, edx
    mov  r8d, %2
    mov  r9d, %3
    sub  rsp, 64
    mov  dword [rsp+32], %4
    mov  dword [rsp+40], %5
    call gui_combobox
    add  rsp, 64
%endmacro
%macro GUI_ON 2
    mov  ecx, %1
    lea  rdx, [rel %2]
    call gui_on_command
%endmacro
%macro GUI_ON_PAINT 1
    lea  rcx, [rel %1]
    call gui_on_paint
%endmacro
%macro GUI_ON_CLOSE 1
    lea  rcx, [rel %1]
    call gui_on_close
%endmacro
%macro GUI_MSGBOX 1-2
    %if %0 == 1
        lea  rcx, [rel %1]
        xor  edx, edx
        call gui_msgbox
    %else
        lea  rcx, [rel %1]
        lea  rdx, [rel %2]
        call gui_msgbox
    %endif
%endmacro
%macro GUI_RGB 3
    mov  eax, (%3 << 16) | (%2 << 8) | (%1)
%endmacro
%macro GUI_RUN 0
    call gui_run
%endmacro
%macro GUI_QUIT 0
    call gui_quit
%endmacro
%macro GUI_SHUTDOWN 0
    call gui_shutdown
%endmacro
%endif
