
format pe64 dll efi
entry main

section '.text' code executable readable


include 'uefi.inc'
;incluir las funciones de E/S de uefi 

main:

	InitializeLib ;inicializar libreria de uefi

	;llamada uefi que sirve para para imprimir en pantalla los mensajes y obtener datos del teclado 
	uefi_call_wrapper ConOut, OutputString, ConOut, bienvenida
	uefi_call_wrapper ConOut, OutputString, ConOut, controles 
	jmp jugar ;iniciar el juego 

jugar:

	;Realiza un reset en la pantalla con los valores iniciales
	uefi_call_wrapper ConIn, Reset, ConIn, 0
	call mover_carros
	call enseñar_pantalla
	call entrada_usuario
	call valor_tecla
	jmp jugar

mover_carro:
	xor eax,eax ;limpiar 
	; Guardar la posicion del carro actual 
	mov eax,[posicion_carro]
	; Añadir una nueva celda vacia al tablero y eliminar el auto 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	; Mover el carro hacia la izquierda 
	sub eax,2
	call carro_llego_final ;verificar si el carro llega al final 
	call revisar_choque_carro ;verificar si el carro choca 
	; dibujar el carro 
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	; modificar la posicion del carro 
	mov [posicion_carro],eax
	retn




mover_buseta:
	xor eax,eax
	; Guardar la posicion del camion 
	mov eax,[posicion_buseta]
	; Borrar camion y crear una nueva celda vacia 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	; Mover el camion hacia la derecha 
	add eax,4
	call buseta_llego_final ;revisar si el camion llegar 
	call revisar_choque_buseta ;revisar si el camion choca 
	;dibuja el camion 
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	;definir la posicion tomando como referencia la primera x
	sub eax,2
	;actualizar la posicion 
	mov [posicion_buseta],eax
	retn






mover_camion:
	xor eax,eax
	;Guardar la posicion inicial del bus 
	mov eax,[posicion_camion]
	;Borrar el bus y añadir una nueva celda vacia 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;mover la primera posicion del bus hacia la derecha 
	add eax,6
	call camion_llego_final ;verificar si el bus llega al final de la celda
	call revisar_choque_camion ;verificar si el bus choca 
	;dibuja el bus 
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	;referenciar el valor del bus a la primera x 
	sub eax,4
	;actualizar la posicion del bus 
	mov [posicion_camion],eax
	retn





;revisar si el carro llego al final izquierdo 
carro_llego_final:
	add eax,2
	cmp eax,[limite_izquierdo_fila4]
	je reiniciar_carro ;reiniciar el carro 
	sub eax,2 ;mover el carro a la izquierda 
	retn





;verificar si el camion llego al borde derecha 
buseta_llego_final:
	sub eax,2
	cmp eax,[limite_derecho_fila3]
	je reiniciar_buseta ;reiniciar camion
	add eax,2 ;mover el camion hacia la derecha 
	retn





;Verificar si el bus llego al final de la celda derecha 
camion_llego_final:
	sub eax,2
	cmp eax,[limite_derecho_fila2]
	je reiniciar_camion ;reiniciar el bus 
	add eax,2 
	retn




;reiniciar el carro en la posicion izquierda 
reiniciar_carro:
	;eliminar el carro existente 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;setear la posicion inicial en la columna izquierda
	sub eax,2
	add eax,[col_pantalla]
	;dibujar el carro 
	xor ecx,ecx
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	;actualizar la posicion del carro 
	mov [posicion_carro],eax
	jmp jugar ;seguir jugando






;reiniciar el camion en la posicion derecha 
reiniciar_buseta:
	;eliminar el camion actual
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	sub eax,2
	mov byte[board+eax],cl
	;obtener la posicion inicial del camion 
	add eax,4
	sub eax,[col_pantalla]
	;dibujar el camion 
	xor ecx,ecx
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	;referenciar el camion
	sub eax,2
	;actualizar la posicion del camion
	mov [posicion_buseta],eax
	jmp jugar ;seguir jugando 







;reiniciar el bus en la posicion izquierda 
reiniciar_camion:
	;eliminar el bus 
	mov cl,byte[vacio]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	;Obtener la posicion inicial del bus 
	add eax,6
	sub eax,[col_pantalla]

	;dibujar el bus en la posicion inicial 
	xor ecx,ecx
	mov cl,byte[vehiculo]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	;referenciar el bus 
	sub eax,4
	;actualizar la posicion del bus 
	mov [posicion_camion],eax
	jmp jugar




;revisar si el carro choca 
revisar_choque_carro:
	xor ecx,ecx
	mov cl,byte[frog]
	cmp byte[board+eax],cl ;comparar si estan en la misma posicion 
	je juego_terminado ;termino el juego 
	retn




;revisar si el camion choca 
revisar_choque_buseta:
	xor ecx,ecx
	mov cl,byte[frog] 
	cmp byte[board+eax],cl ;comparar si las posiciones son iguales
	je juego_terminado ;el juego termina 
	retn




;revisar si el bus choca 
revisar_choque_camion:
	xor ecx,ecx
	mov cl,byte[frog]
	cmp byte[board+eax],cl ;comparar las posiciones 
	je juego_terminado ;el juego termina 
	retn



;definir el movimiento de los vehiculos 
mover_carros:
	call mover_carro ;llamar el movimiento de los carros
	call mover_buseta ;llamar el movimiento de los camiones 
	call mover_camion ;llamar el movimiento de los buses 
	retn


;enseñar la pantalla mediante una uefi call 
enseñar_pantalla:
	uefi_call_wrapper ConOut, OutputString, ConOut, board
	retn


;obtener la entrada del usuario mediante el uefi call 
entrada_usuario:
	uefi_call_wrapper ConIn, ReadKeyStroke, ConIn, INPUT_KEY
	cmp byte[INPUT_KEY.UnicodeChar], 0 ;compara que la entrada sea valida 
	jz entrada_usuario
	retn

;definir las teclas y los movimientos que hace cada una 
valor_tecla:
	call limpiar_pantalla
	cmp byte[INPUT_KEY+2], "w"
	je moverse_arriba ;llamar a moverse arriba 
	cmp byte[INPUT_KEY+2], "a"
	je moverse_izquierda ;llamar a moverse a la izquierda 
	cmp byte[INPUT_KEY+2], "s"
	je moverse_abajo ;llamar a moverse a bajo 
	cmp byte[INPUT_KEY+2], "d"
	je moverse_derecha ;llamar a moverse a la derecha 
	retn



;llamada uefi para limpiar la pantalla 
limpiar_pantalla:
	uefi_call_wrapper ConOut, ClearScreen, ConOut
	retn



;movimiento hacia abajo 
moverse_abajo:
	xor eax,eax
	; obtener la posicion del frog 
	mov eax,[posicion_frog]
	call revisar_fila ;revisar la primera fila 
	;Borrar el frog actual y moverlo a la nueva celda 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;mover al frog hacia abajo 
	add eax,72
	call termino_juego
	;dibujar el frog
	mov cl,byte[frog]
 	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	retn






;movimiento hacia arriba 
moverse_arriba:
	xor eax,eax
	;guardar la posicion del frog 
	mov eax,[posicion_frog]
	;borrar el frog y agregar celda vacia 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;mover el frog hacia arriba 
	sub eax,72
	call termino_juego ;revisar si el juego termino 
	call revisar_gano ;revisar el el jugador gana el juego 
	;dibujar el frog 
	mov cl,byte[frog]
 	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	retn





;movimiento hacia la derecha 
moverse_derecha:
	xor eax,eax
	;guardar la posicion 
	mov eax,[posicion_frog]
	;borrar el frog y agregar una celda vacia 
 	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;mover el frog hacia la derecha 
	add eax,2
	call termino_juego ;revisar si el juego termina 
	call limite_derecho ;revisar si el frog llega al limite derecho 
	;dibujar el frog 
	mov cl,byte[frog]
	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	retn





;movimiento a la izquierda 
moverse_izquierda:
	xor eax,eax
	;guardar la posicion del frog 
	mov eax,[posicion_frog]
	;borrar la posicion del frog y añadir una nueva celda vacia 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;mover el frog hacia la izquierda 
	sub eax,2
	call termino_juego ;revisar si el juego termina 
	call limite_izquierdo ;
	;dibujar el frog 
	mov cl,byte[frog]
	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	retn






termino_juego:
	;revisar si el frog choca 
	cmp byte[board+eax], 'C' ;si choca 
	je juego_terminado ;llama a final del juego 
	retn






;revisar si se encuentra en la primera fila 
revisar_fila:
	add eax,72
	cmp eax, [limite_derecho_fila5]
	jg jugar
	sub eax,72
	retn


;revisar si se gano 
revisar_gano:
	cmp eax,[col_pantalla]
	jl juego_ganado
	retn


;revisar si el frog llego al limite derecho 
limite_derecho:
	sub eax,2
	cmp eax,[limite_derecho_fila5] ;comparar si es en la fila 5
	je reiniciar_frog_izquierda
	cmp eax,[limite_derecho_fila4] ;comparar si es en la fila 4
	je reiniciar_frog_izquierda
	cmp eax,[limite_derecho_fila3] ;comparar si es en la fila 3
	je reiniciar_frog_izquierda
	cmp eax,[limite_derecho_fila2] ;comparar si es en la fila 2
	je reiniciar_frog_izquierda
	;volver a colocar el frog 
	add eax,2

	retn

;reiniciar el frog a la izquierda 
reiniciar_frog_izquierda:
	;borrar la posicion del frog 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;obtener la ultima posicion de la fila 
	add eax,2
	sub eax,[col_pantalla]
	mov cl,byte[frog]
	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	jmp jugar ;seguir jugando 




;revisar si el frog llego al limite derecho
limite_izquierdo:
	add eax,2
	cmp eax,[limite_izquierdo_fila5] ;revisar el limite en la fila 5
	je reiniciar_frog_derecho
	cmp eax,[limite_izquierdo_fila4] ;revisar el limite en la fila 4
	je reiniciar_frog_derecho
	cmp eax,[limite_izquierdo_fila3] ;revisar el limite en la fila 3
	je reiniciar_frog_derecho
	cmp eax,[limite_izquierdo_fila2] ;revisar el limite en la fila 2
	je reiniciar_frog_derecho
	;volver a colocar el frog 
	sub eax,2
	retn



;reiniciar el frog a la derecha 
reiniciar_frog_derecho:
	;eliminar la posicion del frog 
	mov cl,byte[vacio]
	mov byte[board+eax],cl
	;obtener la posicion inicial 
	sub eax,2
	add eax,[col_pantalla]
	mov cl,byte[frog]
	mov byte[board+eax],cl
	;actualizar la posicion del frog 
	mov [posicion_frog],eax
	jmp jugar ;seguir jugando 
	
	
	
;juego terminado 
juego_terminado:
	call limpiar_pantalla ;limpiar la pantalla 
	uefi_call_wrapper ConOut, OutputString, ConOut, perdedor
	jmp finalizado ;mostrar la pantalla de juego terminado 




;el jugador ha ganado 
juego_ganado:
	call limpiar_pantalla ;limpiar la pantalla 
	uefi_call_wrapper ConOut, OutputString, ConOut, ganador
	jmp finalizado ;mostrar la pantalla de juego terminado 




;juego terminado 
finalizado:
	mov eax, EFI_SUCCESS
	uefi_call_wrapper BootServices, Exit, BootServices




;seccion de definicion de datos 
section '.data' data readable writeable

	;Logica de los limites hacia la derecha 
	limite_derecho_fila1	dd		68
	limite_derecho_fila2	dd		142
	limite_derecho_fila3	dd		214
	limite_derecho_fila4	dd		286
	limite_derecho_fila5	dd		358

	;logica de los limites hacia la izquierda 
	limite_izquierdo_fila1	dd		8
	limite_izquierdo_fila2	dd		76
	limite_izquierdo_fila3	dd		148
	limite_izquierdo_fila4	dd		220
	limite_izquierdo_fila5	dd		292



	posicion_frog		dd		326 ;definir la posicion del frog 
	posicion_camion		dd		80 ;definir la posicion del bus 
	posicion_buseta	dd		182   ;definir la posicion del camion 
	posicion_carro		dd		242 ;definir la posicion del carro 
	filas_pantalla			dd		5 ;definir la cantidad de filas 
	col_pantalla			dd		68  ;definir la cantidad de columnas 
	largo_pantalla				dd		360 ;definir el tamaño de la pantalla 

	board						du		13,10,'----------------------------------',\
												13,10,'---CCC----------------------------',\
												13,10,'-------------------CC-------------',\
								 				13,10,'----------CC----------------------',\
								 				13,10,'-----------------F----------------',13,10,0 
								 				;definir la pantalla 

	frog						du		'F' ;definir el frog 
 	vacio			du		'-' ;definir la celda vacia 
	vehiculo					du		'C' ;definir un vehiculo 
	INPUT_KEY				EFI_INPUT_KEY  ;definir el imput key 


	controles  	du 		'PARA MOVERSE USE A W S D',13,10,0
	perdedor  	du 		'PERDEDOOOOOOOR!',13,10,0
	ganador	  	du 		'GANO DE SUERTE!',13,10,0
	bienvenida du		13,10,'El Frogger mas guapo que haz visto!',13,10,'ESTO ES EL FROGGER DEL SISTEMAS OPERATIVOS SIUA',13,10,0

section '.reloc' fixups data discardable
