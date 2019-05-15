;===============================================================================
; Programa PacMan.as
;
; Descricao: Implementa��o do jogo PacMan para Assembly do P3
;
;
; Autor: xxxxxxxxx
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
PacMan		STR     0820h, 0820h
Monsters	STR	0101h, 0D01h, 0130h, 0D30h
MonstersOLD	STR	0101h, 0D01h, 0130h, 0D30h
PacMan_Vidas	WORD	0003h
PacMan_Pontos	WORD	0000h
Num_Monsters	WORD	0004h
RandomWord	WORD	RANDOM_MASK
VLinha1         STR     '--------------------------------------------------', FIM_TEXTO
VLinha2         STR     '|................................................|', FIM_TEXTO
VLinha3         STR     '|...----------......----------......----------...|', FIM_TEXTO
VLinha4         STR     '|...|        |......|        |......|        |...|', FIM_TEXTO
VLinha5         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha6         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha7         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha8         STR     '|......|  |.........|        |.........|  |......|', FIM_TEXTO
VLinha9         STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha10        STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha11        STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha12        STR     '|...|        |......|        |.........|  |......|', FIM_TEXTO
VLinha13        STR     '|...----------......----------.........----......|', FIM_TEXTO
VLinha14        STR     '|................................................|', FIM_TEXTO
VLinha15        STR     '--------------------------------------------------', FIM_TEXTO
Titulo		STR	'*** PAC_MAN (MEEC 17/18) ***', FIM_TEXTO
Vidas		STR	'#Vidas:', FIM_TEXTO
Pontos		STR	'#Pontos:', FIM_TEXTO
LCDLinha0	STR	'PAC_MAN',FIM_TEXTO
LCDLinha1	STR	'Rank1: ',FIM_TEXTO

RITMO        STR   50,40,30,20,10,1


Clock_Tic	WORD	000ah
N_to_Display	WORD	0001h
Update_Display	WORD	0000h
Pausa		WORD	0000h

;===============================================================================
; ZONA III: Codigo
;           conjunto de instrucoes Assembly, ordenadas de forma a realizar
;           as funcoes pretendidas
;===============================================================================
                ORIG    0000h
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
; MoveDown_Pac: Rotina de interrupcao 2
;
;===============================================================================
MoveDown_Pac:   NOP	; completar rotina de atendimento da int 2
		PUSH	R1
		MOV		R1, M[PacMan]
		MOV		M[IO_CURSOR], R1
		MOV		R1, NOTHING
		CALL	EscCar
		MOV		R1, M[PacMan]
		ADD		R1, 0100h
		MOV		M[PacMan], R1
		MOV		M[IO_CURSOR], R1
		MOV		R1, PAC_MAN
		CALL	EscCar
		POP	R1
        RTI

;===============================================================================
; MoveLeft_Pac: Rotina de interrupcao 4
;
;===============================================================================
MoveLeft_Pac:   NOP	; completar rotina de atendimento da int 4
                PUSH	R1
				MOV		R1, M[PacMan]
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[PacMan]
				SUB		R1, 0001h
				MOV		M[PacMan], R1
				MOV		M[IO_CURSOR], R1
				MOV		R1, PAC_MAN
				CALL	EscCar
				POP	R1
				RTI

;===============================================================================
; MoveRight_Pac: Rotina de interrupcao 6
;
;===============================================================================
MoveRight_Pac:  NOP	; completar rotina de atendimento da int 6
                PUSH	R1
				MOV		R1, M[PacMan]
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[PacMan]
				ADD		R1, 0001h
				MOV		M[PacMan], R1
				MOV		M[IO_CURSOR], R1
				MOV		R1, PAC_MAN
				CALL	EscCar
				POP	R1
				RTI

;===============================================================================
; MoveUp_Pac: Rotina de interrupcao 8
;
;===============================================================================
MoveUp_Pac:     NOP	; completar rotina de atendimento da int 8

				PUSH	R1
        PUSH  R2
        MOV		R1, M[PacMan]
        SUB   R1,0100h
        MOV		M[IO_CURSOR], R1
        MOV		R2, M[R1]
        CMP		R2, '-'
        BR.Z	NVALIDA
        CMP		R2, '|'
        BR.Z	NVALIDA
        ADD   R1,0100h
				MOV		R1, M[PacMan]
				MOV		M[IO_CURSOR], R1
				MOV		R1, NOTHING
				CALL	EscCar
				MOV		R1, M[PacMan]
				SUB		R1, 0100h
        MOV		M[PacMan], R1
        MOV		M[IO_CURSOR], R1
        MOV		R1, PAC_MAN
        CALL	EscCar

  NVALIDA:POP R2
				  POP	R1

				RTI

;===============================================================================
; Validar_Jogada:
;				Entradas:	R1 - Possivel posição do PacMan
;       Saidas:R3
;				-	== 002Dh
;				|	== 007Ch
;
;===============================================================================
Validar_Jogada:             NOP
                            PUSH  R1
                      			PUSH	R2
                            MOV   R3,0
                            SUB   R1,0100h
                  					MOV		R2, M[W]
                  					CMP		R2, '-'
                  					BR.Z	FIM_Validar_Jogada
                  					CMP		R2, '|'
                  					BR.Z	FIM_Validar_Jogada
                            MOV   R3,0001h
FIM_Validar_Jogada:					POP		R2
                            POP   R1
                            RET

;===============================================================================
; Cria_monstro:
;				Entradas:	R1 - Possivel posição do PacMan
;
;
;0101h, 0D01h, 0130h, 0D30h
;==============================================================================
Cria_monstro:            NOP
                         PUSH	R1
                         PUSH R2
                         PUSH R3
                         MOV  R3,4
                         MOV  R2,Monsters
              CRIAR:     MOV		R1, M[R2]
                         MOV		M[IO_CURSOR], R1
                         MOV		R1, MONSTER
                         CALL	EscCar
                         ADD    R2,1
                         SUB    R3,1
                         BR.NZ CRIAR
                         POP R3
                         POP R2
                         POP R1
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
		MOV	R1,
		MOV	M[TempControlo], R1
		MOV	M[Update_Display], R1
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
		RETss-sdd-s-d-.s-.sd-sd-s--s-s.-sd-.s.-s-s.sd-s.-sd.-s-.

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
			MOV			R1, M[PacMan]
			MOV			M[IO_CURSOR] , R1
			MOV			R1, PAC_MAN
			CALL		EscCar
      MOV   R2,Monsters
      MOV		R1, M[R2]
      MOV		M[IO_CURSOR], R1
      MOV		R1, MONSTER
      CALL	EscCar
      ADD   R2,1
      MOV		R1, M[R2]
      MOV		M[IO_CURSOR], R1
      MOV		R1, MONSTER
      CALL	EscCar
      ADD   R2,1
      MOV		R1, M[R2]
      MOV		M[IO_CURSOR], R1
      MOV		R1, MONSTER
      CALL	EscCar
      ADD   R2,1
      MOV		R1, M[R2]
      MOV		M[IO_CURSOR], R1
      MOV		R1, MONSTER
      CALL	EscCar
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
		; Exemplo de colocar uma contagem sincrona no display de 7 segmentos
					MOV		M[Update_Display], R0
					MOV		R1, M[N_to_Display]
					INC 	R1
					MOV		M[N_to_Display], R1
					MOV		M[DISP7S1], R1
					ROR		R1, 4
					MOV		M[DISP7S2], R1
					ROR		R1, 4
					MOV		M[DISP7S3], R1
					POP		R1
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
		SUB	R1, 1010h
		TEST	R2, 0001h
		ADD	R1, 0100h
   	MOV	M[IO_CURSOR], R1
		MOV	M[PacMan], R1
		MOV	R1, PAC_MAN
		MOV	M[IO_WRITE], R1
		POP	R3
		POP	R2
		POP	R1
		RET


;TODO

===============================================================================
; Monsters_Aleat:
;===============================================================================

Monsters_Aleat:	PUSH	R1
		PUSH	R2
		PUSH	R3
    PUSH  R4
    PUSH  R5
		; Exemplo de colocar um simbolo a mover no ecran ... sem valida��o de limites
		; e com I2 a colocar o Pacman no ponto de partida
    MOV R5,4
    MOV R4,Monsters
GERA:	CALL	Random_Gen
    MOV R2,M[RandomWord]
    ROR R2,3
    CMP R1,R2
    ;SE FOR NEGATIVO,VAI PARA CIMA
    ;SE FOSSE 0 IA ANALISAR A HORIZONTAL

    2 MANEIRA
;DEPOIS DO CALL
;AND COM D

    3 MANEIRA
    ;LOOP PARA VER SE É VÁLIDA

    4 MANEIRA,
    ANALISAR OS 3 BITS MAIS SIGNIFICATIVOS
    SE FOR 000 ELE FAZ MOVE MoveDown
    SE FOR 001 ELE FAZ MOVE UP
    SE FOR 010 ELE FAZ MOVE MoveRight
    SE FOR 011 ELE FAZ MOVE MoveLeft
    SE FOR 100,101,110 OU 111 ELE VAI PARA UMA DAS DIAGONAIS
    FAZEMOS UM CATÁLOGO DE INSTRUÇÕES





		MOV	R1,M[R4]
		MOV	M[IO_CURSOR], R1
		MOV	R3, ' '
		MOV	M[IO_WRITE], R3
		MOV	R2, M[RandomWord]
    SUB R1,R2
  	MOV	M[IO_CURSOR], R1
		MOV	M[Monsters], R1
		MOV	R1, MONSTER
		MOV	M[IO_WRITE], R1
    ADD R4,1
    SUB R5,1
    BR.NZ GERA
    POP R5
    POP R4
		POP	R3
		POP	R2
		POP	R1
		RET
    ;===============================================================================
    ; confronto:
    ;===============================================================================

    confronto:
          PUSH R1
          PUSH R2
          MOV R1, M[PAC_MAN]
          MOV R2, M[Monsters]
          CMP R1,R2
          BR.NZ NAO
          SUB PacMan_Vidas,1
    NAO:  POP R2
          POP R1


    		RET

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
;===============================================================================
inicio:     MOV     R1, SP_INICIAL
    	    MOV     SP, R1
			CALL	InitInt

			ENI
Reinicia:	CALL    LimpaJanela
          NOP		; completar com programa principal
		     	CALL	Print_Labi
          COR  : CALL Monsters_Aleat
                  CALL WAIT
                BR COR





NoUpDateDisplay:	NOP
			MOV		R1, M[Update_Display]
			CMP		R1, 0
			BR.Z	NoUpDateDisplay
			CALL	UpDate_Display
			;==== Escrita nos LEDS ====
			MOV		R1, M[N_to_Display]
			MOV		M[LEDS], R1
			;==== Escrita no LCD ====
			MOV		R2, 8008h
			MOV		M[LCD_CURSOR], R2
			AND		R1, 000Fh
			ADD		R1, 48
				; Nota: Somar 48 corresponde a obter o c�digo dos
				; digitos em ASCII ... altere o c�digo de modo a escrever
				; os digitos hexadecimais em vez dos caracteres que surgem
				; no c�digo ASCII a seguir ao 9.
			MOV		M[LCD_WRITE], R1

		;==== Pausa com recurso a I0 ====
Em_Pausa:	MOV	R1, M[Pausa]
			CMP	R1, 1
			MOV		R1, 0001h
			MOV		M[PORTMASCARA_INT], R1
			BR.Z	Em_Pausa	;se no endereço estiver a um, ele continua em pausa
			MOV		R1, 9D55h
			MOV		M[PORTMASCARA_INT], R1

		JMP	NoUpDateDisplay

Fim:            BR     	Fim

;===============================================================================
