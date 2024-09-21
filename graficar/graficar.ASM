format PE GUI 4.0
entry start

include 'win32a.inc'
include 'opengl.inc'

section '.data' data readable writeable
  _title db 'OpenGL Rectangles', 0
  _class db 'FASMOPENGL32', 0

  wc WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, NULL, NULL, _class
  hwnd dd ?
  hdc dd ?
  hrc dd ?

  msg MSG
  rc RECT
  pfd PIXELFORMATDESCRIPTOR

section '.text' code readable executable

start:
    invoke GetModuleHandle, 0
    mov [wc.hInstance], eax
    invoke LoadIcon, 0, IDI_APPLICATION
    mov [wc.hIcon], eax
    invoke LoadCursor, 0, IDC_ARROW
    mov [wc.hCursor], eax
    invoke RegisterClass, wc
    invoke CreateWindowEx, 0, _class, _title, WS_VISIBLE + WS_OVERLAPPEDWINDOW + WS_CLIPCHILDREN + WS_CLIPSIBLINGS, 100, 100, 800, 600, NULL, NULL, [wc.hInstance], NULL
    mov [hwnd], eax

msg_loop:
    invoke GetMessage, msg, NULL, 0, 0
    or eax, eax
    jz end_loop
    invoke TranslateMessage, msg
    invoke DispatchMessage, msg
    jmp msg_loop

end_loop:
    invoke ExitProcess, [msg.wParam]

proc WindowProc hwnd, wmsg, wparam, lparam
    push ebx esi edi
    cmp [wmsg], WM_CREATE
    je .wmcreate
    cmp [wmsg], WM_SIZE
    je .wmsize
    cmp [wmsg], WM_PAINT
    je .wmpaint
    cmp [wmsg], WM_DESTROY
    je .wmdestroy
  .defwndproc:
    invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
    jmp .finish
  .wmcreate:
    invoke GetDC, [hwnd]
    mov [hdc], eax
    mov edi, pfd
    mov ecx, sizeof.PIXELFORMATDESCRIPTOR shr 2
    xor eax, eax
    rep stosd
    mov [pfd.nSize], sizeof.PIXELFORMATDESCRIPTOR
    mov [pfd.nVersion], 1
    mov [pfd.dwFlags], PFD_SUPPORT_OPENGL + PFD_DOUBLEBUFFER + PFD_DRAW_TO_WINDOW
    mov [pfd.iLayerType], PFD_MAIN_PLANE
    mov [pfd.iPixelType], PFD_TYPE_RGBA
    mov [pfd.cColorBits], 16
    mov [pfd.cDepthBits], 16
    mov [pfd.cAccumBits], 0
    mov [pfd.cStencilBits], 0
    invoke ChoosePixelFormat, [hdc], pfd
    invoke SetPixelFormat, [hdc], eax, pfd
    invoke wglCreateContext, [hdc]
    mov [hrc], eax
    invoke wglMakeCurrent, [hdc], [hrc]
    invoke GetClientRect, [hwnd], rc
    invoke glViewport, 0, 0, [rc.right], [rc.bottom]

    ; Establecer el color de fondo
    invoke glClearColor, 0.0, 0.0, 0.0, 1.0

    xor eax, eax
    jmp .finish
  .wmsize:
    invoke GetClientRect, [hwnd], rc
    invoke glViewport, 0, 0, [rc.right], [rc.bottom]
    xor eax, eax
    jmp .finish



  .wmpaint:
    ; Limpiar el buffer de color
    invoke glClear, GL_COLOR_BUFFER_BIT
    invoke glLoadIdentity

    ; Dibujar 10 rectángulos con posiciones fijas
    invoke glColor3f, 0.0, 1.0, 0.0 ; Establecer color a verde
    invoke glBegin, GL_QUADS


     ; Rectángulo 1 (más alto)
    invoke glVertex2f, -0.95, -0.8
    invoke glVertex2f, -0.85, -0.8
    invoke glVertex2f, -0.85, -0.4
    invoke glVertex2f, -0.95, -0.4

    ; Rectángulo 2 (más bajo)
    invoke glVertex2f, -0.75, -0.8
    invoke glVertex2f, -0.65, -0.8
    invoke glVertex2f, -0.65, -0.7
    invoke glVertex2f, -0.75, -0.7

    ; Rectángulo 3 (altura estándar)
    invoke glVertex2f, -0.55, -0.8
    invoke glVertex2f, -0.45, -0.8
    invoke glVertex2f, -0.45, -0.6
    invoke glVertex2f, -0.55, -0.6

    ; Rectángulo 4 (más alto)
    invoke glVertex2f, -0.35, -0.8
    invoke glVertex2f, -0.25, -0.8
    invoke glVertex2f, -0.25, -0.3
    invoke glVertex2f, -0.35, -0.3

    ; Rectángulo 5 (más bajo)
    invoke glVertex2f, -0.15, -0.8
    invoke glVertex2f, -0.05, -0.8
    invoke glVertex2f, -0.05, -0.7
    invoke glVertex2f, -0.15, -0.7

    ; Rectángulo 6 (altura estándar)
    invoke glVertex2f, 0.05, -0.8
    invoke glVertex2f, 0.15, -0.8
    invoke glVertex2f, 0.15, -0.6
    invoke glVertex2f, 0.05, -0.6

    ; Rectángulo 7 (más alto)
    invoke glVertex2f, 0.25, -0.8
    invoke glVertex2f, 0.35, -0.8
    invoke glVertex2f, 0.35, -0.3
    invoke glVertex2f, 0.25, -0.3

    ; Rectángulo 8 (más bajo)
    invoke glVertex2f, 0.45, -0.8
    invoke glVertex2f, 0.55, -0.8
    invoke glVertex2f, 0.55, -0.7
    invoke glVertex2f, 0.45, -0.7

    ; Rectángulo 9 (altura estándar)
    invoke glVertex2f, 0.65, -0.8
    invoke glVertex2f, 0.75, -0.8
    invoke glVertex2f, 0.75, -0.6
    invoke glVertex2f, 0.65, -0.6

    ; Rectángulo 10 (más alto)
    invoke glVertex2f, 0.85, -0.8
    invoke glVertex2f, 0.95, -0.8
    invoke glVertex2f, 0.95, -0.4
    invoke glVertex2f, 0.85, -0.4

    invoke glEnd

    ; Intercambiar buffers para mostrar
    invoke SwapBuffers, [hdc]




    invoke ValidateRect, [hwnd], 0  ; Validar rectángulo para evitar llamadas continuas a WM_PAINT
    xor eax, eax
    jmp .finish






  .wmdestroy:
    invoke wglMakeCurrent, 0, 0
    invoke wglDeleteContext, [hrc]
    invoke ReleaseDC, [hwnd], [hdc]
    invoke PostQuitMessage, 0
    xor eax, eax
  .finish:
    pop edi esi ebx
    ret
endp

section '.idata' import data readable writeable
  library kernel, 'KERNEL32.DLL',\
          user, 'USER32.DLL',\
          gdi, 'GDI32.DLL',\
          opengl, 'OPENGL32.DLL'
  import kernel,\
         GetModuleHandle, 'GetModuleHandleA',\
         ExitProcess, 'ExitProcess'
  import user,\
         RegisterClass, 'RegisterClassA',\
         CreateWindowEx, 'CreateWindowExA',\
         DefWindowProc, 'DefWindowProcA',\
         GetMessage, 'GetMessageA',\
         TranslateMessage, 'TranslateMessage',\
         DispatchMessage, 'DispatchMessageA',\
         LoadCursor, 'LoadCursorA',\
         LoadIcon, 'LoadIconA',\
         GetClientRect, 'GetClientRect',\
         GetDC, 'GetDC',\
         ReleaseDC, 'ReleaseDC',\
         PostQuitMessage, 'PostQuitMessage',\
         ValidateRect, 'ValidateRect'
  import gdi,\
         ChoosePixelFormat, 'ChoosePixelFormat',\
         SetPixelFormat, 'SetPixelFormat',\
         SwapBuffers, 'SwapBuffers'
  import opengl,\
         wglCreateContext, 'wglCreateContext',\
         wglMakeCurrent, 'wglMakeCurrent',\
         wglDeleteContext, 'wglDeleteContext',\
         glBegin, 'glBegin',\
         glEnd, 'glEnd',\
         glVertex2f, 'glVertex2f',\
         glColor3f, 'glColor3f',\
         glClear, 'glClear',\
         glClearColor, 'glClearColor',\
         glLoadIdentity, 'glLoadIdentity',\
         glViewport, 'glViewport'
