# GuiASM [ Help AI for include ]

Petite bibliothèque GUI pour Windows x64, écrite en NASM. Pas de runtime C++ : tu `%include "gui.inc"`, tu lies les `.obj` du projet, tu obtiens une fenêtre Win32 classique (user32 + gdi32).

Cible : apps perso, prototypes, ou cours ASM où tu veux une vraie fenêtre sans remonter toute la plomberie Win32 à la main.

## Prérequis

| Outil | Rôle |
|-------|------|
| NASM 2.16+ | Assembleur (binaire fourni dans `tools/nasm-2.16.03/`) |
| MinGW-w64 `gcc` | Link `-mwindows` |

Windows 64 bits uniquement. Convention d’appel **Microsoft x64**.

## Build

À la racine du dépôt :

```bat
build.bat
```

Produit `bin\demo.exe` et `bin\minimal.exe`. Les objets vont dans `obj\`.

## Exemple minimal

Voir `examples/minimal.asm`. Schéma type :

```asm
default rel
bits 64
%include "gui.inc"

section .data
    title db "Mon App", 0
    lbl   db "Hello", 0
    btn   db "OK", 0

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

on_ok:
    push rbp
    mov  rbp, rsp
    and  rsp, -16
    sub  rsp, 48
    GUI_MSGBOX lbl, title
    call gui_quit
    mov  rsp, rbp
    pop  rbp
    ret
```

Démo plus complète (peinture GDI, plusieurs contrôles) : `examples/demo.asm`.

### Lier ton propre `.asm`

Même liste d’objets que `build.bat` :

```bat
nasm -f win64 -Iinclude\ -o obj\app.obj app.asm
gcc -mwindows -o bin\app.exe obj\app.obj obj\gui_core.obj obj\gui_widgets.obj obj\gui_draw.obj obj\gui_log.obj -luser32 -lgdi32 -lkernel32
```

## Pile (important)

Win64 exige une pile alignée sur **16 octets** avant chaque `call` vers une API système. Au début de `main`, utilise **`GUI_MAIN_ENTER`** (défini dans `gui.inc`). Les handlers (`WM_COMMAND`, `WM_PAINT`, etc.) doivent faire la même chose : `push rbp` / `and rsp, -16` / shadow 32+ octets, ou tu risques un crash opaque (`0xC0000005`).

Les macros `GUI_BUTTON`, `GUI_LABEL`, … gèrent déjà l’alignement côté appelant.

## API en bref

**Macros** (le plus courant) : `GUI_INIT`, `GUI_WINDOW`, `GUI_RUN`, `GUI_SHUTDOWN`, `GUI_QUIT`, widgets (`GUI_BUTTON`, `GUI_LABEL`, `GUI_EDIT`, `GUI_CHECKBOX`, `GUI_GROUPBOX`, `GUI_LISTBOX`, `GUI_COMBOBOX`), `GUI_ON`, `GUI_ON_PAINT`, `GUI_ON_CLOSE`, `GUI_MSGBOX`, `GUI_LOG`.

**Fonctions** (quand tu as besoin de plus de contrôle) : `gui_window_create`, `gui_set_text` / `gui_get_text`, `gui_fill_rect`, `gui_draw_text`, listes/combos (`gui_list_add`, `gui_combo_add`, …), timers et clavier via `gui_on_timer`, `gui_on_keydown`.

Référence complète : symboles `extern` et macros dans `include/gui.inc`, constantes Win32 dans `include/winconst.inc`.

## Log

`call gui_log_init` en tête de `main` → fichier **`guiasm.log`** à côté de l’exe (souvent `bin\` si tu lances depuis là). Utile : `GUI_LOG`, `gui_log_last_error` après un appel raté. Le filtre d’exception (`gui_log_install_filter`) est optionnel.

## Arborescence

```
include/          gui.inc, winconst.inc
src/              gui_core.asm, gui_widgets.asm, gui_draw.asm, gui_log.asm
examples/         demo.asm, minimal.asm
build.bat
tools/nasm-2.16.03/
bin/  obj/        générés au build
```

## Licence

[MIT](LICENSE) — utilisation, modification et redistribution libres, avec conservation du copyright.

NASM (si tu l’ajoutes dans `tools/`) reste sous sa propre licence : [NASM LICENSE](https://www.nasm.us/doc/nasmdoc.html).
