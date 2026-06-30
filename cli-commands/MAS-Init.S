;APS00002099000020990000209900002099000020990000209900002099000020990000209900002099
; Reset MAS-Player "MAS-Init"

ExecBase =	     4

; EXEC
CloseLibrary =	  -414
OpenLibrary =	  -552

; DOS
ModeOld =	  1005
ModeNew =	  1006

Open =		   -30
Close =		   -36
Read =		   -42
Write =		   -48


; Hauptprogramm
Main
; A5 für indirekte Zugriffe
	Lea	VB(PC),A5
; Librarys
	Bsr.w	Open_Dos_Library
	Beq.b	Main_Close
; Status über das Abspielen holen
	Bsr.w	Open_Env_Status
	Beq.b	Main_Init
	Bsr.w	Read_Status
	Bsr.w	Close_Env_Status
; Vergleiche, ob dar Player nicht spielt!
	Lea	Env_Status_Base-VB(A5),A0
	Cmp.L	#"STOP",(A0)
	Bne.b	Main_Close
; Nur wenn der Player nicht spielt, darf der Chip initialisiert werden
Main_Init
; Datenrichtung am Parallelport festlegen
	Bsr.w	Direction
; Reset
	Bsr.w	MAS_Reset
; Chip Initialisieren
	Bsr.w	MAS_Init
; Neuen Status schreiben
	Bsr.w	Open_New_Env_Status
	Bsr.w	Write_Status
	Bsr.w	Close_Env_Status
; Programm verlassen
Main_Close
	Bsr.w	Close_Dos_Library
	Rts

; DOS Library öffnen
Open_Dos_Library
	Tst.L	Dos_Base-VB(A5)
	Bne.b	Open_Dos_Return
	Move.L	ExecBase,A6
	Lea	Dos_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,Dos_Base-VB(A5)
Open_Dos_Return
	Rts

; DOS Library schließen
Close_Dos_Library
	Tst.L	Dos_Base-VB(A5)
	Beq.b	Close_Dos_Return
	Move.L	ExecBase,A6
	Move.L	Dos_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
	Move.L	#0,Dos_Base-VB(A5)
Close_Dos_Return
	Rts

; Variable Status öffnen zum lesen
Open_Env_Status
	Lea	Env_Status_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Env_Status_Hd-VB(A5)
	Rts

; Variable Status_schließen
Close_Env_Status
	Tst.L	Env_Status_Hd-VB(A5)
	Beq.b	Close_Env_Status_Exit
	Move.L	Dos_Base-VB(A5),A6
	Move.L	Env_Status_Hd-VB(A5),D1
	Jsr	Close(A6)
Close_Env_Status_Exit
	Rts

; Variable Status lesen
Read_Status
	Move.L	Env_Status_Hd-VB(A5),D1
	Lea	Env_Status_Base-VB(A5),A6
	Move.L	A6,D2
	Move.L	#16,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
Read_Status_Exit
	Rts

; Variable Status öffnen zum schreiben
Open_New_Env_Status
	Lea	Env_Status_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeNew,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Env_Status_Hd-VB(A5)
	Rts

; Variable Status schreiben
Write_Status
	Move.L	Env_Status_Hd-VB(A5),D1
	Lea	Env_Status_Write_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Rts

; Datenrichtung am Parallelport
Direction
; Parallelprot D0-7 auf Ausgabe schalten
	Move.B	#%11111111,$BFE301
; Datenrichtung "Busy", "PaperOut" auf Eingabe
	Move.B	#%11000000,$BFD200
	Rts

; MAS Resetleitung ziehen
MAS_Reset
	Lea	$BFE101,A1
	Move.B	#%11111111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11111111,(A1)
	Rts

MAS_Init
; Serielles Interface initialisieren (ab G10 nötig)!
; (Write $0020 into register $3B)
	Lea	$BFE101,A1
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$93,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$B0,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$02,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
; (Execute "RUN 1" command)
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$01,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
; Initialisierung des MAS (Start-up configuration),  laut PDF-Dokumentation.
	Lea	$BFE101,A1
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$9E,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$62,D0		; Bit 0=PI0 1=PI1 2=PI2 3=PI3
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0		; Bit 0=PI4 4=PI8
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
	Rts

; I2C Start
Write_IIC_S
	Move.B	#%11111111,(A1)
	Move.B	#%11110111,(A1)
	Move.B	#%11110111,(A1)
	Move.B	#%11110011,(A1)
	Rts

; I2C Stop
Write_IIC_P
	Move.B	#%11110011,(A1)
	Move.B	#%11110111,(A1)
	Move.B	#%11110111,(A1)
	Move.B	#%11111111,(A1)
	Rts

; I2C 1
Write_IIC_1
	Move.B	#%11110011,(A1)
	Move.B	#%11111011,(A1)
	Move.B	#%11111111,(A1)
	Move.B	#%11111011,(A1)
	Move.B	#%11110011,(A1)
	Rts

; I2C 0
Write_IIC_0
	Move.B	#%11110011,(A1)
	Move.B	#%11110011,(A1)
	Move.B	#%11110111,(A1)
	Move.B	#%11110011,(A1)
	Move.B	#%11110011,(A1)
	Rts

; Schiebe Byte (D0) zum IC2-Bus
Write_IIC_D0
	Moveq.L	#9,D1
Write_Loop
	Subq.B	#1,D1
	Beq.b	Write_IIC_0
	Rol.B	#1,D0
	Btst	#0,D0
	Beq.b	Write_0
	Bsr.b	Write_IIC_1
	Bra.b	Write_Loop
Write_0
	Bsr.b	Write_IIC_0
	Bra.b	Write_Loop


; Beginn der Variablen
VB

; Information über die Versionsnummer
Version
	Dc.B	"$VER:MAS-Init V0.6",0
	Even

; DOS
Dos_Base
	Dc.L	0
Dos_Name
	Dc.B	"dos.library",0
	Even

; Variable Status
Env_Status_Name
	Dc.B	"env:MAS_Status",0
	Even
; File Hd für die Variable
Env_Status_Hd
	Dc.L	0
; Puffer beim Einlesen der Variable
Env_Status_Base
	Dcb.B	16,0
; Wenn der Chip Initialisiert wurde, dann wird dies in die Status Variable geschrieben
Env_Status_Write_Buffer
	Dc.B	"INIT"
	Even
