include macros.asm

;------------------------ MAIN------------------------------------------------------

.model small
.stack 100h 
.data

 intro1 db 'UNIVERSIDAD DE SAN CARLOS',0ah,0dh,'FACULTAD DE INGENIERIA',0ah,0dh,'CIENCIAS Y SISTEMAS',0ah,0dh,'$'
 intro2 db 'ARQUITECTURA DE COMPUTADORAS 1',0ah,0dh,'JOSE EDUARDO MORAN REYES',0ah,0dh,'201807455',0ah,0dh,'SECCION A',0ah,0dh,'$'
 opciones db 0ah,0dh,'1) CARGAR ARCHIVO',0ah,0dh,'2) CONSOLA',0ah,0dh,'3) SALIR',0ah,0dh,'$' 
 msmError2 db 0ah,0dh,'Error al leer archivo','$'
 msmError3 db 0ah,0dh,'Error al crear archivo','$'
 msmError4 db 0ah,0dh,'Error al Escribir archivo','$'
 igual db '0','$'
 actual db 0
 suma db 'add','$'
 resta db 'sub','$'
 multi db 'mul','$'
 divi db 'div','$'
 suma1 db '+','$'
 resta1 db '-','$'
 multi1 db '*','$'
 divi1 db '/','$'
 bufferJSON db 3000 dup('$')
 bufferCadena db 30 dup('$')
 rutaIngresada db 200 dup(0),0
 rutaArchivo db 'input.json',00h
 saltoLinea db 0ah,0dh,'$'
 llaveAbre db '{','$'
 llaveCierra db '}','$'
 contadorLlave db 0,'$'
 imprimir db 'x','$' 
 numeros db '$$$$$$','$'
 preorder dw 300 dup('$')
 
handleCarga dw ?
handleFichero dw ?

.code 
    main proc
        print intro1
        print intro2
        MENU:
        print opciones
             getChar
            cmp al,49
            je OPCION1
            cmp al,50
            je OPCION2
            cmp al,51
            je SALIR
            jmp MENU 

            OPCION1:
                print divi
                analizarArchivo bufferJSON
                jmp MENU           
            OPCION2:
                jmp MENU
            
	        ErrorLeer:
	    	print msmError2
	    	getChar
	    	jmp MENU
	        ErrorCrear:
	    	print msmError3
	    	jmp MENU
		    ErrorEscribir:
	    	print msmError4
	    	getChar
	    	jmp MENU   
            SALIR: 
			MOV ah,4ch
			int 21h


    main endp
end
