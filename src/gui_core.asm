default rel
bits 64
%include "winconst.inc"
global gui_init
global gui_shutdown
global gui_window_create
global gui_window_get
global gui_run
global gui_quit
global gui_on_command
global gui_on_paint
global gui_on_close
global gui_on_timer
global gui_on_keydown
global gui_on_mousemove
global gui_on_lbutton
global gui_msgbox
global gui_msgbox_ex
global gui_set_text
global gui_get_text
global gui_enable
global gui_show
global gui_set_focus
global gui_invalidate
global gui_set_timer
global gui_kill_timer
global gui_get_hwnd_by_id
global gui_register_hwnd
global gui_apply_font
global gui_get_hinstance
global gui_get_hfont
global gui_get_hfont_title
extern GetModuleHandleA
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern PostQuitMessage
extern DefWindowProcA
extern DestroyWindow
extern LoadCursorA
extern LoadIconA
extern GetStockObject
extern BeginPaint
extern EndPaint
extern SetWindowTextA
extern GetWindowTextA
extern EnableWindow
extern SetFocus
extern InvalidateRect
extern SetTimer
extern KillTimer
extern MessageBoxA
extern SendMessageA
extern CreateFontA
extern DeleteObject
extern GetLastError
extern gui_log_init
extern gui_log_shutdown
extern gui_log_write
extern gui_log_write_dec
extern gui_log_last_error
extern gui_log_if_null
extern gui_log_fatal
section .data
    log_init_ok      db "[OK] gui_init", 0
    log_reg_class    db "[OK] RegisterClassExA", 0
    log_reg_fail     db "[ERR] RegisterClassExA", 0
    log_reg_exists   db "[WARN] Classe deja enregistree", 0
    log_font_fail    db "[WARN] CreateFontA, police par defaut", 0
    log_win_create   db "[OK] fenetre creee hwnd=", 0
    log_win_fail     db "[ERR] CreateWindowExA a echoue", 0
    log_loop_end     db "[INFO] Fin boucle messages code=", 0
    log_wm_destroy   db "[INFO] WM_DESTROY", 0
    log_wm_close     db "[INFO] WM_CLOSE", 0
    log_wm_cmd       db "[INFO] WM_COMMAND id=", 0
    log_paint_start  db "[INFO] WM_PAINT", 0
    log_paint_hdc    db "[ERR] BeginPaint hdc null", 0
    log_handler      db "[INFO] Appel handler id=", 0
    log_getmsg_fail  db "[ERR] GetMessageA", 0
    g_classname     db "GuiASMWindowClass", 0
    g_default_title db "GuiASM", 0
    g_font_face     db "Segoe UI", 0
    g_font_ui       db "Segoe UI", 0
section .bss
    alignb 8
    g_hinstance     resq 1
    g_hwnd          resq 1
    g_hfont         resq 1
    g_hfont_title   resq 1
    g_cmd_table     resb GUI_MAX_HANDLERS * 16
    g_cmd_count     resd 1
    alignb 8
    g_paint_fn      resq 1
    g_close_fn      resq 1
    g_timer_fn      resq 1
    g_keydown_fn    resq 1
    g_mousemove_fn  resq 1
    g_lbutton_fn    resq 1
    g_msg           resb 48
    g_ps            resb 72
    g_wc            resb 80
    g_id_hwnd       resq 128
section .text
gui_init:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 160
    xor  ecx, ecx
    call GetModuleHandleA
    mov  [g_hinstance], rax
    mov  dword [g_cmd_count], 0
    xor  eax, eax
    mov  [g_paint_fn], rax
    mov  [g_close_fn], rax
    mov  [g_timer_fn], rax
    mov  [g_keydown_fn], rax
    mov  [g_mousemove_fn], rax
    mov  [g_lbutton_fn], rax
    mov  [g_hwnd], rax
    lea  rdi, [g_id_hwnd]
    mov  ecx, 128
    xor  eax, eax
    rep  stosq
    mov  ecx, 16
    xor  edx, edx
    xor  r8d, r8d
    xor  r9d, r9d
    mov  dword [rsp+32], FW_NORMAL
    mov  dword [rsp+40], 0
    mov  dword [rsp+48], 0
    mov  dword [rsp+56], 0
    mov  dword [rsp+64], DEFAULT_CHARSET
    mov  dword [rsp+72], OUT_DEFAULT_PRECIS
    mov  dword [rsp+80], CLIP_DEFAULT_PRECIS
    mov  dword [rsp+88], DEFAULT_QUALITY
    mov  dword [rsp+96], DEFAULT_PITCH
    lea  rax, [g_font_face]
    mov  [rsp+104], rax
    call CreateFontA
    mov  [g_hfont], rax
    test rax, rax
    jnz  .font_ui_ok
    mov  ecx, DEFAULT_GUI_FONT
    call GetStockObject
    mov  [g_hfont], rax
.font_ui_ok:
    mov  ecx, 28
    xor  edx, edx
    xor  r8d, r8d
    xor  r9d, r9d
    mov  dword [rsp+32], FW_BOLD
    mov  dword [rsp+40], 0
    mov  dword [rsp+48], 0
    mov  dword [rsp+56], 0
    mov  dword [rsp+64], DEFAULT_CHARSET
    mov  dword [rsp+72], OUT_DEFAULT_PRECIS
    mov  dword [rsp+80], CLIP_DEFAULT_PRECIS
    mov  dword [rsp+88], DEFAULT_QUALITY
    mov  dword [rsp+96], DEFAULT_PITCH
    lea  rax, [g_font_ui]
    mov  [rsp+104], rax
    call CreateFontA
    mov  [g_hfont_title], rax
    test rax, rax
    jnz  .font_title_ok
    mov  rcx, [g_hfont]
    mov  [g_hfont_title], rcx
.font_title_ok:
    lea  rdi, [g_wc]
    xor  eax, eax
    mov  ecx, 80
    rep  stosb
    lea  rbx, [g_wc]
    mov  dword [rbx], 80
    mov  dword [rbx+4], 0
    lea  rax, [rel WndProc]
    mov  [rbx+8], rax
    mov  rax, [g_hinstance]
    mov  [rbx+24], rax
    xor  ecx, ecx
    mov  edx, IDI_APPLICATION
    call LoadIconA
    mov  [rbx+32], rax
    xor  ecx, ecx
    mov  edx, IDC_ARROW
    call LoadCursorA
    mov  [rbx+40], rax
    mov  ecx, COLOR_BTNFACE + 1
    call GetStockObject
    mov  [rbx+48], rax
    lea  rax, [g_classname]
    mov  [rbx+64], rax
    lea  rcx, [g_wc]
    call RegisterClassExA
    test eax, eax
    jnz  .reg_ok
    call GetLastError
    cmp  eax, ERROR_CLASS_ALREADY_EXISTS
    je   .reg_ok
    lea  rcx, [log_reg_fail]
    call gui_log_last_error
    jmp  .reg_done
.reg_ok:
    lea  rcx, [log_init_ok]
    call gui_log_write
.reg_done:
    mov  rsp, rbp
    pop  rbp
    ret
gui_window_create:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    and  rsp, -16
    sub  rsp, 128
    mov  rsi, rcx
    mov  ebx, edx
    mov  edi, r8d
    mov  r12d, r9d
    mov  r13d, [rbp+48]
    test rsi, rsi
    jnz  .title_ok
    lea  rsi, [g_default_title]
.title_ok:
    xor  ecx, ecx
    lea  rdx, [g_classname]
    mov  r8, rsi
    mov  r9d, WS_OVERLAPPEDWINDOW | WS_VISIBLE
    mov  dword [rsp+32], r12d
    mov  dword [rsp+40], r13d
    mov  dword [rsp+48], ebx
    mov  dword [rsp+56], edi
    mov  qword [rsp+64], 0
    mov  qword [rsp+72], 0
    mov  rax, [g_hinstance]
    mov  [rsp+80], rax
    mov  qword [rsp+88], 0
    call CreateWindowExA
    mov  [g_hwnd], rax
    mov  rbx, rax
    test rbx, rbx
    jnz  .win_ok
    lea  rcx, [log_win_fail]
    call gui_log_last_error
    xor  rax, rax
    jmp  .win_out
.win_ok:
    lea  rcx, [log_win_create]
    call gui_log_write
    mov  rcx, rbx
    mov  edx, SW_SHOWDEFAULT
    call ShowWindow
    mov  rcx, rbx
    call UpdateWindow
    mov  rax, rbx
.win_out:
    lea  rsp, [rbp-40]
    pop  r13
    pop  r12
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
gui_window_get:
    mov  rax, [g_hwnd]
    ret
gui_get_hinstance:
    mov  rax, [g_hinstance]
    ret
gui_get_hfont:
    mov  rax, [g_hfont]
    ret
gui_get_hfont_title:
    mov  rax, [g_hfont_title]
    ret
gui_run:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 32
.loop:
    lea  rcx, [g_msg]
    xor  edx, edx
    xor  r8d, r8d
    xor  r9d, r9d
    call GetMessageA
    cmp  eax, -1
    je   .gerr
    test eax, eax
    jle  .done
    lea  rcx, [g_msg]
    call TranslateMessage
    lea  rcx, [g_msg]
    call DispatchMessageA
    jmp  .loop
.gerr:
    lea  rcx, [log_getmsg_fail]
    call gui_log_last_error
    jmp  .done
.done:
    lea  rcx, [log_loop_end]
    call gui_log_write
    mov  rsp, rbp
    pop  rbp
    ret
gui_quit:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    xor  ecx, ecx
    call PostQuitMessage
    mov  rsp, rbp
    pop  rbp
    ret
gui_shutdown:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  rcx, [g_hfont_title]
    test rcx, rcx
    jz   .f1
    call DeleteObject
    mov  qword [g_hfont_title], 0
.f1:
    mov  rcx, [g_hfont]
    test rcx, rcx
    jz   .ok
    call DeleteObject
    mov  qword [g_hfont], 0
.ok:
    call gui_log_shutdown
    mov  rsp, rbp
    pop  rbp
    ret
gui_on_command:
    mov  eax, [g_cmd_count]
    cmp  eax, GUI_MAX_HANDLERS
    jae  .full
    mov  r8d, eax
    shl  r8d, 4
    lea  r9, [g_cmd_table]
    add  r9, r8
    mov  dword [r9], ecx
    mov  qword [r9+8], rdx
    inc  dword [g_cmd_count]
.full:
    ret
gui_on_paint:
    mov  [g_paint_fn], rcx
    ret
gui_on_close:
    mov  [g_close_fn], rcx
    ret
gui_on_timer:
    mov  [g_timer_fn], rcx
    ret
gui_on_keydown:
    mov  [g_keydown_fn], rcx
    ret
gui_on_mousemove:
    mov  [g_mousemove_fn], rcx
    ret
gui_on_lbutton:
    mov  [g_lbutton_fn], rcx
    ret
gui_msgbox:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  r8, rdx
    mov  rdx, rcx
    mov  rcx, [g_hwnd]
    test r8, r8
    jnz  .has
    lea  r8, [g_default_title]
.has:
    mov  r9d, MB_OK | MB_ICONINFORMATION
    call MessageBoxA
    mov  rsp, rbp
    pop  rbp
    ret
gui_msgbox_ex:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  r9d, r8d
    mov  r8, rdx
    mov  rdx, rcx
    mov  rcx, [g_hwnd]
    call MessageBoxA
    mov  rsp, rbp
    pop  rbp
    ret
gui_register_hwnd:
    cmp  ecx, 127
    ja   .skip
    lea  rax, [g_id_hwnd]
    mov  [rax+rcx*8], rdx
.skip:
    ret
gui_get_hwnd_by_id:
    cmp  ecx, 127
    ja   .bad
    lea  rax, [g_id_hwnd]
    mov  rax, [rax+rcx*8]
    ret
.bad:
    xor  eax, eax
    ret
gui_apply_font:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  rdx, WM_SETFONT
    mov  r8, [g_hfont]
    mov  r9d, 1
    test rcx, rcx
    jz   .skip
    call SendMessageA
.skip:
    mov  rsp, rbp
    pop  rbp
    ret
gui_set_text:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rdx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .done
    mov  rcx, rax
    mov  rdx, rsi
    call SetWindowTextA
.done:
    add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_get_text:
    push rbp
    mov  rbp, rsp
    push rsi
    push rdi
    and  rsp, -16
    sub  rsp, 48
    mov  rsi, rdx
    mov  edi, r8d
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .fail
    mov  rcx, rax
    mov  rdx, rsi
    mov  r8d, edi
    call GetWindowTextA
    jmp  .done
.fail:
    xor  eax, eax
.done:
    add  rsp, 48
    pop  rdi
    pop  rsi
    pop  rbp
    ret
gui_enable:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  esi, edx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .done
    mov  rcx, rax
    mov  edx, esi
    call EnableWindow
.done:
    add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_show:
    push rbp
    mov  rbp, rsp
    push rsi
    and  rsp, -16
    sub  rsp, 48
    mov  esi, edx
    call gui_get_hwnd_by_id
    test rax, rax
    jz   .done
    mov  rcx, rax
    mov  edx, SW_HIDE
    test esi, esi
    jz   .go
    mov  edx, SW_SHOW
.go:
    call ShowWindow
.done:
    add  rsp, 48
    pop  rsi
    pop  rbp
    ret
gui_set_focus:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    call gui_get_hwnd_by_id
    mov  rcx, rax
    call SetFocus
    mov  rsp, rbp
    pop  rbp
    ret
gui_invalidate:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    test ecx, ecx
    jz   .main
    call gui_get_hwnd_by_id
    jmp  .do
.main:
    mov  rax, [g_hwnd]
.do:
    mov  rcx, rax
    xor  edx, edx
    mov  r8d, 1
    call InvalidateRect
    mov  rsp, rbp
    pop  rbp
    ret
gui_set_timer:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  r8d, edx
    mov  edx, ecx
    mov  rcx, [g_hwnd]
    xor  r9, r9
    call SetTimer
    mov  rsp, rbp
    pop  rbp
    ret
gui_kill_timer:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    mov  edx, ecx
    mov  rcx, [g_hwnd]
    call KillTimer
    mov  rsp, rbp
    pop  rbp
    ret
WndProc:
    push rbp
    mov  rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    and  rsp, -16
    sub  rsp, 64
    mov  rbx, rcx
    mov  esi, edx
    mov  rdi, r8
    mov  r12, r9
    cmp  esi, WM_COMMAND
    je   .command
    cmp  esi, WM_PAINT
    je   .paint
    cmp  esi, WM_CLOSE
    je   .close
    cmp  esi, WM_DESTROY
    je   .destroy
    cmp  esi, WM_TIMER
    je   .timer
    cmp  esi, WM_KEYDOWN
    je   .keydown
    cmp  esi, WM_MOUSEMOVE
    je   .mousemove
    cmp  esi, WM_LBUTTONDOWN
    je   .lbutton
.def:
    mov  rcx, rbx
    mov  edx, esi
    mov  r8, rdi
    mov  r9, r12
    call DefWindowProcA
    jmp  .leave
.command:
    mov  eax, edi
    movzx eax, ax
    mov  ecx, [g_cmd_count]
    test ecx, ecx
    jz   .def
    lea  rsi, [g_cmd_table]
.scan:
    cmp  dword [rsi], eax
    je   .hit
    add  rsi, 16
    dec  ecx
    jnz  .scan
    jmp  .def
.hit:
    mov  rax, [rsi+8]
    test rax, rax
    jz   .zero
    sub  rsp, 48
    call rax
    add  rsp, 48
.zero:
    xor  eax, eax
    jmp  .leave
.paint:
    mov  rax, [g_paint_fn]
    test rax, rax
    jz   .def
    mov  rcx, rbx
    lea  rdx, [g_ps]
    call BeginPaint
    test rax, rax
    jnz  .paint_ok
    lea  rcx, [log_paint_hdc]
    call gui_log_last_error
    xor  eax, eax
    jmp  .leave
.paint_ok:
    mov  rcx, rax
    mov  rax, [g_paint_fn]
    sub  rsp, 48
    call rax
    add  rsp, 48
    mov  rcx, rbx
    lea  rdx, [g_ps]
    call EndPaint
    xor  eax, eax
    jmp  .leave
.close:
    lea  rcx, [log_wm_close]
    call gui_log_write
    mov  rax, [g_close_fn]
    test rax, rax
    jz   .do_destroy
    sub  rsp, 48
    call rax
    add  rsp, 48
    test eax, eax
    jnz  .cancel
.do_destroy:
    mov  rcx, rbx
    call DestroyWindow
.cancel:
    xor  eax, eax
    jmp  .leave
.destroy:
    lea  rcx, [log_wm_destroy]
    call gui_log_write
    xor  ecx, ecx
    call PostQuitMessage
    xor  eax, eax
    jmp  .leave
.timer:
    mov  rax, [g_timer_fn]
    test rax, rax
    jz   .def
    mov  ecx, edi
    sub  rsp, 48
    call rax
    add  rsp, 48
    xor  eax, eax
    jmp  .leave
.keydown:
    mov  rax, [g_keydown_fn]
    test rax, rax
    jz   .def
    mov  ecx, edi
    sub  rsp, 48
    call rax
    add  rsp, 48
    xor  eax, eax
    jmp  .leave
.mousemove:
    mov  rax, [g_mousemove_fn]
    test rax, rax
    jz   .def
    mov  ecx, r12d
    movsx edx, cx
    shr  ecx, 16
    movsx r8d, cx
    mov  ecx, edx
    mov  edx, r8d
    sub  rsp, 48
    call rax
    add  rsp, 48
    xor  eax, eax
    jmp  .leave
.lbutton:
    mov  rax, [g_lbutton_fn]
    test rax, rax
    jz   .def
    mov  ecx, r12d
    movsx edx, cx
    shr  ecx, 16
    movsx r8d, cx
    mov  ecx, edx
    mov  edx, r8d
    sub  rsp, 48
    call rax
    add  rsp, 48
    xor  eax, eax
.leave:
    lea  rsp, [rbp-32]
    pop  r12
    pop  rdi
    pop  rsi
    pop  rbx
    pop  rbp
    ret
