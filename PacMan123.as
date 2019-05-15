;===============================================================================
; Programa PacMan.as
;
; Descricao: Implementa��o do jogo PacMan para Assembly do P3
;
;
; Autor: João ALmeida 90119 & Rafael Cordeiro 90171 , grupo 57
; Data: 05/2018
;===============================================================================

;===============================================================================
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;===============================================================================
; GAME SYMBOLS
PAC_MAN		EQU	'@'
MONSTER		EQU	'X'
BONUS		EQU	'#'
NOTHING		EQU ' '

; RAMDOM_MASK
RANDOM_MASK	EQU	1001110000010110b

; STACK POINTER
SP_INICIAL      EQU     FDFFh

; I/O a partir de FF00H
DISP7S1         EQU     FFF0h
DISP7S2         EQU     FFF1h
DISP7S3         EQU     FFF2h
LCD_WRITE	EQU	FFF5h
LCD_CURSOR	EQU	FFF4h
LEDS            EQU     FFF8h
INTERRUPTORES   EQU     FFF9h
IO_CURSOR       EQU     FFFCh
IO_WRITE        EQU     FFFEh

LIMPAR_JANELA   EQU     FFFFh
FIM_TEXTO       EQU     '$'

; INTERRUPCOES
TAB_INT0        EQU     FE00h
TAB_INT2        EQU     FE02h
TAB_INT4        EQU     FE04h
TAB_INT6        EQU     FE06h
TAB_INT8        EQU     FE08h
TAB_INTA        EQU     FE0Ah
TAB_INTB        EQU     FE0Bh
TAB_INTC        EQU     FE0Ch
TAB_INTTemp     EQU     FE0Fh
PORTMASCARA_INT	EQU		FFFAh

; TEMPORIZADOR
TempValor		EQU		FFF6h
TempControlo	EQU		FFF7h

;===============================================================================
; ZONA II: Definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres.
;          Cada caracter ocupa 1 palavra
;===============================================================================
                ORIG    8000h
PacMan		STR     0820h, 0820h	;posição do PacMan atual, nao interessa para nada, perguntar ao ilic
Monsters	STR	0101h, 0D01h,0130h, 0D30h
MonstersOLD	STR	0101h, 0D01h, 0130h, 0D30h
Mexe_PacMan		WORD    0000h
PacMan_Vidas	WORD	0003h
PacMan_Pontos	WORD	0000h
Num_Monsters	WORD	0004h
RandomWord	WORD	RANDOM_MASK
VLinha1         STR     '--------------------------------------------------', FIM_TEXTO
VLinha2         STR     '|................................................|', FIM_TEXTO
VLinha3         STR     '|...__________......___________.....__________...|', FIM_TEXTO
VLinha4         STR     '|...|__    __|......|    _____|.....|__    __|...|', FIM_TEXTO
VLinha5         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha6         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha7         STR     '|......|  |.........|   |____..........|  |......|', FIM_TEXTO
VLinha8         STR     '|......|  |.........|____    |.........|  |......|', FIM_TEXTO
VLinha9         STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha10        STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha11        STR     '|....__|  |__........____|   |.........|  |......|', FIM_TEXTO
VLinha12        STR     '|...|________|......|________|.........|__|......|', FIM_TEXTO
VLinha13        STR     '|................................................|', FIM_TEXTO
VLinha14        STR     '|................................................|', FIM_TEXTO
VLinha15        STR     '--------------------------------------------------', FIM_TEXTO
Titulo		STR	'*** PAC_MAN (MEEC 17/18) ***', FIM_TEXTO
Vidas		STR	'#Vidas:', FIM_TEXTO
Pontos		STR	'#Pontos:', FIM_TEXTO
LCDLinha0	STR	'PAC_MAN',FIM_TEXTO
LCDLinha1	STR	'Rank1: ',FIM_TEXTO

Clock_Tic	WORD	0001h		;velociade do clock de relogio
N_to_Display	STR	0079h, 0079h	;tempo restante e tempo inicial
;N_to_Display_Inicial WORD	0079h
Update_Display	WORD	0000h
Pausa		WORD	0000h
Particulas	STR	0121h, 0121h		;nr de partículas a mostrar tabuleiro e o nr de partículas inical
;Particulas_Inicial	WORD

;===============================================================================
; ZONA III: Codigo
;           conjunto de instrucoes Assembly, ordenadas de forma a realizar
;           as funcoes pretendidas
;===============================================================================
                ORIG    0000h
				MOV		R1, SP_INICIAL
				MOV		SP, R1
                JMP     inicio

;===============================================================================
; Pausa: Rotina de interrupcao 0
;
;===============================================================================
Pausa_Pac:  NOP
			PUSH	R1
			MOV	R1, M[Pausa]
			XOR	R1, 0001h
			MOV	M[Pausa], R1
			POP	R1
        	RTI

;===============================================================================
; MoveDown_Pac:
;
;===============================================================================
MoveDown_PacMan:   NOP	; completar rotina de atendimento da int 8
				PUSH	R1
				PUSH	R7
				PUSH	R5
				MOV 	R7, 0
				MOV		R5, 0
				MOV		R1, M[PacMan]
				ADD		R1, 0100h
				CALL	Validar_Jogadas
				CMP		R7, 0000h
				BR.Z	FIM_Do_MoveDown_Pac
				CALL	Atualizar_Posicao_PacMan
				;jogada válida e remoção da bola
				MOV		R1, M[PacMan]
				SUB		R1, 0100h
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[Particulas]
				DEC		R1
				MOV		M[Particulas], R1
FIM_Do_MoveDown_Pac:		NOP
				POP		R5
				POP		R7
				POP		R1
				RET

;===============================================================================
; MoveDown_Pamman: Rotina de interrupcao 2
;
;===============================================================================
MoveDown_Pac:   NOP
                PUSH	R1
				MOV		R1, 0002h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveLeft_PacMan: TODO
;
;===============================================================================
MoveLeft_PacMan:   NOP	; completar rotina de atendimento da int 4
                PUSH	R1
				PUSH 	R7
				PUSH	R5
				MOV		R7, 0
				MOV		R5, 0
				MOV		R1, M[PacMan]
				SUB		R1, 0001h
				CALL	Validar_Jogadas
				CMP		R7, 0000h
				BR.Z	FIM_Do_MoveLeft_Pac
				CALL	Atualizar_Posicao_PacMan
				;jogada válida e remoção da bola
				MOV		R1, M[PacMan]
				ADD		R1, 0001h
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[Particulas]
				DEC		R1
				MOV		M[Particulas], R1
FIM_Do_MoveLeft_Pac:	NOP
				POP		R5
				POP		R7
				POP		R1
				RET

;===============================================================================
; MoveLeft_Pac: Rotina de interrupcao 4
;
;===============================================================================
MoveLeft_Pac:   NOP	; completar rotina de atendimento da int 4
                PUSH	R1
				MOV		R1, 0004h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveRight_Pac:
;
;===============================================================================
MoveRight_PacMan:  NOP	; completar rotina de atendimento da int 6
                PUSH	R1
				PUSH	R7
				PUSH	R5
				MOV		R7, 0
				MOV		R5, 0
				MOV		R1, M[PacMan]
				ADD		R1, 0001h
				CALL	Validar_Jogadas
				CMP		R7, 0000h
				BR.Z	FIM_Do_MoveRight_Pac
				CALL	Atualizar_Posicao_PacMan
				;jogada válida e remoção da bola
				MOV		R1, M[PacMan]
				SUB		R1, 0001h
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[Particulas]
				DEC		R1
				MOV		M[Particulas], R1
FIM_Do_MoveRight_Pac:	NOP
				POP		R5
				POP		R7
				POP		R1
				RET
;===============================================================================
; MoveRight_Pamman: Rotina de interrupcao 6
;
;===============================================================================
MoveRight_Pac:   NOP
                PUSH	R1
				MOV		R1, 0006h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveUp_Pac:
;
;===============================================================================
MoveUp_PacMan:     NOP	; completar rotina de atendimento da int 8
				PUSH	R1
				PUSH	R7
				PUSH	R5
				MOV 	R7, 0
				MOV		R5, 0
				MOV		R1, M[PacMan]
				SUB		R1, 0100h
				CALL	Validar_Jogadas
				CMP		R7, 0000h
				BR.Z	FIM_Do_MoveUp_Pac
				CALL	Atualizar_Posicao_PacMan
				;jogada válida e remoção da bola
				MOV		R1, M[PacMan]
				ADD		R1, 0100h
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[Particulas]
				DEC		R1
				MOV		M[Particulas], R1
FIM_Do_MoveUp_Pac:		NOP
				POP		R5
				POP		R7
				POP		R1
				RET

;===============================================================================
; MoveUp_Pamman: Rotina de interrupcao 8
;
;===============================================================================
MoveUp_Pac:   NOP
                PUSH	R1
				MOV		R1, 0008h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; Validar_Jogada:
;
;		R1 - posição pacman
;		R2 - posição no tabuleiro
;		R3 - posição xx do movimento
;		R4 - posição yy do movimento
;		R5 - tamanho da string
;		R7 - bool jogada válida
;
;===============================================================================
Validar_Jogadas:	NOP
					PUSH	R5
					PUSH	R4
					PUSH	R3
					PUSH	R2
					MOV		R2, VLinha1
					MOV		R3, R1
					MOV		R4, R1
					MOV		R5, 51
					AND		R3, 00FFh
					SHR		R4, 8
					MUL		R4, R5
					ADD		R5, R3
					ADD		R5, R2
					MOV		R2, M[R5]
					CMP		R2, '-'
					BR.Z	FIM
					CMP		R2, '|'
					BR.Z	FIM
					CMP		R2, '_'
					BR.Z	FIM
					MOV		R7, 1
	FIM:			POP		R2
					POP		R3
					POP		R4
					POP 	R5
					RET

;===============================================================================
; Atualizar_Posicao_PacMan:
;
;
;
;===============================================================================
Atualizar_Posicao_PacMan:	NOP
							;jogada válida , atualização da posição do PacMan
							MOV		M[PacMan], R1
							MOV		M[IO_CURSOR], R1
							MOV		R1, PAC_MAN
							CALL	EscCar
							RET

;===============================================================================
; Timer: Rotina de interrupcao 15
;
;===============================================================================
Temp_Pac:	NOP	; completar rotina de atendimento da int 15
		; Este c�digo refere-se apenas ao exemplo PacMan_Help1 n�o ao LAB4
		PUSH 	R1
		MOV	R1, M[Clock_Tic]
		MOV	M[TempValor], R1
		MOV	R1, 1
		MOV	M[TempControlo], R1
		MOV	M[Update_Display],R1
		POP	R1
		RTI

;===============================================================================
; EscDisplay: Rotina que efectua escrita no DISPLAY de 7 segmentos
;               Entradas: R1 - Valor a enviar para o porto do DISPLAY
;                         R2 - Porto do DISPLAY a utilizar
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria/porto M[R2]
;===============================================================================
EscDisplay:     MOV     M[R2], R1
                RET

;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
LimpaJanela:    PUSH 	R2
                MOV     R2, LIMPAR_JANELA
		MOV     M[IO_CURSOR], R2
                POP 	R2
                RET

;===============================================================================
; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;         O caracter pode ser visualizado na janela de texto.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================
EscCar:     MOV     M[IO_WRITE], R1
            RET

;===============================================================================
; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;            pelo caracter FIM_TEXTO, na janela de texto numa posicao
;            especificada. Pode-se definir como terminador qualquer caracter
;            ASCII.
;               Entradas: pilha - posicao para escrita do primeiro carater
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
EscString:      PUSH    R1
                PUSH    R2
				PUSH    R3
                MOV     R2, M[SP+6]   ; Apontador para inicio da "string"
                MOV     R3, M[SP+5]   ; Localizacao do primeiro carater
Ciclo:          MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                CALL    EscCar
                INC     R2
                INC     R3
                BR      Ciclo
FimEsc:         POP     R3
                POP     R2
                POP     R1
                RETN    2                ; Actualiza STACK

;===============================================================================
; Random_Gen: Gera um n�mero alet�rio que coloca em M[RandomWord]
;===============================================================================
Random_Gen:	PUSH	R1
		MOV	R1, M[RandomWord]
		TEST	R1, 0001h
		BR.NZ	Bit1NZ
		ROR	R1, 1
		BR 	End_Random
Bit1NZ:		XOR	R1, RANDOM_MASK
		ROR	R1, 1
End_Random:	MOV	M[RandomWord], R1
		POP	R1
		RET

;===============================================================================
; CLRLCD: Rotina para limpar LCD
;               Entradas:
;               Saidas:
;               Efeitos:
;===============================================================================
CLRLCD:         PUSH    R1
                MOV     R1, 8020h
				MOV	M[LCD_CURSOR], R1
                POP     R1
                RET

;===============================================================================
; Print_Labi:
;===============================================================================

; Este c�digo refere-se apenas ao exemplo PacMan_Help1 n�o ao projecto
; Como mostrar o labirinto na janela de texto (24 Linhas e 80 Colunas)?
; Uma possibilidade ... mas durante o jogo apenas devem ser alterada as posi��es
; ... afectadas pelo movimento - manter tanto a mem�ria como a Janela de Texto actualizada
Print_Labi:	PUSH		R1
			PUSH		R2
			PUSH 		R3
			PUSH		R4
			MOV			R1, VLinha1
			MOV			R2, VLinha2
			MOV			R3, 15
			MOV 		R4, 0000h
			SUB	R2,		R1
Loop_labirinto:		PUSH	R1
			PUSH		R4
			CALL		EscString
			ADD	R4, 	0100h
			ADD	R1, 	R2
			DEC	R3
			BR.NZ		Loop_labirinto
			MOV 		R1, 1
			MOV			R2, M[R1 + PacMan]
			MOV			M[PacMan], R2
			MOV			R1, M[PacMan]
			MOV			M[IO_CURSOR] , R1
			MOV			R1, PAC_MAN
			CALL		EscCar
			POP			R4
			POP			R3
			POP			R3
			POP			R1
			RET
; Fim de mostrar o labirinto na janela de texto.

;===============================================================================
; Update_Display:
;===============================================================================

UpDate_Display:		PUSH	R1
					PUSH	R2
		; Exemplo de colocar uma contagem sincrona no display de 7 segmentos
					MOV		M[Update_Display], R0
					MOV		R2, M[N_to_Display]
					DEC 	R2
					CMP		R2, 0
					JMP.N	Fim
					MOV		R1, R2
					CALL	SEPARAR_NUMEROS
					MOV		M[N_to_Display], R2
					MOV		M[DISP7S1], R1
					ROR		R1, 4
					MOV		M[DISP7S2], R1
					ROR		R1, 4
					MOV		M[DISP7S3], R1
					POP		R2
					POP		R1
					RET


;===============================================================================
; SEPARAR_NUMEROS
;===============================================================================
SEPARAR_NUMEROS:			NOP
							PUSH	R3
							PUSH	R2
							MOV 	R3, R1
							MOV		R1, 0
				LCD3:		MOV		R2, 0064h
			Inc_LCD3:		CMP		R3, R2
							BR.N	LCD2
							SUB		R3, R2
							ADD		R1, 0100h
							BR		Inc_LCD3
				LCD2:		MOV		R2, 000Ah
			Inc_LCD2:		CMP		R3, R2
							BR.N	LCD1
							SUB		R3, R2
							ADD		R1, 0010h
							BR		Inc_LCD2
				LCD1:		MOV		R2, 0001h
			Inc_LCD1:		CMP		R3, R2
							BR.N	FIM_SEPARAR_NUMEROS
							SUB		R3, R2
							ADD		R1, 0001h
							BR		Inc_LCD1
FIM_SEPARAR_NUMEROS :		POP		R2
							POP		R3
							RET

;===============================================================================
;                                      Conversor para ASCII, recebendo em R1, um numero hexadecimal
;===============================================================================
Conversor_para_ASCII:	NOP
						PUSH	R2;		numero de digitos
						PUSH	R3;		convresoes de hexa para numero a escrever
						PUSH	R4;		controlo digito a selecionar
						PUSH	R6;		posição do display
						PUSH	R5;
						MOV		R6, 8005h
						MOV		R2, 0
						MOV		R3, R1
	LOOP_ASCII:			INC		R2
						CMP		R3, 0
						BR.Z	Stage_Two
						SHR		R3, 4
						BR		LOOP_ASCII
	Stage_Two:			CALL	SEPARAR_NUMEROS
						MOV		R4, 000Fh
	Stage_Three:		MOV		R3, R1
						AND		R3, R4
	Bits_na_direita:	MOV		R5, R3
						AND		R5, FFF0h
						BR.Z	Escrita_no_LCD
						SHR		R3, 4
						BR		Bits_na_direita
	Escrita_no_LCD:		ADD		R3, 48
						MOV		M[LCD_CURSOR], R6
						MOV		M[LCD_WRITE], R3
						DEC		R6
						SHL		R4,	4
						DEC		R2
						BR.NZ	Stage_Three
						POP		R5
						POP		R6
						POP		R4
						POP		R3
						POP		R2
						RET

;===============================================================================
; PacMan_Aleat:
;===============================================================================

PacMan_Aleat:	PUSH	R1
		PUSH	R2
		PUSH	R3
		; Exemplo de colocar um simbolo a mover no ecran ... sem valida��o de limites
		; e com I2 a colocar o Pacman no ponto de partida
		CALL	Random_Gen
		MOV	R1, M[PacMan]
		MOV	M[IO_CURSOR], R1
		MOV	R3, ' '
		MOV	M[IO_WRITE], R3
		MOV	R2, M[RandomWord]
		SUB	R1, 0101h
		TEST	R2, 0001h
		BR.Z	Check_Y
		ADD	R1, 0002h
Check_Y:	TEST	R2, 0002h
		BR.Z	DisplayPacman
		ADD	R1, 0200h
DisplayPacman:	MOV	M[IO_CURSOR], R1
		MOV		M[PacMan], R1
		MOV		R1, PAC_MAN
		CALL	EscCar
		POP		R3
		POP		R2
		POP		R1
		RET


;TODO
;===============================================================================
;                                       InitInt:
;===============================================================================
InitInt:    NOP		; TODO
        	MOV		R1, Pausa_Pac
			MOV 	M[TAB_INT0], R1
			MOV		R1, MoveDown_Pac
			MOV 	M[TAB_INT2], R1
        	MOV		R1, MoveLeft_Pac
            MOV 	M[TAB_INT4], R1
            MOV		R1, MoveRight_Pac
            MOV 	M[TAB_INT6], R1
            MOV		R1, MoveUp_Pac
			MOV 	M[TAB_INT8], R1
			MOV		R1, Fim
            MOV 	M[TAB_INTC], R1
			MOV		R1, Temp_Pac
			MOV 	M[TAB_INTTemp], R1
			MOV		R1, M[Clock_Tic]
			MOV		M[TempValor], R1
			MOV		R1, 1
			MOV		M[TempControlo], R1
			MOV		R1, 9D55h
			MOV		M[PORTMASCARA_INT], R1
			RET

;===============================================================================
;                                Programa prinicipal

;	R2, serve
;===============================================================================
inicio:     MOV     R1, SP_INICIAL
    	    MOV     SP, R1
			CALL	InitInt
			ENI
Reinicia:	CALL    LimpaJanela
            NOP		; completar com programa principal
			CALL	Print_Labi
			MOV		R2, M[N_to_Display ]
			INC		R2
			MOV		M[N_to_Display], R2
			MOV		R2, M[Particulas]
			INC		R2
			MOV		M[Particulas], R2

     MOV R5,1
      NoUpDateDisplay:	NOP
  	  MOV		R1, M[Update_Display]
  		CMP		R1, 0
  	  BR.Z	NoUpDateDisplay
      DEC   R5
      CMP   R5,0
      BR.NZ XY
  	  CALL	UpDate_Display
    	MOV		R2, M[N_to_Display]
      ;==== Escrita nos LEDS ====
      MOV		R1, M[N_to_Display]
      MOV		M[LEDS], R1
      ;==== Escrita no LCD ====
      PUSH	R1
      MOV		R1, M[Particulas]
      CALL	Conversor_para_ASCII
      POP		R1


    XY:  PUSH R2
			;==== Analise dos movimentos ====
      MOV		R2, M[Mexe_PacMan]
			CMP		R2, 0002h
			CALL.Z	MoveDown_PacMan
			CMP		R2, 0004h
			CALL.Z	MoveLeft_PacMan
			CMP		R2, 0006h
			CALL.Z	MoveRight_PacMan
			CMP		R2, 0008h
			CALL.Z	MoveUp_PacMan
			MOV		R2, 0000h
			MOV		M[Mexe_PacMan], R2
			NOP
      POP R2
		;==== Pausa com recurso a I0 ====
Em_Pausa:	MOV	R1, M[Pausa]
			CMP	R1, 1
			MOV		R1, 0001h
			MOV		M[PORTMASCARA_INT], R1
			BR.Z	Em_Pausa	;se no endereço estiver a um, ele continua em pausa
			MOV		R1, 9D55h
			MOV		M[PORTMASCARA_INT], R1



		JMP	NoUpDateDisplay


Fim:            NOP
				MOV		R1, 0000h
				MOV		M[PORTMASCARA_INT], R1
				BR     	Fim

;===============================================================================
