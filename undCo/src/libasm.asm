GLOBAL  _read_msw,_lidt
GLOBAL  _int_08_hand
GLOBAL  _int_80_hand
GLOBAL  _int_09_hand
GLOBAL  _IO_in
GLOBAL	_IO_out
GLOBAL  __write
GLOBAL  __read
GLOBAL  __hour
GLOBAL  __min
GLOBAL  _mascaraPIC1,_mascaraPIC2,_Cli,_Sti
GLOBAL  _debug

EXTERN  int_08
EXTERN  int_09
EXTERN  int_80


SECTION .text


_Cli:
	cli			; limpia flag de interrupciones
	ret

_Sti:

	sti			; habilita interrupciones por flag
	ret

_mascaraPIC1:			; Escribe mascara del PIC 1
	push    ebp
        mov     ebp, esp
        mov     ax, [ss:ebp+8]  ; ax = mascara de 16 bits
        out	21h,al
        pop     ebp
        retn

_mascaraPIC2:			; Escribe mascara del PIC 2
	push    ebp
        mov     ebp, esp
        mov     ax, [ss:ebp+8]  ; ax = mascara de 16 bits
        out	0A1h,al
        pop     ebp
        retn

_read_msw:
        smsw    ax		; Obtiene la Machine Status Word
        retn


_lidt:				; Carga el IDTR
        push    ebp
        mov     ebp, esp
        push    ebx
        mov     ebx, [ss: ebp + 6] ; ds:bx = puntero a IDTR 
	rol	ebx,16		    	
	lidt    [ds: ebx]          ; carga IDTR
        pop     ebx
        pop     ebp
        retn


_int_08_hand:				; Handler de INT 8 ( Timer tick)
        push    ds
        push    es                      ; Se salvan los registros
        pusha                           ; Carga de DS y ES con el valor del selector
        mov     ax, 10h			; a utilizar.
        mov     ds, ax
        mov     es, ax                  
        call    int_08                 
        mov	al,20h			; Envio de EOI generico al PIC
	out	20h,al
	popa                            
        pop     es
        pop     ds
        iret

_int_80_hand:				; Handler de INT 80 ( System calls)
        push ebp
		mov ebp,esp
                             ; Se salvan los registros
        pusha                           ; Carga de DS y ES con el valor del selector

        call    int_80

		mov esp,ebp
		pop ebp
          
        iret
        
_int_09_hand:				; Handler de INT 09 (Teclado)
        push ebp
		mov ebp,esp
		pusha 

        call    int_09
		mov	al,20h			; Envio de EOI generico al PIC
		out	20h,al
		
		popa
		mov esp,ebp
		pop ebp
		
		
          
        iret
        
;SYSTEM CALLS

__write:
	mov ecx, [esp+8]
	mov ebx, 1
	int 080h
	ret

__read:
	mov ecx, [esp+8]
	mov ebx, 2
	int 080h
	ret
	
__hour:
	mov ecx, [esp+4]
	mov ebx, 3
	int 080h
	ret
	
__min:
	mov ecx, [esp+4]
	mov ebx, 4
	int 080h
	ret

_IO_in:
	mov dx, [esp+4]
	in al, dx
	ret
	
_IO_out:
	mov al, [esp+8]
	mov dx, [esp+4]
	out dx,al
	ret

; Debug para el BOCHS, detiene la ejecució; Para continuar colocar en el BOCHSDBG: set $eax=0
;


_debug:
        push    bp
        mov     bp, sp
        push	ax
vuelve:	mov     ax, 1
        cmp	ax, 0
	jne	vuelve
	pop	ax
	pop     bp
        retn