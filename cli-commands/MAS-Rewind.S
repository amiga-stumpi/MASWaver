;APS00001AB500001AB500001AB500001AB500001AB500001AB500001AB500001AB500001AB500001AB5
; Track Rewind "MAS-Rewind"

ExecBase =	     4

; EXEC
CloseLibrary =	  -414
OpenLibrary =	  -552

; DOS
ModeNew =	  1006

Open =		   -30
Close =		   -36
Write =		   -48


; Hauptprogramm
Main
; A5 für indirekte Zugriffe
	Lea	VB(PC),A5
; Librarys
	Bsr.w	Open_Dos_Library
	Beq.b	Main_Close
; Neuen Status schreiben zum Zurückspulen
	Bsr.w	Open_New_Env_Status
	Bsr.w	Write_Status
	Bsr.w	Close_Env_Status
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
	Move.L	#6,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
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


; Beginn der Variablen
VB

; Information über die Versionsnummer
Version
	Dc.B	"$VER:MAS-Rewind V0.1",0
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
; Information die das Abspielen unterbricht
Env_Status_Write_Buffer
	Dc.B	"REWIND"
	Even
