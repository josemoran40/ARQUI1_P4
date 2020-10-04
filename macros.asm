
;--------------------------------------------------- IMPRMIR ---------------------------------------------
print macro cadena 
 LOCAL ETIQUETA 
 ETIQUETA: 
	MOV ah,09h 
	MOV dx,@data
	MOV ds,dx 
	MOV dx, offset cadena
	int 21h 
endm

getChar macro
    mov ah,01h
    int 21h
endm


getTexto macro buffer
    LOCAL CONTINUE, FIN
    PUSH SI
    PUSH AX

    xor si,si
    CONTINUE:
    getChar
    cmp al,0dh
    je FIN
    mov buffer[si],al
    inc si
    jmp CONTINUE

    FIN:
    mov al,'$'
    mov buffer[si],al
    POP AX
    POP SI
endm

;-------------------------------------------------- ANALIZADOR LEXICO -----------------------------------------------------

analizarArchivo macro buffer
	LOCAL CICLO, verSuma, analizar, omitir, fin
	xor si, si
	mov si,0
	getTexto rutaIngresada
	abrirArchivo rutaIngresada, handleCarga
	leerArchivo 3000, buffer, handleCarga
	print buffer
	CICLO:
		cmp buffer[si],'"'
		je analizar
		jmp omitir
	analizar:
		limpiarCadena bufferCadena,30
		copiarTexto bufferCadena, buffer
	
	verSuma:
		compararCadenas bufferCadena, suma, igual
		cmp igual, '0'
		je omitir
		print suma

	omitir:
		cmp buffer[si],'$'
		je fin
	
	inc si
	jmp CICLO
	fin:	
	
endm 

limpiarCadena macro buffer, length
	LOCAL CICLO
	push cx
	push di
	xor cx,cx
	mov cx, length
	xor di, di
	mov di,0
	CICLO:
		mov buffer[si],'$'
	LOOP CICLO
	pop di
	pop cx			
endm


copiarTexto macro buffer,lectura
	LOCAL mientras, salir
	push di
	xor di, di
	mov di, 0
	inc si
	mientras:
		cmp lectura[si],'"'
		je salir
		mov al, lectura[si]
		mov buffer[di], al

		inc si
		inc di
	jmp mientras

	salir:
	pop di
endm



compararCadenas macro cadena1,cadena2,bandera
	LOCAL comp,fin,igual
	push di
	push bx
	mov bandera[0],'0'
	xor di,di
	sub di,1
	comp:
		inc di
		cmp cadena1[di],'$'
		je igual1
		cmp cadena2[di],'$'
		je igual2
		mov bl,cadena2[di]
		cmp cadena1[di],bl
		je comp
		jmp fin
	igual1:
		cmp cadena2[di],'$'
		jne fin
		mov bandera[0],'1'
		jmp fin
	igual2:
		cmp cadena1[di],'$'
		jne fin
		mov bandera[0],'1'
	fin:
	pop bx
	pop di
endm


;------------------------------------------------ MANEJO DE ARCHIVOS ---------------------------------------------------------
abrirArchivo macro ruta,handle
    mov ah,3dh
    mov al,10b
    lea dx,ruta
    int 21h
    mov handle,ax
    ;jc ErrorAbrir
endm


leerArchivo macro numbytes, buffer, handle
    PUSH cx
    leer numbytes, buffer, handle
    POP cx
endm
leer macro numbytes,buffer,handle
    mov ah,3fh
    mov bx,handle
    mov cx,numbytes
    lea dx,buffer
    int 21h
    jc ErrorLeer
endm

closefile macro handler
    LOCAL Inicio
    xor ax, ax
    Inicio:
        mov ah, 3eh
        mov bx, handler
        int 21h
        jc CloseError
endm


