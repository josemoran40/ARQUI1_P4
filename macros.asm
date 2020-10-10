
;--------------------------------------------------- IMPRMIR ---------------------------------------------
print macro cadena 
 LOCAL ETIQUETA 
 pushear 
 ETIQUETA: 
	MOV ah,09h 
	MOV dx,@data
	MOV ds,dx 
	MOV dx, offset cadena
	int 21h 

popear
endm

getChar macro
    mov ah,01h
    int 21h
endm

printARR macro cadena, idx 
	LOCAL ETIQUETA 
	push si
	ETIQUETA: 
		MOV ah,02h 
		MOV si,idx
		MOV dl, cadena[idx] 
		int 21h
		pop si
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
	LOCAL CICLO, verSuma, analizar, omitir, fin, verResta, restar,verMulti,multiplicar,verDivi, dividir,llaveA,llaveC, numero,negativo, verNumero
	LOCAL estado0, estado1
	xor si, si
	mov si,0
	mov estado[0],'2'
	getTexto rutaIngresada
	abrirArchivo rutaIngresada, handleCarga
	leerArchivo 3000, buffer, handleCarga
	CICLO:


		cmp estado[0], '0'
		je estado0
		cmp estado[0], '1'
		je estado1
		cmp estado[0], '2'
		je estado2
		cmp estado[0], '3'
		je estado3
		estado0:
		cmp buffer[si],'"'
		je analizar
		cmp buffer[si],'{'
		je llaveA
		cmp buffer[si],'}'
		je llaveC
		jmp omitir

		estado3:
		cmp buffer[si],'"'
		je getID
		jmp omitir

		estado2:
		cmp buffer[si],'"'
		je analizar3
		jmp omitir
		estado1:
		cmp buffer[si],'"'
		je analizar2
		cmp buffer[si],'-'
		je negativo
		cmp buffer[si],48
		jb omitir
		cmp buffer[si],57
		ja omitir
		jmp numero




		analizar:
			limpiarCadena bufferCadena,30
			copiarTexto bufferCadena, buffer
		
		verSuma:
			compararCadenas bufferCadena, suma, igual
			cmp igual, '1'
			je sumar 	
			compararCadenas bufferCadena, suma1, igual
			cmp igual, '1'
			je sumar 
		
		verResta:
			compararCadenas bufferCadena, resta, igual
			cmp igual, '1'
			je restar 	
			compararCadenas bufferCadena, resta1, igual
			cmp igual, '1'
			je restar 

		verMulti:
			compararCadenas bufferCadena, multi, igual
			cmp igual, '1'
			je multiplicar 	
			compararCadenas bufferCadena, multi1, igual
			cmp igual, '1'
			je multiplicar
			
		verDivi:
			compararCadenas bufferCadena, divi, igual
			cmp igual, '1'
			je dividir 	
			compararCadenas bufferCadena, divi1, igual
			cmp igual, '1'
			je dividir 
		
		verNumero:
			compararCadenas buffercadena, numeral, igual
			cmp igual,'1'
			je estadoNumero


		jmp omitir

		sumar:
			agregarToken suma1
			aumentarPush
			mov estado[0],'0'
			jmp omitir
		restar:
			agregarToken resta1
			aumentarPush
			mov estado[0],'0'
			jmp omitir

		multiplicar:
			agregarToken multi1
			aumentarPush
			mov estado[0],'0'
			jmp omitir
			
		dividir:
			agregarToken divi1
			aumentarPush
			mov estado[0],'0'
			jmp omitir
		
		llaveA:
			sumarContador
			mov estado[0],'0' 
			jmp omitir
		llaveC:
			restarContador
			mov estado[0],'0' 
			cmp contadorLlave[0], 0
			je realizarOperacion
			jmp omitir
		
		estadoNumero:			
			mov estado[0],'1'
			jmp omitir
		
		analizar2:
			limpiarCadena bufferCadena,30
			limpiarCadena numeros, 5
			copiarTexto bufferCadena, buffer
			buscarNumero 
			toNumber numeros
			agregarNumero
			aumentarPush
			mov estado[0],'0' 
			jmp omitir

		
		analizar3:
			limpiarCadena bufferNombre,30
			copiarTexto bufferNombre, buffer
			mov estado[0],'3' 
			print bufferNombre
			print saltoLinea
			jmp omitir

		getID:
			limpiarCadena bufferID,30
			copiarTexto bufferID, buffer
			mov estado[0],'0' 
			print bufferID
			print saltoLinea
			jmp omitir

		numero:
			limpiarCadena bufferCadena,30
			copiarNumero bufferCadena, buffer, 0
			toNumber bufferCadena
			agregarNumero
			aumentarPush
			mov estado[0],'0'
			jmp omitir
		
		negativo:
			limpiarCadena bufferCadena,30
			push ax
			mov al, buffer[si]
			mov bufferCadena[0], al
			pop ax
			inc si
			copiarNumero bufferCadena, buffer, 1
			toNumber bufferCadena
			limpiarCadena numeros, 4
			pushear
			toString numeros
			popear
			agregarNumero
			aumentarPush
			mov estado[0],'0'
			jmp omitir

		realizarOperacion:
			operar
			agregarOperacion
			toNumber numeros
			agregarResultado
			aumentarResultado
			pushear
			print operadas
			print saltoLinea
			popear
			mov estado[0],'3'
			mov actual[0],0
			limpiarDW preorder,150
		omitir:
			cmp buffer[si],'$'
			je fin
	
	inc si
	jmp CICLO
	fin:	
endm 

agregarToken macro token 
	push ax
	push di
	push bx
	xor di, di
	xor al, al
	xor bx, bx
	mov al, token[0]
	mov ah, '$'
	mov bl, actual[0]
	mov di, bx
	mov preorder[di], ax
	pop bx
	pop di
	pop ax 

endm

agregarNumero macro 
	push di
	push bx
	xor di, di
	xor bx, bx
	mov bl, actual[0]
	mov di, bx
	mov preorder[di], ax
	pushear
	;toString numeros
	;print numeros
	;print saltoLinea
	popear
	pop bx
	pop di
endm

sumarContador macro
	push ax
	xor ax, ax
	mov al, contadorLlave[0]
	add al,1
	mov contadorLlave[0], al
	;add al, 49
	;mov imprimir, al
	;print imprimir
	pop ax

endm


aumentarPush macro 
	push bx
	xor bx, bx
	mov bl, actual[0]
	add bl,2
	mov actual[0], bl
	
	pop bx

endm

aumentarResultado macro 
	push bx
	xor bx, bx
	mov bl, actResul[0]
	add bl,2
	mov actResul[0], bl
	
	pop bx

endm

agregarResultado macro 
	push di
	push bx
	xor di, di
	xor bx, bx
	mov bl, actResul[0]
	mov di, bx
	mov resultados[di], ax
	pushear
	;toString numeros
	;print numeros
	;print saltoLinea
	;print separador
	popear
	pop bx
	pop di
endm

restarContador macro 
	push ax
	xor ax, ax
	mov al, contadorLlave[0]
	sub al,1
	mov contadorLlave[0], al
	;add al, 49
	;mov imprimir, al
	;print imprimir
	pop ax
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
		mov buffer[di],'$'
		inc di
	LOOP CICLO
	pop di
	pop cx			
endm

limpiarDW macro buffer, length
	LOCAL CICLO
	push cx
	push di
	push ax
	xor cx,cx
	mov cx, length
	xor di, di
	mov di,0
	CICLO:
		mov al,'$'
		mov ah,'$'
		mov buffer[di],ax
		inc di
		inc di
	LOOP CICLO
	pop ax
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

copiarNumero macro buffer,lectura, num
	LOCAL mientras, salir
	push di
	xor di, di
	mov di, num
	mientras:
		cmp lectura[si],48
		jb salir
		cmp lectura[si],57
		ja salir
		mov al, lectura[si]
		mov buffer[di], al

		inc si
		inc di
	jmp mientras

	salir:
	dec si
	pop di
endm

compararCadenas macro cadena1,cadena2,bandera
	LOCAL comp,fin,igual1, igual2
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

agregarOperacion macro
LOCAL buscarDolar, encontrado, mientras, addDosPuntos
 pushear 

	xor di, di
	xor cx, cx
	xor si, si
	mov di, 0
	mov cx, 600
	mov si,0
	buscarDolar:
		cmp operadas[di], '$'
		je encontrado
		inc di
		loop buscarDolar
	
	encontrado:
		mov operadas[di],'"'
		inc di
	mientras:
		cmp bufferID[si],'$'
		je addDosPuntos
		mov al, bufferID[si]
		mov operadas[di], al

		inc si
		inc di
	jmp mientras

	addDosPuntos:
		mov operadas[di],'"'
		inc di		
		mov operadas[di],':'
		inc di
		mov si,0
	mientras2:
		cmp numeros[si],'$'
		je fin
		mov al, numeros[si]
		mov operadas[di], al

		inc si
		inc di
	jmp mientras2
	fin:
		mov operadas[di],0ah
		inc di		
		mov operadas[di],0dh
		inc di
 popear
endm

buscarNumero macro
LOCAL buscarSalto,buscarComilla,comparar, comp,igual1,igual2,fin, encontrado,mientras, salir
pushear 

	xor di, di
	xor cx, cx
	xor si, si
	mov di, 0
	mov cx, 600
	mov igual[0],'0'
	
	jmp buscarComilla
	buscarSalto:
		mov igual[0],'0'
		cmp operadas[di], 0ah
		je buscarComilla
		inc di
		loop buscarSalto
		jmp salir

	buscarComilla:
		cmp operadas[di], '"'
		je comparar
		inc di
		loop buscarComilla
		jmp salir
	comparar:
	mov si,-1
	comp:
		inc si
		inc di
		dec cx
		cmp operadas[di],'"'
		je igual1
		cmp bufferCadena[si],'$'
		je igual2
		mov bl,operadas[di]
		cmp bufferCadena[si],bl
		je comp
		jmp fin

	igual1:
		cmp bufferCadena[si],'$'
		jne fin
		mov igual[0],'1'
		jmp fin
	igual2:
		cmp operadas[di],'"'
		jne fin
		mov igual[0],'1'
	fin:
		cmp igual[0],'1'
		je encontrado
		jmp buscarSalto
	
	encontrado:
	inc di
	inc di
	mov si,0
	cmp operadas[di],'-'
	je negativo
	jmp mientras

	negativo:
		mov al, operadas[di]
		mov numeros[si], al
		inc si
		inc di
		mientras:
		cmp operadas[di],48
		jb salir
		cmp operadas[di],57
		ja salir
		mov al, operadas[di]
		mov numeros[si], al

		inc si
		inc di
	jmp mientras

	salir:


popear	

endm

;
;------------------------------------------------- OPERAR --------------------------------------------------------
operar macro
	push si
	push cx
	push ax
	print separador
	print saltoLinea
	xor ax, ax
	xor si, si
	mov si,10
	ejectuar
	mov ax,preorder[0]
	toString numeros
	print numeros
	print saltoLinea
	pop ax
	pop cx
	pop si
endm

ejectuar macro
LOCAL sumar, salir, izquierda, derecha, terminar, reiniciar, seahueva, restar, dividir
	LOCAL INCIO, CICLO, multiplicar, restar, mover, negar
	push  cx
	INCIO:
	mov si, 0
	mov cx, 100
		CICLO: 
			xor dx,dx
			xor ax, ax
			xor bx,bx
			mov dx, preorder[si]
			
			cmp dl ,'$'
			je seahueva
			cmp dl, '-'
			je restar
			cmp dl, '+'
			je sumar
			cmp dl, '*'
			je multiplicar
			cmp dl, '/'
			je dividir
			jmp siguiente

			sumar:
				verficarIz
				cmp which[0],'0'
				je siguiente
				verficarDe
				cmp which[0],'0'
				je siguiente
				mov ax, preorder[si+2]
				mov bx, preorder[si+4]
				add ax,bx
				mov preorder[si], ax
				;toString numeros
				;print numeros
				;print saltoLinea
				jmp reiniciar
			restar:
				verficarIz
				cmp which[0],'0'
				je siguiente
				verficarDe
				cmp which[0],'0'
				je siguiente
				mov ax, preorder[si+2]
				mov bx, preorder[si+4]
				sub ax,bx
				mov preorder[si], ax
				;toString numeros
				;print numeros
				;print saltoLinea
				jmp reiniciar

			multiplicar:
				verficarIz
				cmp which[0],'0'
				je siguiente
				verficarDe
				cmp which[0],'0'
				je siguiente
				mov ax, preorder[si+2]
				mov bx, preorder[si+4]
				mul bx
				mov preorder[si], ax
				;toString numeros
				;print numeros
				;print saltoLinea
				jmp reiniciar

			dividir:
				verficarIz
				cmp which[0],'0'
				je siguiente
				verficarDe
				cmp which[0],'0'
				je siguiente
				push cx
				push dx
				xor cx, cx
				xor ax, ax
				mov ax, preorder[si+2]
				mov cx, preorder[si+4]
				obtenerSigno
				quitarSignoIz
				quitarSignoDe
				xor dx, dx
				mov dx,0
				div cx
				;neg ax
				cmp signo[0],'1'
				je negar
				jmp mover
				negar: 
					neg ax
				
				mover:
				;pushear;
				;toString numeros
				;print numeros
				;print saltoLinea
				;popear
				mov preorder[si], ax
				pop dx
				pop cx
				jmp reiniciar
			siguiente:
				add si,2
				dec cx
			jne CICLO
			jmp terminar
			reiniciar:
				moverTodos
				jmp INCIO
			seahueva:
	terminar:
	pop cx
endm

verficarIz macro
	LOCAL continuar
	push dx
	mov which[0],'0'
	mov dx,preorder[si+2]
	cmp dl,'+'
	je continuar
	cmp dl,'-'
	je continuar
	cmp dl,'*'
	je continuar
	cmp dl,'/'
	je continuar	
	mov which[0],'1'
	continuar:

	pop dx
endm

verficarDe macro
	LOCAL continuar
	push dx
	mov which,'0'
	mov dx,preorder[si+4]
	cmp dl,'+'
	je continuar
	cmp dl,'-'
	je continuar
	cmp dl,'*'
	je continuar	
	cmp dl,'/'
	je continuar
	mov which,'1'

	continuar:

	pop dx
endm

moverTodos macro
	LOCAL CICLO
	push dx
	push cx
	inc si 
	inc si
	CICLO:
		mov dx, preorder[si+4]
		mov preorder[si], dx
		inc si 
		inc si
		;mov dx, si
		;mov imprimir[0],dl
		;print imprimir
		;print multi1
		cmp si,300
		je terminar
		jmp CICLO
	terminar:
	pop cx
	pop dx
endm 
obtenerSigno macro
local negativo, negativo1, negativo2, operador2, comparar, salir
	pushear
	mov signo[0],'0'
	mov signo1[0],'0'
	mov signo2[0],'0'
	test ax,1000000000000000b
	jnz negativo1
	jmp operador2
	negativo1:
		mov signo1[0],'1'

	operador2:
	test cx,1000000000000000b
	jnz negativo2
	jmp comparar
	negativo2:
		mov signo2[0],'1'

	comparar:	
	mov al, signo1[0]
	mov ah, signo2[0]
	cmp al, ah
	jne negativo
	jmp salir
	negativo:
		mov signo[0],'1'
	salir:

	popear

endm


quitarSignoIz macro
	local salir, negativo

	test ax,1000000000000000b
	jnz negativo
	jmp salir
	negativo:
		neg ax
	salir:
endm
quitarSigno macro
	local salir, negativo
	mov negarmedia[0],'0'

	test ax,1000000000000000b
	jnz negativo
	jmp salir
	negativo:
		mov negarmedia[0],'1'
		neg ax
	salir:
endm

quitarSignoDe macro
	local salir, negativo

	test cx,1000000000000000b
	jnz negativo
	jmp salir
	negativo:
		neg cx
	salir:
endm


;------------------------------------------------ MANEJO DE ARCHIVOS ---------------------------------------------------------
abrirArchivo macro ruta,handle
    mov ah,3dh
    mov al,10b
    lea dx,ruta
    int 21h
    mov handle,ax
    jc ErrorAbrir
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


crearArchivo macro buffer,handle
    mov ah,3ch
    mov cx,00h
    lea dx,buffer
    int 21h
    jc ErrorCrear
    mov handle,ax
endm

escribirArchivo macro numbytes,buffer,handle
    pushear
    escribir numbytes,buffer,handle
    popear
endm


escribir macro numbytes,buffer,handle
	mov ah, 40h
	mov bx,handle
	mov cx,numbytes
	lea dx,buffer
	int 21h
	jc ErrorEscribir
endm


;------------------------------------------------ CONVERSIONES ------------------------------------
toNumber macro string
        local inicio, EndGC, NegativeSymbol, Negative
        Push si
        
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        mov bx, 10
        xor si, si
        xor di, di
        ; Check signs
        inicio:
            mov cl, string[si]      
            ; If the ascii is +
            cmp cl, '-'
                je NegativeSymbol
            ; If the ascii is less than the ascii of 0
            cmp cl, 48
                jl EndGC
            ; If the ascii is more than the ascii of 9
            cmp cl, 57
                jg EndGC
            inc si
            sub cl, 48  ; Subtract 48 to get the number
            mul bx      ; Multiply by 10
            add ax, cx

            jmp inicio
        NegativeSymbol:
            inc di            
            inc si
            jmp inicio
        Negative:
            ;TestingAX
            xor di, di
            neg ax
            xor dx, dx
        EndGC:        
            cmp di, 01h
                je Negative
            Pop si
endm

toString macro string
	local Divide, Divide2, EndCr3, Negative, End2, EndGC
        Push si
        xor si, si
        xor cx, cx
        xor bx, bx
        xor dx, dx
        mov dl, 0ah
        test ax, 1000000000000000b
            jnz Negative
        jmp Divide2
        Negative:
            neg ax
            mov string[si], 45
            inc si
            jmp Divide2
        
        Divide:
            xor ah, ah
        Divide2:
            div dl
            inc cx
            Push ax
            cmp al, 00h
                je EndCr3
            jmp Divide
        EndCr3:
            pop ax
            add ah, 30h
            mov string[si], ah
            inc si
        Loop EndCr3
        mov ah, 24h
        mov string[si], ah
        inc si
        EndGC:
            Pop si
endm

    Pushear macro
        push ax
        push bx
        push cx
        push dx
        push si
        push di
    endm

    Popear macro                    
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
endm

;------------------------------------------ REPORTE --------------------------------------------------------
generarReporte macro
	crearArchivo reporteNombre, handleReporte
    abrirArchivo reporteNombre, handleReporte
	escribirArchivo SIZEOF cabeceraReporte1, cabeceraReporte1, handleReporte
	escribirArchivo SIZEOF cabeceraReporte2, cabeceraReporte2, handleReporte
	escribirArchivo SIZEOF caberecaReporte3, caberecaReporte3, handleReporte
	generarFecha bufferhora
	mov ah,bufferhora[0] 
	mov al,bufferhora[1] 
	mov dia[11], ah
	mov dia[12], al
	mov ah,bufferhora[3] 
	mov al,bufferhora[4] 
	mov mes[11], ah
	mov mes[12], al
	mov ah,bufferhora[6] 
	mov al,bufferhora[7] 
	mov anio[12], ah
	mov anio[13], al 
	escribirArchivo SIZEOF dia, dia, handleReporte
	escribirArchivo SIZEOF mes, mes, handleReporte
	escribirArchivo SIZEOF anio, anio, handleReporte
	escribirArchivo SIZEOF caberecaReporte4, caberecaReporte4, handleReporte
	generarHora bufferhora
	mov ah,bufferhora[0] 
	mov al,bufferhora[1] 
	mov hora[12], ah
	mov hora[13], al
	mov ah,bufferhora[3] 
	mov al,bufferhora[4] 
	mov min[11], ah
	mov min[12], al
	mov ah,bufferhora[6] 
	mov al,bufferhora[7] 
	mov segu[11], ah
	mov segu[12], al 
	escribirArchivo SIZEOF hora, hora, handleReporte
	escribirArchivo SIZEOF min, min, handleReporte
	escribirArchivo SIZEOF segu, segu, handleReporte
	escribirArchivo SIZEOF caberecaReporte5, caberecaReporte5, handleReporte
	obtenerIndice
	escribirArchivo di, operadas, handleReporte
	
	escribirArchivo SIZEOF caberecaReporte6, caberecaReporte6, handleReporte
	escribirArchivo SIZEOF caberecaReporte8, caberecaReporte8, handleReporte
	bubbleSort
	calcularMediana
	escribirArchivo SIZEOF mediana-1, mediana, handleReporte
	obtenerIndiceNumero
	escribirArchivo di, numeros, handleReporte
	escribirArchivo SIZEOF saltoYtab, saltoYtab, handleReporte
	calcularMenor
	escribirArchivo SIZEOF menor-1, menor, handleReporte
	obtenerIndiceNumero
	escribirArchivo di, numeros, handleReporte
	escribirArchivo SIZEOF saltoYtab, saltoYtab, handleReporte
	calcularMayor
	escribirArchivo SIZEOF mayor-1, mayor, handleReporte
	obtenerIndiceNumero
	escribirArchivo di, numeros, handleReporte
	escribirArchivo SIZEOF saltoYtab, saltoYtab, handleReporte
	calcularMedia
	escribirArchivo SIZEOF media-1, media, handleReporte
	obtenerIndiceNumero
	escribirArchivo di, numeros, handleReporte
	escribirArchivo SIZEOF caberecaReporte7, caberecaReporte7, handleReporte
	closefile handleReporte
endm 


obtenerIndice macro
	LOCAL mientras, fin
	xor di, di
	mov di,0
	mientras:
		cmp operadas[di],'$'
		je fin
		inc di
		jmp mientras
	fin:
endm

obtenerIndiceNumero macro
	LOCAL mientras, fin
	xor di, di
	mov di,0
	mientras:
		cmp numeros[di],'$'
		je fin
		inc di
		jmp mientras
	fin:
endm
generarFecha macro buffer
    xor ax, ax
    xor bx, bx
    mov ah, 2ah             
    int 21h
    mov di,0
    mov al,dl
    convertirBCD buffer
    inc di           
    mov al, dh
    convertirBCD buffer
    inc di                
    mov buffer[di], 32h
    inc di  
    mov buffer[di], 30h 
    inc di 
    mov buffer[di], 32h
    inc di  
    mov buffer[di], 30h  
endm

generarHora macro buffer
    xor     ax, ax
    xor     bx, bx
    mov     ah, 2ch
    int     21h
    mov     di,0
    mov     al, ch
    convertirBCD buffer
    inc     di  
    mov     al, cl
    convertirBCD buffer
    inc     di
    mov     al, dh
    convertirBCD buffer
endm

convertirBCD macro buffer     
    push dx
    xor dx,dx
    mov dl,al
    xor ax,ax
    mov bl,0ah
    mov al,dl
    div bl
    push ax
    add al,30h
    mov buffer[di], al        
    inc di
    pop ax
    add ah,30h
    mov buffer[di], ah
    inc di
    pop dx
endm


;----------------------------------------- ESTADISTICOS ------------------------------------------------
bubbleSort macro
	LOCAL iloop, oloop, common, CICLO
	pushear
	xor dx, dx
	xor bx, bx
	xor ax, ax
	mov al, actResul[0]
	mov bx,2
	div bx
	xor bx, bx
	mov dx, ax
	mov bx, ax


	dec bx
    oloop:
        mov cx, bx
        mov si, 0
        iloop:
			xor di, di
            mov ax, resultados[si]              
            cmp ax, resultados[si+2]
            jl common                      
        	mov di, resultados[si+2]
			mov resultados[si+2], ax
            mov resultados[si], di                    

            common:
                inc si
				inc si
                loop iloop

        dec dx
        jnz oloop
	inc bx
	mov cx, bx
	xor si, si
	mov si,0
	CICLO:
		mov ax, resultados[si]
		pushear
		toString numeros
		popear
		print numeros
		print saltoLinea  
		inc si
		inc si
		dec cx
		jne CICLO
	

	popear
endm


calcularMediana macro
	local imprimir, mover
	pushear
	xor dx, dx
	xor bx, bx
	xor ax, ax
	mov al, actResul[0]
	mov bx,2
	div bx
	xor di, di
	mov di, ax
	div bx
	cmp dx, 0
	je mover
	sub di,1
	mover:
	print mediana
	mov ax, resultados[di]
	pushear
	toString numeros
	popear
	print numeros
	print saltoLinea
	popear
endm

calcularMenor macro
	pushear
	print menor
	mov ax,  resultados[0]
	pushear
	toString numeros
	popear
	print numeros
	print saltoLinea
	popear
endm

calcularMayor macro
	pushear
	print mayor
	xor ax, ax
	mov al, actResul[0]
	mov di, ax
	sub di,2
	xor ax, ax
	mov ax,  resultados[di]
	pushear
	toString numeros
	popear
	print numeros
	print saltoLinea
	popear
endm

calcularMedia macro
	local CICLO, imprimir
	pushear
	print media
	xor ax, ax
	xor dx, dx
	mov al, actResul[0]
	mov bx, 2
	div bx
	mov di, ax
	mov cx, ax
	xor ax, ax
	mov si, 0
	mov ax, 0
		CICLO:
			mov bx, resultados[si] 
			add ax, bx
			inc si
			inc si
			dec cx
		jne CICLO
	quitarSigno
	xor dx, dx
	mov cx, di
	div cx
	cmp negarmedia[0], '0'
	je imprimir
	neg ax
	imprimir:
	pushear
	toString numeros
	popear
	print numeros
	print saltoLinea
	popear
endm

calcularModa macro

	pushear


	popear
endm

