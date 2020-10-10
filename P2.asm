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
 msmError5 db 0ah,0dh,'Error al abrir archivo','$'
 msmError6 db 0ah,0dh,'Error al cerrar el archivo','$'
 igual db '0','$'
 actual db 0,'$'
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
 bufferNombre db 30 dup('$')
 bufferID db 30 dup('$')
 rutaIngresada db 200 dup(0),0
 rutaArchivo db 'input.json',00h
 saltoLinea db 0ah,0dh,'$'
 llaveAbre db '{','$'
 llaveCierra db '}','$'
 contadorLlave db 0,'$'
 imprimir db 'x','$' 
 numeros db '$$$$$$','$'
 preorder dw 300 dup('$')
 left dw 1 dup('$')
 rigth dw 1 dup('$')
 which db '0','$'
 entra db 'entra','$'
 signo db '0','$'
 signo1 db '0','$'
 signo2 db '0','$'
 numeral db '#','$'
 estado db '0', '$'
 separador db '--------------------','$'
 operadas db 600 dup('$')
 resultados dw 30 dup('$')
 actResul db 0, '$'
 mediana db 'mediana: ','$'
 menor db 'menor: ','$'
 mayor db 'mayor: ','$'
 media db 'media: ','$'
 negarmedia db '0','$'
 pos db 0
; ------------------------------------------ REPORTE --------------------------------------------
reporteNombre db 'reporte.jso',00h
handleReporte dw ?
 cabeceraReporte1 db '{',0ah,0dh,09h,'"reporte":','{',0ah,0dh,09h,09h,'"alumno":','{',0ah,0dh,09h,09h,09h,'"nombre":"JOSE EDUARDO MORAN REYES",'
 cabeceraReporte2 db 0ah,0dh,09h,09h,09h,'"Carnet":"201807455",',0ah,0dh,09h,09h,09h,'"Seccion":"A",',0ah,0dh,09h,09h,09h,'"Curso":"ARQUITECTURA DE COMPUTADORES Y COMPILADORES 1"'
 caberecaReporte3 db 0ah,0dh,09h,09h,'}',0ah,0dh,09h,09h,'"fecha":{'
 dia db 0ah,0dh,09h,09h,09h,'"dia":  ,'
 mes db 0ah,0dh,09h,09h,09h,'"mes":  ,'
 anio db 0ah,0dh,09h,09h,09h,'"año":  '
 caberecaReporte4 db 0ah,0dh,09h,09h,'}',0ah,0dh,09h,09h,'"hora":{'
 hora db 0ah,0dh,09h,09h,09h,'"Hora":  ,'
 min db 0ah,0dh,09h,09h,09h,'"Min":  ,'
 segu db 0ah,0dh,09h,09h,09h,'"Seg":  '
 caberecaReporte5 db 0ah,0dh,09h,09h,'}',0ah,0dh,09h,09h,'"operaciones":{',0ah,0dh,09h,09h,09h
 caberecaReporte6 db 0ah,0dh,09h,09h,'}'
 caberecaReporte7 db 0ah,0dh,09h,09h,'}',0ah,0dh,09h,'}',0ah,0dh,'}'
 caberecaReporte8 db 0ah,0dh,09h,09h,'"estadisticos":{',0ah,0dh,09h,09h,09h
 saltoYtab db 0ah,0dh,09h,09h,09h

handleCarga dw ?
handleFichero dw ?
 bufferFecha db 12 dup('-')
 bufferHora db 8 dup(':') 

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
                print saltoLinea
                analizarArchivo bufferJSON
                generarReporte
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
            
	        ErrorAbrir:
	    	print msmError5
	    	jmp MENU

            
            CloseError:
            print msmError6
	    	getChar
            jmp MENU  
            SALIR: 
			MOV ah,4ch
			int 21h


    main endp
end
