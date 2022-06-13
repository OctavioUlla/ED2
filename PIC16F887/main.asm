LIST   P=PIC16F887
#include p16f887.inc                ; Include register definition file

	    
WAUX	    EQU	    0x70
STAUX	    EQU	    0x71
BOOL	    EQU	    0x72 
UMBRALL	    EQU	    0X73
UMBRALH	    EQU	    0X74		    
KEYNUM	    EQU	    0X75
AUX_DISPLAY EQU	    0X76
AUX_FILE    EQU	    0X77
CONTA	    EQU	    0X78
L1	    EQU	    0X79	    
L0	    EQU	    0X7A
P1	    EQU	    0X7B
P0	    EQU	    0X7C
RCAUX	    EQU	    0X7D	    
	    
	    
 
	    ORG	    0x00
	    GOTO    INICIO
	    ORG	    0X04
	    GOTO    INT
	    ORG	    0x05
INICIO	
	    BSF	    STATUS,RP0
	    BSF	    STATUS,RP1
	    CLRF    ANSELH
	    MOVLW   0X01
	    MOVWF   ANSEL
	    BCF	    STATUS,RP1
	    MOVLW   B'01110111'	; pullups:ON,T0CS:T0CKI pin(para detener el Timer),PSA:TMR0,PR:256  
	    MOVWF   OPTION_REG
	    MOVLW   b'11110000'
	    MOVWF   WPUB
	    MOVWF   TRISB
	    MOVWF   IOCB
	    BSF	    TRISA,RA1 ; IMPORTANTEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE: Estaba en BCF pero para mi es BCF
	    CLRF    TRISC
	    CLRF    TRISD
	    CLRF    TRISE
	    BSF	    PIE1,RCIE
	    BSF	    PIE1,ADIE
	    BCF	    TXSTA,SYNC
	    MOVLW   B'10110000'
	    MOVWF   ADCON1
	    
	    BCF	    STATUS,RP0
	    CLRF    PORTB
		CLRF    PORTD
	    MOVF    PORTB,F
	    MOVLW   b'11001000'
	    MOVWF   INTCON
	    MOVLW   b'10010000'
	    MOVWF   RCSTA
	    MOVLW   b'11000000'
	    MOVLW   0X79
	    MOVWF    FSR
	    MOVLW   .2
	    MOVWF   CONTA
	    MOVLW   B'11000000'
	    MOVWF   ADCON0
	    MOVLW   0X05
	    MOVWF   L0
	    CALL    LANZADC
	    
	    ;BORRAR ESTO
	    MOVLW   0X05
	    MOVWF   P0
	    MOVLW   0X04
	    MOVWF   P1
	    MOVLW   0X08
	    MOVWF   L1
TODOS_DIG   
	    ;SUBRRUTINA PA DORMIR
	    ;BTFSC   BOOL,5
	    ;CALL    GOSLEEP
	    
	    MOVLW   L1
	    MOVWF   FSR		; apunta al primer d?gito a mostrar
	    MOVLW   B'00000001'
	    MOVWF   PORTD		; habilita d?gito a mostrar
OTRO_DIG    MOVF    INDF,W		; lee dato hexadecimal a mostrar
	    CALL    CONV_7SEG	; llama a subrutina convierte a 7 segmentos
		MOVWF   AUX_DISPLAY
	    MOVWF   PORTC		; escribe d?gito en 7 segmento
		
		BTFSS   AUX_DISPLAY,6
		BCF     PORTD,7       ;No podemos usar RC6 porque es Tx entonces copiamos el ultimo bit a RD7	
		
		BTFSC   AUX_DISPLAY,6
		BSF     PORTD,7
		
	    CALL    RETARDO	; lo mantiene encendido un tiempo
	    BCF	    STATUS,C	; carry en 1 para poder rotar
	    RLF	    PORTD,F		; desplaza el 0 al pr?ximo d?gito
	    INCF    FSR,F		; apunta al pr?ximo dato a mostrar
	    BTFSS   PORTD,4	; ya mostr? los 4 d?gitos?
	    GOTO    OTRO_DIG	; no mostr? todo, va al pr?ximo d?gito
	    GOTO    TODOS_DIG	; ya mostr? los 4 d?gitos vuelve a refrescar
	    goto    $
	    

GOSLEEP	    BCF	    BOOL,2
	    BSF	    STATUS,RP0
	    BCF	    PIE1,ADIE
	    BCF	    PIE1,TMR1IF
	    BCF	    STATUS,RP0
	    BCF	    T1CON,TMR1ON
	    CLRF    PORTD
	    SLEEP
	    NOP
	    RETURN
	    
CONV_7SEG   ADDWF PCL,F		; suma a PC el valor del d?gito
	    RETLW 0x3F		; obtiene el valor 7 segmentos del 0
	    RETLW 0x06		; obtiene el valor 7 segmentos del 1
	    RETLW 0x5B		; obtiene el valor 7 segmentos del 2
	    RETLW 0x4F		; obtiene el valor 7 segmentos del 3
	    RETLW 0x66		; obtiene el valor 7 segmentos del 4
	    RETLW 0x6D		; obtiene el valor 7 segmentos del 5
	    RETLW 0x7D		; obtiene el valor 7 segmentos del 6
	    RETLW 0x07		; obtiene el valor 7 segmentos del 7
	    RETLW 0x7F		; obtiene el valor 7 segmentos del 8
	    RETLW 0x67		; obtiene el valor 7 segmentos del 9
	    RETLW 0x77		; obtiene el valor 7 segmentos del A
	    RETLW 0x7C		; obtiene el valor 7 segmentos del B
	    RETLW 0x39		; obtiene el valor 7 segmentos del C
	    RETLW 0x5E		; obtiene el valor 7 segmentos del D
	    RETLW 0x79		; obtiene el valor 7 segmentos del E
	    RETLW 0x71		; obtiene el valor 7 segmentos del F	  
INT	    
	    MOVWF   WAUX	; Se guarda valor del registro W
	    SWAPF   STATUS,W	; Se guarda valor del registro STATUS
	    MOVWF   STAUX
	    
	    BTFSC   INTCON,T0IF
	    CALL    TIMER0
	    BTFSC   PIR1,TMR1IF
	    CALL    TIMER1
	    BTFSC   PIR1,RCIF
	    CALL    RX
	    BTFSC   INTCON,RBIF
	    CALL    INTPORTB
	    BTFSC   PIR1,ADIF
	    CALL    ADC
	    
	    SWAPF   STAUX,W
	    MOVWF   STATUS	; a STATUS se le da su contenido original
	    SWAPF   WAUX,F	; a W se le da su contenido original
	    SWAPF   WAUX,W
	    RETFIE
	    
RX	    
	    BCF	    BOOL,5
	    MOVF    RCREG,W
	    MOVWF   RCAUX
	    
	    BTFSC   RCAUX,0
	    CALL    ENTRA
	    BTFSC   RCAUX,1
	    CALL    SALE
	    
	    BTFSC   RCAUX,0
	    RETURN
	    BTFSC   RCAUX,1
	    RETURN 
	    BTFSC   RCAUX,2
	    RETURN
	    BSF	    BOOL,5
	    
	    RETURN
	    
	    
ENTRA
	    BSF	    BOOL,0
	    BCF	    PORTE,RE2
	    BSF	    PORTE,RE1
	    CALL    STARTMEDICION
	    CALL    BARBIJO	    
	    RETURN
	    
SALE
	    BCF	    BOOL,0
	    BCF	    PORTE,RE1
	    BSF	    PORTE,RE2
	    CALL    STARTMEDICION
	    RETURN
	    
STARTMEDICION
	    BTFSC   BOOL,2 ;SI NO ESTA MIDIENDO MIDO
	    RETURN
	    BSF	    BOOL,2
	    ;PRENDER EL TIMER1
	    BSF	    STATUS,RP0
	    BSF	    PIE1,TMR1IE
	    BCF	    STATUS,RP0
	    MOVLW   B'10110100'
	    MOVWF   T1CON
	    CALL    SETT1
	    BSF	    T1CON,TMR1ON
	    CALL    LANZADC
	    
	    RETURN

SETT1
	    MOVLW   0X96
	    MOVWF   TMR1L
	    MOVLW   0XE7
	    MOVWF   TMR1H
	    BCF	    PIR1,TMR1IF
	    RETURN
	    
LANZADC	    
	    BSF	    ADCON0,0
	    BSF	    ADCON0,1
	    RETURN
	    
TIMER1	    
	    CALL    SETT1
	    CALL    LANZADC
	    RETURN
	    
ADC	    
	    BTFSS   BOOL,3
	    GOTO    SETUMBRAL
	    BCF	    STATUS,C
	    MOVF    ADRESH,W	
	    SUBWF   UMBRALH,W	;VEO SI LA LECTURAH ES MAYOR QUE EL UMBRALH
	    BTFSC   STATUS,C
	    GOTO    NADIEM
	    BSF	    STATUS,RP0
	    BCF	    STATUS,C
	    MOVF    ADRESL,W
	    SUBWF   UMBRALL,W	;VEO SI LA LECTURAL MAYOR QUE EL UMBRALL
	    BCF	    STATUS,RP0
	    BTFSC   STATUS,C
	    GOTO    NADIEM
	    
	    BSF	    BOOL,1
	    BCF	    PIR1,ADIF ;NO ESTOY SEGURO QUE SE LIMPIE ACA
	    RETURN
	    
NADIEM
	    BTFSS   BOOL,1  ;CONTROLO QUE ANTES NO HABIA NADIE
	    RETURN
	    BCF	    BOOL,1
	    BTFSC   BOOL,0  ;CONTROLO SI ENTRA
	    CALL    INCPER
	    BTFSS   BOOL,0  ;CONTROLO SI SALE
	    CALL    DECPER
	    
	    BCF	    STATUS,C
	    MOVF    P1,W
	    SUBWF   L1,W
	    BTFSS   STATUS,C	;CHEQUEO QUE EL SEGUNDO BMS DE PERSONAS ES MAYOR QUE EL DE LIMITE
	    GOTO    REDLEDON
	    MOVF    L0,W
	    SUBWF   P0,W
	    BTFSC   STATUS,C	;CHEQUEO QUE EL ULTIMOBMS DE PERSONAS ES MAYOR O IGUAL QUE EL DE LIMITE
	    GOTO    REDLEDON
	    GOTO    REDLEDOFF
	    
REDLEDON    	    
	    BSF	    PORTE,RE0
	    RETURN
	    
REDLEDOFF    	    
	    BCF	    PORTE,RE0
	    RETURN	    

INCPER	    
	    INCF    P0
	    BTFSS   P0,4
	    RETURN
	    CLRF    P0
	    INCF    P1	    
	    
DECPER	    
	    DECF    P0
	    BTFSS   P0,4
	    RETURN
	    MOVLW   B'00001111'
	    MOVWF   P0
	    DECF    P1
	    
BARBIJO	 
	    BTFSC   RCAUX,2
	    BCF	    PORTA,RA1
	    BTFSS   RCAUX,2
	    BSF	    PORTA,RA1
	    RETURN

SETUMBRAL   
	    MOVF    ADRESH,W
	    MOVWF   UMBRALH
	    BSF	    STATUS,RP0
	    MOVF    ADRESL,W
	    SUBLW   .100
	    MOVWF   UMBRALL
	    BCF	    STATUS,RP0
	    BSF	    BOOL,3
	    BCF	    PIR1,ADIF
	    RETURN
	    
INTPORTB
	    BCF	    STATUS,RP0
	    BCF	    STATUS,RP1
	    MOVF    PORTB,F     ; Se realiza una instrucci?n "read,modify,write" para poder limpiar RBIF
	    BCF	    INTCON,RBIF
	    BCF	    INTCON,RBIE ; Se deshabilita interrupci?n por PORTB	    
	    MOVLW   .60		; Valor que setea 50 mseg aprox. para el antirebote por timer
	    MOVWF   TMR0	; Se carga el valor deseado en el TMR0, T[s]= ((256-TMR0)*prescaler+2)*Ty
	    BSF	    STATUS,RP0
	    BCF	    OPTION_REG,T0CS; T0CS:Ty (para iniciar funcionamiento del Timer) 		    
	    BCF	    INTCON,T0IF ; Se limpia bandera de interrupci?n por TMR0
	    BSF	    INTCON,T0IE ; Se habilita interrupci?n por desbordamiento en TMR0
	    RETURN	    
	    
	    
TIMER0	    
	    BSF	    STATUS,RP0
	    BCF	    STATUS,RP1
	    ;BSF	    OPTION_REG,T0CS		    
	    BCF	    INTCON,T0IF ; Se limpia bandera de interrupcion por TMR0
	    BCF	    INTCON,T0IE ; Se deshabilita interrupci?n por TMR0
	    BCF	    STATUS,RP0	    
	    CALL    SCAN
	    ;CLRF    PORTB	; Se llevan a cero las salidas <b0:b3>
	    ;MOVF    PORTB,F     ; Se establece estado de referencia para la interrupci?n por PORTB
	    BCF	    INTCON,RBIF  
	    BSF	    INTCON,RBIE ; Se habilita interrupci?n por PORTB
	    
SCAN	    	    
	    CLRF    KEYNUM	; Se lleva a cero el contador del n?mero de tecla
	    MOVLW   b'00001110'	; valor que permite evaluar primera fila del teclado
	    MOVWF   AUX_FILE
SCAN_NEXT
	    MOVF    AUX_FILE,W    
	    MOVWF   PORTB	
	    BTFSS   PORTB,RB4	; pregunta si la columna 1 es 0
	    GOTO    SR_KEY
	    INCF    KEYNUM,F
	    BTFSS   PORTB,RB5	; pregunta si la columna 2 es 0
	    GOTO    SR_KEY
	    INCF    KEYNUM,F
	    BTFSS   PORTB,RB6	; pregunta si la columna 3 es 0
	    GOTO    SR_KEY
	    INCF    KEYNUM,F
	    BTFSS   PORTB,RB7	; pregunta si la columna 4 es 0
	    GOTO    SR_KEY
	    BSF	    STATUS,C	; ninguna columna es 0
	    RLF	    AUX_FILE,F	; Se rota el cero para evaluar la pr?xima fila
	    INCF    KEYNUM,F	; Se incrementa el contador
		
	    MOVLW   .16		
	    SUBWF   KEYNUM,W	; Se testea si ya se escane? las 16 teclas
		
	    BTFSS   STATUS,Z		
	    GOTO    SCAN_NEXT	; no lleg? a 16, busca pr?xima fila
		CLRF    PORTB
		MOVF    PORTB,F
	    RETURN
	    
SR_KEY	    	    
	    BCF	    STATUS,IRP
		
		MOVLW   0x7B
		MOVWF   FSR
		MOVF    CONTA,W ;Volver a la posicion del buffer donde se quedo
		SUBWF   FSR,F
		
	    MOVF    KEYNUM,W
	    MOVWF   INDF
	    INCF    FSR
	    DECFSZ  CONTA
	    RETURN
	    MOVLW   .2
	    MOVWF   CONTA

	    RETURN
	    
	    ;RETARDO DE 5 MILISEG PARA EL DISPLAY
RETARDO	    MOVLW   .40
	    MOVWF   0X20
LOOP2	    MOVLW   .41
	    MOVWF   0X21
LOOP1	    DECFSZ  0X21 
	    GOTO    LOOP1
	    DECFSZ  0X20
	    GOTO    LOOP2
	    RETURN
	    
	    END

