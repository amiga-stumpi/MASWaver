;APS00000DAF00000DAF00000DAF00000DAF00000DAF00000DAF00000DAF00000DAF00000DAF00000DAF
;	»»»-------------------------------------------------------------«««
;	»»»								«««
;	»»»	MAS-Player						«««
;	»»»	~~~~~~~~~~						«««
;	»»»	Copyright:	Dirk Conrad				«««
;	»»»			Holländerstr.38	13407	(45198051)	«««
;	»»»								«««
;	»»»	Assembler:	ASM-PRO V1.16				«««
;	»»»								«««
;	»»»-------------------------------------------------------------«««

ExecBase =	     4

; EXEC
MEMF_PUBLIC =	     1
MEMF_CHIP =	     2
MEMF_FAST =	     4
MEMF_CLEAR =	 65536
MEMF_LARGEST =	131072

AddIntServer =	  -168
RemIntServer =	  -174
AllocMem =	  -198
FreeMem =	  -210
FindTask =	  -294
SetTaskPri =	  -300
GetMsg =	  -372
ReplyMsg =	  -378
WaitPort =	  -384
CloseLibrary =	  -414
OpenLibrary =	  -552

; DOS
ModeOld =	  1005
ModeNew =	  1006

Open =		   -30
Close =		   -36
Read =		   -42
Write =		   -48
Seek =		   -66
DeleteFile =	   -72
Rename =	   -78
Lock =		   -84
UnLock =	   -90
Examine =	  -102
ExNext =	  -108
CurrentDir =	  -126
Delay =		  -198

; INTUITION
CloseScreen =	   -66
CloseWindow =	   -72
DisplayBeep =	   -96
DrawImage =	  -114
OpenScreen =	  -198
OpenWindow =	  -204
ScreenToBack =	  -246
RefreshGList =	  -432
AddGList =	  -438
RemoveGList =	  -444

; GRAPHICS
TextLength =	   -54
Text =		   -60
Move =		  -240
SetAPen =	  -342
SetBPen =	  -348
SetDrMd =	  -354
SetRGB4 =	  -288
VBeamPos =	  -384

; DISKFONT
OpenDiskFont =	   -30

; ASL
AllocFileRequest = -30
FreeFileRequest =  -36
RequestFile =	   -42

; Festwerte
BFP_Raw_Size =	    59840
Plane_Size =	    11968
File_List_Size	=  131074
Load_Size =	    32000

; CLI oder WB-Startup
; ~~~~~~~~~~~~~~~~~~~

Startup
	Lea	VB(PC),A5
;	Bra.w	Main
	Movem.L	D0/A0,-(SP)
	Move.L	#0,WB_Msg-VB(A5)
	Move.L	#0,Start_File_Lock-VB(A5)
	Move.L	ExecBase,A6
	Sub.L	A1,A1
	Jsr	FindTask(A6)
	Move.L	D0,A4
	Tst.L	$AC(A4)
	Beq.b	Workbench
	Movem.L	(SP)+,D0/A0
	Bra.b	Main
Workbench
	Lea	$5C(A4),A0
	Jsr	WaitPort(A6)
	Lea	$5C(A4),A0
	Jsr	GetMsg(A6)
	Move.L	D0,WB_Msg-VB(A5)
	Move.L	D0,A0
	Move.L	$24(A0),A0
	Move.L	(A0),Start_File_Lock-VB(A5)
	Movem.L	(SP)+,D0/A0
	Bsr.b	Main
	Move.L	D0,-(SP)
	Move.L	ExecBase,A6
	Move.L	WB_Msg-VB(A5),A1
	Jsr	ReplyMsg(A6)
	Move.L	(SP)+,D0
	Rts

WB_Msg
; Workbench-Nachricht
	Dc.L	0
Start_File_Lock
; File Lock beim Start
	Dc.L	0


; Hauptprogramm
; ~~~~~~~~~~~~~

Version
	Dc.B	"$VER:Amiga MAS-Player 1.3g (19-DEC-2004)",0
	Even

Main
	Lea	VB(PC),A5
	Bsr.w	Open_Dos_Library
	Beq.w	Main_Close_All
	Bsr.w	Open_Intuition_Library
	Beq.w	Main_Close_All
	Bsr.w	Open_Graphics_Library
	Beq.w	Main_Close_All
	Bsr.w	ResetHardware
	Bsr.w	Open_Diskfont_Library
	Beq.b	Main_Close_All
	Bsr.w	Open_Diskfont
	Beq.b	Main_Close_All
	Bsr.w	Alloc_Mem_BFP
	Beq.b	Main_Close_All
	Bsr.w	Alloc_Mem_File_List
	Beq.b	Main_Close_All
	Bsr.w	Open_Screen
	Beq.b	Main_Close_All
	Lea	Skin_About,A0
	Bsr.w	Copy_Skin_Data
	Bne.b	Main_Close_All
	Bsr.w	Open_Window
	Beq.b	Main_Close_All
	Bsr.w	Current_Dir
	Bsr.w	Open_Prefs
	Bsr.w	Alloc_Mem_Play_Buffer
	Beq.b	Main_Close_All
	Bsr.w	Test_Hardware
	Jsr	Add_About_Gadgets
	Bne.b	Main_Close_All
	Tst.B	Hardware_Flag-VB(A5)
	Beq.b	Main_No_Hardware
	Bsr.w	Window_Playlist
Main_No_Hardware
	Bsr.w	Get_Path
	Bsr.w	Add_Interrupt
	Tst.b	Start_Flag-VB(A5)
	Beq.b	Main_Loop
	Bsr.w	Play
Main_Loop
	Bsr.w	Load
	Bsr.b	Err_LED
	Bsr.w	Analyse
	Bsr.w	Get_Msg_Information
	Bsr.w	Do_Gadgets
	Bne.b	Main_Loop
	Bsr.w	Stop
	Move.W	#0,Error-VB(A5)
Main_Close_All
	Tst.W	Error-VB(A5)
	Beq.b	Main_No_Error
	Jsr	Error_Output
Main_No_Error
	Bsr.w	Rem_Interrupt
	Bsr.w	Free_Mem_Play_Buffer
	Bsr.w	Close_Window
	Bsr.w	Close_Screen
	Bsr.w	Free_Mem_File_List
	Bsr.w	Free_Mem_BFP
	Bsr.w	Analyse_Free_Mem
	Bsr.w	Close_Diskfont_Library
	Bsr.w	Close_Graphics_Library
	Bsr.w	Close_Intuition_Library
	Bsr.w	Close_Dos_Library
	Moveq.L	#0,D0
Return
	Rts


; Farbe der Fehler-LED setzen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~

Err_LED
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Return
	Btst.B	#2,$BFD000
	Beq.b	Err_LED_Green
Err_LED_Red
	Tst.B	Err_LED_Color-VB(A5)
	Bne.b	Return
	Move.L	Graphics_Base-VB(A5),A6
	Move.L	Screen_View_Port-VB(A5),A0
	Move.L	#15,D1
	Moveq.L	#0,D2
	Moveq.L	#0,D3
	Move.L	#14,D0
	Jsr	SetRGB4(A6)
	Move.B	#1,Err_LED_Color-VB(A5)
	Rts
Err_LED_Green
	Tst.B	Err_LED_Color-VB(A5)
	Beq.b	Return
	Move.L	Graphics_Base-VB(A5),A6
	Move.L	Screen_View_Port-VB(A5),A0
	Moveq.L	#0,D1
	Move.L	#15,D2
	Moveq.L	#0,D3
	Move.L	#14,D0
	Jsr	SetRGB4(A6)
	Move.B	#0,Err_LED_Color-VB(A5)
	Rts

Err_LED_Color
	Dc.B	0
	Even


; Hole Informationen über Aktionen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get_Msg_Information
	Move.W	#-1,Push_Gadget-VB(A5)
	Move.L	Window_Hd-VB(A5),A0
	Move.L	86(A0),A0
	Move.L	ExecBase,A6
	Jsr	GetMsg(A6)
	Tst.L	D0
	Beq.w	Get_Msg_Joy
	Move.L	D0,A0
	Move.L	20(A0),D6
	Btst	#6,D6
	Bne.b	Get_Msg_Gadget
	Btst	#10,D6
	Bne.b	Get_Msg_Key
	Move.L	D0,A1
	Move.L	ExecBase,A6
	Jsr	ReplyMsg(A6)
	Rts
Get_Msg_Gadget
; Wenn ein Gadget ausgewählt wurde
	Move.L	28(A0),A1
	Move.W	38(A1),Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key
	Move.L	D0,A1
	Move.B	$19(A1),D1
	Cmp.B	#25,D1
	Beq.w	Get_Msg_Key_p
	Cmp.B	#$73,D1 ; CDTV
	Beq.w	Get_Msg_Key_p
	Cmp.B	#33,D1
	Beq.w	Get_Msg_Key_s
	Cmp.B	#$72,D1 ; CDTV
	Beq.w	Get_Msg_Key_s
	Cmp.B	#19,D1
	Beq.w	Get_Msg_Key_r
	Cmp.B	#$74,D1 ; CDTV
	Beq.w	Get_Msg_Key_r
	Cmp.B	#35,D1
	Beq.w	Get_Msg_Key_f
	Cmp.B	#$75,D1 ; CDTV
	Beq.w	Get_Msg_Key_f
	Cmp.B	#76,D1
	Beq.w	Get_Msg_Key_Up
	Cmp.B	#$3E,D1
	Beq.w	Get_Msg_Key_Up
	Cmp.B	#77,D1
	Beq.w	Get_Msg_Key_Down
	Cmp.B	#$3F,D1
	Beq.w	Get_Msg_Key_Down
	Cmp.B	#80,D1
	Beq.w	Get_Msg_Key_F1
	Cmp.B	#$1D,D1
	Beq.w	Get_Msg_Key_F1
	Cmp.B	#81,D1
	Beq.w	Get_Msg_Key_F2
	Cmp.B	#$1E,D1
	Beq.w	Get_Msg_Key_F2
	Cmp.B	#82,D1
	Beq.w	Get_Msg_Key_F3
	Cmp.B	#$1F,D1
	Beq.w	Get_Msg_Key_F3
	Cmp.B	#83,D1
	Beq.w	Get_Msg_Key_F4
	Cmp.B	#$2D,D1
	Beq.w	Get_Msg_Key_F4
	Cmp.B	#84,D1
	Beq.w	Get_Msg_Key_F5
	Cmp.B	#$2E,D1
	Beq.w	Get_Msg_Key_F5
	Cmp.B	#34,D1
	Beq.w	Get_Msg_Key_d
	Cmp.B	#$43,D1
	Beq.w	Get_Msg_Key_Enter
	Cmp.B	#66,D1
	Beq.w	Get_Msg_Key_Tab
	Cmp.B	#$45,D1
	Beq.w	Get_Msg_Key_ESC
	Bra.w	Get_Msg_Return
Get_Msg_Key_p
	Move.W	#300,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_s
	Move.W	#301,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_r
	Move.W	#302,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_f
	Move.W	#303,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_Up
	Move.W	#212,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_Down
	Move.W	#213,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_F1
	Move.W	#100,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_F2
	Move.W	#101,Push_Gadget-VB(A5)
	Bra.w	Get_Msg_Return
Get_Msg_Key_F3
	Move.W	#102,Push_Gadget-VB(A5)
	Bra.b	Get_Msg_Return
Get_Msg_Key_F4
	Move.W	#103,Push_Gadget-VB(A5)
	Bra.b	Get_Msg_Return
Get_Msg_Key_F5
	Move.W	#104,Push_Gadget-VB(A5)
	Bra.b	Get_Msg_Return
Get_Msg_Key_d
	Move.W	#200,Push_Gadget-VB(A5)
	Bra.b	Get_Msg_Return
Get_Msg_Key_ESC
	Move.L	D0,D0_Save-VB(A5)
	Bsr.w	Window_Playlist
	Bsr.w	Get_Path
	Move.L	D0_Save-VB(A5),D0
	Bra.b	Get_Msg_Return
Get_Msg_Key_Enter
	Move.L	D0,D0_Save-VB(A5)
	Bsr.w	Window_Playlist
	Bsr.w	Del_All_From_Key
	Bsr.w	Get_Path
	Bsr.w	Add_All
	Bsr.w	Play
	Move.L	D0_Save-VB(A5),D0
	Bra.b	Get_Msg_Return
Get_Msg_Key_Tab
	Tst.B	Folder-VB(A5)
	Bne.b	Get_Msg_Return
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Beq.b	Get_Msg_Return
	Tst.L	File_Name_Pos-VB(A5)
	Beq.b	Get_Msg_Return
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
	Cmp.B	#":",-1(A1)
	Beq.b	Get_Msg_Key_d
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
	Bra.w	File_Parent_Dir
Get_Msg_Return
	Move.L	D0,A1
	Move.L	ExecBase,A6
	Jsr	ReplyMsg(A6)
Get_Msg_Joy
	Move.W	$DFF00C,D0
	Btst	#1,D0
	Bne.b	Get_Msg_Joy_f
	Btst	#9,D0
	Bne.b	Get_Msg_Joy_r
	Move.W	D0,D1
	Lsr.W	#1,D1
	Eor.W	D0,D1
	Btst	#0,D1
	Bne.w	Get_Msg_Joy_Down
	Btst	#8,D1
	Bne.b	Get_Msg_Joy_Up
	Btst.B	#7,$BFE001
	Beq.w	Get_Msg_Joy_p
Get_Msg_Exit
	Rts
Get_Msg_Joy_r
	Move.L	Play_Pos-VB(A5),D0
	Beq.b	Get_Msg_Joy_r_Exit
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#3,D1
	Jsr	Delay(A6)
	Move.L	Play_Pos-VB(A5),A0
Get_Msg_Joy_r_Loop
	Sub.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_r_Loop
	Cmp.B	#23,(A0)
	Beq.w	File_Select_From_Joy
	Cmp.B	#24,(A0)
	Beq.w	Playlist_Select_From_Joy
Get_Msg_Joy_r_Exit
	Moveq.L	#-1,D0
	Rts
Get_Msg_Joy_f
	Move.L	Play_Pos-VB(A5),D0
	Beq.b	Get_Msg_Joy_f_Exit
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#3,D1
	Jsr	Delay(A6)
	Move.L	Play_Pos-VB(A5),A0
Get_Msg_Joy_f_Loop
	Add.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_f_Loop
	Cmp.B	#23,(A0)
	Beq.w	File_Select_From_Joy
	Cmp.B	#24,(A0)
	Beq.w	Playlist_Select_From_Joy
Get_Msg_Joy_f_Exit
	Moveq.L	#-1,D0
	Rts
Get_Msg_Joy_Up
	Move.L	Play_Pos-VB(A5),D0
	Beq.b	Get_Msg_Joy_Up_Exit
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#3,D1
	Jsr	Delay(A6)
	Move.L	Play_Pos-VB(A5),A0
Get_Msg_Joy_Up_Loop
	Sub.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Up_Loop
	Cmp.B	#23,(A0)
	Beq.b	Get_Msg_Joy_Up_Sub
	Cmp.B	#24,(A0)
	Beq.b	Get_Msg_Joy_Up_Sub
	Bra.b	Get_Msg_Joy_Up_Exit
Get_Msg_Joy_Up_Sub
	Move.L	#10,D0
Get_Msg_Joy_Up_Sub_Loop
	Sub.L	#32,A0	
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Up_Sub_Loop
	Subq.L	#1,D0
	Beq.b	Get_Msg_Joy_Up_Loop_End
	Cmp.B	#23,(A0)
	Beq.b	Get_Msg_Joy_Up_Sub_Loop
	Cmp.B	#24,(A0)
	Beq.b	Get_Msg_Joy_Up_Sub_Loop
Get_Msg_Joy_Up_Loop_End
	Add.L	#32,A0
	Cmp.B	#23,(A0)
	Beq.w	File_Select_From_Joy
	Cmp.B	#24,(A0)
	Beq.w	Playlist_Select_From_Joy
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Up_Loop_End
Get_Msg_Joy_Up_Exit
	Moveq.L	#-1,D0
	Rts
Get_Msg_Joy_Down
	Move.L	Play_Pos-VB(A5),D0
	Beq.b	Get_Msg_Joy_Down_Exit
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#3,D1
	Jsr	Delay(A6)
	Move.L	Play_Pos-VB(A5),A0
Get_Msg_Joy_Down_Loop
	Add.L	#32,A0
	Cmp.B	#23,(A0)
	Beq.b	Get_Msg_Joy_Down_Add
	Cmp.B	#24,(A0)
	Beq.b	Get_Msg_Joy_Down_Add
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Down_Loop
	Bra.b	Get_Msg_Joy_Down_Exit
Get_Msg_Joy_Down_Add
	Move.L	#10,D0
Get_Msg_Joy_Down_Add_Loop
	Add.L	#32,A0	
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Down_Add_Loop
	Subq.L	#1,D0
	Beq.b	Get_Msg_Joy_Down_Loop_End
	Cmp.B	#23,(A0)
	Beq.b	Get_Msg_Joy_Down_Add_Loop
	Cmp.B	#24,(A0)
	Beq.b	Get_Msg_Joy_Down_Add_Loop
Get_Msg_Joy_Down_Loop_End
	Sub.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Get_Msg_Joy_Down_Loop_End
	Cmp.B	#23,(A0)
	Beq.w	File_Select_From_Joy
	Cmp.B	#24,(A0)
	Beq.w	Playlist_Select_From_Joy
Get_Msg_Joy_Down_Exit
	Moveq.L	#-1,D0
	Rts
Get_Msg_Joy_p
	Btst.B	#7,$BFE001
	Beq.b	Get_Msg_Joy_p
	Move.W	#300,Push_Gadget-VB(A5)
	Bsr.w	Wait
	Rts

Push_Gadget
; Nr. des Gadgets, welches betätigt wurde
	Dc.L	-1

D0_Save
	Dc.L	0


; Aktionen bei betätigung eines Gadgets
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Do_Gadgets
	Move.W	Push_Gadget-VB(A5),D0
	Bls.w	Do_Nothing
	Cmp.W	#002,D0
	Beq.w	Screen_To_Back
	Cmp.W	#100,D0
	Beq.w	Window_Playlist
	Cmp.W	#101,D0
	Beq.w	Window_Control
	Cmp.W	#102,D0
	Beq.w	Window_Cue
	Cmp.W	#103,D0
	Beq.w	Window_Prefs
	Cmp.W	#104,D0
	Beq.w	Window_About
	Cmp.W	#300,D0
	Beq.w	Play
	Cmp.W	#301,D0
	Beq.w	Stop
	Cmp.W	#302,D0
	Beq.w	Play_Prev
	Cmp.W	#303,D0
	Beq.w	Play_Next
	Cmp.W	#310,D0
	Beq.w	Play_Rep
	Move.B	Folder-VB(A5),D1
	Tst.B	D1
	Beq.b	Do_Playlist_Gadgets
	Cmp.B	#1,D1
	Beq.w	Do_Control_Gadgets
	Cmp.B	#2,D1
	Beq.w	Do_Cue_Gadgets
	Cmp.B	#3,D1
	Beq.w	Do_Prefs_Gadgets
	Bra.w	Do_Nothing
Do_Playlist_Gadgets
	Cmp.W	#200,D0
	Beq.w	Get_Device_List
	Cmp.W	#201,D0
	Beq.w	Search
	Cmp.W	#203,D0
	Beq.w	Add_All
	Cmp.W	#204,D0
	Beq.w	Del_All
	Cmp.W	#205,D0
	Beq.w	Add
	Cmp.W	#206,D0
	Beq.w	Del
	Cmp.W	#207,D0
	Beq.w	Move_Up
	Cmp.W	#208,D0
	Beq.w	Move_Down
	Cmp.W	#210,D0
	Beq.w	Goto_Top
	Cmp.W	#211,D0
	Beq.w	Goto_Button
	Cmp.W	#212,D0
	Beq.w	Goto_Up
	Cmp.W	#213,D0
	Beq.w	Goto_Down
	Cmp.W	#220,D0
	Beq.w	Print_List_Slider
	Move.W	Last_FileS_PropY-VB(A5),D1
	Cmp.W	FileS_PropY-VB(A5),D1
	Bne.w	Print_List_Slider
	Cmp.W	#231,D0
	Beq.w	File_1
	Cmp.W	#232,D0
	Beq.w	File_2
	Cmp.W	#233,D0
	Beq.w	File_3
	Cmp.W	#234,D0
	Beq.w	File_4
	Cmp.W	#235,D0
	Beq.w	File_5
	Cmp.W	#236,D0
	Beq.w	File_6
	Cmp.W	#237,D0
	Beq.w	File_7
	Cmp.W	#238,D0
	Beq.w	File_8
	Cmp.W	#239,D0
	Beq.w	File_9
	Cmp.W	#240,D0
	Beq.w	File_10
	Cmp.W	#241,D0
	Beq.w	File_11
	Cmp.W	#242,D0
	Beq.w	File_12
	Cmp.W	#243,D0
	Beq.w	File_13
	Bra.w	Do_Nothing
Do_Control_Gadgets
	Cmp.W	#320,D0
	Beq.w	Play_PosS
	Cmp.W	#330,D0
	Beq.w	Volume_Slider
	Cmp.W	#331,D0
	Beq.w	Volume_Up
	Cmp.W	#332,D0
	Beq.w	Volume_Down
	Cmp.W	#340,D0
	Beq.w	Treble_Slider
	Cmp.W	#341,D0
	Beq.w	Treble_0
	Cmp.W	#342,D0
	Beq.w	Treble_Mid
	Cmp.W	#350,D0
	Beq.w	Bass_Slider
	Cmp.W	#351,D0
	Beq.w	Bass_0
	Cmp.W	#352,D0
	Beq.w	Bass_Mid
	Cmp.W	#360,D0
	Beq.w	Prefactor_Slider
	Cmp.W	#361,D0
	Beq.w	Prefactor_0
	Cmp.W	#362,D0
	Beq.w	Prefactor_Mid
	Cmp.W	#375,D0
	Beq.w	Play_Genre
	Cmp.W	#380,D0
	Beq.w	Remove_TAG_Infos
	Cmp.W	#381,D0
	Beq.w	Save_TAG_Infos
	Bra.w	Do_Nothing
Do_Cue_Gadgets
	Cmp.W	#500,D0
	Beq.w	Play_AnalyseS
	Cmp.W	#510,D0
	Beq.w	Print_Cue
	Cmp.W	#520,D0
	Beq.w	Cue_Add_Track
	Cmp.W	#521,D0
	Beq.w	Cue_Add_Index
	Cmp.W	#530,D0
	Beq.w	Split_MP
	Cmp.W	#531,D0
	Beq.w	Save_Cue
	Cmp.W	#540,D0
	Beq.w	Delete_Complete_Cue
	Cmp.W	#550,D0
	Beq.w	Cue_Play0
	Cmp.W	#551,D0
	Beq.w	Cue_Play1
	Cmp.W	#552,D0
	Beq.w	Cue_Play2
	Cmp.W	#553,D0
	Beq.w	Cue_Play3
	Cmp.W	#554,D0
	Beq.w	Cue_Play4
	Cmp.W	#555,D0
	Beq.w	Cue_Play5
	Cmp.W	#556,D0
	Beq.w	Cue_Play6
	Cmp.W	#557,D0
	Beq.w	Cue_Play7
	Cmp.W	#558,D0
	Beq.w	Cue_Play8
	Cmp.W	#559,D0
	Beq.w	Cue_Play9
	Cmp.W	#560,D0
	Beq.w	Cue_Delete0
	Cmp.W	#561,D0
	Beq.w	Cue_Delete1
	Cmp.W	#562,D0
	Beq.w	Cue_Delete2
	Cmp.W	#563,D0
	Beq.w	Cue_Delete3
	Cmp.W	#564,D0
	Beq.w	Cue_Delete4
	Cmp.W	#565,D0
	Beq.w	Cue_Delete5
	Cmp.W	#566,D0
	Beq.w	Cue_Delete6
	Cmp.W	#567,D0
	Beq.w	Cue_Delete7
	Cmp.W	#568,D0
	Beq.w	Cue_Delete8
	Cmp.W	#569,D0
	Beq.w	Cue_Delete9
	Bra.w	Do_Nothing
Do_Prefs_Gadgets
	Cmp.W	#400,D0
	Beq.w	Toggle_Assign
	Cmp.W	#401,D0
	Beq.w	Toggle_MP
	Cmp.W	#410,D0
	Beq.w	Set_Task_Pri
	Cmp.W	#420,D0
	Beq.w	Toggle_Rep_Kind
	Cmp.W	#421,D0
	Beq.w	Toggle_Auto
	Cmp.W	#422,D0
	Beq.w	Toggle_CPU
	Cmp.W	#423,D0
	Beq.w	Toggle_Analyse
	Cmp.W	#424,D0
	Beq.w	Toggle_Start
	Cmp.W	#425,D0
	Beq.w	Toggle_Random
	Cmp.W	#430,D0
	Beq.w	Set_Play_Buffer
	Cmp.W	#436,D0
	Beq.w	Select_PLS
	Cmp.W	#441,D0
	Beq.w	Select_Path
	Cmp.W	#446,D0
	Beq.w	Select_SplitTo
	Cmp.W	#450,D0
	Beq.w	Open_Prefs
	Cmp.W	#451,D0
	Beq.w	Save_Prefs
Do_Nothing
	Tst.W	D0
	Rts


; MAS-Player Hardware zurücksetzen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ResetHardware
	Move.B	#%11111111,$BFE301
	Move.B	#%11000000,$BFD200
	Lea	$BFE101,A1
	Move.B	#%11111111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11101111,(A1)
	Move.B	#%11111111,(A1)
; Ser.Interface initialisieren (ab G10)
; (Write $0020 into register $3B)
	Bsr.w	Wait
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
; Startup Config
	Bsr.w	Wait
	Lea	$BFE101,A1
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$9E,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$62,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
	Rts


; Teste, welche Hardware vorhanden ist
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Test_Hardware
	Bsr.w	Wait
	Move.L	Send_Size-VB(A5),Send_Size_Save-VB(A5)
Test_Pro
	Move.B	#2,Hardware_Flag-VB(A5)
	Move.W	#274,D7
	Lea	Sound,A0
	Move.L	A0,Send_Adr-VB(A5)
	Moveq.L	#-1,D6
Test_Pro_Loop
	Move.L	#200,Send_Size-VB(A5)
	Move.L	#200,Load_Count-VB(A5)
	Move.L	A5,A1
	Jsr	Send_From_Test_Hardware
	Move.L	A1,A5
	Tst.L	D6
	Beq.b	Test_Pro_CRC
	Cmp.W	#250,D7
	Beq.b	Test_Pro_Exit
Test_Pro_CRC
	Btst.B	#2,$BFD000
	Bne.b	Test_Pro_Demand
	Moveq.L	#0,D6
Test_Pro_Demand
	Btst.B	#0,$BFD000
	Beq.b	Test_Pro_Demand
	Subq.W	#1,D7
	Bne.b	Test_Pro_Loop
	Tst.L	D6
	Beq.b	Test_Found
Test_Pro_Exit
Test_Lite
	Move.B	#1,Hardware_Flag-VB(A5)
	Move.W	#274,D7
	Lea	Sound,A0
	Move.L	A0,Send_Adr-VB(A5)
	Moveq.L	#-1,D6
Test_Lite_Loop
	Move.L	#200,Send_Size-VB(A5)
	Move.L	#200,Load_Count-VB(A5)
	Move.L	A5,A1
	Jsr	Send_From_Test_Hardware
	Move.L	A1,A5
	Tst.L	D6
	Beq.b	Test_Lite_CRC
	Cmp.W	#250,D7
	Beq.b	Test_Lite_Exit
Test_Lite_CRC
	Btst.B	#2,$BFD000
	Bne.b	Test_Lite_Demand
	Moveq.L	#0,D6
Test_Lite_Demand
	Btst.B	#0,$BFD000
	Beq.b	Test_Lite_Demand
	Subq.W	#1,D7
	Bne.b	Test_Lite_Loop
	Tst.L	D6
	Beq.b	Test_Found
Test_Lite_Exit
	Move.B	#0,Hardware_Flag-VB(A5)
Test_Found
	Move.L	Send_Size_Save-VB(A5),Send_Size-VB(A5)
	Move.L	Play_Buffer_Base-VB(A5),A0
	Move.L	A0,Send_Adr-VB(A5)
	Rts

Hardware_Flag
; Zeigt an, welche Hardware vorhanden ist
; 0 = Keine
; 1 = MAS-Player Lite
; 2 = MAS-Player PRO
	Dc.B	0
	Even

Send_Size_Save
	Dc.L	0


; Interrupt
; ~~~~~~~~~

Add_Interrupt
	Tst.B	Int_Get_Flag-VB(A5)
	Bne.w	Return
; CIA B Interrupt
	Moveq.L	#13,D0
	Lea	Interrupt_Struc,A1
	Move.L	ExecBase,A6
	Jsr	AddIntServer(A6)
; Timer starten
	Move.B	#%00010001,$BFDE00
; Tmier A Lo
	Move.B	#0,$BFD400
; Timer A Hi
	Move.B	#4,$BFD500
; Timer A Interrupt erlauben
	Move.B	#%10000001,$BFDD00
	Move.B	#-1,Int_Get_Flag
	Rts

Rem_Interrupt
	Tst.B	Int_Get_Flag-VB(A5)
	Beq.w	Return
; Timer stopen
	Move.B	#%00010000,$BFDE00
; Timer A Interrupt verbieten
	Move.B	#%10000001,$BFDD00
; CIA B Interrupt
	Moveq.L	#13,D0
	Lea	Interrupt_Struc,A1
	Move.L	ExecBase,A6
	Jsr	RemIntServer(A6)
	Move.B	#0,Int_Get_Flag
	Rts

Interrupt_Struc
	Dc.L	0
	Dc.L	0
	Dc.B	2
	Dc.B	0
	Dc.L	Interrupt_Name
	Dc.L	VB
	Dc.L	Send

Int_Get_Flag
	Dc.B	0

Interrupt_Name
	Dc.B	"Amiga MAS-Player",0
	Even


; Laden des Titels
; ~~~~~~~~~~~~~~~~

Load
; Soll überhaupt geladen werden?
	Tst.B	Play_Flag-VB(A5)
	Beq.w	Load_Return
; Hat sich der Regler bewegt?
	Lea	PosS_PropX-VB(A5),A0
	Move.W	(A0),D0
	Cmp.W	Load_Last_PosS-VB(A5),D0
	Beq.w	Load_Part
	Move.W	D0,Load_Last_PosS-VB(A5)
; Bin ich im Folder Control?
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Load_Refresh_Analyse
; Prop Gadget Refresh
	Lea	PosS_PropStep-VB(A5),A0
	Move.L	Load_Count-VB(A5),D0
	Lsr.L	#6,D0
	Move.W	D0,(A0)
	Lea	PosS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Sub.L	A2,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Load_Refresh_Analyse
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.b	Load_Part
; Bin ich im Folder Cue?
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Load_Part
; Aktuelle Zeit berechnen
	Move.L	Analyse_Pointer-VB(A5),D0
	Sub.L	#16384,D0
	Divu	#65535,D0
	Move.L	D0,D2
	Swap	D2
	Move.W	AnalyseS_PropX-VB(A5),D1
	Mulu	D1,D0
	Mulu	D1,D2
	Lsr.L	#8,D2
	Lsr.L	#8,D2
	Add.L	D2,D0
	And.L	#$FFFFFFFC,D0
	Move.L	Analyse_Load_Base-VB(A5),A0
	Add.L	#16384,A0
	Add.L	D0,A0
	Move.L	(A0),D0
	Lea	Time_Text-VB(A5),A0
	Bsr.w	Calc_Time_D0_A0
	Bsr.w	Print_Time
; Wird das Gadget gerade angefasst?
	Btst.B	#0,AnalyseS_PropInfo
	Bne.b	Load_Part
; Prop Gadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Sub.L	A2,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Load_Part
	Move.L	Buffer_Size-VB(A5),D0
	Move.L	Load_Count-VB(A5),D1
	Add.L	#Load_Size,D1
	Cmp.L	D0,D1
	Bhs.b	Load_Return
; Lade in den Buffer
	Move.L	Play_Hd-VB(A5),D1
	Move.L	Load_Adr-VB(A5),D2
	Move.L	#Load_Size,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.b	Load_End
	Add.L	D0,Load_Adr-VB(A5)
	Add.L	D0,Load_Count-VB(A5)
	Move.L	Play_Buffer_Base-VB(A5),D0
	Add.L	Buffer_Size-VB(A5),D0
	Cmp.L	Load_Adr-VB(A5),D0
	Bne.b	Load_Return
	Move.L	Play_Buffer_Base-VB(A5),Load_Adr-VB(A5)
Load_End
; Lied am Ende
	Move.L	Load_Count-VB(A5),D0
	Cmp.L	#250,D0
	Bge.b	Load_Return
	Bsr.w	Stop
	Bsr.w	Play_Next
Load_Return
	Rts

Load_Adr
	Dc.L	0

Load_Count
	Dc.L	0

Load_Count_Save
	Dc.L	0

Load_Last_PosS
	Dc.W	0


; Play Funktionen
; ~~~~~~~~~~~~~~~

Play
	Move.L	Play_Pos-VB(A5),D0
	Bne.b	Play_Test
; Wenn kein Lied angewählt ist
	Move.L	File_List_Base-VB(A5),A0
	Tst.W	(A0)
	Beq.w	Play_Exit
	Cmp.B	#12,(A0)
	Beq.w	Play_Exit
	Move.L	A0,Play_Pos-VB(A5)
	Sub.L	#32,Play_Pos-VB(A5)
	Bra.w	Play_Next
Play_Test
; Teste ob neues Lied angewählt wurde
	Tst.B	Play_New_Flag-VB(A5)
	Beq.b	Play_Old
; Wenn ja, dann altes Lied stoppen
	Bsr.w	Stop
	Move.B	#0,Play_New_Flag-VB(A5)
; Analyse start
	Move.B	#0,Start_Analyse_Flag-VB(A5)
Play_Old
; Teste ob Lied bereits spielt
	Tst.B	Play_Flag-VB(A5)
; Wenn ja, dann Pause
	Bne.w	Pause
; Lock holen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,Play_Lock-VB(A5)
	Beq.w	Stop
; File Info Block füllen
	Move.L	Play_Lock-VB(A5),D1
	Lea	Play_File_Info_Block-VB(A5),A6
	Move.L	A6,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Examine(A6)
; Lock freigeben
	Move.L	Play_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
; Lied öffnen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeOld,D2
	Jsr	Open(A6)
	Move.L	D0,Play_Hd-VB(A5)
	Beq.w	Stop
Play_Seek_TAG
; Gehe zu TAG Informationen
	Move.L	Play_Hd-VB(A5),D1
	Move.L	#-128,D2
	Moveq.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; TAG lesen
	Move.L	Play_Hd-VB(A5),D1
	Lea	Play_TAG_Info_Text-VB(A5),A6
	Move.L	A6,D2
	Move.L	#128,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; String Gadgets vorbereiten
	Lea	Title_Buffer-VB(A5),A0
	Lea	Play_File_Info_Block-VB(A5),A1
	Add.L	#8,A1
	Moveq.L	#-1,D1
Play_Title_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Addq.L	#1,D1
	Cmp.L	#30,D1
	Beq.b	Play_Title_End
	Tst.B	D0
	Bne.b	Play_Title_Loop
Play_Title_End
	Move.B	#0,-1(A0)
	Lea	Title_Len-VB(A5),A0
	Move.W	D1,(A0)
	Lea	Artist_Buffer-VB(A5),A0
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
Play_Artist_Name_Loop1
	Move.B	-(A1),D0
	Cmp.B	#"/",D0
	Beq.b	Play_Artist_Name
	Cmp.B	#":",D0
	Beq.b	Play_Artist_Name
	Bra.b	Play_Artist_Name_Loop1
Play_Artist_Name
	Addq.L	#1,A1
	Moveq.L	#-1,D1
Play_Artist_Name_Loop2
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Addq.L	#1,D1
	Cmp.L	#30,D1
	Beq.B	Play_Artist_Name_End
	Cmp.B	#"/",D0
	Beq.b	Play_Artist_Name_End
	Cmp.B	#":",D0
	Beq.b	Play_Artist_Name_End
	Tst.B	D0
	Beq.b	Play_Artist_Name_End
	Bra.b	Play_Artist_Name_Loop2
Play_Artist_Name_End
	Move.B	#0,-1(A0)
	Lea	Artist_Len-VB(A5),A0
	Move.W	D1,(A0)
	Lea	Album_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Album_Len-VB(A5),A0
	Move.W	#0,(A0)
	Lea	Comment_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Comment_Len-VB(A5),A0
	Move.W	#0,(A0)
	Lea	Year_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Year_Len-VB(A5),A0
	Move.W	#0,(A0)
	Move.W	#65535,GenreS_PropY-VB(A5)
; Teste ob Lied TAG Info enthält
	Lea	Play_TAG_Info_Text-VB(A5),A0
	Cmp.B	#"T",(A0)+
	Bne.w	Play_Set_Prop
	Cmp.B	#"A",(A0)+
	Bne.w	Play_Set_Prop
	Cmp.B	#"G",(A0)+
	Bne.w	Play_Set_Prop
Play_Prt_TAG
	Lea	Play_TAG_Info_Text-VB(A5),A0
	Add.L	#3,A0
	Lea	Title_Buffer-VB(A5),A1
	Move.W	#30,D0
Play_Titel_Loop
	Move.B	(A0)+,(A1)+
	Subq.W	#1,D0
	Bne.b	Play_Titel_Loop
	Move.W	#31,D1
Play_Title_Cut_Loop
	Subq.W	#1,D1
	Cmp.B	#32,-(A1)
	Beq.b	Play_Title_Cut_Loop
	Move.B	#0,1(A1)
	Move.W	D1,Title_Len-VB(A5)
	Lea	Artist_Buffer-VB(A5),A1
	Move.W	#30,D0
Play_Artist_Loop
	Move.B	(A0)+,(A1)+
	Subq.W	#1,D0
	Bne.b	Play_Artist_Loop
	Move.W	#31,D1
Play_Artist_Cut_Loop
	Subq.W	#1,D1
	Cmp.B	#32,-(A1)
	Beq.b	Play_Artist_Cut_Loop
	Move.B	#0,1(A1)
	Move.W	D1,Artist_Len-VB(A5)
	Lea	Album_Buffer-VB(A5),A1
	Move.W	#30,D0
Play_Album_Loop
	Move.B	(A0)+,(A1)+
	Subq.W	#1,D0
	Bne.b	Play_Album_Loop
	Move.W	#31,D1
Play_Album_Cut_Loop
	Subq.W	#1,D1
	Cmp.B	#32,-(A1)
	Beq.b	Play_Album_Cut_Loop
	Move.B	#0,1(A1)
	Move.W	D1,Album_Len-VB(A5)
	Lea	Year_Buffer-VB(A5),A1
	Moveq.L	#4,D0
Play_Year_Loop
	Move.B	(A0)+,(A1)+
	Subq.W	#1,D0
	Bne.b	Play_Year_Loop
	Move.W	#5,D1
Play_Year_Cut_Loop
	Subq.W	#1,D1
	Cmp.B	#32,-(A1)
	Beq.b	Play_Year_Cut_Loop
	Move.B	#0,1(A1)
	Move.W	D1,Year_Len-VB(A5)
	Lea	Comment_Buffer-VB(A5),A1
	Move.W	#30,D0
Play_Comment_Loop
	Move.B	(A0)+,(A1)+
	Subq.W	#1,D0
	Bne.b	Play_Comment_Loop
	Move.W	#31,D1
Play_Comment_Cut_Loop
	Subq.W	#1,D1
	Cmp.B	#32,-(A1)
	Beq.b	Play_Comment_Cut_Loop
	Move.B	#0,1(A1)
	Move.W	D1,Comment_Len-VB(A5)
	Move.B	(A0),D0
	Cmp.B	#255,D0
	Beq.b	Play_Set_Prop
	Lea	Genre_Tab-VB(A5),A1
	Subq.L	#1,A1
Play_Genre_Loop
	Add.L	#16,A1
	Move.B	(A1),D1
	Cmp.B	#255,D1
	Beq.b	Play_Genre_Found
	Cmp.B	D0,D1
	Bne.b	Play_Genre_Loop
Play_Genre_Found
	Move.W	-15(A1),GenreS_PropY-VB(A5)
Play_Set_Prop
; File auf Prop Gadget Stellung spulen
	Move.L	Play_Buffer_Base-VB(A5),D0
	Move.L	#0,Load_Count-VB(A5)
	Move.L	D0,Load_Adr-VB(A5)
	Move.L	D0,Send_Adr-VB(A5)
	Move.B	#1,Play_Flag-VB(A5)
	Lea	PosS_PropX-VB(A5),A0
	Moveq.L	#0,D2
	Move.W	(A0),D2
	Beq.b	Play_Seek_0
	Lea	Play_File_Info_Block-VB(A5),A0
	Move.L	124(A0),D0
	Divu	#$FFFF,D0
	Mulu	D0,D2
Play_Seek_0
	Moveq.L	#-1,D3
	Move.L	Play_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
Play_Step_Width
; Schrittweite für Prop Gadget berechnen
	Lea	Play_File_Info_Block-VB(A5),A0
	Move.L	124(A0),D0
	Move.L	Send_Size-VB(A5),D1
; D1*25
	Move.L	D1,D2
	Move.L	D1,D3
	Lsl.L	#3,D2
	Lsl.L	#4,D3
	Add.L	D2,D1
	Add.L	D3,D1
; Korrektur wegen Integer
	Add.W	#15,D1
	Divu	D1,D0
	Move.L	#65536,D1
	Tst.W	D0
	Bne.b	Play_Calc_Size
	Moveq.L	#1,D0
Play_Calc_Size
	Divu	D0,D1
	Move.W	D1,Play_Step_Size-VB(A5)
Play_Info
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Play_Exit
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.w	Load
	Bsr.B	Play_Refresh_Info
Play_Exit
	Moveq.L	#-1,D0
	Rts

Play_Refresh_Info
; Stringgadget Refresh
	Lea	Title_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	Artist_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	Album_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	Comment_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	Year_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	GenreS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Move.L	#1,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrundfarbe
	Move.L	#8,D0
	Bsr.w	Set_B_Pen_D0
; Cursor setzen
	Move.L	#47,D0
	Move.L	#71,D1
	Bsr.w	Move_D0_D1
; KBps ausgeben
	Moveq.L	#3,D0
	Lea	KBps_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#106,D0
	Move.L	#71,D1
	Bsr.w	Move_D0_D1
; Hz ausgeben
	Moveq.L	#5,D0
	Lea	Hz_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Genre ausgeben
	Bsr.b	Play_Genre
Play_Refresh_Info_Exit
	Rts

Play_Genre
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Hintergrundfarbe
	Move.L	#0,D0
	Bsr.w	Set_B_Pen_D0
; Cursor setzen
	Move.L	#229,D0
	Move.L	#184,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Lea	Genre_Empty_Text-VB(A5),A0
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#229,D0
	Move.L	#199,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Lea	Genre_Empty_Text-VB(A5),A0
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#229,D0
	Move.L	#214,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Lea	Genre_Empty_Text-VB(A5),A0
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Text transparent
	Moveq.L	#0,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Move.L	#1,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrundfarbe
	Move.L	#0,D0
	Bsr.w	Set_B_Pen_D0
; Cursor setzen
	Move.L	#230,D0
	Move.L	#199,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Lea	Genre_Tab-VB(A5),A0
	Addq.L	#2,A0
	Moveq.L	#0,D0
	Move.W	GenreS_PropY-VB(A5),D0
	Divu	#517,D0
	Lsl.W	#4,D0
	Ext.L	D0
	Add.L	D0,A0
	Move.L	A0,A4
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Textfarbe
	Move.L	#6,D0
	Bsr.w	Set_A_Pen_D0
; Cursor setzen
	Move.L	#230,D0
	Move.L	#184,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Move.L	A4,A0
	Sub.L	#16,A0
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#230,D0
	Move.L	#214,D1
	Bsr.w	Move_D0_D1
; Text ausgeben
	Move.L	A4,A0
	Add.L	#16,A0
	Moveq.L	#13,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
	Moveq.L	#-1,D0
	Rts

Play_PosS
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.b	Play_Set_PosS
	Move.W	PosS_PropX-VB(A5),AnalyseS_PropX-VB(A5)
Play_Set_PosS
; Lied ab neuer Position anspielen
	Move.L	Play_Hd-VB(A5),D1
	Beq.w	Play_PosS_Exit
	Lea	Play_File_Info_Block-VB(A5),A0
	Move.L	124(A0),D0
	Divu	#$FFFF,D0
	Lea	PosS_PropX-VB(A5),A0
	Move.W	(A0),D2
	Mulu	D0,D2
	Moveq.L	#-1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Move.L	Play_Buffer_Base-VB(A5),D0
	Move.L	#0,Load_Count-VB(A5)
	Move.L	D0,Load_Adr-VB(A5)
	Move.L	D0,Send_Adr-VB(A5)
	Move.W	#0,PosS_PropStep-VB(A5)
; Prop Gadget Refresh
	Lea	PosS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Play_PosS_Exit
	Moveq.L	#-1,D0
	Rts

Play_AnalyseS
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.w	Play_AnalyseS_Exit
; Aktuelle Zeit berechnen
	Move.L	Analyse_Pointer-VB(A5),D0
	Sub.L	#16384,D0
	Divu	#65535,D0
	Move.L	D0,D2
	Swap	D2
	Move.W	AnalyseS_PropX-VB(A5),D1
	Mulu	D1,D0
	Mulu	D1,D2
	Lsr.L	#8,D2
	Lsr.L	#8,D2
	Add.L	D2,D0
	And.L	#$FFFFFFFC,D0
	Move.L	Analyse_Load_Base-VB(A5),A0
	Add.L	#16384,A0
	Add.L	D0,A0
	Move.L	(A0),D0
	Lea	Time_Text-VB(A5),A0
	Bsr.w	Calc_Time_D0_A0
	Bsr.w	Print_Time
; Gadget losgelassen
	And.B	#$FE,AnalyseS_PropInfo-VB(A5)
	Move.W	AnalyseS_PropX-VB(A5),PosS_PropX-VB(A5)
; Lied ab neuer Position anspielen
	Move.L	Play_Hd-VB(A5),D1
	Beq.w	Play_AnalyseS_Exit
	Lea	Play_File_Info_Block-VB(A5),A0
	Move.L	124(A0),D0
	Divu	#$FFFF,D0
	Lea	AnalyseS_PropX-VB(A5),A0
	Move.W	(A0),D2
	Mulu	D0,D2
	Moveq.L	#-1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Move.L	Play_Buffer_Base-VB(A5),D0
	Move.L	#0,Load_Count-VB(A5)
	Move.L	D0,Load_Adr-VB(A5)
	Move.L	D0,Send_Adr-VB(A5)
; Prop Gadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Play_AnalyseS_Exit
	Moveq.L	#-1,D0
	Rts

Pause
; Lied anhalten
	Tst.L	Play_Pos-VB(A5)
	Beq.b	Stop
	Move.B	#0,Play_Flag-VB(A5)
; Lied schließen
	Move.L	Dos_Base-VB(A5),A6
	Move.L	Play_Hd-VB(A5),D1
	Beq.b	Pause_Exit
	Jsr	Close(A6)
	Move.L	#0,Play_Hd-VB(A5)
	Move.L	Play_Buffer_Base-VB(A5),D0
	Move.L	#0,Load_Count-VB(A5)
	Move.L	D0,Load_Adr-VB(A5)
	Move.L	D0,Send_Adr-VB(A5)
	Move.W	#0,PosS_PropStep-VB(A5)
; Prop Gadget Refresh
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Pause_Exit
	Lea	PosS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Pause_Exit
	Moveq.L	#-1,D0
	Rts

Stop
; Lied anhalten
	Move.B	#0,Play_Flag-VB(A5)
; Lied schließen
	Move.L	Dos_Base-VB(A5),A6
	Move.L	Play_Hd-VB(A5),D1
	Beq.b	Stop_Set_Gadgets
	Jsr	Close(A6)
	Move.L	#0,Play_Hd-VB(A5)
	Move.L	Play_Buffer_Base-VB(A5),D0
	Move.L	#0,Load_Count-VB(A5)
	Move.L	D0,Load_Adr-VB(A5)
	Move.L	D0,Send_Adr-VB(A5)
	Move.W	#0,PosS_PropStep-VB(A5)
Stop_Set_Gadgets
; Prop Gadget Position auf 0
	Lea	PosS_PropX-VB(A5),A0
	Move.W	#0,(A0)
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Stop_Set_Analyse
; Prop Gadget Refresh
	Lea	PosS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Stop_Set_Analyse
	Lea	Time_Text-VB(A5),A0
	Move.L	#"00:0",(A0)+
	Move.L	#"0:00",(A0)
; Prop Gadget bei Analyse auch auf Position 0
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.b	Stop_No_Refresh
	Lea	AnalyseS_PropX-VB(A5),A0
	Move.W	#0,(A0)
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Stop_No_Refresh
; Prop Gadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bsr.w	Print_Time
Stop_No_Refresh
	Tst.L	Play_Pos-VB(A5)
	Bne.b	Stop_Exit
	Bsr.b	Deselect
Stop_Exit
	Moveq.L	#-1,D0
	Rts

Deselect
; Titel abwählen
	Tst.B	Play_Flag-VB(A5)
	Bne.w	Deselect_Exit
	Lea	Title_Buffer-VB(A5),A0
	Lea	No_Title_Info_Text-VB(A5),A1
Deselect_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Tst.B	D0
	Bne.b	Deselect_Loop
	Lea	Artist_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Album_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Comment_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Year_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	KBps_Text-VB(A5),A0
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)
	Lea	Hz_Text-VB(A5),A0
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)+
	Move.B	#" ",(A0)
	Move.W	#65535,GenreS_PropY-VB(A5)
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Deselect_Analyse
	Bsr.w	Play_Refresh_Info
Deselect_Analyse
; Analyse stop
	Bsr.w	Analyse_Off
Deselect_Exit
	Rts

Play_Prev
; Vorherigen Titel anwählen
	Move.L	File_List_Base-VB(A5),A1
	Move.L	Play_Pos-VB(A5),A0
	Cmp.L	#0,A0
	Beq.b	Play_Prev_Exit
Play_Prev_Loop
	Cmp.L	A0,A1
	Beq.b	Play_Prev_Exit
	Sub.L	#32,A0
	Tst.B	(A0)
	Beq.b	Play_Prev_Exit
	Cmp.B	#23,(A0)
	Beq.b	Play_Prev_OK
	Cmp.B	#24,(A0)
	Beq.b	Play_Playlist_Prev_OK
	Bra.b	Play_Prev_Loop
Play_Prev_OK
	Move.L	A0,Play_Pos-VB(A5)
	Bsr.w	Stop
	Bra.w	File_Select_From_Play
Play_Playlist_Prev_OK
	Move.L	A0,Play_Pos-VB(A5)
	Bsr.w	Stop
	Bra.w	Playlist_Select_From_Play
Play_Prev_Exit
	Moveq.L	#-1,D0
	Rts

Play_Next
; Nächsten Titel anwählen
	Move.L	Play_Pos-VB(A5),A0
	Cmp.L	#0,A0
	Beq.w	Play_Next_Exit
	Tst.B	Play_New_Flag-VB(A5)
	Bne.w	Play
	Tst.B	Repeat_Flag-VB(A5)
	Beq.b	Play_Next_Loop
	Bsr.w	Stop
	Bra.w	Play
Play_Next_Loop
	Tst.b	Random_Flag
	Beq.w	Play_Next_Regulary
Play_Next_Random
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	VBeamPos(A6)
	Move.L	Play_Pos-VB(A5),D1
	Add.L	#32,D1
	Sub.L	File_List_Base-VB(A5),D1
	Lsr.L	#5,D1
	And.L	#$000000FF,D0
	Add.L	D0,D1
Play_Next_Cut_Loop
	Cmp.L	List_Len-VB(A5),D1
	Blo.b	Play_Next_Compare
	Sub.L	List_Len-VB(A5),D1
	Bra.b	Play_Next_Cut_Loop
Play_Next_Compare
	Lea	Random_Notice-VB(A5),A0
	Move.L	#256,D0
Play_Next_Compare_Loop
	Cmp.L	(A0)+,D1
	Beq.b	Play_Next_Double
	Subq.L	#1,D0
	Bne.b	Play_Next_Compare_Loop
; Zahl war nicht dabei
	Lea	Random_Notice-VB(A5),A0
	Move.L	Random_Pointer-VB(A5),D0
	Add.L	D0,A0
	Move.L	D1,(A0)
	Addq.L	#4,D0
	Cmp.L	#256*4,D0
	Beq.b	Clear_Random_Notice
	Move.L	D0,Random_Pointer-VB(A5)
; Zahl ausgewählt	
	Lsl.L	#5,D1
	Move.L	D1,A0
	Add.L	File_List_Base-VB(A5),A0
	Move.L	A0,Play_Pos-VB(A5)
	Bra.b	Play_Next_From_Random
Play_Next_Double
; Zahl war schon vorhanden
	Lea	Random_Notice-VB(A5),A0
	Move.L	Random_Pointer-VB(A5),D0
	Add.L	D0,A0
	Move.L	D1,(A0)
	Addq.L	#4,D0
	Cmp.L	#256*4,D0
	Beq.b	Clear_Random_Notice
	Move.L	D0,Random_Pointer-VB(A5)
	Bra.w	Play_Next_Random
Clear_Random_Notice
	Move.L	#256,D0
	Lea	Random_Notice-VB(A5),A0
Clear_Random_Notice_Loop
	Move.L	#-1,(A0)+
	Subq.L	#1,D0
	Bne.b	Clear_Random_Notice_Loop
	Move.L	#0,Random_Pointer-VB(A5)
	Bra.w	Play_Next_Random
Play_Next_Regulary
	Add.L	#32,A0
	Tst.W	(A0)
	Beq.b	Play_Next_Repeat
Play_Next_From_Random
	Cmp.B	#23,(A0)
	Beq.b	Play_Next_Select
	Cmp.B	#24,(A0)
	Beq.b	Play_Next_Playlist_Select
	Cmp.B	#2,(A0)
	Beq.b	Play_Next_Regulary
	Bra.w	Play_Next_Loop
Play_Next_Select
	Move.L	A0,Play_Pos-VB(A5)
	Bsr.w	Stop
	Bra.w	File_Select_From_Play
Play_Next_Playlist_Select
	Move.L	A0,Play_Pos-VB(A5)
	Bsr.w	Stop
	Bra.w	Playlist_Select_From_Play
Play_Next_Repeat
	Tst.B	Rep_Dir_Flag-VB(A5)
	Beq.b	Play_Next_Exit
Play_Next_Repeat_Loop
	Sub.L	#32,A0
	Cmp.B	#23,(A0)
	Beq.b	Play_Next_OK
	Cmp.B	#24,(A0)
	Beq.b	Play_Next_OK
	Cmp.B	#2,(A0)
	Beq.b	Play_Next_Repeat_Loop
	Bra.b	Play_Next_Stop
Play_Next_OK
	Move.L	File_List_Base-VB(A5),A0
	Sub.L	#32,A0
	Bra.w	Play_Next_Loop
Play_Next_Stop
	Move.L	#0,Play_Pos-VB(A5)
Play_Next_Exit
	Moveq.L	#-1,D0
	Rts

Random_Notice
	Dcb.L	256,-1

Random_Pointer
	Dc.L	0

Play_Rep
; Repeat
	Bchg.B	#0,Repeat_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts

Save_TAG_Infos
	Tst.L	Play_Pos-VB(A5)
	Beq.b	Save_TAG_Exit
	Tst.L	Play_Hd-VB(A5)
	Bne.b	Save_TAG
; Lied öffnen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeOld,D2
	Jsr	Open(A6)
	Beq.b	Save_TAG_Exit
	Move.L	D0,Play_Hd-VB(A5)
	Bsr.b	Save_TAG
; Lied schließen
	Move.L	Dos_Base-VB(A5),A6
	Move.L	Play_Hd-VB(A5),D1
	Jsr	Close(A6)
	Move.L	#0,Play_Hd-VB(A5)
Save_TAG_Exit
	Moveq.L	#-1,D0
	Rts
Save_TAG
; Gehe zu TAG Informationen
	Move.L	Play_Hd-VB(A5),D1
	Move.L	#-128,D2
	Moveq.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Move.L	D0,Seek_Save-VB(A5)
; TAG lesen
	Move.L	Play_Hd-VB(A5),D1
	Move.L	Play_Buffer_Base-VB(A5),D2
	Move.L	#128,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	Play_Buffer_Base-VB(A5),A0
	Cmp.B	#"T",(A0)
	Bne.b	Save_New
	Cmp.B	#"A",1(A0)
	Bne.b	Save_New
	Cmp.B	#"G",2(A0)
	Bne.b	Save_New
; Gehe zu TAG Informationen
	Move.L	Play_Hd-VB(A5),D1
	Move.L	#-128,D2
	Moveq.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
Save_New
; TAG schreiben
	Lea	Play_TAG_Info_Text-VB(A5),A0
	Move.L	#"TAG ",(A0)+
	Moveq.L	#31,D0
Save_Clr_TAG_Loop
	Move.L	#"    ",(A0)+
	Subq.L	#1,D0
	Bne.b	Save_Clr_TAG_Loop
Save_Title
	Lea	Play_TAG_Info_Text+3-VB(A5),A0
	Lea	Title_Buffer-VB(A5),A1
	Move.W	Title_Len-VB(A5),D1
	Beq.b	Save_Artist
Save_Title_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.W	#1,D1
	Bne.b	Save_Title_Loop
Save_Artist
	Lea	Play_TAG_Info_Text+33-VB(A5),A0
	Lea	Artist_Buffer-VB(A5),A1
	Move.W	Artist_Len-VB(A5),D1
	Beq.b	Save_Album
Save_Artist_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.W	#1,D1
	Bne.b	Save_Artist_Loop
Save_Album
	Lea	Play_TAG_Info_Text+63-VB(A5),A0
	Lea	Album_Buffer-VB(A5),A1
	Move.W	Album_Len-VB(A5),D1
	Beq.b	Save_Year
Save_Album_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.W	#1,D1
	Bne.b	Save_Album_Loop
Save_Year
	Lea	Play_TAG_Info_Text+93-VB(A5),A0
	Lea	Year_Buffer-VB(A5),A1
	Move.W	Year_Len-VB(A5),D1
	Beq.b	Save_Comment
Save_Year_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.W	#1,D1
	Bne.b	Save_Year_Loop
Save_Comment
	Lea	Play_TAG_Info_Text+97-VB(A5),A0
	Lea	Comment_Buffer-VB(A5),A1
	Move.W	Comment_Len-VB(A5),D1
	Beq.b	Save_Genre
Save_Comment_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.W	#1,D1
	Bne.b	Save_Comment_Loop
Save_Genre
	Lea	Play_TAG_Info_Text+127-VB(A5),A0
	Moveq.L	#0,D0
	Move.W	GenreS_PropY-VB(A5),D0
	Divu	#517,D0
	Lea	Genre_Tab-VB(A5),A1
	Lsl.W	#4,D0
	Move.B	15(A1,D0.W),(A0)
; Alles schreiben
	Lea	Play_TAG_Info_Text-VB(A5),A6
	Move.L	A6,D2
	Move.L	#128,D3
	Move.L	Play_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Gehe zu alter Position
	Move.L	Play_Hd-VB(A5),D1
	Move.L	Seek_Save-VB(A5),D2
	Moveq.L	#-1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Moveq.L	#-1,D0
	Rts

Remove_TAG_Infos
	Tst.L	Play_Pos-VB(A5)
	Beq.b	Remove_TAG_Exit
	Lea	Title_Buffer-VB(A5),A0
	Lea	Play_File_Info_Block-VB(A5),A1
	Add.L	#8,A1
	Moveq.L	#-1,D1
Remove_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Addq.L	#1,D1
	Tst.B	D0
	Bne.b	Remove_Loop
	Lea	Title_Len-VB(A5),A0
	Move.W	D1,(A0)
	Lea	Artist_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Artist_Len-VB(A5),A0
	Move.W	#0,(A0)
	Lea	Album_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Album_Len-VB(A5),A0
	Move.W	#0,(A0)
	Lea	Comment_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Comment_Len-VB(A5),A0
	Move.W	#0,(A0)
	Lea	Year_Buffer-VB(A5),A0
	Move.B	#0,(A0)
	Lea	Year_Len-VB(A5),A0
	Move.W	#0,(A0)
	Move.W	#65535,GenreS_PropY-VB(A5)
	Bsr.W	Play_Refresh_Info
	Bra.w	Save_TAG_Infos
Remove_TAG_Exit
	Moveq.L	#-1,D0
	Rts


; CUE Funktionen
; ~~~~~~~~~~~~~~

Print_Cue
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Move.L	#0,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrundfarbe
	Move.L	#1,D0
	Bsr.w	Set_B_Pen_D0
	Lea	Cue_List,A0
	Move.W	CueS_PropY-VB(A5),D0
	Lsr.W	#8,D0
	Mulu	#22,D0
	Add.L	D0,A0		
	Move.L	#10,D2
	Move.L	#85,D1
Print_Cue_Loop
; Cursor setzen
	Movem.L	D1-D2/A0,-(A7)
	Move.L	#17,D0
	Bsr.w	Move_D0_D1
	Movem.L	(A7)+,D1-D2/A0
; Text ausgeben
	Move.L	#22,D0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Movem.L	D1-D2/A0,-(A7)
	Jsr	Text(A6)
	Movem.L	(A7)+,D1-D2/A0
	Add.L	#22,A0
	Add.L	#17,D1
	Subq.L	#1,D2
	Bne.b	Print_Cue_Loop
Print_Cue_Exit
	Moveq.L	#-1,D0
	Rts

Cue_Add_Track
	Move.B	#1,Add_Track_Flag-VB(A5)
	Bra.b	Cue_Add_Index_Cont
Cue_Add_Index
	Move.B	#0,Add_Track_Flag-VB(A5)
Cue_Add_Index_Cont
	Lea	Time_Text-VB(A5),A0
	Lea	Time_Save_Text-VB(A5),A1
	Move.L	(A0)+,D5
	Move.L	D5,(A1)+
	Move.L	(A0),D6
	Move.L	D6,(A1)+
	Bsr.w	Time_To_Bin_D5_D6_D0
	Move.L	D0,D7
	Lea	Cue_List,A0
	Move.L	#5808,D1
Cue_Add_Index_Loop
	Sub.L	#22,D1
	Beq.w	Cue_Add_Index_Exit
	Cmp.B	#"X",8(A0,D1.W)
	Bne.b	Cue_Add_Index_Loop
; Vergeiche
	Move.B	13(A0,D1.W),D5
	Lsl.W	#8,D5
	Move.B	14(A0,D1.W),D5
	Lsl.L	#8,D5
	Move.B	15(A0,D1.W),D5
	Lsl.L	#8,D5
	Move.B	16(A0,D1.W),D5
	Move.B	17(A0,D1.W),D6
	Lsl.W	#8,D6
	Move.B	18(A0,D1.W),D6
	Lsl.L	#8,D6
	Move.B	19(A0,D1.W),D6
	Lsl.L	#8,D6
	Move.B	20(A0,D1.W),D6
	Bsr.w	Time_To_Bin_D5_D6_D0
	Cmp.L	D7,D0
	Beq.w	Cue_Add_Index_Exit
	Bhi.b	Cue_Add_Index_Loop
Cue_Add_Index_Found
	Add.L	#22,D1
	Add.L	D1,A0
	Cmp.L	#5808,D1
	Beq.w	Cue_Add_Index_Exit
; Einschieben
	Move.B	Add_Track_Flag-VB(A5),D0
Cut_Add_Track_Ins_Loop
	Lea	Cue_List,A2
	Add.L	#5808,A2
Cut_Add_Index_Ins_Loop
	Move.L	-22(A2),(A2)
	Move.L	-18(A2),4(A2)
	Move.L	-14(A2),8(A2)
	Move.L	-10(A2),12(A2)
	Move.L	-6(A2),16(A2)
	Move.W	-2(A2),20(A2)
	Sub.L	#22,A2
	Cmp.L	A0,A2
	Bne.b	Cut_Add_Index_Ins_Loop
	Subq.B	#1,D0
	Bpl.b	Cut_Add_Track_Ins_Loop
Cua_Add_Track_Ins
	Tst.b	Add_Track_Flag-VB(A5)
	Beq.b	Cue_Add_Index_Ins
	Move.L	#"  TR",(A0)+
	Move.L	#"ACK ",(A0)+
	Move.L	#"00 A",(A0)+
	Move.L	#"UDIO",(A0)+
	Move.L	#"    ",(A0)+
	Move.W	#"  ",(A0)+
	Lea	Time_Save_Text-VB(A5),A1
Cue_Add_Index_Ins
	Move.L	#"    ",(A0)+
	Move.L	#"INDE",(A0)+
	Move.L	#"X 00",(A0)+
	Move.B	#" ",(A0)+
	Lea	Time_Save_Text-VB(A5),A1
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	(A1)+,(A0)+
	Move.B	#" ",(A0)
	Bsr.w	Cue_Correct
	Bsr.w	Print_Cue
Cue_Add_Index_Exit
	Moveq.L	#-1,D0
	Rts

Add_Track_Flag
	Dc.B	0
	Even

Save_Cue
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.w	Save_Cue_Exit
; Datei öffnen
	Move.L	#ModeNew,D2
	Lea	Cue_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Cue_Hd-VB(A5)
	Beq.w	Save_Cue_Exit
	Lea	Cue_List,A4
; Header
	Lea	Cue_Header_Begin-VB(A5),A0
	Move.L	A0,D2
	Moveq.L	#6,D3
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Lea	File_Name-VB(A5),A0
	Move.L	A0,D2
	Moveq.L	#-1,D3
Save_Cue_Name_Loop
	Addq.L	#1,D3
	Move.B	(A0)+,D0
	Bne.b	Save_Cue_Name_Loop
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Lea	Cue_Header_End-VB(A5),A0
	Move.L	A0,D2
	Moveq.L	#7,D3
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Move.L	A4,Cue_List_Pointer-VB(A5)
Save_Cue_Loop
	Move.L	Cue_List_Pointer-VB(A5),A0
	Cmp.L	#"    ",2(A0)
	Beq.b	Save_Cue_Close
	Cmp.L	#"TRAC",2(A0)
	Beq.b	Save_Cue_Track
Save_Cue_Index
	Move.L	#21,D3
	Bra.b	Save_Cue_Line
Save_Cue_Track
	Move.L	#16,D3
Save_Cue_Line
	Move.L	A0,D2
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Beq.b	Save_Cue_Close
	Lea	Cue_CR-VB(A5),A0
	Move.L	A0,D2
	Moveq.L	#2,D3
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Add.L	#22,Cue_List_Pointer-VB(A5)
	Bra.b	Save_Cue_Loop
Save_Cue_Close
; Datei schließen
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Save_Cue_Exit
	Moveq.L	#-1,D0
	Rts

Cue_CR
	Dc.W	$0D0A

Cue_Header_Begin
	Dc.B	"FILE ",34

Cue_Header_End
	Dc.B	34," MP3",$0D,$0A
	Even

Load_Cue
; Lied öffnen
	Lea	Cue_List,A4
	Move.L	A4,Cue_List_Pointer-VB(A5)
	Lea	File_Name-VB(A5),A0
	Lea	Cue_Name-VB(A5),A1
Load_Cue_Name_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Load_Cue_Name_Loop
	Cmp.B	#".",-5(A1)
	Bne.b	Load_Cue_No_Ext
	Move.B	#"C",-4(A1)
	Move.B	#"U",-3(A1)
	Move.B	#"E",-2(A1)
	Bra.b	Load_Cue_Open
Load_Cue_No_Ext
	Move.B	#".",-1(A1)
	Move.B	#"C",(A1)
	Move.B	#"U",1(A1)
	Move.B	#"E",2(A1)
	Move.B	#0,3(A1)
Load_Cue_Open
	Lea	Cue_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeOld,D2
	Jsr	Open(A6)
	Move.L	D0,Cue_Hd-VB(A5)
	Beq.w	Load_Cue_Exit
; Überprüfe ob am Anfang der CUE-List "FILE" steht!
	Move.L	Cue_Hd-VB(A5),D1
	Lea	Cue_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Load_Cue_End
	Move.L	Cue_Buffer-VB(A5),D0
	Or.L	#$20202020,D0
	Cmp.L	#"file",D0
	Bne.w	Load_Cue_End
Load_Cue_Loop
	Move.L	Cue_Hd-VB(A5),D1
	Lea	Cue_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Load_Cue_End
	Lea	Cue_Buffer-VB(A5),A0
	Move.B	(A0),D0
	Or.B	#32,D0
	Cmp.B	#"t",D0
	Beq.b	Load_Cue_Track
	Cmp.B	#"i",D0
	Beq.b	Load_Cue_Index
	Bra.b	Load_Cue_Loop
Load_Cue_Index
	Move.L	Cue_Hd-VB(A5),D1
	Lea	Cue_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Load_Cue_End
	Lea	Cue_Buffer-VB(A5),A0
	Move.L	(A0),D0
	Or.L	#$20202020,D0
	Cmp.L	#"ndex",D0
	Bne.b	Load_Cue_Loop
	Move.L	Cue_List_Pointer-VB(A5),A4
	Move.L	#"    ",(A4)+
	Move.L	#"INDE",(A4)+
	Move.B	#"X",(A4)+
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	A4,D2
	Move.L	#12,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Add.L	#22,Cue_List_Pointer-VB(A5)
	Bra.w	Load_Cue_Loop
Load_Cue_Track
	Move.L	Cue_Hd-VB(A5),D1
	Lea	Cue_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Load_Cue_End
	Lea	Cue_Buffer-VB(A5),A0
	Move.L	(A0),D0
	Or.L	#$20202020,D0
	Cmp.L	#"rack",D0
	Bne.w	Load_Cue_Loop
	Move.L	Cue_List_Pointer-VB(A5),A4
	Move.L	#"  TR",(A4)+
	Move.L	#"ACK ",(A4)+
	Move.L	#"00 A",(A4)
	Move.L	#"UDIO",4(A4)
	Subq.L	#1,A4
	Move.L	Cue_Hd-VB(A5),D1
	Move.L	A4,D2
	Move.L	#3,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Add.L	#22,Cue_List_Pointer-VB(A5)
	Bra.w	Load_Cue_Loop
Load_Cue_End
	Move.L	Dos_Base-VB(A5),A6
	Move.L	Cue_Hd-VB(A5),D1
	Beq.b	Load_Cue_Exit
	Jsr	Close(A6)
	Move.L	#0,Cue_Hd-VB(A5)
Load_Cue_Exit
	Moveq.L	#-1,D0
	Rts

Cue_Hd
	Dc.L	0

Cue_Name
	Dcb.B	2048,0

Cue_Buffer
	Dc.L	0

Cue_List_Pointer
	Dc.L	0

Delete_Complete_Cue
	Bsr.w	Delete_Cue
	Move.W	#0,CueS_PropY-VB(A5)
; Propgadget Refresh
	Lea	CueS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bsr.w	Print_Cue
	Moveq.L	#-1,D0
	Rts

Delete_Cue
	Lea	Cue_List,A0
	Move.L	#5830,D0
Delete_Cue_Loop
	Move.W	#"  ",(A0)+
	Subq.L	#2,D0
	Bne.b	Delete_Cue_Loop
	Lea	Cue_List+2,A0
	Move.L	#"TRAC",(A0)+
	Move.L	#"K 01",(A0)+
	Move.L	#" AUD",(A0)+
	Move.W	#"IO",(A0)
	Lea	Cue_List+26,A0
	Move.L	#"INDE",(A0)+
	Move.L	#"X 01",(A0)+
	Move.L	#" 00:",(A0)+
	Move.L	#"00:0",(A0)+
	Move.W	#"0 ",(A0)
	Rts

Cue_Correct
	Lea	Cue_List,A0
	Move.L	#22,D0
	Move.B	#48,D1
	Move.B	#49,D2
	Move.B	#48,D3
	Move.B	#48,D4
Cue_Correct_Loop
	Cmp.b	#"*",(A0,D0.W)
	Beq.b	Cue_Correct_Del
	Cmp.B	#"K",6(A0,D0.W)
	Beq.w	Cue_Correct_Track
	Cmp.B	#"X",8(A0,D0.W)
	Beq.w	Cue_Correct_Index
Cue_Correct_Cont
	Add.L	#22,D0
	Cmp.L	#5830,D0
	Blo.b	Cue_Correct_Loop
	Sub.L	#22,D0
	Bsr.b	Cue_Cut_End
	Rts
Cue_Correct_Del
	Cmp.L	#5808,D0
	Beq.b	Cue_Correct_End
	Move.L	D0,D5
	Move.L	22(A0,D0.W),(A0,D0.W)
	Move.L	26(A0,D0.W),4(A0,D0.W)
	Move.L	30(A0,D0.W),8(A0,D0.W)
	Move.L	34(A0,D0.W),12(A0,D0.W)
	Move.L	38(A0,D0.W),16(A0,D0.W)
	Move.W	42(A0,D0.W),20(A0,D0.W)
	Add.L	#22,D0
	Bra.b	Cue_Correct_Del
Cue_Correct_End
	Bsr.b	Cue_Cut_End
	Bra.w	Cue_Correct
Cue_Cut_End
	Move.L	#"    ",(A0,D0.W)
	Move.L	#"    ",4(A0,D0.W)
	Move.L	#"    ",8(A0,D0.W)
	Move.L	#"    ",12(A0,D0.W)
	Move.L	#"    ",16(A0,D0.W)
	Move.W	#"  ",20(A0,D0.W)
	Cmp.L	#"TRAC",-20(A0,D0.W)
	Bne.w	Cue_Cut_Return
	Move.L	#"    ",-22(A0,D0.W)
	Move.L	#"    ",-18(A0,D0.W)
	Move.L	#"    ",-14(A0,D0.W)
	Move.L	#"    ",-10(A0,D0.W)
	Move.L	#"    ",-6(A0,D0.W)
	Move.W	#"  ",-2(A0,D0.W)
Cue_Cut_Return
	Rts
Cue_Correct_Track
	Move.B	#48,D3
	Move.B	#48,D4
	Addq.B	#1,D2
	Cmp.B	#58,D2
	Bne.b	Cue_Correct_Track_Set
	Move.B	#48,D2
	Addq.B	#1,D1
	Cmp.B	#58,D1
	Bne.b	Cue_Correct_Track_Set
	Move.B	#"*",(A0,D0.W)
	Bra.w	Cue_Correct_Loop
Cue_Correct_Track_Set
	Move.B	D1,8(A0,D0.W)
	Move.B	D2,9(A0,D0.W)
	Bra.w	Cue_Correct_Cont
Cue_Correct_Index
	Addq.B	#1,D4
	Cmp.B	#58,D4
	Bne.b	Cue_Correct_Index_Set
	Move.B	#48,D4
	Addq.B	#1,D3
	Cmp.B	#58,D3
	Bne.w	Cue_Correct_Index_Set
	Move.B	#"*",(A0,D0.W)
	Bra.w	Cue_Correct_Loop
Cue_Correct_Index_Set
	Move.B	D3,10(A0,D0.W)
	Move.B	D4,11(A0,D0.W)
	Bra.w	Cue_Correct_Cont

Cue_Play0
	Moveq.L	#0,D0
	Bra.b	Cue_Play
Cue_Play1
	Move.L	#22,D0
	Bra.b	Cue_Play
Cue_Play2
	Move.L	#44,D0
	Bra.b	Cue_Play
Cue_Play3
	Move.L	#66,D0
	Bra.b	Cue_Play
Cue_Play4
	Move.L	#88,D0
	Bra.b	Cue_Play
Cue_Play5
	Move.L	#110,D0
	Bra.b	Cue_Play
Cue_Play6
	Move.L	#132,D0
	Bra.b	Cue_Play
Cue_Play7
	Move.L	#154,D0
	Bra.b	Cue_Play
Cue_Play8
	Move.L	#176,D0
	Bra.b	Cue_Play
Cue_Play9
	Move.L	#198,D0
Cue_Play
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.w	Cue_Play_Exit
	Move.W	CueS_PropY-VB(A5),D1
	Lsr.W	#8,D1
	Mulu	#22,D1
	Add.L	D1,D0
	Lea	Cue_List,A0
	Add.L	D0,A0
	Cmp.L	#"TRAC",2(A0)
	Bne.b	Cue_Play_Get_Time
	Add.L	#22,A0
Cue_Play_Get_Time
	Cmp.L	#"    ",4(A0)
	Beq.w	Cue_Play_Exit
	Move.B	13(A0),D5
	Lsl.W	#8,D5
	Move.B	14(A0),D5
	Lsl.L	#8,D5
	Move.B	15(A0),D5
	Lsl.L	#8,D5
	Move.B	16(A0),D5
	Move.B	17(A0),D6
	Lsl.W	#8,D6
	Move.B	18(A0),D6
	Lsl.L	#8,D6
	Move.B	19(A0),D6
	Lsl.L	#8,D6
	Move.B	20(A0),D6
	Bsr.w	Time_To_Bin_D5_D6_D0
	Move.L	D0,D7
	Lea	Time_Total_Text-VB(A5),A0
	Move.L	(A0)+,D5
	Move.L	(A0),D6
	Bsr.w	Time_To_Bin_D5_D6_D0
	Lsr.L	#4,D7
	Lsr.L	#4,D0
	Beq.b	Cue_Play_Zero
	Mulu	#65535,D7
	Divu	D0,D7
Cue_Play_Zero
	Move.W	D7,AnalyseS_PropX-VB(A5)
; Prop Gadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Sub.L	A2,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Play_AnalyseS
Cue_Play_Exit
	Moveq.L	#-1,D0
	Rts

Cue_Delete0
	Moveq.L	#0,D0
	Bra.b	Cue_Delete
Cue_Delete1
	Move.L	#22,D0
	Bra.b	Cue_Delete
Cue_Delete2
	Move.L	#44,D0
	Bra.b	Cue_Delete
Cue_Delete3
	Move.L	#66,D0
	Bra.b	Cue_Delete
Cue_Delete4
	Move.L	#88,D0
	Bra.b	Cue_Delete
Cue_Delete5
	Move.L	#110,D0
	Bra.b	Cue_Delete
Cue_Delete6
	Move.L	#132,D0
	Bra.b	Cue_Delete
Cue_Delete7
	Move.L	#154,D0
	Bra.b	Cue_Delete
Cue_Delete8
	Move.L	#176,D0
	Bra.b	Cue_Delete
Cue_Delete9
	Move.L	#198,D0
Cue_Delete
	Move.W	CueS_PropY-VB(A5),D1
	Lsr.W	#8,D1
	Mulu	#22,D1
	Add.L	D1,D0
	Cmp.L	#22,D0
	Bls.b	Cue_Delete_Exit
	Lea	Cue_List,A0
	Add.L	D0,A0
	Move.B	#"*",(A0)
	Cmp.L	#"TRAC",-20(A0)
	Bne.b	Cue_Delete_End
	Cmp.L	#"    ",26(A0)
	Beq.b	Cue_Delete_Last
	Cmp.L	#"TRAC",24(A0)
	Bne.b	Cue_Delete_End
	Move.B	#"*",22(A0)
	Bra.b	Cue_Delete_End
Cue_Delete_Last
	Move.B	#"*",-22(A0)
Cue_Delete_End
	Bsr.w	Cue_Correct
	Bsr.w	Print_Cue
Cue_Delete_Exit
	Moveq.L	#-1,D0
	Rts

Time_To_Bin_D5_D6_D0
	Moveq.L	#0,D0
; 1er
	Move.B	D6,D0
	Sub.B	#48,D0
; 10er
	Ror.L	#8,D6
	Move.B	D6,D2
	And.L	#$000000FF,D2
	Sub.B	#48,D2
	Mulu	#10,D2
	Add.L	D2,D0
; 100er
	Ror.L	#8,D6
	Ror.L	#8,D6
	Move.B	D6,D2
	And.L	#$000000FF,D2
	Sub.B	#48,D2
	Mulu	#100,D2
	Add.L	D2,D0
	Ror.L	#8,D6
; 1000er
	Move.B	D5,D2
	And.L	#$000000FF,D2
	Sub.B	#48,D2
	Mulu	#1000,D2
	Add.L	D2,D0
; 10000er
	Ror.L	#8,D5
	Ror.L	#8,D5
	Move.B	D5,D2
	And.L	#$000000FF,D2
	Sub.B	#48,D2
	Mulu	#6000,D2
	Add.L	D2,D0
; 100000er
	Ror.L	#8,D5
	Move.B	D5,D2
	And.L	#$000000FF,D2
	Sub.B	#48,D2
	Mulu	#60000,D2
	Add.L	D2,D0
	Ror.L	#8,D5
	Rts

Print_Time
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Move.L	#1,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrundfarbe
	Move.L	#8,D0
	Bsr.w	Set_B_Pen_D0
; Cursor setzen
	Move.L	#5,D0
	Move.L	#51,D1
	Bsr.w	Move_D0_D1
; KBps ausgeben
	Moveq.L	#8,D0
	Lea	Time_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#95,D0
	Move.L	#51,D1
	Bsr.w	Move_D0_D1
; KBps ausgeben
	Moveq.L	#8,D0
	Lea	Time_Total_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
Print_Time_Exit
	Moveq.L	#-1,D0
	Rts

Time_Text
	Dc.B	"00:00:00"

Time_Total_Text
	Dc.B	"00:00:00"

Time_Save_Text
	Dc.B	"        "

Calc_Time_D0_A0
; Minuten
	Move.L	D0,D1
	Divu	#60000,D1
	And.L	#$0000FFFF,D1
	Divu	#100,D1
	And.L	#$0000FFFF,D1
; Minuten zu Dez.
	Move.L	D1,D2
	Move.L	D1,D3
	Divu	#10,D2
	And.L	#$0000FFFF,D2
	Move.B	D2,(A0)
	Add.B	#48,(A0)+
	Mulu	#10,D2
	Sub.B	D2,D3	
	Add.B	#48,D3
	Move.B	D3,(A0)+
; zu Sekunden
	Addq.L	#1,A0
	Mulu	#46875,D1 	; 46875*128 = 6000000
	Lsl.L	#7,D1
	Sub.L	D1,D0
; Sekunden
	Move.L	D0,D1
	Divu	#10000,D1
	And.L	#$0000FFFF,D1
	Divu	#10,D1
	And.L	#$0000FFFF,D1
; Sekunden zu Dez.
	Move.L	D1,D2
	Move.L	D2,D3
	Divu	#10,D2
	And.L	#$0000FFFF,D2
	Move.B	D2,(A0)
	Add.B	#48,(A0)+
	Mulu	#10,D2
	Sub.B	D2,D3	
	Add.B	#48,D3
	Move.B	D3,(A0)+
; zu mil.
	Addq.L	#1,A0
	Mulu	#10,D1
	Mulu	#10000,D1
	Sub.L	D1,D0
; mil.
	Move.L	D0,D1
	Divu	#1000,D1
	And.L	#$0000FFFF,D1
; mil. zu Dez.
	Move.L	D1,D2
	Move.L	D1,D3
	Divu	#10,D2
	And.L	#$0000FFFF,D2
	Move.B	D2,(A0)
	Add.B	#48,(A0)+
	Mulu	#10,D2
	Sub.B	D2,D3	
	Add.B	#48,D3
	Move.B	D3,(A0)+
	Moveq.L	#-1,D0
	Rts

Split_MP
	Tst.B	Analyse_OK_Flag-VB(A5)
	Beq.w	Split_Exit
	Tst.L	Play_Pos-VB(A5)
	Beq.w	Split_Exit
	Move.L	#Split_Div_Tab,A2
; Tabelle erzeugen mit den Größenangaben der Teilung
	Lea	Time_Total_Text-VB(A5),A0
	Move.L	(A0)+,D5
	Move.L	(A0),D6
	Bsr.w	Time_To_Bin_D5_D6_D0
	Move.L	D0,Split_Total-VB(A5)
	Lea	Cue_List+22,A0
Split_Div_Loop
	Add.L	#22,A0
	Cmp.L	#"    ",4(A0)
	Beq.w	Split_Div_End
	Cmp.L	#"TRAC",2(A0)
	Bne.b	Split_Div_Loop
	Add.L	#22,A0
	Move.B	13(A0),D5
	Lsl.W	#8,D5
	Move.B	14(A0),D5
	Lsl.L	#8,D5
	Move.B	15(A0),D5
	Lsl.L	#8,D5
	Move.B	16(A0),D5
	Move.B	17(A0),D6
	Lsl.W	#8,D6
	Move.B	18(A0),D6
	Lsl.L	#8,D6
	Move.B	19(A0),D6
	Lsl.L	#8,D6
	Move.B	20(A0),D6
	Bsr.w	Time_To_Bin_D5_D6_D0
; Teillänge ausrechnen
	Lea	Play_File_Info_Block-VB(A5),A1
	Move.L	124(A1),D1
	Lsr.L	#4,D0
	Lsr.L	#8,D1
	Lsr.L	#4,D1
	Mulu	D1,D0
	Move.L	Split_Total-VB(A5),D7
	Lsr.L	#4,D7
	Beq.b	Split_Div_Zero
	Divu	D7,D0
	And.L	#$0000FFFF,D0
	Lsl.L	#8,D0
	Lsl.L	#4,D0
Split_Div_Zero
	Move.L	D0,(A2)+
	Bra.b	Split_Div_Loop
Split_Div_End
	Move.L	#-1,(A2)
; Datei öffnen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeOld,D2
	Jsr	Open(A6)
	Move.L	D0,Split_Hd-VB(A5)
	Beq.w	Split_Exit
Split_Frame_Loop
; Daten lesen bis zum ersten Frame
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound,D2
	Move.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_End
	Move.L	#Sound,A0
	Cmp.B	#$FF,(A0)
	Bne.b	Split_Frame_Loop
; Daten lesen
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound+1,D2
	Move.L	#2,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_End
; Bitrate merken
	Move.L	#Sound,A0
	Move.B	2(A0),Split_Freq-VB(A5)
	And.B	#%00001100,Split_Freq-VB(A5)
; MPEG merken
	Move.B	1(A0),Split_MPEG-VB(A5)
	And.B	#%00011000,Split_MPEG-VB(A5)
; Layer merken
	Move.B	1(A0),Split_Layer-VB(A5)
	And.B	#%00000110,Split_Layer-VB(A5)
; Frame gefunden, drei zurück
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#-3,D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Filename SplitTo erstellen
	Lea	SplitTo_Buffer-VB(A5),A0
	Lea	Split_File_Name-VB(A5),A1
Split_Copy_Loop
	Move.B	(A0)+,D0
	Beq.b	Split_Test_Name
	Move.B	D0,(A1)+
	Bra.b	Split_Copy_Loop
Split_Test_Name
	Cmp.B	#":",-1(A1)
	Beq.b	Split_Add_Name
	Cmp.B	#"/",-1(A1)
	Beq.b	Split_Add_Name
	Move.B	#"/",(A1)+
Split_Add_Name
	Move.B	#"T",(A1)+
	Move.B	#"R",(A1)+
	Move.B	#"A",(A1)+
	Move.B	#"C",(A1)+
	Move.B	#"K",(A1)+
	Move.B	#"_",(A1)+
	Move.B	#"0",(A1)+
	Move.L	A1,Track_Nr_Pointer-VB(A5)
	Move.B	#"0",(A1)+
	Move.B	#0,(A1)
; Zeiger einrichten
	Move.L	#Split_Div_Tab-4,A0
	Move.L	A0,Split_Div_Pointer-VB(A5)
	Move.L	#0,Split_Read-VB(A5)
; Info zurücksetzen
	Lea	Split_Info_Text-VB(A5),A0
	Move.B	#"0",13(A0)
	Move.B	#"0",14(A0)
Split_Loop
; Pointer addieren
	Add.L	#4,Split_Div_Pointer-VB(A5)
; Info Track addieren
	Lea	Split_Info_Text-VB(A5),A0
	Move.L	Track_Nr_Pointer-VB(A5),A1
	Add.B	#1,14(A0)
	Add.B	#1,(A1)
	Cmp.B	#58,14(A0)
	Bne.b	Split_Prt
	Move.B	#"0",14(A0)
	Move.B	#"0",(A1)
	Add.B	#1,13(A0)
	Add.B	#1,-1(A1)
Split_Prt
; Cursor
	Moveq.L	#95,D0
	Move.L	#160,D1
	Jsr	Move_D0_D1
; Information welcher Track gespeichert wird
	Moveq.L	#16,D0
	Lea	Split_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Ausgabe-Datei öffnen
	Lea	Split_File_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeNew,D2
	Jsr	Open(A6)
	Move.L	D0,Track_Hd-VB(A5)
	Beq.w	Split_End
Split_RnW_Loop
; Daten lesen
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound,D2
	Move.L	#4096,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_End
	Add.L	D0,Split_Read-VB(A5)
; In Ausgabe-Datei schreiben
	Move.L	D0,D3
	Move.L	#Sound,D2
	Move.L	Track_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schauen, wieviel geschrieben werden muß
	Move.L	Split_Div_Pointer-VB(A5),A0
	Move.L	(A0),D0
	Cmp.L	Split_Read-VB(A5),D0
	Bls.w	Split_Frame_Loop2
	Bra.b	Split_RnW_Loop
Split_Frame_False2
	Moveq.L	#2,D0
	Bra.b	Split_Frame_False
Split_Frame_False1
	Moveq.L	#1,D0
	Bra.b	Split_Frame_False
Split_Frame_Loop2
; Daten lesen
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound,D2
	Move.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_Close
	Move.L	#Sound,A0
	Cmp.B	#$FF,(A0)
	Beq.b	Split_Frame_Found
Split_Frame_False
	Add.L	D0,Split_Read-VB(A5)
; In Ausgabe-Datei schreiben
	Move.L	D0,D3
	Move.L	#Sound,D2
	Move.L	Track_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Bra.b	Split_Frame_Loop2
Split_Frame_Found
; Daten lesen
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound+1,D2
	Move.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_Frame_False1
	Moveq.L	#2,D0
; Frame nochmals vergleichen
	Move.L	#Sound,A0
	Btst.B	#7,1(A0)
	Beq.b	Split_Frame_False
	Btst.B	#6,1(A0)
	Beq.b	Split_Frame_False
	Btst.B	#5,1(A0)
	Beq.b	Split_Frame_False
	Move.B	1(A0),D0
	And.B	#%00011000,D0
	Cmp.B	Split_MPEG-VB(A5),D0
	Bne.b	Split_Frame_False
	Move.B	1(A0),D0
	And.B	#%00000110,D0
	Cmp.B	Split_Layer-VB(A5),D0
	Bne.b	Split_Frame_False
; Daten lesen
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#Sound+2,D2
	Move.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Split_Frame_False2
	Moveq.L	#3,D0
; Frame 3. mal vergleichen
	Move.L	#Sound,A0
	Move.B	2(A0),D0
	And.B	#%11110000,D0
	Cmp.B	#%11110000,D0
	Beq.w	Split_Frame_False
	Cmp.B	#%00000000,D0
	Beq.w	Split_Frame_False
	Move.B	2(A0),D0
	And.B	#%00001100,D0
	Cmp.B	Split_Freq-VB(A5),D0
	Bne.w	Split_Frame_False
; Frame gefunden, drei zurück
	Move.L	Split_Hd-VB(A5),D1
	Move.L	#-3,D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
Split_Close
; Ausgabe-Datei schließen
	Move.L	Track_Hd-VB(A5),D1
	Beq.b	Split_End
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	#0,Track_Hd-VB(A5)
	Bra.w	Split_Loop
Split_End
; Datei schließen
	Move.L	Split_Hd-VB(A5),D1
	Beq.b	Split_Prt_Cue
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	#0,Split_Hd-VB(A5)
; Letzte Ausgabe-Datei schließen
	Move.L	Track_Hd-VB(A5),D1
	Beq.b	Split_Prt_Cue
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	#0,Track_Hd-VB(A5)
Split_Prt_Cue
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#1,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#1,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#95,D0
	Move.L	#160,D1
	Jsr	Move_D0_D1
; Information löschen
	Moveq.L	#16,D0
	Lea	Split_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
	Bsr.w	Print_Cue
Split_Exit
	Moveq.L	#-1,D0
	Rts

Split_Hd
	Dc.L	0

Track_Hd
	Dc.L	0

Split_Total
	Dc.L	0

Split_Read
	Dc.L	0

Split_Frame_Counter
	Dc.L	0

Split_Info_Text
	Dc.B	" Write track 01 "
	Even

Split_File_Name
	Dcb.B	266,0

Track_Nr_Pointer
	Dc.L	0

Split_Div_Pointer
	Dc.L	0

Split_Freq
	Dc.B	0
	Even

Split_MPEG
	Dc.B	0
	Even

Split_Layer
	Dc.B	0
	Even

Analyse
	Tst.B	Start_Analyse_Flag
	Bmi.w	Analyse_Close
	Beq.w	Analyse_First
; Stetige Analyse
	Move.L	Analyse_Hd-VB(A5),D1
	Move.L	Analyse_Load_Base-VB(A5),D2
	Move.L	#16384,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Analyse_End
	Add.L	D0,Analyse_Size-VB(A5)
	Move.L	D0,Analyse2Go-VB(A5)
; Analyse Status
	Move.W	Analyse_Status_Count-VB(A5),D0
	Add.W	#1,D0
	Move.W	D0,Analyse_Status_Count-VB(A5)
	Cmp.W	#4,D0
	Bne.b	Analyse_Cont
	Move.W	#0,Analyse_Status_Count-VB(A5)
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Analyse_Cont
	Moveq.L	#0,D0
	Moveq.L	#0,D1
	Lea	Play_File_Info_Block-VB(A5),A0
	Move.W	124(A0),D0
	Lsl.L	#5,D0
	Move.W	Analyse_Size-VB(A5),D1
	Beq.b	Analyse_Zero1
	Divu	D1,D0
Analyse_Zero1
	Move.L	#65535,D1
	Tst.W	D0
	Beq.b	Analyse_Zero2
	Divu	D0,D1
	Lsl.L	#5,D1
Analyse_Zero2
	Move.W	D1,AnalyseS_PropStep-VB(A5)
	Move.W	#0,AnalyseS_PropX-VB(A5)
; Propgadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Analyse_Cont
	Move.L	Analyse2Go,D5
	Sub.L	Analyse_Overflow-VB(A5),D5
	Move.L	Analyse_Load_Base-VB(A5),A0
	Add.L	Analyse_Overflow-VB(A5),A0
Analyse_Frame_Loop
	Subq.L	#1,D5
	Bmi.w	Analyse_Next
	Cmp.B	#$FF,(A0)+
	Beq.b	Analyse_Frame
; Wenn Frame nicht in ordnung, vergl. Dateilänge
	Lea	Play_File_Info_Block-VB(A5),A1
	Move.L	124(A1),D0
; .. vor Dateiende darf ein Fehler entstehen!
	Sub.L	#10240,D0
	Move.L	Analyse_Size-VB(A5),D1
	Sub.L	D5,D1
	Cmp.L	D1,D0
	Bmi.w	Analyse_End
	Cmp.L	#10240,D1
	Blo.b	Analyse_Frame_Loop
Analyse_Error
	Bra.w	Analyse_Break
Analyse_Frame
	Cmp.L	#16384+92160-4,Analyse_Pointer
	Bhs.w	Analyse_Break
; Frame gefunden
	Tst.L	D5
	Beq.w	Analyse_Save_Next1
	Cmp.L	#1,D5
	Beq.w	Analyse_Save_Next2
; KBps errechnen
	Moveq.L	#0,D0
	Moveq.L	#0,D1
	Move.B	(A0),D0
	And.B	#%00001110,D0
	Lsl.W	#5,D0
	Move.B	1(A0),D1
	And.B	#%11110000,D1
	Lsr.B	#2,D1
	Or.W	D1,D0
	Lea	KBps_Tab-VB(A5),A1
	Move.B	2(A1,D0.W),D2
	Cmp.B	#"?",D2
	Beq.b	Analyse_Frame_Loop
	Moveq.L	#0,D2
	Move.B	3(A1,D0.W),D2
	Move.L	(A1,D0.W),KBps_Text-VB(A5)
; Hz errechnen
	Moveq.L	#0,D0
	Moveq.L	#0,D1
	Move.B	(A0),D0
	And.B	#%00011000,D0
	Lsl.B	#2,D0
	Move.B	1(A0),D1
	And.B	#%00001100,D1
	Lsl.B	#1,D1
	Or.W	D1,D0
	Lea	Hz_Tab-VB(A5),A1
	Move.B	4(A1,D0.W),D1
	Cmp.B	#"?",D1
	Beq.w	Analyse_Frame_Loop
	Moveq.L	#0,D3
	Move.W	6(A1,D0.W),D3
	Move.B	5(A1,D0.W),D4
	Move.L	(A1,D0.W),Hz_Text-VB(A5)
	Move.B	4(A1,D0.W),Hz_Text+4-VB(A5)
	Bsr.w	Analyse_Prt
; Zeit in Tabelle schreiben
	Move.L	Analyse_Load_Base-VB(A5),A1
	Add.L	Analyse_Pointer-VB(A5),A1
	Move.L	(A1)+,D0
	Move.L	D0,(A1)
	Lea	Frame_Len_Tab-VB(A5),A2
	Moveq.L	#0,D0
	Move.B	(A0),D0
	And.B	#%00000100,D0	; Layer Bit
	Lsl.B	#4,D0
	Add.B	D4,D0
	Add.L	D0,A2
	Move.L	(A2),D0
	Add.L	D0,(A1)
; Tabelle verkürzen
	Move.L	Analyse_Diver-VB(A5),D0
	Beq.b	Analyse_No_Div
	Subq.L	#1,D0
	Move.L	D0,Analyse_Diver-VB(A5)
	Move.L	(A1),-(A1)
	Bra.b	Analyse_Frame_Len
Analyse_No_Div
	Move.L	#9,Analyse_Diver
	Add.L	#4,Analyse_Pointer-VB(A5)
	Bra.w	Analyse_Frame_Len
Analyse_Frame_Len
; Framelänge berechnen
	Lea	Frame_Size_Tab-VB(A5),A1
	Add.L	D2,D3
	Add.L	D3,A1
	Move.W	(A1),D2
	Subq.L	#1,D2
	Move.B	1(A0),D3
	And.W	#2,D3
	Lsr.W	#1,D3
	Add.L	D3,D2
	Add.L	D2,A0
	Sub.L	D2,D5
	Bra.w	Analyse_Frame_Loop
Analyse_Next
	Add.L	#1,D5
	Neg.L	D5
	Move.L	D5,Analyse_Overflow-VB(A5)
	Bra.w	Analyse_Exit
Analyse_Save_Next1
	Move.L	Analyse_Hd-VB(A5),D1
	Move.L	#-1,D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Subq.L	#1,Analyse_Size-VB(A5)
	Move.L	#0,Analyse_Overflow-VB(A5)
	Bra.w	Analyse_Exit
Analyse_Save_Next2
	Move.L	Analyse_Hd-VB(A5),D1
	Move.L	#-2,D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
	Subq.L	#2,Analyse_Size-VB(A5)
	Move.L	#0,Analyse_Overflow-VB(A5)
	Bra.w	Analyse_Exit

Analyse_First
; Analyse beim ersten mal
	Tst.L	Analyse_Hd-VB(A5)
	Bne.w	Analyse_Close
	Move.B	#1,Start_Analyse_Flag-VB(A5)
	Move.L	#"  - ",KBps_Text-VB(A5)
	Move.L	#"    ",Hz_Text-VB(A5)
	Move.B	#"-",Hz_Text+4-VB(A5)
	Move.L	#0,Analyse_Size-VB(A5)
	Move.L	#0,Analyse_Overflow-VB(A5)
	Bsr.w	Analyse_Prt
	Move.W	#0,AnalyseS_PropX-VB(A5)
	Move.L	#0,Analyse_Last_KBps-VB(A5)
	Move.B	#0,Analyse_OK_Flag-VB(A5)
; Erste "Zeit" vorbereiten
	Move.L	#16384,Analyse_Pointer-VB(A5)
	Move.L	Analyse_Load_Base-VB(A5),A0
	Add.L	Analyse_Pointer-VB(A5),A0
	Move.L	#0,(A0)+
	Move.L	#0,(A0)
	Lea	Time_Text-VB(A5),A0
	Move.L	#"00:0",(A0)+
	Move.L	#"0:00",(A0)
	Lea	Time_Total_Text-VB(A5),A0
	Move.L	#"00:0",(A0)+
	Move.L	#"0:00",(A0)
	Bsr.w	Delete_Cue
	Bsr.w	Load_Cue
	Move.W	#0,CueS_PropY-VB(A5)
; Bin ich im Folder Cue?
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Analyse_Test
; Propgadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	CueS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bsr.w	Print_Time
	Bsr.w	Print_Cue
Analyse_Test
; Analyse erlaubt?
	Tst.B	Analyse_Flag-VB(A5)
	Bne.b	Analyse_First_Open
	Move.B	#-1,Start_Analyse_Flag-VB(A5)
	Bra.w	Analyse_Exit
Analyse_First_Open
; Datei öffnen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Move.L	#ModeOld,D2
	Jsr	Open(A6)
	Move.L	D0,Analyse_Hd-VB(A5)
	Beq.w	Analyse_Break
; Speicher reserviern
	Tst.L	Analyse_Load_Base-VB(A5)
	Bne.w	Analyse_Exit
	Move.L	ExecBase,A6
	Move.L	#16384+92160,D0
	Move.L	#MEMF_PUBLIC+MEMF_CLEAR,D1
	Jsr	AllocMem(A6)
	Move.L	D0,Analyse_Load_Base-VB(A5)
	Beq.w	Analyse_Break
	Moveq.L	#-1,D0
	Rts

Analyse_Prt
	Move.L	KBps_Text-VB(A5),D1
	Move.B	#32,D1
	Cmp.L	#"  - ",D1
	Beq.b	Analyse_Prt_Cont
	Cmp.L	#"  ? ",D1
	Beq.w	Analyse_Prt_Exit
	Cmp.L	#"VBR ",D1
	Beq.w	Analyse_Prt_Exit
	Move.L	Analyse_Last_KBps-VB(A5),D6
	Beq.b	Analyse_Prt_Cont
	Move.B	#32,D6
	Cmp.L	#"    ",D6
	Beq.b	Analyse_Prt_Cont
	Cmp.L	#"  - ",D6
	Beq.b	Analyse_Prt_Cont
	Cmp.L	#"  ? ",D6
	Beq.b	Analyse_Prt_Cont
	Cmp.L	D1,D6
	Beq.b	Analyse_Prt_Exit
	Move.L	#"VBR ",KBps_Text-VB(A5)
Analyse_Prt_Cont
; Bin ich im Folder Control
	Cmp.B	#1,Folder-VB(A5)
	Bne.b	Analyse_Prt_Exit
	Movem.L	D0/D2-D5/A0,-(A7)
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Move.L	#1,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrundfarbe
	Move.L	#8,D0
	Bsr.w	Set_B_Pen_D0
; Cursor setzen
	Move.L	#47,D0
	Move.L	#71,D1
	Bsr.w	Move_D0_D1
; KBps ausgeben
	Moveq.L	#3,D0
	Lea	KBps_Text-VB(A5),A0
	Move.L	(A0),Analyse_Last_KBps-VB(A5)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Cursor setzen
	Move.L	#106,D0
	Move.L	#71,D1
	Bsr.w	Move_D0_D1
; Hz ausgeben
	Moveq.L	#5,D0
	Lea	Hz_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
	Movem.L	(A7)+,D0/D2-D5/A0
Analyse_Prt_Exit
	Rts

Analyse_Break
	Move.L	#0,A0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	DisplayBeep(A6)
Analyse_Off
	Move.W	#65535,AnalyseS_PropStep-VB(A5)
	Move.W	#0,CueS_PropY-VB(A5)
	Bsr.w	Delete_Cue
	Lea	Time_Text-VB(A5),A0
	Move.L	#"00:0",(A0)+
	Move.L	#"0:00",(A0)
	Lea	Time_Total_Text-VB(A5),A0
	Move.L	#"00:0",(A0)+
	Move.L	#"0:00",(A0)
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Analyse_Stop
; Propgadget Refresh
	Lea	CueS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bsr.w	Print_Time
	Bsr.w	Print_Cue
	Bra.b	Analyse_Stop
Analyse_End
	Move.W	#32,AnalyseS_PropStep-VB(A5)
	Move.B	#1,Analyse_OK_Flag-VB(A5)
	Move.L	Analyse_Load_Base-VB(A5),A0
	Add.L	Analyse_Pointer-VB(A5),A0
	Move.L	(A0),D0
	Lea	Time_Total_Text-VB(A5),A0
	Bsr.w	Calc_Time_D0_A0
Analyse_Stop
	Move.B	#-1,Start_Analyse_Flag
	Cmp.B	#2,Folder-VB(A5)
	Bne.b	Analyse_Close
; Propgadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Analyse_Close
	Move.L	Analyse_Hd-VB(A5),D1
	Beq.b	Analyse_Wait
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	#0,Analyse_Hd-VB(A5)
Analyse_Wait
; Den anderen Tasks ein bißchen Zeit spendieren
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#3,D1
	Jsr	Delay(A6)
Analyse_Exit
	Moveq.L	#-1,D0
	Rts

Analyse_Free_Mem
	Tst.L	Analyse_Load_Base-VB(A5)
	Beq.b	Analyse_Free_Mem_Exit
	Move.L	ExecBase,A6
	Move.L	Analyse_Load_Base-VB(A5),A1
	Move.L	#16384+92160,D0
	Jsr	FreeMem(A6)
	Move.L	#0,Analyse_Load_Base-VB(A5)
Analyse_Free_Mem_Exit
	Rts

Start_Analyse_Flag
;  0 = Erste Analyse
;  1 = Analyse in arbeit
; -1 = Analyse beendet
	Dc.B	-1

Analyse_OK_Flag
; 1 = Analyse OK
; 0 = nicht OK
	Dc.B	0
	Even

Analyse_Hd
; Filehandler um das Lied zu untersuchen
	Dc.L	0

Analyse_Load_Base
	Dc.L	0

Analyse_Pointer
; Zeiger in den Speicher bei Analyse
	Dc.L	0

Analyse_Diver
	Dc.L	0

Analyse_Status_Count
; Zähler, damit nicht jedesmal das Gadget refresht wird
	Dc.W	0

Analyse2Go
; Beinhaltet die Anzahl der geladenen Bytes
	Dc.L	0

Analyse_Overflow
	Dc.L	0

Analyse_Size
; Wieviel Bytes schon analysiert wurden
	Dc.L	0

Analyse_Last_KBps
	Dc.L	0

	Cnop	0,4
Play_File_Info_Block
	Dcb.B	260,0

Play_Hd
; File Händler
	Dc.L	0

Play_Lock
	Dc.L	0

Seek_Save
	Dc.L	0

Play_Step_Size
; Schrittweite des Prop Gradets
	Dc.L	0
	Even

Play_Flag
; Information, ob das Lied spielt?
	Dc.B	0
	Even

Play_New_Flag
; Information, ob ein neues Lied angewählt wurde?
	Dc.B	0
	Even

Repeat_Flag
; Soll das Lied wiederholt werden?
	Dc.B	0
	Even

Play_TAG_Info_Text
	Dcb.B	128,0
	Even

Frame_Info
	Dc.L	0

No_Title_Info_Text
	Dc.B	"[NO TRACK SELECTED]",0
	Even

Frame_Size_Tab
; 		?,00   8,02  16,04  24,06  32,08  40,10  48,12  56,14  64,16  80,18  96,20 112,22 128,24 144,26 160,28 192,30 224,32 256,34 320,36 384,38
; 8000
	Dc.W	1,   144,   288,   432,   576,   720,   864,  1008,  1152,  1440,  1728,  2016,  2304,  2592,  2880,     1,     1,     1,     1,     1
; 12000
	Dc.W	1,    96,   192,   288,   384,   480,   576,   672,   768,   960,  1152,  1344,  1536,  1728,  1920,     1,     1,     1,     1,     1
; 11025
	Dc.W	1,   104,   208,   313,   417,   522,   626,   731,   835,  1044,  1253,  1462,  1671,  1880,  2089,     1,     1,     1,     1,     1
; 16000
	Dc.W	1,    72,   144,   216,   288,   360,   432,   504,   576,   720,   864,  1008,  1152,  1296,  1440,     1,     1,     1,     1,     1
; 24000
	Dc.W	1,    48,    96,   144,   192,   240,   288,   336,   384,   480,   576,   672,   768,   864,   960,     1,     1,     1,     1,     1
; 22050
	Dc.W	1,    52,    104,  156,   208,   261,   313,   365,   417,   522,   626,   731,   835,   940,  1044,     1,     1,     1,     1,     1
; 32000
	Dc.W	1,     1,      1,    1,   144,   180,   216,   252,   288,   360,   432,   504,   576,   648,   720,   864,  1008,  1152,  1440,  1728
; 48000
	Dc.W	1,     1,      1,    1,    96,   120,   144,   168,   192,   240,   288,   336,   384,   432,   480,   576,   732,   768,   960,  1152
; 44100
	Dc.W	1,     1,      1,    1,   104,   130,   156,   182,   208,   261,   313,   365,   417,   470,   522,   626,   731,   835,  1044,  1253

KBps_Tab
; MPEG 2 & 2,5
; reserved
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
; Layer3
 	Dc.B	"  ?",000,"  8",002," 16",004," 24",006," 32",008," 40",010," 48",012," 56",014
 	Dc.B	" 64",016," 80",018," 96",020,"112",022,"128",024,"144",026,"160",028,"  ?",000
; Layer2
	Dc.B	"  ?",000,"  8",002," 16",004," 24",006," 32",008," 40",010," 48",012," 56",014
	Dc.B	" 64",016," 80",018," 96",020,"112",022,"128",024,"144",026,"160",028,"  ?",000
; Layer1
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
; MPEG 1
; reserved
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
; Layer3
	Dc.B	"  ?",000," 32",008," 40",010," 48",012," 56",014," 64",016," 80",018," 96",020
	Dc.B	"112",022,"128",024,"160",028,"192",030,"224",032,"256",034,"320",036,"  ?",000
; Layer2
	Dc.B	"  ?",000," 32",008," 48",012," 56",014," 64",016," 80",018," 96",020,"112",022
	Dc.B	"128",024,"160",028,"192",030,"224",032,"256",034,"320",036,"384",038,"  ?",000
; Layer1
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000
	Dc.B	"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000,"  ?",000

KBps_Text
	Dc.B	"  - "

Hz_Tab
; MPEG 2.5
	Dc.B	"11025",0
	Dc.W	80
	Dc.B	"12000",4
	Dc.W	40
	Dc.B	" 8000",8
	Dc.W	0
	Dc.B	"    ?",12
	Dc.W	0
; reserved
	Dc.B	"    ?",16
	Dc.W	0
	Dc.B	"    ?",20
	Dc.W	0
	Dc.B	"    ?",24
	Dc.W	0
	Dc.B	"    ?",28
	Dc.W	0
; MPEG 2
	Dc.B	"22050",32
	Dc.W	200
	Dc.B	"24000",36
	Dc.W	160
	Dc.B	"16000",40
	Dc.W	120
	Dc.B	"    ?",44
	Dc.W	0
; MPEG 1
	Dc.B	"44100",48
	Dc.W	320
	Dc.B	"48000",52
	Dc.W	280
	Dc.B	"32000",56
	Dc.W	240
	Dc.B	"    ?",60
	Dc.W	0

Hz_Text
	Dc.B	"    -   "

Frame_Len_Tab
; Layer 3
;              11025 12000 8000                        22050 24000 16000   44100 48000 32000
	Dc.L	5224,4800,7200,9999,9999,9999,9999,9999,2612,2400,3200,9990,2612,2400,3600,9990
; Layer 2
;              11025 12000 8000                        22050 24000 16000   44100 48000 32000
	Dc.L	9999,9999,9999,9999,9999,9999,9999,9999,5224,4800,7200,9999,2612,2400,3600,9999

Genre_Empty_Text
	Dc.B	"             ",255
Genre_Tab
	Dc.W	0
	Dc.B	"A Capela     ",123
	Dc.W	517
	Dc.B	"Acid         ",34
	Dc.W	1034
	Dc.B	"Acid Jazz    ",74
	Dc.W	1551
	Dc.B	"Acid Punk    ",73
	Dc.W	2068
	Dc.B	"Acoustic     ",99
	Dc.W	2585
	Dc.B	"Alternative  ",20
	Dc.W	3102
	Dc.B	"AlternRock   ",40
	Dc.W	3619
	Dc.B	"Ambient      ",26
	Dc.W	4136
	Dc.B	"Avantgarde   ",90
	Dc.W	4653
	Dc.B	"Ballad       ",116
	Dc.W	5170
	Dc.B	"Bass         ",41
	Dc.W	5687
	Dc.B	"Bebob        ",85
	Dc.W	6204
	Dc.B	"Big Band     ",96
	Dc.W	6721
	Dc.B	"Bluegrass    ",89
	Dc.W	7238
	Dc.B	"Blues        ",0
	Dc.W	7755
	Dc.B	"Booty Brass  ",107
	Dc.W	8272
	Dc.B	"Cabaret      ",65
	Dc.W	8789
	Dc.B	"Celtic       ",88
	Dc.W	9306
	Dc.B	"Chamber Music",104
	Dc.W	9823
	Dc.B	"Chanson      ",102
	Dc.W	10340
	Dc.B	"Chorus       ",97
	Dc.W	10857
	Dc.B	"Christian Rap",61
	Dc.W	11374
	Dc.B	"Classic Rock ",1
	Dc.W	11891
	Dc.B	"Classical    ",32
	Dc.W	12408
	Dc.B	"Club         ",112
	Dc.W	12925
	Dc.B	"Comedy       ",57
	Dc.W	13442
	Dc.B	"Country      ",2
	Dc.W	13959
	Dc.B	"Cult         ",58
	Dc.W	14476
	Dc.B	"Dance        ",3
	Dc.W	14993
	Dc.B	"Dance Hall   ",125
	Dc.W	15510
	Dc.B	"Darkwave     ",50
	Dc.W	16027
	Dc.B	"Death Metal  ",22
	Dc.W	16544
	Dc.B	"Disco        ",4
	Dc.W	17061
	Dc.B	"Dream        ",55
	Dc.W	17578
	Dc.B	"Drum Solo    ",122
	Dc.W	18095
	Dc.B	"Duet         ",120
	Dc.W	18612
	Dc.B	"EasyListening",98
	Dc.W	19129
	Dc.B	"Electronic   ",52
	Dc.W	19646
	Dc.B	"Ethnic       ",48
	Dc.W	20163
	Dc.B	"Euro-House   ",124
	Dc.W	20680
	Dc.B	"Euro-Techno  ",25
	Dc.W	21197
	Dc.B	"Eurodance    ",54
	Dc.W	21714
	Dc.B	"Fast Fusion  ",84
	Dc.W	22231
	Dc.B	"Folk         ",80
	Dc.W	22748
	Dc.B	"Folk-Rock    ",81
	Dc.W	23265
	Dc.B	"Folklore     ",115
	Dc.W	23782
	Dc.B	"Freestyle    ",119
	Dc.W	24299
	Dc.B	"Funk         ",5
	Dc.W	24816
	Dc.B	"Fusion       ",30
	Dc.W	25333
	Dc.B	"Game         ",36
	Dc.W	25850
	Dc.B	"Gangsta      ",59
	Dc.W	26367
	Dc.B	"Gospel       ",38
	Dc.W	26884
	Dc.B	"Gothic       ",49
	Dc.W	27401
	Dc.B	"Gothic Rock  ",91
	Dc.W	27918
	Dc.B	"Grunge       ",6
	Dc.W	28435
	Dc.B	"Hard Rock    ",79
	Dc.W	28952
	Dc.B	"Hip-Hop      ",7
	Dc.W	29469
	Dc.B	"House        ",35
	Dc.W	29986
	Dc.B	"Humour       ",100
	Dc.W	30503
	Dc.B	"Industrial   ",19
	Dc.W	31020
	Dc.B	"Instr. Pop   ",46
	Dc.W	31537
	Dc.B	"Instr. Rock  ",47
	Dc.W	32054
	Dc.B	"Instrumental ",33
	Dc.W	32571
	Dc.B	"Jazz         ",8
	Dc.W	33088
	Dc.B	"Jazz+Funk    ",29
	Dc.W	33605
	Dc.B	"Jungle       ",63
	Dc.W	34122
	Dc.B	"Latin        ",86
	Dc.W	34639
	Dc.B	"Lo-Fi        ",71
	Dc.W	35156
	Dc.B	"Meditative   ",45
	Dc.W	35673
	Dc.B	"Metal        ",9
	Dc.W	36190
	Dc.B	"Musical      ",77
	Dc.W	36707
	Dc.B	"National Folk",82
	Dc.W	37224
	Dc.B	"NativeAmeric.",64
	Dc.W	37741
	Dc.B	"New Age      ",10
	Dc.W	38258
	Dc.B	"New Wave     ",66
	Dc.W	38775
	Dc.B	"Noise        ",39
	Dc.W	39292
	Dc.B	"Oldies       ",11
	Dc.W	39809
	Dc.B	"Opera        ",103
	Dc.W	40326
	Dc.B	"Other        ",12
	Dc.W	40843
	Dc.B	"Polka        ",75
	Dc.W	41360
	Dc.B	"Pop          ",13
	Dc.W	41877
	Dc.B	"Pop-Folk     ",53
	Dc.W	42394
	Dc.B	"Pop/Funk     ",62
	Dc.W	42911
	Dc.B	"Porn Groove  ",109
	Dc.W	43428
	Dc.B	"Poweer Ballad",117
	Dc.W	43945
	Dc.B	"Pranks       ",23
	Dc.W	44462
	Dc.B	"Primus       ",108
	Dc.W	44979
	Dc.B	"Progres. Rock",92
	Dc.W	45496
	Dc.B	"Psychadelic  ",67
	Dc.W	46013
	Dc.B	"Psyched. Rock",93
	Dc.W	46530
	Dc.B	"Punk         ",43
	Dc.W	47047
	Dc.B	"Punk Rock    ",121
	Dc.W	47564
	Dc.B	"R&B          ",14
	Dc.W	48081
	Dc.B	"Rap          ",15
	Dc.W	48598
	Dc.B	"Rave         ",68
	Dc.W	49115
	Dc.B	"Reggae       ",16
	Dc.W	49632
	Dc.B	"Retro        ",76
	Dc.W	50149
	Dc.B	"Revival      ",87
	Dc.W	50666
	Dc.B	"Rhytmic Soul ",118
	Dc.W	51183
	Dc.B	"Rock         ",17
	Dc.W	51700
	Dc.B	"Rock & Roll  ",78
	Dc.W	52217
	Dc.B	"Samba        ",114
	Dc.W	52734
	Dc.B	"Satire       ",110
	Dc.W	53251
	Dc.B	"Showtunes    ",69
	Dc.W	53768
	Dc.B	"Ska          ",21
	Dc.W	54285
	Dc.B	"Slow Jam     ",111
	Dc.W	54802
	Dc.B	"Slow Rock    ",95
	Dc.W	55319
	Dc.B	"Sonata       ",105
	Dc.W	55836
	Dc.B	"Soul         ",42
	Dc.W	56353
	Dc.B	"Sound Clip   ",37
	Dc.W	56870
	Dc.B	"Soundtrack   ",24
	Dc.W	57387
	Dc.B	"Southern Rock",56
	Dc.W	57904
	Dc.B	"Space        ",44
	Dc.W	58421
	Dc.B	"Speech       ",101
	Dc.W	58938
	Dc.B	"Swing        ",83
	Dc.W	59455
	Dc.B	"SymphonicRock",94
	Dc.W	59972
	Dc.B	"Symphony     ",106
	Dc.W	60489
	Dc.B	"Tango        ",113
	Dc.W	61006
	Dc.B	"Techno       ",18
	Dc.W	61523
	Dc.B	"TechnoIndust.",51
	Dc.W	62040
	Dc.B	"Top 40       ",60
	Dc.W	62557
	Dc.B	"Trailer      ",70
	Dc.W	63074
	Dc.B	"Trance       ",31
	Dc.W	63591
	Dc.B	"Tribal       ",72
	Dc.W	64108
	Dc.B	"Trip-Hop     ",27
	Dc.W	64625
	Dc.B	"Vocal        ",28
	Dc.W	65142
	Dc.B	"Undefined    ",255
	Dc.W	65535
	Dc.B	"             ",255


VB	; Pointer für indirekte Variablen


; I2C Bus
; ~~~~~~~

Volume_Up
	Lea	VolS_PropY-VB(A5),A0
	Move.W	#0,(A0)
	Lea	VolS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.b	Volume_Slider

Volume_Down
	Lea	VolS_PropY-VB(A5),A0
	Move.W	#$FFFF,(A0)
	Lea	VolS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Volume_Slider

Volume_Slider
	Lea	VolS_PropY-VB(A5),A0
	Moveq.L	#0,D0
	Move.W	(A0),D0
	Divu	#3276,D0
	Lsl.W	#2,D0
	Lea	Volume_Tab-VB(A5),A0
	Move.L	(A0,D0.W),D2
	Move.W	D2,D3
	Lsr.W	#8,D3
	Move.L	D2,D4
	Swap	D4
	Move.L	Load_Count-VB(A5),Load_Count_Save-VB(A5)
	Move.L	#0,Load_Count-VB(A5)
	Lea	$BFE101,A1
VolumeS_LL
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$B0,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$01,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$07,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$F8,D0
	Bsr.w	Write_IIC_D0
	Move.B	D3,D0
	Bsr.w	Write_IIC_D0
	Move.B	D2,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	D4,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
VolumeS_RR
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$B0,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$01,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$07,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$FB,D0
	Bsr.w	Write_IIC_D0
	Move.B	D3,D0
	Bsr.w	Write_IIC_D0
	Move.B	D2,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$00,D0
	Bsr.w	Write_IIC_D0
	Move.B	D4,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
	Move.L	Load_Count_Save-VB(A5),Load_Count-VB(A5)
	Moveq.L	#-1,D0
	Rts

Volume_Tab
	Dc.L	$80000,$8DEB8,$9A537,$A5621,$AF3CD,$B8053,$BFD92,$C6D31
	Dc.L	$CD0AD,$D2958,$D785E,$DBECC,$DFD91,$E3583,$E675F,$E93CF
	Dc.L	$EBB6A,$EDEB6,$EFE2C,$F1A36,$FFFFA

Prefactor_0
	Lea	PrefactorS_PropX-VB(A5),A0
	Move.W	#0,(A0)
	Lea	PrefactorS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.b	Prefactor_Slider

Prefactor_Mid
	Lea	PrefactorS_PropX-VB(A5),A0
	Move.W	#$7FFF,(A0)
	Lea	PrefactorS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Prefactor_Slider

Prefactor_Slider
	Lea	PrefactorS_PropX-VB(A5),A0
	Moveq.L	#0,D0
	Move.W	(A0),D0
	Divu	#4369,D0
	Lsl.W	#1,D0
	Lea	Prefactor_Tab-VB(A5),A0
	Move.W	(A0,D0.W),D2
	Move.W	D2,D3
	Lsr.W	#8,D3
	Move.L	Load_Count-VB(A5),Load_Count_Save-VB(A5)
	Move.L	#0,Load_Count-VB(A5)
	Lea	$BFE101,A1
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$9E,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$70,D0
	Bsr.w	Write_IIC_D0
	Move.B	D3,D0
	Bsr.w	Write_IIC_D0
	Move.B	D2,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
	Move.L	Load_Count_Save-VB(A5),Load_Count-VB(A5)
	Moveq.L	#-1,D0
	Rts

Prefactor_Tab
	Dc.W	$8000,$8E00,$9A40,$A580,$AF40,$B800,$BFC0,$C6C0
	Dc.W	$CD00,$D25C,$D780,$DC00,$DFC0,$E340,$E680,$E940

Bass_0
	Lea	BassS_PropX-VB(A5),A0
	Move.W	#0,(A0)
	Lea	BassS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.b	Bass_Slider

Bass_Mid
	Lea	BassS_PropX-VB(A5),A0
	Move.W	#$7FFF,(A0)
	Lea	BassS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Bass_Slider

Bass_Slider
	Lea	BassS_PropX-VB(A5),A0
	Moveq.L	#0,D0
	Move.W	(A0),D0
	Divu	#2184,D0
	Lsl.W	#1,D0
	Lea	Bass_Tab-VB(A5),A0
	Move.W	(A0,D0.W),D2
	Move.W	D2,D3
	Lsr.W	#8,D3
	Move.L	Load_Count-VB(A5),Load_Count_Save-VB(A5)
	Move.L	#0,Load_Count-VB(A5)
	Lea	$BFE101,A1
	Bsr.w	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$96,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$B0,D0
	Bsr.w	Write_IIC_D0
	Move.B	D3,D0
	Bsr.w	Write_IIC_D0
	Move.B	D2,D0
	Bsr.w	Write_IIC_D0
	Bsr.w	Write_IIC_P
	Move.L	Load_Count_Save-VB(A5),Load_Count-VB(A5)
	Moveq.L	#-1,D0
	Rts

Bass_Tab
	Dc.W	$9E40,$A280,$A740,$AC40,$B180,$B740,$BD40,$C3C0
	Dc.W	$CA40,$D180,$D8C0,$E040,$E800,$EFC0,$F7C0,$0000
	Dc.W	$0800,$1000,$17C0,$1F80,$2700,$2E40,$3580,$3C00
	Dc.W	$4280,$4880,$4E40,$5380,$5880,$5D40,$6180

Treble_0
	Lea	TrebleS_PropX-VB(A5),A0
	Move.W	#0,(A0)
	Lea	TrebleS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.b	Treble_Slider

Treble_Mid
	Lea	TrebleS_PropX-VB(A5),A0
	Move.W	#$7FFF,(A0)
	Lea	TrebleS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Treble_Slider

Treble_Slider
	Lea	TrebleS_PropX-VB(A5),A0
	Moveq.L	#0,D0
	Move.W	(A0),D0
	Divu	#2184,D0
	Lsl.W	#1,D0
	Lea	Treble_Tab-VB(A5),A0
	Move.W	(A0,D0.W),D2
	Move.W	D2,D3
	Lsr.W	#8,D3
	Move.L	Load_Count-VB(A5),Load_Count_Save-VB(A5)
	Move.L	#0,Load_Count-VB(A5)
	Lea	$BFE101,A1
	Bsr.b	Write_IIC_S
	Move.B	#$3A,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$68,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$96,D0
	Bsr.w	Write_IIC_D0
	Move.B	#$F0,D0
	Bsr.w	Write_IIC_D0
	Move.B	D3,D0
	Bsr.w	Write_IIC_D0
	Move.B	D2,D0
	Bsr.w	Write_IIC_D0
	Bsr.b	Write_IIC_P
	Move.L	Load_Count_Save-VB(A5),Load_Count-VB(A5)
	Moveq.L	#-1,D0
	Rts

Treble_Tab
	Dc.W	$B2C0,$BB40,$C180,$C6C0,$CBC0,$D040,$D500,$D980
	Dc.W	$DE00,$E280,$E7E0,$EC00,$F0C0,$F5C0,$FAC0,$0000
	Dc.W	$5400,$AC00,$1040,$1600,$1C00,$2200,$2840,$2EC0
	Dc.W	$3540,$3C00,$42C0,$49C0,$5180,$5840,$5F80

Write_IIC_S
	Move.B	#%11111111,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11110111,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11110011,(A1)
	Bsr.b	IIC_Delay
	Rts

Write_IIC_P
	Move.B	#%11110011,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11110111,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11111111,(A1)
	Bsr.b	IIC_Delay
	Rts

Write_IIC_1
	Move.B	#%11111011,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11111111,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11111011,(A1)
	Bsr.b	IIC_Delay
	Rts

Write_IIC_0
	Move.B	#%11110011,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11110111,(A1)
	Bsr.b	IIC_Delay
	Move.B	#%11110011,(A1)
	Bsr.b	IIC_Delay
	Rts

IIC_Delay
	Movem.L	D0-D1/A1,-(A7)
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	VBeamPos(A6)
	Move.L	D0,D7
IIC_Delay_Loop
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	VBeamPos(A6)
	Cmp.L	D0,D7
	Beq.b	IIC_Delay_Loop
	Movem.L	(A7)+,D0-D1/A1
	Rts

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


; Warte ein Augenblick
; ~~~~~~~~~~~~~~~~~~~~

Wait
	Move.L	Dos_Base-VB(A5),A6
	Moveq.L	#25,D1
	Jsr	Delay(A6)
	Rts


; Preferences
; ~~~~~~~~~~~

Save_Prefs
; Datei neu
	Move.L	#ModeNew,D2
; Datei öffnen
	Lea	Prefs_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Prefs_Hd-VB(A5)
	Beq.w	Save_Prefs_Exit
; Schreibe ID
	Lea	Prefs_ID-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Pfad
	Lea	Path_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Playlist Name
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe SplitTo Name
	Lea	SplitTo_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Taskpriorität
	Lea	Task_PriS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Prefactor
	Lea	PrefactorS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Bass
	Lea	BassS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Treble
	Lea	TrebleS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Load Buffer
	Lea	Buffer_Size-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Schreibe Flags
	Lea	Prefs_Flags-VB(A5),A6
	Move.L	A6,D2
	Move.L	#8,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
;Datei schließen
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Save_Prefs_Exit
	Moveq.L	#-1,D0
	Rts

Prefs_Hd
	Dc.L	0

Prefs_ID
	Dc.B	"MP13"

Prefs_Name
	Dc.B	"MAS-Player.prefs",0
	Even

Open_Prefs
; Datei alt
	Move.L	#ModeOld,D2
; Datei öffnen
	Lea	Prefs_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Prefs_Hd-VB(A5)
	Beq.w	Open_Prefs_Exit
; Lese ID
	Lea	Prefs_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Lea	Prefs_Buffer-VB(A5),A6
	Cmp.L	#"MP13",(A6)
	Bne.w	Open_Prefs_Error
; Lese Pfad
	Lea	Path_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Playlist Name
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese SplitTo Name
	Lea	SplitTo_Buffer-VB(A5),A6
	Move.L	A6,D2
	Move.L	#256,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Taskpriorität
	Lea	Task_PriS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Prefactor
	Lea	PrefactorS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Bass
	Lea	BassS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Treble
	Lea	TrebleS_PropX-VB(A5),A6
	Move.L	A6,D2
	Move.L	#2,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Load Buffer
	Lea	Buffer_Size-VB(A5),A6
	Move.L	A6,D2
	Move.L	#4,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
; Lese Flags
	Lea	Prefs_Flags-VB(A5),A6
	Move.L	A6,D2
	Move.L	#8,D3
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
;Datei schließen
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
; Buffer Size Gadget berechnen
	Move.L	Buffer_Size-VB(A5),D0
	Cmp.L	#64000,D0
	Beq.b	Open_Prefs_64K
	Cmp.L	#128000,D0
	Beq.b	Open_Prefs_128K
	Cmp.L	#256000,D0
	Beq.b	Open_Prefs_256K
	Cmp.L	#512000,D0
	Beq.b	Open_Prefs_512K
	Cmp.L	#1024000,D0
	Beq.b	Open_Prefs_1M
Open_Prefs_2M
	Move.W	#0,BufferS_PropY-VB(A5)
	Bra.b	Open_Prefs_Buffer_End
Open_Prefs_1M
	Move.W	#13107,BufferS_PropY-VB(A5)
	Bra.b	Open_Prefs_Buffer_End
Open_Prefs_512K
	Move.W	#26214,BufferS_PropY-VB(A5)
	Bra.b	Open_Prefs_Buffer_End
Open_Prefs_256K
	Move.W	#39321,BufferS_PropY-VB(A5)
	Bra.b	Open_Prefs_Buffer_End
Open_Prefs_128K
	Move.W	#52428,BufferS_PropY-VB(A5)
	Bra.b	Open_Prefs_Buffer_End
Open_Prefs_64K
	Move.W	#65535,BufferS_PropY-VB(A5)
Open_Prefs_Buffer_End
	Lea	Assign_Gadget-VB(A5),A0
	Move.B	Assign_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	MP_Gadget-VB(A5),A0
	Move.B	MP_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	Rep_Dir_Gadget-VB(A5),A0
	Move.B	Rep_Dir_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	Auto_Gadget-VB(A5),A0
	Move.B	Auto_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	CPU_Gadget-VB(A5),A0
	Move.B	CPU_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	Random_Gadget-VB(A5),A0
	Move.B	Random_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	Analyse_Gadget-VB(A5),A0
	Move.B	Analyse_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
	Lea	Start_Gadget-VB(A5),A0
	Move.B	Start_Flag-VB(A5),D0
	And.B	#1,D0
	Lsl.B	#7,D0
	Move.B	D0,13(A0)
Open_Prefs_Ref_Gadgets
	Cmp.B	#3,Folder-VB(A5)
	Bne.b	Open_Prefs_Exit
	Bsr.w	Window_Prefs
	Bra.w	Play_Step_Width
Open_Prefs_Error
;Datei schließen
	Move.L	Prefs_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Open_Prefs_Exit
; Setze Werte von veränderten Gadgets
	Bsr.w	Set_Task_Pri
	Bsr.w	Prefactor_Slider
	Bsr.w	Bass_Slider
	Bsr.w	Treble_Slider
	Bsr.b	CPU_Set_Send_Size
	Moveq.L	#-1,D0
	Rts

Prefs_Buffer
	Dcb.B	56,0


; Wechsel Assign anzeigen oder nicht
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Toggle_Assign
	Bchg.B	#0,Assign_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel nur .MPx anzeigen oder nicht
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Toggle_MP
	Bchg.B	#0,MP_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel Repeat type
; ~~~~~~~~~~~~~~~~~~~

Toggle_Rep_Kind
	Bchg.B	#0,Rep_Dir_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel Auto Play
; ~~~~~~~~~~~~~~~~~

Toggle_Auto
	Bchg.B	#0,Auto_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel Random
; ~~~~~~~~~~~~~~

Toggle_Random
	Bchg.B	#0,Random_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel CPU type
; ~~~~~~~~~~~~~~~~

Toggle_CPU
	Bchg.B	#0,CPU_Flag-VB(A5)
	Bsr.w	Stop
CPU_Set_Send_Size
	Move.L	#200,Send_Size-VB(A5)
	Tst.B	CPU_Flag
	Beq.b	Toggle_CPU_Exit
	Move.L	#250,Send_Size-VB(A5)
Toggle_CPU_Exit
	Moveq.L	#-1,D0
	Rts


; Wechsel Analyse an/aus
; ~~~~~~~~~~~~~~~~~~~~~~

Toggle_Analyse
	Bchg.B	#0,Analyse_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Wechsel Auto Start
; ~~~~~~~~~~~~~~~~~~

Toggle_Start
	Bchg.B	#0,Start_Flag-VB(A5)
	Moveq.L	#-1,D0
	Rts


; Play Buffer setzen
; ~~~~~~~~~~~~~~~~~~

Set_Play_Buffer
	Bsr.w	Stop
	Bsr.w	Free_Mem_Play_Buffer
	Lea	BufferS_PropY-VB(A5),A0
	Move.W	(A0),D0
	Cmp.W	#6554,D0
	Blo.b	Set_Play_Buffer_2M
	Cmp.W	#19661,D0
	Blo.b	Set_Play_Buffer_1M
	Cmp.W	#32768,D0
	Blo.b	Set_Play_Buffer_512K
	Cmp.W	#45875,D0
	Blo.b	Set_Play_Buffer_256K
	Cmp.W	#58982,D0
	Blo.b	Set_Play_Buffer_128K
Set_Play_Buffer_64K
	Move.L	#64000,Buffer_Size-VB(A5)
	Bra.b	Set_Play_Buffer_Exit
Set_Play_Buffer_128K
	Move.L	#128000,Buffer_Size-VB(A5)
	Bra.b	Set_Play_Buffer_Exit
Set_Play_Buffer_256K
	Move.L	#256000,Buffer_Size-VB(A5)
	Bra.b	Set_Play_Buffer_Exit
Set_Play_Buffer_512K
	Move.L	#512000,Buffer_Size-VB(A5)
	Bra.b	Set_Play_Buffer_Exit
Set_Play_Buffer_1M
	Move.L	#1024000,Buffer_Size-VB(A5)
	Bra.b	Set_Play_Buffer_Exit
Set_Play_Buffer_2M
	Move.L	#2048000,Buffer_Size-VB(A5)
Set_Play_Buffer_Exit
	Bsr.w	Alloc_Mem_Play_Buffer
	Bne.b	Set_Play_Buffer_Return
	Move.W	#$FFFF,BufferS_PropY-VB(A5)
; Propgadget Refresh
	Lea	BufferS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Fehler signalisieren
	Move.L	#0,A0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	DisplayBeep(A6)
; Kleinste Menge reservieren
	Move.L	#64000,Buffer_Size-VB(A5)
	Bsr.w	Alloc_Mem_Play_Buffer
Set_Play_Buffer_Return
	Rts


; Task Priorität setzen
; ~~~~~~~~~~~~~~~~~~~~~

Set_Task_Pri
	Sub.L	A1,A1
	Move.L	ExecBase,A6
	Jsr	FindTask(A6)
	Beq.B	Set_Task_Pri_Exit
	Move.L	D0,A1
	Lea	Task_PriS_PropX-VB(A5),A0
	Move.W	(A0),D0
	Sub.W	#32768,D0
	Ext.L	D0
	Asr.L	#8,D0
	Asr.L	#3,D0
	Move.L	ExecBase,A6
	Jsr	SetTaskPri(A6)
Set_Task_Pri_Exit
	Moveq.L	#-1,D0
	Rts


; ASL für Playliste
; ~~~~~~~~~~~~~~~~~

Select_PLS
; ASL Library öffnen
	Move.L	ExecBase,A6
	Lea	ASL_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,ASL_Base-VB(A5)
	Beq.w	Select_PLS_Exit
; Filestructure holen
	Move.L	ASL_Base-VB(A5),A6
	Jsr	AllocFileRequest(A6)
	Move.L	D0,Requester-VB(A5)
	Beq.w	Select_PLS_Close
; ASL Requester
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	RequestFile(A6)
; Werte übernehmen
	Lea	Playlist_Name-VB(A5),A2
	Move.L	Requester-VB(A5),A0
	Move.L	8(A0),A1
	Move.L	#256,D1
Select_PLS_Loop
	Move.B	(A1)+,D0
	Beq.b	Select_PLS_Loop_End
	Subq.L	#1,D1
	Beq.b	Select_PLS_Loop_End
	Move.B	D0,(A2)+
	Bra.b	Select_PLS_Loop
Select_PLS_Loop_End
	Cmp.L	#256,D1
	Beq.b	Select_PLS_No_Slash
	Cmp.B	#":",-1(A2)
	Beq.b	Select_PLS_No_Slash
	Move.B	#"/",(A2)+
Select_PLS_No_Slash
	Move.L	4(A0),A1
Select_PLS_Loop2
	Move.B	(A1)+,D0
	Beq.b	Select_PLS_Loop2_End
	Subq.L	#1,D1
	Beq.b	Select_PLS_Loop2_End
	Move.B	D0,(A2)+
	Bra.b	Select_PLS_Loop2
Select_PLS_Loop2_End
	Cmp.L	#256,D1
	Beq.b	Select_PLS_Add
	Cmp.B	#"/",-1(A2)
	Beq.b	Select_PLS_Add
	Cmp.B	#":",-1(A2)
	Beq.b	Select_PLS_Add
	Bra.w	Select_PLS_End
Select_PLS_Add
	Move.B	#"M",(A2)+
	Move.B	#"A",(A2)+
	Move.B	#"S",(A2)+
	Move.B	#"-",(A2)+
	Move.B	#"P",(A2)+
	Move.B	#"l",(A2)+
	Move.B	#"a",(A2)+
	Move.B	#"y",(A2)+
	Move.B	#"e",(A2)+
	Move.B	#"r",(A2)+
	Move.B	#".",(A2)+
	Move.B	#"p",(A2)+
	Move.B	#"l",(A2)+
	Move.B	#"s",(A2)+
Select_PLS_End
	Move.B	#0,(A2)
; Stringgadget Refresh
	Lea	PLS_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Filestructure freigeben
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	FreeFileRequest(A6)
Select_PLS_Close
; ASL Library schließen
	Move.L	ExecBase,A6
	Move.L	ASL_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
Select_PLS_Exit
	Moveq.L	#-1,D0
	Rts

ASL_Name
	Dc.B	"asl.library",0

ASL_Base
	Dc.L	0

Requester
	Dc.L	0

; ASL für den Pfad der Musik
; ~~~~~~~~~~~~~~~~~~~~~~~~~~

Select_Path
; ASL Library öffnen
	Move.L	ExecBase,A6
	Lea	ASL_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,ASL_Base-VB(A5)
	Beq.b	Select_Path_Exit
; Filestructure holen
	Move.L	ASL_Base-VB(A5),A6
	Jsr	AllocFileRequest(A6)
	Move.L	D0,Requester-VB(A5)
	Beq.b	Select_Path_Close
; ASL Requester
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	RequestFile(A6)
; Werte übernehmen
	Lea	Path_Buffer-VB(A5),A2
	Move.L	Requester-VB(A5),A0
	Move.L	8(A0),A1
	Move.L	#256,D1
Select_Path_Loop
	Move.B	(A1)+,D0
	Beq.b	Select_Path_Loop_End
	Subq.L	#1,D1
	Beq.b	Select_Path_Loop_End
	Move.B	D0,(A2)+
	Bra.b	Select_Path_Loop
Select_Path_Loop_End
	Move.B	#0,(A2)
; Stringgadget Refresh
	Lea	Path_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Filestructure freigeben
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	FreeFileRequest(A6)
Select_Path_Close
; ASL Library schließen
	Move.L	ExecBase,A6
	Move.L	ASL_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
Select_Path_Exit
	Moveq.L	#-1,D0
	Rts

; ASL für den "Split To" Pfad
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~

Select_SplitTo
; ASL Library öffnen
	Move.L	ExecBase,A6
	Lea	ASL_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,ASL_Base-VB(A5)
	Beq.b	Select_SplitTo_Exit
; Filestructure holen
	Move.L	ASL_Base-VB(A5),A6
	Jsr	AllocFileRequest(A6)
	Move.L	D0,Requester-VB(A5)
	Beq.b	Select_SplitTo_Close
; ASL Requester
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	RequestFile(A6)
; Werte übernehmen
	Lea	SplitTo_Buffer-VB(A5),A2
	Move.L	Requester-VB(A5),A0
	Move.L	8(A0),A1
	Move.L	#256,D1
Select_SplitTo_Loop
	Move.B	(A1)+,D0
	Beq.b	Select_SplitTo_Loop_End
	Subq.L	#1,D1
	Beq.b	Select_SplitTo_Loop_End
	Move.B	D0,(A2)+
	Bra.b	Select_SplitTo_Loop
Select_SplitTo_Loop_End
	Move.B	#0,(A2)
; Stringgadget Refresh
	Lea	SplitTo_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Filestructure freigeben
	Move.L	Requester-VB(A5),A0
	Move.L	ASL_Base-VB(A5),A6
	Jsr	FreeFileRequest(A6)
Select_SplitTo_Close
; ASL Library schließen
	Move.L	ExecBase,A6
	Move.L	ASL_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
Select_SplitTo_Exit
	Moveq.L	#-1,D0
	Rts


; DOS Library
; ~~~~~~~~~~~

Open_Dos_Library
	Move.W	#$100,Error-VB(A5)
	Tst.L	Dos_Base-VB(A5)
	Bne.b	Dos_Return
	Move.L	ExecBase,A6
	Lea	Dos_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,Dos_Base-VB(A5)
	Rts

Close_Dos_Library
	Tst.L	Dos_Base-VB(A5)
	Beq.b	Dos_Return
	Move.L	ExecBase,A6
	Move.L	Dos_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
	Move.L	#0,Dos_Base-VB(A5)
Dos_Return
	Rts

Dos_Base
	Dc.L	0
Dos_Name
	Dc.B	"dos.library",0
	Even


; Intuition Library
; ~~~~~~~~~~~~~~~~~

Open_Intuition_Library
	Move.W	#$101,Error-VB(A5)
	Tst.L	Intuition_Base-VB(A5)
	Bne.b	Intuition_Return
	Move.L	ExecBase,A6
	Lea	Intuition_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,Intuition_Base-VB(A5)
	Rts

Close_Intuition_Library
	Tst.L	Intuition_Base-VB(A5)
	Beq.b	Intuition_Return
	Move.L	ExecBase,A6
	Move.L	Intuition_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
	Move.L	#0,Intuition_Base-VB(A5)
Intuition_Return
	Rts

Intuition_Base
	Dc.L	0
Intuition_Name
	Dc.B	"intuition.library",0
	Even


; Graphics Library
; ~~~~~~~~~~~~~~~~

Open_Graphics_Library
	Move.W	#$102,Error-VB(A5)
	Tst.L	Graphics_Base-VB(A5)
	Bne.b	Graphics_Return
	Move.L	ExecBase,A6
	Lea	Graphics_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,Graphics_Base-VB(A5)
	Rts

Close_Graphics_Library
	Tst.L	Graphics_Base-VB(A5)
	Beq.b	Graphics_Return
	Move.L	ExecBase,A6
	Move.L	Graphics_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
	Move.L	#0,Graphics_Base-VB(A5)
Graphics_Return
	Rts

Graphics_Base
	Dc.L	0
Graphics_Name
	Dc.B	"graphics.library",0
	Even


; Diskfont Library
; ~~~~~~~~~~~~~~~~

Open_Diskfont_Library
	Move.W	#$103,Error-VB(A5)
	Tst.L	Diskfont_Base-VB(A5)
	Bne.b	Diskfont_Return
	Move.L	ExecBase,A6
	Lea	Diskfont_Name-VB(A5),A1
	Moveq	#0,D0
	Jsr	OpenLibrary(A6)
	Move.L	D0,Diskfont_Base-VB(A5)
	Rts

Close_Diskfont_Library
	Tst.L	Diskfont_Base-VB(A5)
	Beq.b	Diskfont_Return
	Move.L	ExecBase,A6
	Move.L	Diskfont_Base-VB(A5),A1
	Jsr	CloseLibrary(A6)
	Move.L	#0,Diskfont_Base-VB(A5)
Diskfont_Return
	Rts

Diskfont_Base
	Dc.L	0
Diskfont_Name
	Dc.B	"diskfont.library",0
	Even


; Font Behandlung
; ~~~~~~~~~~~~~~~

Open_Diskfont
; Font von der Disk in den Speicher laden
	Move.W	#$700,Error-VB(A5)
	Tst.L	Text_Font_Hd-VB(A5)
	Bne.b	Open_Diskfont_Return
	Move.L	Diskfont_Base-VB(A5),A6
	Lea	Diskfont_Text_Attr-VB(A5),A0
	Jsr	OpenDiskFont(A6)
	Move.L	D0,Text_Font_Hd-VB(A5)
Open_Diskfont_Return
	Rts

Text_Font_Hd
	Dc.L	0

Diskfont_Text_Attr
	Dc.L	Font_Name
	Dc.W	15
	Dc.B	0,0
Font_Name
	Dc.B	"MAS.font",0
	Even


; Speicher Anforderungen
; ~~~~~~~~~~~~~~~~~~~~~~

Alloc_Mem_BFP
; Speicher für die Bitplanes
	Move.W	#$200,Error-VB(A5)
	Tst.L	BFP_Base-VB(A5)
	Bne.b	Alloc_Mem_BFP_Return
	Move.L	ExecBase,A6
	Move.L	#BFP_Raw_Size,D0
	Move.L	#MEMF_CHIP+MEMF_CLEAR,D1
	Jsr	AllocMem(A6)
	Move.L	D0,BFP_Base-VB(A5)
	Move.L	D0,Window_Plane_0-VB(A5)
	Add.L	#Plane_Size,D0
	Move.L	D0,Window_Plane_1-VB(A5)
	Add.L	#Plane_Size,D0
	Move.L	D0,Window_Plane_2-VB(A5)
	Add.L	#Plane_Size,D0
	Move.L	D0,Window_Plane_3-VB(A5)
	Add.L	#Plane_Size,D0
	Move.L	D0,Window_Plane_4-VB(A5)
	Add.L	#Plane_Size,D0
	Tst.L	BFP_Base-VB(A5)
Alloc_Mem_BFP_Return
	Rts

Free_Mem_BFP
	Tst.L	BFP_Base-VB(A5)
	Beq.b	Free_Mem_BFP_Return
	Move.L	ExecBase,A6
	Move.L	BFP_Base-VB(A5),A1
	Move.L	#BFP_Raw_Size,D0
	Jsr	FreeMem(A6)
	Move.L	#0,BFP_Base-VB(A5)
Free_Mem_BFP_Return
	Rts

BFP_Base
	Dc.L	0

Alloc_Mem_File_List
; Speicher für die Fileliste
	Move.W	#$201,Error-VB(A5)
	Tst.L	File_List_Base-VB(A5)
	Bne.b	Alloc_Mem_File_List_Return
	Move.L	ExecBase,A6
	Move.L	#File_List_Size,D0
	Move.L	#MEMF_PUBLIC+MEMF_CLEAR,D1
	Jsr	AllocMem(A6)
	Move.L	D0,File_List_Base-VB(A5)
Alloc_Mem_File_List_Return
	Rts

Free_Mem_File_List
	Tst.L	File_List_Base-VB(A5)
	Beq.b	Free_Mem_File_List_Return
	Move.L	ExecBase,A6
	Move.L	File_List_Base-VB(A5),A1
	Move.L	#File_List_Size,D0
	Jsr	FreeMem(A6)
	Move.L	#0,File_List_Base-VB(A5)
Free_Mem_File_List_Return
	Rts

File_List_Base
	Dc.L	0

Alloc_Mem_Play_Buffer
; Speicher für den Buffer
	Move.W	#$202,Error-VB(A5)
	Tst.L	Play_Buffer_Base-VB(A5)
	Bne.b	Alloc_Mem_Play_Buffer_Return
	Move.L	ExecBase,A6
	Move.L	Buffer_Size,D0
	Move.L	#MEMF_PUBLIC+MEMF_CLEAR,D1
	Jsr	AllocMem(A6)
	Move.L	D0,Play_Buffer_Base-VB(A5)
Alloc_Mem_Play_Buffer_Return
	Rts

Free_Mem_Play_Buffer
	Tst.L	Play_Buffer_Base-VB(A5)
	Beq.b	Free_Mem_Play_Buffer_Return
	Move.L	ExecBase,A6
	Move.L	Play_Buffer_Base-VB(A5),A1
	Move.L	Buffer_Size,D0
	Jsr	FreeMem(A6)
	Move.L	#0,Play_Buffer_Base-VB(A5)
Free_Mem_Play_Buffer_Return
	Rts

Play_Buffer_Base
	Dc.L	0


; Bildschirm
; ~~~~~~~~~~

Open_Screen
	Move.W	#$300,Error-VB(A5)
	Tst.L	Screen_Hd-VB(A5)
	Bne.b	Open_Screen_Return
	Move.L	Intuition_Base-VB(A5),A6
	Lea	Screen_Defs-VB(A5),A0
	Jsr	OpenScreen(A6)
	Move.L	D0,D1
	Add.L	#44,D1
	Move.L	D1,Screen_View_Port-VB(A5)
	Move.L	D0,D1
	Add.L	#84,D1
	Move.L	D1,Screen_Rast_Port-VB(A5)
	Move.L	D0,Screen_Hd-VB(A5)
Open_Screen_Return
	Rts

Close_Screen
	Tst.L	Screen_Hd-VB(A5)
	Beq.b	Close_Screen_Return
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Screen_Hd-VB(A5),A0
	Jsr	CloseScreen(A6)
	Move.L	#0,Screen_Hd-VB(A5)
Close_Screen_Return
	Rts

Screen_Hd
; Bildschirmhändler
	Dc.L	0

Screen_View_Port
	Dc.L	0

Screen_Rast_Port
	Dc.L	0

Screen_Defs
; Screenstruktur
	Dc.W	0,0
Screen_Size_X
	Dc.W	352
Screen_Size_Y
	Dc.W	272,5
	Dc.B	2,7
	Dc.W	2,$F
	Dc.L	Diskfont_Text_Attr,Screen_Titel,0,0

Screen_Titel
	Dc.B	"MAS-Player 2000, by DCR",0
	Even

Screen_To_Back
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Screen_Hd-VB(A5),A0
	Jsr	ScreenToBack(A6)
	Moveq.L	#-1,D0
	Rts


; Fensterbehandlung
; ~~~~~~~~~~~~~~~~~

Open_Window
	Move.W	#$400,Error-VB(A5)
	Tst.L	Window_Hd-VB(A5)
	Bne.b	Open_Window_Return
	Move.L	Screen_Hd-VB(A5),Window_Screen_Hd-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Lea	Window_Defs-VB(A5),A0
	Jsr	OpenWindow(A6)
	Move.L	D0,A0
	Move.L	50(A0),Window_Rast_Port-VB(A5)
	Move.L	D0,Window_Hd-VB(A5)
Open_Window_Return
	Rts

Close_Window
	Tst.L	Window_Hd-VB(A5)
	Beq.b	Close_Window_Return
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Jsr	CloseWindow(A6)
	Move.L	#0,Window_Hd-VB(A5)
Close_Window_Return
	Rts

Window_Hd
; Fensterhändler
	Dc.L	0

Window_Rast_Port
	Dc.L	0

Window_Defs
; Fensterstruktur
	Dc.W	0,0
Window_X_Size
	Dc.W	352
Window_Y_Size
	Dc.W	272
	Dc.B	8,3
	Dc.L	$460
	Dc.L	$11880,0,0,0
Window_Screen_Hd
	Dc.L	0,Window_Bitmap
	Dc.W	352,272,352,272,15

Window_Bitmap
	Dc.W	44,272
	Dc.B	0,5
	Dc.W	0
Window_Plane_0
	Dc.L	0
Window_Plane_1
	Dc.L	0
Window_Plane_2
	Dc.L	0
Window_Plane_3
	Dc.L	0
Window_Plane_4
	Dc.L	0
Window_Plane_5
	Dc.L	0
Window_Plane_6
	Dc.L	0
Window_Plane_7
	Dc.L	0

Window_Playlist
	Move.B	#-1,Folder-VB(A5)
	Lea	Skin_Playlist,A0
	Bsr.w	Copy_Skin_Data
	Bsr.w	Window_Refresh
	Bsr.w	Add_Playlist_Gadgets
	Move.B	#0,Folder-VB(A5)
; Playliste!
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Beq.b	Window_Playlist_PLS
	Bsr.w	Print_List
	Moveq.L	#-1,D0
	Rts
Window_Playlist_PLS
	Bsr.w	Get_Playlist_Again
	Moveq.L	#-1,D0
	Rts

Window_Control
	Move.B	#-1,Folder-VB(A5)
	Lea	Skin_Control,A0
	Bsr.w	Copy_Skin_Data
	Bsr.w	Window_Refresh
	Move.W	#0,Rep_Gadget+12-VB(A5)
	Tst.b	Repeat_Flag-VB(A5)
	Beq.b	Window_Control_Rep
	Move.W	#$80,Rep_Gadget+12-VB(A5)
Window_Control_Rep
	Bsr.w	Add_Control_Gadgets
	Move.B	#1,Err_LED_Color-VB(A5)
	Move.B	#1,Folder-VB(A5)
	Moveq.L	#-1,D0
	Rts

Window_Cue
	Move.B	#-1,Folder-VB(A5)
	Lea	Skin_Cue,A0
	Bsr.w	Copy_Skin_Data
	Bsr.b	Window_Refresh
	Move.W	#0,Cue_Rep_Gadget+12-VB(A5)
	Tst.b	Repeat_Flag-VB(A5)
	Beq.b	Window_Cue_Rep
	Move.W	#$80,Cue_Rep_Gadget+12-VB(A5)
Window_Cue_Rep
	Bsr.w	Add_Cue_Gadgets
	Move.B	#1,Err_LED_Color-VB(A5)
	Move.B	#2,Folder-VB(A5)
	Bsr.w	Print_Time
	Bsr.w	Print_Cue
	Moveq.L	#-1,D0
	Rts

Window_Prefs
	Move.B	#-1,Folder-VB(A5)
	Lea	Skin_Prefs,A0
	Bsr.b	Copy_Skin_Data
	Bsr.b	Window_Refresh
	Bsr.w	Add_Prefs_Gadgets
	Move.B	#3,Folder-VB(A5)
	Moveq.L	#-1,D0
	Rts

Window_About
	Move.B	#-1,Folder-VB(A5)
	Lea	Skin_About,A0
	Bsr.b	Copy_Skin_Data
	Bsr.b	Window_Refresh
	Bsr.w	Add_About_Gadgets
	Move.B	#4,Folder-VB(A5)
	Moveq.L	#-1,D0
	Rts

Window_Refresh
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Move.L	62(A0),A1
	Moveq.L	#-1,D0
	Jsr	RemoveGList(A6)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Screen_Rast_Port-VB(A5),A0
	Lea	BFP_Image_Struc-VB(A5),A1
	Moveq.L	#0,D0
	Moveq.L	#0,D1
	Move.L	Window_Plane_0-VB(A5),BFP_Image_Base-VB(A5)
	Jsr	DrawImage(A6)
	Rts

BFP_Image_Struc
	Dc.W	0,0,352,272,5
BFP_Image_Base
	Dc.L	0
	Dc.B	31,0
	Dc.L	0


; Kopiere Skin-Daten
; ~~~~~~~~~~~~~~~~~~
; A0 = Zeiger auf Skin Quelldaten

Copy_Skin_Data
	Move.W	#$600,Error-VB(A5)
	Move.L	Window_Plane_0-VB(A5),A1
	Cmp.L	#"FORM",(A0)+
	Bne.b	Copy_Skin_Return
	Move.L	A0,A3
	Moveq.L	#0,D3
	Moveq.L	#0,D4
Copy_Skin_Search_BODY
; Suche "BODY" Information
	Addq.L	#2,A0
	Cmp.L	#"BODY",(A0)
	Beq.b	Copy_Skin_BODY_Size
	Bra.b	Copy_Skin_Search_BODY
Copy_Skin_BODY_Size
	Addq.L	#8,A0
	Move.L	#BFP_Raw_Size,D0
; D0 = Größe des ausgepackten Bildes
Copy_Skin_BODY_Loop
	Move.B	(A0)+,D2
	Bmi.b	Copy_Skin_BODY_PK
Copy_Skin_BODY_NoPK
; Nicht komprimierter Teil
	Addq.B	#1,D2
Copy_Skin_BODY_NoPK_Loop
	Move.B	(A0)+,(A1)+
	Subq.L	#1,D0
	Beq.b	Set_Color_Map
	Addq.B	#1,D3
	Cmp.B	#44,D3
	Bne.b	Copy_Skin_BODY_PK_No_Next_Line
	Bsr.b	Copy_Skin_Next_Line
Copy_Skin_BODY_PK_No_Next_Line
	Subq.B	#1,D2
	Bne.b	Copy_Skin_BODY_NoPK_Loop
	Bra.b	Copy_Skin_BODY_Loop
Copy_Skin_BODY_PK
; Komprimierter Teil
	Subq.B	#1,D2
	Move.B	(A0)+,D1
Copy_Skin_BODY_PK_Loop
	Move.B	D1,(A1)+
	Subq.L	#1,D0
	Beq.b	Set_Color_Map
	Addq.B	#1,D3
	Cmp.B	#44,D3
	Bne.b	Copy_Skin_BODY_No_Next_Line
	Bsr.b	Copy_Skin_Next_Line
Copy_Skin_BODY_No_Next_Line
	Addq.B	#1,D2
	Bne.b	Copy_Skin_BODY_PK_Loop
	Bra.b	Copy_Skin_BODY_Loop
Copy_Skin_Next_Line
; Berechnung der gleichen Zeile und anderer Bitplane
	Moveq.L	#0,D3
	Sub.L	#44,A1
	Add.L	#Plane_Size,A1
	Addq.B	#1,D4
	Cmp.B	#5,D4
	Bne.b	Copy_Skin_Return
	Moveq.L	#0,D4
	Sub.L	#Plane_Size*5,A1
	Add.L	#44,A1
Copy_Skin_Return
	Rts
Set_Color_Map
; Farbpalette setzen
Set_Color_Search_CMAP
	Addq.L	#2,A3
	Cmp.L	#"CMAP",(A3)
	Bne.b	Set_Color_Search_CMAP
	Add.L	#8,A3
	Moveq.L	#0,D4
Set_Color_Loop
	Move.L	Graphics_Base-VB(A5),A6
	Move.L	Screen_View_Port-VB(A5),A0
	Move.B	(A3)+,D1
	Lsr.B	#4,D1
	Move.B	(A3)+,D2
	Lsr.B	#4,D2
	Move.B	(A3)+,D3
	Lsr.B	#4,D3
	Move.L	D4,D0
	Jsr	SetRGB4(A6)
	Addq.B	#1,D4
	Cmp.B	#32,D4
	Bne.b	Set_Color_Loop
	Moveq.L	#0,D0
	Rts


; Directory vom voreingestellten Pfad holen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get_Path
; Gibt es eine Playlist
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,File_Lock-VB(A5)
	Beq.b	Get_Path_No_PLS
	Move.L	File_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
	Bsr.w	Get_Playlist
	Rts
Get_Path_No_PLS
; Pfad holen
	Lea	Path_Buffer-VB(A5),A0
	Tst.B	(A0)
	Beq.b	Get_Path_Error
	Lea	File_Name-VB(A5),A1	
	Moveq.L	#0,D1
Get_Path_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Addq.L	#1,D1
	Tst.B	D0
	Bne.b	Get_Path_Loop
	Subq.L	#1,D1
	Subq.L	#2,A1
	Cmp.B	#"/",(A1)
	Bne.b	Get_Path_OK
	Move.B	#0,(A1)
	Subq.L	#1,D1
Get_Path_OK
	Move.L	D1,File_Name_Pos-VB(A5)
; Lock holen, ob der Pfad stimmt
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,File_Lock-VB(A5)
	Beq.b	Get_Path_Error
	Bsr.w	Get_Dir
; Propgadget nach oben
	Move.W	#0,FileS_PropY-VB(A5)
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
	Bsr.w	Sort_List
	Bsr.w	Print_List
	Bra.b	Get_Path_Exit
Get_Path_Error
	Bsr.b	Get_Device_List
Get_Path_Exit
	Move.L	File_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
	Rts


; Geräteliste holen
; ~~~~~~~~~~~~~~~~~

Get_Device_List
	Move.L	#0,Play_Pos-VB(A5)
	Move.B	#0,Play_New_Flag-VB(A5)
	Bsr.w	Deselect
; Propgadget für Playliste merken und nach oben
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Bne.b	Get_Device_Prop
	Move.W	FileS_PropY-VB(A5),Save_Pls_PropY-VB(A5)
Get_Device_Prop
	Move.W	#0,FileS_PropY-VB(A5)
; Wenn wir in der Device List sind, dann gehe zur Playlist
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#12,(A0)
	Beq.w	Get_Playlist
	Move.L	Dos_Base-VB(A5),A6
	Move.L	34(A6),A6
	Move.L	24(A6),D0
	Lsl.L	#2,D0
	Move.L	D0,A6
	Move.L	4(A6),D0
	Lsl.L	#2,D0
	Move.L	D0,A6
Get_Device_List_Loop
	Tst.L	(A6)
	Beq.b	Get_Device_List_End
	Move.L	4(A6),D2
	Beq.b	Get_Device_Next
	Tst.B	Assign_Flag-VB(A5)
	Bne.b	Get_Assign
	Cmp.B	#1,D2
	Beq.b	Get_Device_Next
	Cmp.B	#3,D2
	Beq.b	Get_Device_Next
Get_Assign
	Move.L	40(A6),D0
	Lsl.L	#2,D0
	Move.L	D0,A1
	Move.B	(A1)+,D0
	Moveq.L	#1,D1
Get_Device_Name_Loop
	Tst.B	D0
	Beq.b	Get_Device_Name_End
	Move.B	(A1)+,(A0,D1)
	Addq.L	#1,D1
	Subq.B	#1,D0
	Bra.b	Get_Device_Name_Loop
Get_Device_Name_End
	Move.B	#":",(A0,D1)
	Move.B	#0,1(A0,D1)
	Lea	Device_Color_List-VB(A5),A1
	Move.B	(A1,D2),D2
	Move.B	D2,(A0)
	Add.L	#32,A0
Get_Device_Next
	Move.L	(A6),D0
	Lsl.L	#2,D0
	Move.L	D0,A6
	Bra.b	Get_Device_List_Loop
Get_Device_List_End
; Ende der Liste makieren
	Move.W	#0,(A0)
; Liste sortieren
	Bsr.w	Sort_List
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
; Liste ausgeben
	Bsr.w	Print_List
; Filename zuücksetzen
	Move.L	#0,File_Name_Pos-VB(A5)
	Lea	File_Name-VB(A5),A0
	Move.B	#0,(A0)
	Moveq.L	#-1,D0
	Rts

Device_Color_List
; Farben den Gerätetypen zuweisen
; 0 = Device
; 1 = Assign
; 2 = Volume
; 3 = Assign (spät)
	Dc.B	0,15,12,16,0,0,0,0


; Playlist holen
; ~~~~~~~~~~~~~~

Get_Playlist
; Propgadget setzen
	Move.W	Save_Pls_PropY-VB(A5),FileS_PropY-VB(A5)
Get_Playlist_Again
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#95,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information Playlist wird geladen
	Moveq.L	#21,D0
	Lea	Playlist_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
Refresh_Playlist
; File Liste zum Zeiger
	Move.L	File_List_Base-VB(A5),A0
	Move.L	A0,File_List_Pointer-VB(A5)
; Playliste öffnen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	Get_Playlist_End
; Block einlesen
	Move.L	File_List_Pointer-VB(A5),A0
	Move.B	#24,(A0)+
Get_Playlist_Read
	Move.L	A0,-(A7)
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	#32768,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	(A7)+,A0
	Move.L	D0,D4
	Beq.b	Get_Playlist_Error
	Bra.b	Get_Playlist_Entry_Loop
Get_Playlist_Entry
	Move.L	File_List_Pointer-VB(A5),A0
	Move.B	#24,(A0)+
	Moveq.L	#0,D1
Get_Playlist_Entry_Loop
	Subq.W	#1,D4
	Bmi.b	Get_Playlist_Read
	Move.B	(A4)+,D0
	Move.B	D0,(A0)+
	Addq.L	#1,D1
	Cmp.B	#"/",D0
	Beq.b	Get_Playlist_Entry
	Cmp.B	#":",D0
	Beq.b	Get_Playlist_Entry
Get_Playlist_Entry_Cont
	Cmp.B	#$0A,D0
	Bne.b	Get_Playlist_Entry_Loop
	Cmp.L	#30,D1
	Bls.b	Get_Playlist_Entry_Short_Name
	Move.L	File_List_Pointer-VB(A5),A0
	Add.L	#29,A0
	Move.B	#".",(A0)+
	Move.B	#".",(A0)+
	Addq.L	#1,A0
Get_Playlist_Entry_Short_Name
	Move.B	#0,-(A0)
	Add.L	#32,File_List_Pointer-VB(A5)
	Move.L	File_List_Base-VB(A5),D0
	Add.L	#File_List_Size,D0
	Cmp.L	File_List_Pointer-VB(A5),D0
	Bls.b	Get_Playlist_Error
	Bra.b	Get_Playlist_Entry
Get_Playlist_Error
; Datei schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Get_Playlist_End
; Liste abschließen
	Move.L	File_List_Pointer-VB(A5),A0
	Move.W	#0,(A0)
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
; Liste ausgeben
	Bsr.w	Print_List
	Moveq.L	#-1,D0
	Rts

File_List_Pointer
	Dc.L	0

Save_Pls_PropY
; Letzte Position des Slider Gadgets merken
	Dc.L	0

Playlist_Name
	Dc.B	"MAS-Player.pls",0
	Dcb.B	256,0
	Even

Playlist_Hd
	Dc.L	0

Playlist_Temp_Name
	Dcb.B	256,0

Playlist_Temp_Hd
	Dc.L	0

Playlist_Info_Text
	Dc.B	" Loading playlist... "
	Even


; Alle Titel der Playliste hinzufügen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add_All
	Move.L	File_Name_Pos-VB(A5),D0
	Beq.w	Add_All_Exit
; Bin ich in der Playlist?
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Beq.w	Add_All_Exit
; Ist Fileliste Null?
	Tst.W	(A0)
	Beq.w	Add_All_Exit
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Bne.b	Add_All_Open_OK
; Wenn es noch keine Playliste gibt
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeNew,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	Add_All_Exit
Add_All_Open_OK
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Corsor
	Moveq.L	#60,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß alle Titel addiert werden
	Moveq.L	#31,D0
	Lea	Add_All_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; An das Ende der Datei
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	#0,D2
	Moveq.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Directoryliste vorbereiten
	Move.L	File_List_Base-VB(A5),A0
	Move.L	A0,Add_All_Dir_Adr-VB(A5)
	Lea	File_Name-VB(A5),A1
	Move.L	File_Name_Pos-VB(A5),D0
	Move.B	#0,(A1,D0.W)
Add_All_Dir_Name_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Tst.B	D0
	Bne.b	Add_All_Dir_Name_Loop
	Move.B	#0,(A0)
	Move.L	A0,Add_All_New_Dir_Adr-VB(A5)
Add_All_Examine
; Lock holen
	Move.L	Add_All_Dir_Adr-VB(A5),A0
	Move.L	A0,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,Add_All_Lock-VB(A5)
	Beq.w	Add_All_End
; Ersten Eintrag ermitteln
	Move.L	Add_All_Lock-VB(A5),D1
	Lea	File_Info_Block,A0
	Move.L	A0,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Examine(A6)
Add_All_Ex_Loop
; Folgeeinträge ermitteln
	Move.L	Add_All_Lock-VB(A5),D1
	Lea	File_Info_Block-VB(A5),A0
	Move.L	A0,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	ExNext(A6)
	Tst.L	D0
	Beq.w	Add_All_End_Ex
; Ist es ein Directory, was untersucht werden muß?
	Lea	File_Info_Block-VB(A5),A0
	Tst.L	4(A0)
	Bmi.b	Add_All_Cont
; Directory in Liste aufnehmen
	Move.L	Add_All_New_Dir_Adr-VB(A5),A1
	Move.L	File_List_Base-VB(A5),D0
	Add.L	#File_List_Size-1024,D0
	Cmp.L	D0,A1
	Bhs.w	Add_All_End_Ex
	Add.L	#8,A0
	Move.L	Add_All_Dir_Adr-VB(A5),A2
Add_All_Add_Dir_Loop1
	Move.B	(A2)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Add_All_Add_Dir_Loop1
	Subq.L	#1,A1
	Cmp.B	#":",-1(A1)
	Beq.b	Add_All_Add_Dir_Loop2
	Move.B	#"/",(A1)+
Add_All_Add_Dir_Loop2
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Add_All_Add_Dir_Loop2
	Move.B	#0,(A1)
	Move.L	A1,Add_All_New_Dir_Adr-VB(A5)
	Bra.b	Add_All_Ex_Loop
Add_All_Cont
; Eintrag zur Playliste
	Move.L	Add_All_Dir_Adr-VB(A5),A1
	Lea	File_Info_Block-VB(A5),A0
	Add.L	#8,A0
	Lea	Sound,A2
	Moveq.L	#0,D3
Add_All_Dir_Loop
	Move.B	(A1)+,D0
	Beq.b	Add_All_File
	Move.B	D0,(A2)+
	Addq.L	#1,D3
	Bra.b	Add_All_Dir_Loop
Add_All_File
	Cmp.B	#":",-1(A2)
	Beq.b	Add_All_File_Loop
	Move.B	#"/",(A2)+
	Addq.L	#1,D3
Add_All_File_Loop
	Move.B	(A0)+,D0
	Beq.b	Add_All_File_End
	Move.B	D0,(A2)+
	Add.L	#1,D3
	Bra.b	Add_All_File_Loop
Add_All_File_End
	Move.B	#$0A,(A2)+
	Addq.L	#1,D3
; Ist es ein .MPx ?
	Move.B	-3(A2),D0
	Or.B	#$20,D0
	Cmp.B	#"p",D0
	Bne.w	Add_All_Ex_Loop
	Move.B	-4(A2),D0
	Or.B	#$20,D0
	Cmp.B	#"m",D0
	Bne.w	Add_All_Ex_Loop
	Move.B	-5(A2),D0
	Cmp.B	#".",D0
	Bne.w	Add_All_Ex_Loop
; Titel abspeichern
	Move.L	#Sound,D2
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Bra.w	Add_All_Ex_Loop
Add_All_End_Ex
; Lock schließen
	Move.L	Add_All_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
; Abbruch?
	Move.W	#-1,Push_Gadget-VB(A5)
	Move.L	Window_Hd-VB(A5),A0
	Move.L	86(A0),A0
	Move.L	ExecBase,A6
	Jsr	GetMsg(A6)
	Tst.L	D0
	Beq.b	Add_All_No_Break
	Move.L	D0,A0
	Move.L	20(A0),D6
	Btst	#6,D6
	Bne.b	Add_All_End
	Btst	#10,D6
	Bne.b	Add_All_Key
	Move.L	D0,A1
	Move.L	ExecBase,A6
	Jsr	ReplyMsg(A6)
Add_All_No_Break
; Nächstes Directory
	Move.L	Add_All_Dir_Adr-VB(A5),A0
Add_All_Next_Dir_Loop
	Tst.B	(A0)+
	Bne.b	Add_All_Next_Dir_Loop
	Move.L	A0,Add_All_Dir_Adr-VB(A5)
	Tst.B	(A0)
	Bne.w	Add_All_Examine
	Bra.b	Add_All_End
Add_All_Key
	Move.L	D0,A1
	Move.B	$19(A1),D1
	Cmp.B	#$45,D1
	Bne.w	Add_All_No_Break
Add_All_End
; Datei schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
; Ans Ende der Playliste
	Move.W	#$FFFF,FileS_PropY-VB(A5)
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
	Bra.w	Get_Playlist_Again
Add_All_Exit
	Moveq.L	#-1,D0
	Rts

Add_All_Info_Text
	Dc.B	" Add all tracks to playlist... "
	Even

Add_All_Lock
	Dc.L	0

Add_All_Dir_Adr
	Dc.L	0

Add_All_New_Dir_Adr
	Dc.L	0


; Titel der Playliste hinzufügen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add
	Move.L	Play_Pos-VB(A5),D0
	Beq.w	Add_Exit
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Bne.b	Add_Open_OK
; Wenn es noch keine Playliste gibt
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeNew,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	Add_Exit
Add_Open_OK
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Corsor
	Moveq.L	#75,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß der Titel addiert wird
	Moveq.L	#26,D0
	Lea	Add_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; An das Ende der Datei
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	#0,D2
	Moveq.L	#1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Datei schreiben
	Lea	File_Name-VB(A5),A0
	Lea	Sound,A1
	Moveq.L	#0,D3
Add_Filename_Loop
	Move.B	(A0)+,D0
	Beq.b	Add_Filename_End
	Move.B	D0,(A1)+
	Addq.L	#1,D3
	Bra.b	Add_Filename_Loop
Add_Filename_End
	Move.B	#$0A,(A1)
	Addq.L	#1,D3	
	Move.L	#Sound,D2
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Datei schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Bne.b	Add_List
	Bsr.w	Refresh_Playlist
	Bra.b	Add_Exit
Add_List
	Bsr.w	Print_List
Add_Exit
	Moveq.L	#-1,D0
	Rts

Add_Info_Text
	Dc.B	" Add track to playlist... "
	Even


; Playliste löschen
; ~~~~~~~~~~~~~~~~~

Del_All
; Bin ich in der Playliste?
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Bne.b	Del_All_Exit
Del_All_From_Key
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#45,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß gelöcht wird
	Moveq.L	#36,D0
	Lea	Del_All_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Playliste löschen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	DeleteFile(A6)
; Keinen Titel mehr anwählen
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
	Bra.w	Get_Playlist
Del_All_Exit
	Moveq.L	#-1,D0
	Rts

Del_All_Info_Text
	Dc.B	" Delete all tracks from playlist... "
	Even


; Titel aus der Playliste entfernen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Del
	Move.L	Play_Pos-VB(A5),D0
	Beq.w	Del_Exit
; Bin ich in der Playliste?
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Bne.w	Del_List
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#60,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß gelöcht wird
	Moveq.L	#31,D0
	Lea	Del_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Playliste zu .tmp umbenennen
	Lea	Playlist_Name-VB(A5),A0
	Move.L	A0,D1
	Lea	Playlist_Temp_Name-VB(A5),A1
	Move.L	A1,D2
	Moveq.L	#-1,D3
Del_Rename_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Addq.L	#1,D3
	Tst.B	D0
	Bne.b	Del_Rename_Loop
	Tst.L	D3
	Beq.w	Del_Exit
	Sub.L	#2,A1
	Move.B	(A1),D0
	Cmp.B	#":",D0
	Beq.w	Del_Exit
	Cmp.B	#"/",D0
	Beq.w	Del_Exit
	Move.B	#"~",(A1)
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Rename(A6)
; .tmp Datei öffnen
	Lea	Playlist_Temp_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Temp_Hd-VB(A5)
	Beq.w	Del_Exit
; .pls Datei öffnen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeNew,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	Del_Close_Temp
; Position errechnen
	Move.L	Play_Pos-VB(A5),D6
	Sub.L	File_List_Base-VB(A5),D6
	Lsr.L	#5,D6
	Moveq.L	#0,D5
Del_Entry_Read_Loop
; Block lesen
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	#32768,D3
	Move.L	Playlist_Temp_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	D0,D7
	Beq.b	Del_Close
Del_Entry_Loop2
	Moveq.L	#0,D3
Del_Entry_Loop
	Move.B	(A4)+,D0
	Addq.L	#1,D3
	Subq.L	#1,D7
	Cmp.B	#$0A,D0
	Beq.b	Del_Entry_Add
	Tst.L	D7
	Beq.b	Del_Entry_Write
	Bra.b	Del_Entry_Loop
Del_Entry_Write
	Cmp.L	D5,D6
	Beq.b	Del_Entry_Skip
; Zeile schreiben
	Move.L	D3,D3	
	Move.L	A4,D2
	Sub.L	D3,D2
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
Del_Entry_Skip
	Tst.L	D7
	Beq.b	Del_Entry_Read_Loop
	Bra.b	Del_Entry_Loop2
Del_Entry_Add
	Cmp.L	D5,D6
	Beq.b	Del_Entry_Add_Skip
; Zeile schreiben
	Move.L	D3,D3	
	Move.L	A4,D2
	Sub.L	D3,D2
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
Del_Entry_Add_Skip
	Addq.L	#1,D5
	Tst.L	D7
	Beq.b	Del_Entry_Read_Loop
	Bra.b	Del_Entry_Loop2
Del_Close
; Dateien schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Del_Close_Temp
	Move.L	Playlist_Temp_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
Del_Temp
	Lea	Playlist_Temp_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	DeleteFile(A6)
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
	Bsr.w	Refresh_Playlist
Del_Exit
	Moveq.L	#-1,D0
	Rts

Del_Info_Text
	Dc.B	" Delete track from playlist... "
	Even

Del_List
; Eintrag aus der Liste nehmen	
	Move.L	Play_Pos-VB(A5),A0
	Move.L	A0,A1
	Add.L	#32,A1
Del_List_Loop
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Move.L	(A1)+,(A0)+
	Tst.B	(A0)
	Beq.b	Del_List_Refresh
	Bra.b	Del_List_Loop
Del_List_Refresh
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
	Bsr.w	Get_List_Len
	Bsr.w	Print_List
	Bra.b	Del_Exit


; Eintrag hoch/runter
; ~~~~~~~~~~~~~~~~~~~

Move_Up
	Move.L	Play_Pos-VB(A5),D0
	Beq.w	Move_Exit
; Ist es der erste Eintrag?
	Move.L	File_List_Base-VB(A5),A0
	Cmp.L	D0,A0
	Beq.w	Move_Exit
; Bin ich in der Playliste?
	Cmp.B	#24,(A0)
	Bne.w	Move_Up_List
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#125,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information bewege noch oben
	Moveq.L	#12,D0
	Lea	Move_Up_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Datei öffnen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	Move_Close
; Position errechnen
	Move.L	Play_Pos-VB(A5),D6
	Sub.L	File_List_Base-VB(A5),D6
	Lsr.L	#5,D6
	Subq.L	#1,D6
	Moveq.L	#1,D5
	Moveq.L	#0,D4
	Tst.L	D6
	Beq.b	Move_Up_Copy_Loop
Move_Up_Fast_Read
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	#32768,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	D0,D7
Move_Up_Fast_Search
	Move.B	(A4)+,D0
	Subq.L	#1,D7
	Addq.L	#1,D4
	Cmp.B	#$0A,D0
	Beq.b	Move_Up_Fast_Compare
Move_Up_Fast_Cont
	Tst.L	D7
	Beq.b	Move_Up_Fast_Read
	Bra.b	Move_Up_Fast_Search
Move_Up_Fast_Compare
	Cmp.L	D5,D6
	Beq.b	Move_Up_Copy
	Addq.L	#1,D5
	Bra.b	Move_Up_Fast_Cont
Move_Up_Copy
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	D4,D2
	Move.L	#-1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Zeile Lesen
Move_Up_Copy_Loop
	Moveq.L	#0,D5
	Lea	Sound,A4
Move_Up_Entry_Loop
	Move.L	A4,D2
	Move.L	#1,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Move_Close
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Up_Entry_Loop
Move_Up_Entry_Loop2
	Move.L	A4,D2
	Move.L	#1,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.b	Move_Close
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Up_Entry_Loop2
; Zurück an die Stelle, wo getaucht wird
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	D5,D2
	Neg.L	D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Tauschen
	Lea	Sound,A4
	Move.L	#0,D5
Move_Up_Exchange_Loop
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Up_Exchange_Loop
	Move.L	A4,A6
	Move.L	#0,D7
Move_Up_Exchange_Loop2
	Move.B	(A4)+,D0
	Addq.L	#1,D7
	Cmp.B	#$0A,D0
	Bne.b	Move_Up_Exchange_Loop2
; Einträge schrieben	
	Move.L	A6,D2	
	Move.L	D7,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	D5,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Balken eins nach oben
	Sub.L	#32,Play_Pos-VB(A5)
Move_Close
; Dateien schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
; Liste neu aufbauen
	Bsr.w	Refresh_Playlist
Move_Exit
	Moveq.L	#-1,D0
	Rts

Move_Down
	Move.L	Play_Pos-VB(A5),D0
	Beq.b	Move_Exit
; Ist es der letzte Eintrag?
	Move.L	Play_Pos-VB(A5),A0
	Tst.B	32(A0)
	Beq.b	Move_Exit
; Bin ich in der Playliste?
	Move.L	File_List_Base-VB(A5),A0
	Cmp.B	#24,(A0)
	Bne.w	Move_Down_List
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#120,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information bewege noch oben
	Moveq.L	#14,D0
	Lea	Move_Down_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Datei öffnen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.b	Move_Close
; Position errechnen
	Move.L	Play_Pos-VB(A5),D6
	Sub.L	File_List_Base-VB(A5),D6
	Lsr.L	#5,D6
	Moveq.L	#1,D5
	Moveq.L	#0,D4
	Tst.L	D6
	Beq.b	Move_Down_Copy_Loop
Move_Down_Fast_Read
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	#32768,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	D0,D7
Move_Down_Fast_Search
	Move.B	(A4)+,D0
	Subq.L	#1,D7
	Addq.L	#1,D4
	Cmp.B	#$0A,D0
	Beq.b	Move_Down_Fast_Compare
Move_Down_Fast_Cont
	Tst.L	D7
	Beq.b	Move_Down_Fast_Read
	Bra.b	Move_Down_Fast_Search
Move_Down_Fast_Compare
	Cmp.L	D5,D6
	Beq.b	Move_Down_Copy
	Addq.L	#1,D5
	Bra.b	Move_Down_Fast_Cont
Move_Down_Copy
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	D4,D2
	Move.L	#-1,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Zeile Lesen
Move_Down_Copy_Loop
	Moveq.L	#0,D5
	Lea	Sound,A4
Move_Down_Entry_Loop
	Move.L	A4,D2
	Move.L	#1,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Move_Close
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Down_Entry_Loop
Move_Down_Entry_Loop2
	Move.L	A4,D2
	Move.L	#1,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.w	Move_Close
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Down_Entry_Loop2
; Zurück an die Stelle, wo getaucht wird
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	D5,D2
	Neg.L	D2
	Move.L	#0,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Seek(A6)
; Tauschen
	Lea	Sound,A4
	Move.L	#0,D5
Move_Down_Exchange_Loop
	Move.B	(A4)+,D0
	Addq.L	#1,D5
	Cmp.B	#$0A,D0
	Bne.b	Move_Down_Exchange_Loop
	Move.L	A4,A6
	Move.L	#0,D7
Move_Down_Exchange_Loop2
	Move.B	(A4)+,D0
	Addq.L	#1,D7
	Cmp.B	#$0A,D0
	Bne.b	Move_Down_Exchange_Loop2
; Einträge schrieben	
	Move.L	A6,D2	
	Move.L	D7,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	D5,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
; Balken eins nach unten
	Add.L	#32,Play_Pos-VB(A5)
	Bra.w	Move_Close

Move_Up_Info_Text
	Dc.B	" Move up... "
	Even

Move_Down_Info_Text
	Dc.B	" Move down... "
	Even

Move_Up_List
	Move.L	Play_Pos-VB(A5),A0
	Move.L	A0,A1
Move_Up_List_Loop
	Sub.L	#32,A1
	Cmp.B	#2,(A1)
	Beq.b	Move_Up_List_Loop
	Cmp.B	#23,(A1)
	Bne.b	Move_Up_List_Exit
; Achtung, benutze zum Austausch UP aus "Sort"
	Lea	Sort_Buffer_1-VB(A5),A2
	Move.L	A1,A3
	Bsr.w	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A0,A3
	Bsr.w	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A1,A3
	Bsr.w	Copy_From_Buffer
	Lea	Sort_Buffer_1-VB(A5),A2
	Bsr.w	Copy_From_Buffer

	Move.L	A1,Play_Pos-VB(A5)
	
	Bsr.w	Print_List
Move_Up_List_Exit
	Moveq.L	#-1,D0
	Rts

Move_Down_List
	Move.L	Play_Pos-VB(A5),A0
	Move.L	A0,A1
Move_Down_List_Loop
	Add.L	#32,A1
	Cmp.B	#2,(A1)
	Beq.b	Move_Down_List_Loop
	Cmp.B	#23,(A1)
	Bne.b	Move_Down_List_Exit
; Achtung, benutze zum Austausch UP aus "Sort"
	Lea	Sort_Buffer_1-VB(A5),A2
	Move.L	A0,A3
	Bsr.w	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A1,A3
	Bsr.w	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A0,A3
	Bsr.w	Copy_From_Buffer
	Lea	Sort_Buffer_1-VB(A5),A2
	Move.L	A3,A1
	Bsr.w	Copy_From_Buffer
	Move.L	A1,Play_Pos-VB(A5)
	Bsr.w	Print_List
Move_Down_List_Exit
	Moveq.L	#-1,D0
	Rts


; Listenlänge ermittelm
; ~~~~~~~~~~~~~~~~~~~~~

Get_List_Len
	Move.L	File_List_Base-VB(A5),A0
	Moveq.L	#0,D0
Get_List_Len_Loop
	Tst.W	(A0)
	Beq.b	Get_List_Len_Set
	Addq.L	#1,D0
Get_List_Len_Long_Name_Loop
	Add.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Get_List_Len_Long_Name_Loop
	Bra.b	Get_List_Len_Loop
Get_List_Len_Set
	Move.L	D0,List_Len-VB(A5)
	Move.L	List_Len-VB(A5),D0
; Größe des Slider Gadgets berechnen
	Move.L	#65535,D1
	Cmp.L	#13,D0
	Bls.b	Get_List_Full_Prop
	Divu	D0,D1
	Mulu	#13,D1
Get_List_Full_Prop
	Move.W	D1,FileS_PropStep-VB(A5)
; Propgadget Refresh
	Cmp.B	#0,Folder-VB(A5)
	Bne.b	Get_List_Len_Return
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
Get_List_Len_Return
	Rts

List_Len
; Länge der Liste
	Dc.L	0


; Liste sortieren
; ~~~~~~~~~~~~~~~

Sort_List
	Move.L	File_List_Base-VB(A5),A0
	Tst.B	1(A0)
	Beq.w	Sort_List_Return
	Moveq.L	#0,D2
Sort_List_Loop
	Move.L	A0,A1
	Tst.W	32(A0)
	Beq.w	Sort_List_End
Sort_Long_Loop
	Cmp.B	#2,32(A1)
	Bne.b	Sort_List_Begin
	Add.L	#32,A1
	Bra.b	Sort_Long_Loop
Sort_List_Begin
	Tst.W	32(A1)
	Beq.w	Sort_List_End
	Move.L	(A0),D0
	Move.L	32(A1),D1
	Or.L	#$00202020,D0
	Or.L	#$00202020,D1
	Cmp.L	D0,D1
	Blo.w	Sort_Exchg
	Bne.w	Sort_Next
	Move.L	4(A0),D0
	Move.L	36(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.w	Sort_Exchg
	Bne.w	Sort_Next
	Move.L	8(A0),D0
	Move.L	40(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.w	Sort_Exchg
	Bne.w	Sort_Next
	Move.L	12(A0),D0
	Move.L	44(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.b	Sort_Exchg
	Bne.b	Sort_Next
	Move.L	16(A0),D0
	Move.L	48(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.b	Sort_Exchg
	Bne.b	Sort_Next
	Move.L	20(A0),D0
	Move.L	52(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.b	Sort_Exchg
	Bne.b	Sort_Next
	Move.L	24(A0),D0
	Move.L	56(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.b	Sort_Exchg
	Bne.b	Sort_Next
	Move.L	28(A0),D0
	Move.L	60(A1),D1
	Or.L	#$20202020,D0
	Or.L	#$20202020,D1
	Cmp.L	D0,D1
	Blo.b	Sort_Exchg
Sort_Next
	Add.L	#32,A0
	Bra.w	Sort_List_Loop
Sort_List_End
	Tst.B	D2
	Beq.w	Sort_List_Return
	Bra.w	Sort_List
Sort_Exchg
	Moveq.L	#1,D2
	Lea	Sort_Buffer_1-VB(A5),A2
	Move.L	A0,A3
	Bsr.b	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A1,A3
	Add.L	#32,A3
	Bsr.b	Copy_To_Buffer
	Lea	Sort_Buffer_2-VB(A5),A2
	Move.L	A0,A3
	Bsr.b	Copy_From_Buffer
	Lea	Sort_Buffer_1-VB(A5),A2
	Bsr.b	Copy_From_Buffer
	Bra.b	Sort_Next
Copy_To_Buffer
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Move.L	(A3)+,(A2)+
	Cmp.B	#2,(A3)
	Beq.b	Copy_To_Buffer
	Move.W	#0,(A2)
	Rts
Copy_From_Buffer
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Move.L	(A2)+,(A3)+
	Cmp.B	#2,(A2)
	Beq.b	Copy_From_Buffer
	Rts
Sort_List_Return
	Rts

Sort_Buffer_1
	Dcb.B	130,0

Sort_Buffer_2
	Dcb.B	130,0


; An den Listenanfang springen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Goto_Top
	Move.W	#0,FileS_PropY-VB(A5)
; Propgadget Refresh
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Print_List_Slider


; An das Listenende springen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~

Goto_Button
	Move.W	#$FFFF,FileS_PropY-VB(A5)
; Propgadget Refresh
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Print_List_Slider


; Listenslider ein Stück nach oben
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Goto_Up
	Move.W	FileS_PropY-VB(A5),D0
	Sub.W	FileS_PropStep-VB(A5),D0
	Bcc.b	Goto_Up_Top
	Move.W	#0,D0
Goto_Up_Top
	Move.W	D0,FileS_PropY-VB(A5)
; Propgadget Refresh
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Print_List_Slider


; Listenslider ein Stück nach unten
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Goto_Down
	Move.W	FileS_PropY-VB(A5),D0
	Add.W	FileS_PropStep-VB(A5),D0
	Bcc.b	Goto_Down_Button
	Move.W	#$FFFF,D0
Goto_Down_Button
	Move.W	D0,FileS_PropY-VB(A5)
; Propgadget Refresh
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bra.w	Print_List_Slider


; Liste der Titel ausgeben
; ~~~~~~~~~~~~~~~~~~~~~~~~

Print_List
	Tst.B	Folder-VB(A5)
	Bne.w	Print_List_Exit
	Tst.L	Play_Pos-VB(A5)
; Playposition nach Listenposition
	Beq.w	Print_List_Slider
	Move.L	Play_Pos-VB(A5),D0
	Sub.L	File_List_Base-VB(A5),D0
	Move.L	D0,List_Pos-VB(A5)
	Move.L	File_List_Base-VB(A5),A0
	Add.L	D0,A0
; Liste mittig zentrieren
	Move.L	#6,D1
Print_List_Center_Loop
	Tst.L	D0
	Beq.b	Print_List_Auto
Print_List_Center_Long_Loop
	Sub.L	#32,D0
	Sub.L	#32,List_Pos-VB(A5)
	Sub.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Print_List_Center_Long_Loop	
	Subq.L	#1,D1
	Bne.b	Print_List_Center_Loop
	Move.L	A0,A1
	Moveq.L	#1,D1
	Moveq.L	#12,D2
; Wenn die Liste am Ende ist soll unten keine Luft bleiben
Print_List_Center_Loop2
	Add.L	#32,A1
	Cmp.B	#2,(A1)
	Beq.b	Print_List_Center_Loop2
	Tst.W	(A1)
	Beq.b	Print_List_Center_Loop
	Subq.L	#1,D2
	Bne.b	Print_List_Center_Loop2
Print_List_Auto
	Move.L	List_Len-VB(A5),D1
	Cmp.L	#14,D1
	Blo.w	Print_List_PosX
	Move.L	A0,-(A7)
; Slider neu berechnen
	Lsr.L	#5,D0
	Mulu	#65535,D0
	Move.L	List_Len-VB(A5),D1
	Sub.L	#13,D1
	Divu	D1,D0
	Move.W	D0,FileS_PropY-VB(A5)
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Move.L	(A7)+,A0
	Bra.b	Print_List_PosX
; Liste ausgeben an einer Position abhängig vom Balken
Print_List_Slider
	Moveq.L	#0,D0
	Move.W	FileS_PropY-VB(A5),D0
	Move.L	List_Len-VB(A5),D1
	Cmp.L	#14,D1
	Bhs.b	Print_List_Pos
	Move.L	#0,D0
	Bra.b	Print_List_Pos0
Print_List_Pos
	Sub.L	#13,D1
	Move.L	#65535,D2
; Rechenfehler ausgleichen
	Lsl.L	#3,D2
	Divu	D1,D2
	Lsl.L	#3,D0
	Divu	D2,D0
	Ext.L	D0
	Move.L	List_Len-VB(A5),D1
	Sub.L	#13,D1
	Cmp.L	D0,D1
	Bhs.b	Print_List_No_Overflow
	Move.L	D1,D0
Print_List_No_Overflow	
	Move.L	#0,List_Pos-VB(A5)
	Move.L	File_List_Base-VB(A5),A0
Print_List_Start_Loop
	Tst.L	D0
	Beq.w	Print_List_PosX
Print_List_Start_Long_Loop
	Add.L	#32,List_Pos-VB(A5)
	Add.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	Print_List_Start_Long_Loop
	Subq.L	#1,D0
	Bra.b	Print_List_Start_Loop
Print_List_Pos0
	Move.L	#0,List_Pos-VB(A5)
	Move.L	File_List_Base-VB(A5),A0
Print_List_PosX
	Move.L	#13,D2
	Move.L	#55,D1
Print_List_Loop
	Cmp.B	#2,(A0)
	Bne.b	Print_List_Entry
	Add.L	#32,A0
	Bra.b	Print_List_Loop
Print_List_Entry
	Move.L	#5,D0
	Jsr	Move_D0_D1
	Movem.L	D1-D2/A0,-(A7)
; Hintergrundfarbe
	Moveq.L	#1,D0
	Move.L	Play_Pos-VB(A5),D2
	Cmp.L	A0,D2
	Bne.b	Print_List_Mark
	Move.L	#31,D0
Print_List_Mark
	Bsr.w	Set_B_Pen_D0
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textzeile löschen
	Movem.L	D1/A0,-(A7)
	Move.L	#41,D0
	Lea	Blank_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
	Movem.L	(A7)+,D1/A0
; Cursor an den Anfang
	Moveq.L	#5,D0
	Jsr	Move_D0_D1
; Text transparent
	Moveq.L	#0,D0
	Bsr.w	Set_Dr_Md_D0
; Langer Dateiname?
	Cmp.B	#2,32(A0)
	Beq.b	Print_List_Long_Name
; Textfarbe lesen
	Move.B	(A0)+,D0
	Bsr.w	Set_A_Pen_D0
; Textlänge ermitteln und ausgeben
	Moveq.L	#0,D0
Print_List_Text_Len_Loop
	Tst.B	(A0,D0.W)
	Beq.b	Print_List_Line
	Addq.L	#1,D0
	Bra.b	Print_List_Text_Len_Loop
Print_List_Long_Name
; Textfarbe lesen
	Move.B	(A0)+,D0
	Bsr.w	Set_A_Pen_D0
; Text kopieren
	Move.B	(A0),D0
	Beq.w	Print_List_Len0
	Lea	Text_Buffer-VB(A5),A1
Print_List_Long_Name_Copy_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Print_List_Long_Name_Copy_Loop
	Subq.L	#1,A1
	Cmp.B	#2,(A0)+
	Beq.b	Print_List_Long_Name_Copy_Loop	
; Textlänge ermitteln und ausgeben
	Moveq.L	#0,D0
	Lea	Text_Buffer-VB(A5),A0
Print_List_Long_Name_Len_Loop
	Tst.B	(A0,D0.W)
	Beq.b	Print_List_Length
	Addq.L	#1,D0
	Bra.b	Print_List_Long_Name_Len_Loop
; Passt der Text hin??
Print_List_Length
	Movem.L	D0/A0,-(A7)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	TextLength(A6)
	Move.L	D0,D1
	Movem.L	(A7)+,D0/A0
	Cmp.L	#330,D1
	Bls.b	Print_List_Line
; Text zu lang!
	Subq.L	#1,D0
	Move.B	#0,(A0,D0.W)
	Move.B	#".",-1(A0,D0.W)
	Move.B	#".",-2(A0,D0.W)
	Bra.b	Print_List_Length
Print_List_Line
	Tst.L	D0
	Beq.w	Print_List_Len0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Text nicht transparent
	Move.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
	Movem.L	(A7)+,D1-D2/A0
	Movem.L	D1-D2/A0,-(A7)
	Cmp.B	#10,(A0)
	Beq.b	Print_Info_Dir
	Cmp.B	#22,(A0)
	Beq.b	Print_Info_Dir
	Cmp.B	#12,(A0)
	Beq.b	Print_Info_Volume
	Cmp.B	#15,(A0)
	Beq.b	Print_Info_Assign
	Cmp.B	#16,(A0)
	Beq.b	Print_Info_Assign
	Cmp.B	#24,(A0)
	Beq.b	Print_Info_PLS
	Tst.B	(A0)
	Beq.b	Print_Info_Parent
	Bra.w	Print_List_Line_Exit
Print_Info_Dir
	Move.L	#293,D0
	Jsr	Move_D0_D1
	Moveq.L	#6,D0
	Lea	Info_Text_Dir-VB(A5),A0
	Bra.b	Print_List_Info
Print_Info_Parent
	Cmp.B	#31,32(A0)
	Beq.b	Print_Info_CurrentDir
	Move.L	#265,D0
	Jsr	Move_D0_D1
	Moveq.L	#9,D0
	Lea	Info_Text_Parent-VB(A5),A0
	Bra.b	Print_List_Info
Print_Info_CurrentDir
	Move.L	#230,D0
	Jsr	Move_D0_D1
	Moveq.L	#14,D0
	Lea	Info_Text_CurrentDir-VB(A5),A0
	Bra.b	Print_List_Info
Print_Info_Volume
	Move.L	#264,D0
	Jsr	Move_D0_D1
	Moveq.L	#9,D0
	Lea	Info_Text_Volume-VB(A5),A0
	Bra.w	Print_List_Info
Print_Info_Assign
	Move.L	#270,D0
	Jsr	Move_D0_D1
	Moveq.L	#9,D0
	Lea	Info_Text_Assign-VB(A5),A0
	Bra.w	Print_List_Info
Print_Info_PLS
	Move.L	#289,D0
	Jsr	Move_D0_D1
	Moveq.L	#6,D0
	Lea	Info_Text_PLS-VB(A5),A0
Print_List_Info
; Infotext ausgeben
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
	Bra.b	Print_List_Line_Exit
Print_List_Len0
	Cmp.B	#1,D2
	Beq.b	Print_List_Line_Exit
	Move.W	#0,31(A0)
Print_List_Line_Exit
	Movem.L	(A7)+,D1-D2/A0
	Add.L	#32,A0
	Add.L	#15,D1
	Subq.L	#1,D2
	Bne.w	Print_List_Loop
	Move.W	FileS_PropY-VB(A5),Last_FileS_PropY-VB(A5)
Print_List_Exit
	Moveq.L	#-1,D0
	Rts

Text_Buffer
	Dcb.B	128,0

Blank_Text
	Dc.B	"                                         "
	Even

Info_Text_Dir
	Dc.B	" <DIR>"
Info_Text_Parent
	Dc.B	" <PARENT>"
Info_Text_Volume
	Dc.B	" <VOLUME>"
Info_Text_Assign
	Dc.B	" <ASSIGN>"
Info_Text_CurrentDir
	Dc.B	" <CURRENT DIR>"
Info_Text_PLS
	Dc.B	" <PLS>"
	Even

Last_FileS_PropY
; Letzte Stellung des Prop Gadgets merken
	Dc.W	0

List_Pos
; Position an der die Liste ausgegeben wird
	Dc.L	0

Play_Pos
; Adresse des gerade spielenden Liedes in der Liste
	Dc.L	0


; Auswahl eines Files
; ~~~~~~~~~~~~~~~~~~~

File_1
	Moveq.L	#0,D0
	Bra.b	File
File_2
	Moveq.L	#1,D0
	Bra.b	File
File_3
	Moveq.L	#2,D0
	Bra.b	File
File_4
	Moveq.L	#3,D0
	Bra.b	File
File_5
	Moveq.L	#4,D0
	Bra.b	File
File_6
	Moveq.L	#5,D0
	Bra.b	File
File_7
	Moveq.L	#6,D0
	Bra.b	File
File_8
	Moveq.L	#7,D0
	Bra.b	File
File_9
	Moveq.L	#8,D0
	Bra.b	File
File_10
	Moveq.L	#9,D0
	Bra.b	File
File_11
	Moveq.L	#10,D0
	Bra.b	File
File_12
	Moveq.L	#11,D0
	Bra.b	File
File_13
	Moveq.L	#12,D0
File
	Move.L	File_List_Base-VB(A5),A0
	Add.L	List_Pos-VB(A5),A0
File_First_Loop
	Cmp.B	#2,(A0)
	Bne.b	File_First
	Add.L	#32,(A0)
	Bra.b	File_First_Loop
File_First
	Tst.L	D0
	Beq.b	File_Found
File_Next
	Add.L	#32,A0
	Cmp.B	#2,(A0)
	Beq.b	File_Next
	Subq.L	#1,D0
	Bra.b	File_First
File_Found
	Cmp.W	#0,(A0)
	Beq.w	File_Exit
	Move.L	#0,Play_Pos-VB(A5)
	Move.L	A0,-(A7)
	Bsr.w	Deselect
	Move.L	(A7)+,A0
	Move.B	(A0)+,D0
; Ist Volume?
	Cmp.B	#12,D0
	Beq.w	File_Get_Name
; Ist Assign?
	Cmp.B	#15,D0
	Beq.w	File_Get_Name
	Cmp.B	#16,D0
	Beq.w	File_Get_Name
; Ist Directory?
	Cmp.B	#10,D0
	Beq.w	File_Get_Dir
; Ist Jump File?
	Cmp.B	#8,D0
	Beq.w	File_Jump_File
; Ist Jump Dir? (Gleiche wie Jump File)
	Cmp.B	#22,D0
	Beq.w	File_Jump_File
; Ist Parent Dir?
	Tst.B	D0
	Beq.w	File_Parent_Dir
; Ist es eine Datei?
	Cmp.B	#23,D0
	Beq.w	File_Select
; Ist es eine Datei von der Playliste?
	Cmp.B	#24,D0
	Beq.b	File_From_PLS
	Bra.w	File_Exit
Playlist_Select_From_Joy
	Move.L	A0,Play_Pos-VB(A5)
	Addq.L	#1,A0
	Bsr.b	File_From_PLS_UP
	Move.B	#1,Play_New_Flag-VB(A5)
	Bsr.w	Print_List
	Tst.B	Auto_Flag-VB(A5)
	Beq.w	File_Exit
	Bra.w	Play
Playlist_Select_From_Play
	Move.L	Play_Pos-VB(A5),A0
	Addq.L	#1,A0
	Bsr.b	File_From_PLS_UP
	Move.B	#1,Play_New_Flag-VB(A5)
	Bsr.w	Print_List
	Bra.w	Play
File_From_PLS
	Bsr.b	File_From_PLS_UP
	Subq.L	#1,A0
	Move.L	A0,Play_Pos-VB(A5)
	Move.B	#1,Play_New_Flag-VB(A5)
	Bsr.w	Print_List
	Tst.B	Auto_Flag-VB(A5)
	Beq.w	File_Exit
	Bra.w	Play
File_From_PLS_UP
	Move.L	A0,File_Save_A0-VB(A5)
	Move.L	A0,D4
	Subq.L	#1,D4
	Sub.L	File_List_Base-VB(A5),D4
	Lsr.L	#5,D4
; Datei öffnen
	Lea	Playlist_Name-VB(A5),A6
	Move.L	A6,D1
	Move.L	#ModeOld,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,Playlist_Hd-VB(A5)
	Beq.w	File_Exit
	Moveq.L	#1,D5
File_From_PLS_Read
	Lea	Sound,A4
	Move.L	A4,D2
	Move.L	#32768,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Move.L	D0,D7
	Beq.w	File_From_PLS_Error
	Tst.L	D4
	Beq.b	File_From_PLS_Path
File_From_PLS_Loop
	Move.B	(A4)+,D0
	Subq.L	#1,D7
	Cmp.B	#$0A,D0
	Beq.b	File_From_PLS_Compare
File_From_PLS_Next_Loop
	Tst.L	D7
	Beq.b	File_From_PLS_Read
	Bra.b	File_From_PLS_Loop
File_From_PLS_Compare
	Cmp.L	D4,D5
	Beq.b	File_From_PLS_Path
	Addq.L	#1,D5
	Bra.b	File_From_PLS_Next_Loop
File_From_PLS_Path
	Move.L	A4,D6
	Tst.L	D7
	Beq.b	File_From_PLS_Read
File_From_PLS_Path_Loop
	Move.B	(A4)+,D0
	Subq.L	#1,D7
	Cmp.B	#$0A,D0
	Beq.b	File_From_PLS_Cut
	Tst.L	D7
	Beq.b	File_From_PLS_Path_Read
	Bra.b	File_From_PLS_Path_Loop
File_From_PLS_Path_Read
	Move.L	A4,D2
	Move.L	#1,D3
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Read(A6)
	Beq.b	File_From_PLS_Cut
	Move.B	(A4)+,D0
	Cmp.B	#$0A,D0
	Bne.b	File_From_PLS_Path_Read
File_From_PLS_Cut
	Move.B	#0,-1(A4)
	Moveq.L	#1,D1
File_From_PLS_Cut_Loop
	Move.B	-(A4),D0
	Cmp.B	#"/",D0
	Beq.b	File_From_PLS_Cut_End
	Cmp.B	#":",D0
	Beq.b	File_From_PLS_Cut_End2
	Subq.L	#1,D1
	Bra.b	File_From_PLS_Cut_Loop
File_From_PLS_Cut_End
	Subq.L	#1,D1
File_From_PLS_Cut_End2
	Move.L	D6,A4
	Lea	File_Name-VB(A5),A0
File_From_PLS_Copy_Loop
	Move.B	(A4)+,D0
	Move.B	D0,(A0)+
	Beq.b	File_From_PLS_End
	Addq.L	#1,D1
	Bra.b	File_From_PLS_Copy_Loop
File_From_PLS_End
	Move.L	D1,File_Name_Pos-VB(A5)
File_From_PLS_Error
; Datei schließen
	Move.L	Playlist_Hd-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Close(A6)
	Move.L	File_Save_A0-VB(A5),A0
	Rts
File_Select
; Es ist eine Datei!
	Subq.L	#1,A0
File_Select_From_Joy
	Move.L	A0,Play_Pos-VB(A5)
	Addq.L	#1,A0
	Move.B	#1,Play_New_Flag-VB(A5)
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
	Cmp.B	#":",-1(A1)
	Beq.b	File_Loop
	Move.B	#"/",(A1)+
File_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Beq.b	File_Long_Name
	Bra.b	File_Loop
File_Long_Name
	Cmp.B	#2,(A0)+
	Bne.B	File_Start
	Subq.L	#1,A1
	Bra.b	File_Loop
File_Start
	Bsr.w	Print_List
	Tst.B	Auto_Flag-VB(A5)
	Beq.w	File_Exit
	Bra.w	Play
File_Select_From_Play
	Move.L	Play_Pos-VB(A5),A0
	Addq.L	#1,A0
	Move.B	#1,Play_New_Flag-VB(A5)
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
	Cmp.B	#":",-1(A1)
	Beq.b	File_Loop2
	Move.B	#"/",(A1)+
File_Loop2
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Beq.B	File_Long_Name2
	Bra.b	File_Loop2
File_Long_Name2
	Cmp.B	#2,(A0)+
	Bne.B	File_Start2
	Subq.L	#1,A1
	Bra.b	File_Loop2
File_Start2
	Bsr.w	Print_List
	Bra.w	Play
File_Parent_Dir
; Parent Dir, evtl auch Current Dir
	Move.W	Save_PropY-VB(A5),FileS_PropY-VB(A5)
	Move.W	#0,Save_PropY-VB(A5)
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
	Cmp.B	#31,31(A0)
	Beq.w	File_Get_Name_Exit
	Sub.L	#1,File_Name_Pos-VB(A5)
	Sub.L	#1,A1
File_Parent_Dir_Loop
	Cmp.B	#"/",(A1)
	Beq.b	File_Parent_Dir_End
	Cmp.B	#":",(A1)
	Beq.b	File_Parent_Dir_Vol_End
	Sub.L	#1,File_Name_Pos-VB(A5)
	Sub.L	#1,A1
	Bra.b	File_Parent_Dir_Loop
File_Parent_Dir_End
	Move.B	#0,(A1)
	Bra.w	File_Get_Name_Exit
File_Parent_Dir_Vol_End
	Move.B	#0,1(A1)
	Add.L	#1,File_Name_Pos-VB(A5)
	Bra.w	File_Get_Name_Exit
File_Jump_File
	Move.L	A0,A1
	Sub.L	#61,A1
	Move.L	(A1),A1
	Lea	File_Name-VB(A5),A2
	Moveq.L	#-1,D1
File_Jump_File_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A2)+
	Addq.L	#1,D1
	Tst.B	D0
	Bne.b	File_Jump_File_Loop
	Move.L	D1,File_Name_Pos-VB(A5)
	Bra.b	File_Get_Name_Exit
File_Get_Dir
; Propgadget nach oben und letzte Pos. merken
	Move.W	FileS_PropY-VB(A5),Save_PropY-VB(A5)
	Move.W	#0,FileS_PropY-VB(A5)
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
	Cmp.B	#":",-1(A1)
	Beq.b	File_Get_Name_Loop
	Move.B	#"/",(A1)+
	Add.L	#1,File_Name_Pos-VB(A5)
	Bra.b	File_Get_Name_Loop
File_Get_Name
; Filename setzen
	Move.W	#0,FileS_PropY-VB(A5)
	Lea	File_Name-VB(A5),A1
	Add.L	File_Name_Pos-VB(A5),A1
File_Get_Name_Loop
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Beq.b	File_Get_Long_Name
	Add.L	#1,File_Name_Pos-VB(A5)
	Bra.b	File_Get_Name_Loop
File_Get_Long_Name
	Cmp.B	#2,(A0)+
	Bne.B	File_Get_Name_Exit
	Subq.L	#1,A1
	Bra.b	File_Get_Name_Loop
File_Get_Name_Exit
; Drrectory holen
	Bsr.w	Get_Dir
; Liste sortieren
	Bsr.w	Sort_List
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
; Liste ausgeben
	Bsr.w	Print_List
File_Exit
	Moveq.L	#-1,D0
	Rts

File_Save_A0
	Dc.L	0

File_Name
	Dcb.B	2048,0

File_Name_Pos
; Kennzeichnet das Ende im Filenamen
	Dc.L	0


; Directory holen
; ~~~~~~~~~~~~~~~

Get_Dir
; Filelist löschen
	Move.L	File_List_Base-VB(A5),A0
	Move.W	#0,(A0)
; Text nicht transparent
	Moveq.L	#1,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#11,D0
	Bsr.w	Set_A_Pen_D0
; Hintergrund
	Moveq.L	#9,D0
	Bsr.w	Set_B_Pen_D0
; Cursor
	Moveq.L	#95,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß geladen wird
	Cmp.B	#0,Folder-VB(A5)
	Bne.b	Get_Dir_No_Info
	Moveq.L	#21,D0
	Lea	Get_Dir_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
Get_Dir_No_Info
; Mögliches Parent Dir oben in der Liste einfügen
	Move.L	File_List_Base-VB(A5),A0
	Move.L	A0,Get_Dir_List_Pos-VB(A5)
	Lea	File_Name-VB(A5),A6
	Add.L	File_Name_Pos-VB(A5),A6
	Cmp.B	#":",-(A6)
	Beq.b	Get_Dir_Lock
	Moveq.L	#27,D1
Get_Dir_Parent_Loop
	Cmp.B	#":",(A6)
	Beq.b	Get_Dir_Parent_Set_Name
	Cmp.B	#"/",(A6)
	Beq.b	Get_Dir_Parent_Set_Name
	Subq.L	#1,D1
	Beq.b	Get_Dir_Parent_Set_Name
	Subq.L	#1,A6
	Bra.b	Get_Dir_Parent_Loop
Get_Dir_Parent_Set_Name
	Move.B	#0,(A0)+
	Move.B	#".",(A0)+
	Move.B	#".",(A0)+
	Move.B	#".",(A0)+
	Addq.L	#1,A6
Get_Dir_Parent_Set_Name_Loop
	Move.B	(A6)+,D0
	Move.B	D0,(A0)+
	Tst.B	D0
	Bne.b	Get_Dir_Parent_Set_Name_Loop
	Move.B	#"/",-1(A0)
	Move.B	#0,(A0)
	Add.L	#32,Get_Dir_List_Pos-VB(A5)
Get_Dir_Lock
; Lock holen
	Lea	File_Name-VB(A5),A6
	Move.L	A6,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,File_Lock-VB(A5)
	Beq.w	Get_Dir_Exit
; File Info Block füllen
	Move.L	File_Lock-VB(A5),D1
	Lea	File_Info_Block-VB(A5),A6
	Move.L	A6,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Examine(A6)
Get_Dir_Loop
; Eintrag holen
	Move.L	File_Lock-VB(A5),D1
	Lea	File_Info_Block-VB(A5),A6
	Move.L	A6,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	ExNext(A6)
	Tst.L	D0
	Beq.w	Get_Dir_Exit
	Move.L	Get_Dir_List_Pos-VB(A5),A0
	Lea	File_Info_Block-VB(A5),A1
	Add.L	#4,A1
	Tst.L	(A1)+
	Bmi.b	Get_Dir_Filename
Get_Dir_Directory
	Bra.w	Get_Dir_Dirname
Get_Dir_Filename
	Move.B	#23,(A0)+
Get_Dir_Filename_Loop2
	Move.L	#32,D1
Get_Dir_Filename_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.L	#1,D1
	Beq.b	Get_Dir_Long_Name
	Tst.B	D0
	Bne.b	Get_Dir_Filename_Loop
	Bra.b	Get_Dir_Test_MP
Get_Dir_Long_Name
	Add.L	#32,Get_Dir_List_Pos-VB(A5)
	Move.B	#0,-2(A0)
	Move.B	#2,-1(A0)
	Subq.L	#2,A1
	Bra.b	Get_Dir_Filename_Loop2
Get_Dir_Test_MP
	Tst.B	MP_Flag-VB(A5)
	Beq.b	Get_Dir_No_Select
	Subq.L	#2,A0
Get_Dir_Test_p
	Move.B	-(A0),D0
	Beq.b	Get_Dir_Test_p
	Cmp.B	#2,D0
	Beq.b	Get_Dir_Test_p
	Or.B	#$20,D0
	Cmp.B	#"p",D0
	Bne.b	Get_Dir_No_MP
Get_Dir_Test_m
	Move.B	-(A0),D0
	Beq.b	Get_Dir_Test_m
	Cmp.B	#2,D0
	Beq.b	Get_Dir_Test_m
	Or.B	#$20,D0
	Cmp.B	#"m",D0
	Bne.w	Get_Dir_No_MP
Get_Dir_Test_Dot
	Move.B	-(A0),D0
	Beq.b	Get_Dir_Test_Dot
	Cmp.B	#2,D0
	Beq.b	Get_Dir_Test_Dot
	Cmp.B	#".",D0
	Bne.w	Get_Dir_No_MP
Get_Dir_No_Select
	Add.L	#32,Get_Dir_List_Pos-VB(A5)
	Bra.w	Get_Dir_Loop
Get_Dir_No_MP
	Move.L	Get_Dir_List_Pos-VB(A5),A0
	Cmp.B	#23,(A0)
	Beq.w	Get_Dir_Loop
	Sub.L	#32,Get_Dir_List_Pos-VB(A5)
	Bra.b	Get_Dir_No_MP
Get_Dir_Dirname
	Move.B	#10,(A0)+
Get_Dir_Dirname_Loop2
	Move.L	#32,D1
Get_Dir_Dirname_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Subq.L	#1,D1
	Beq.b	Get_Dir_Long_Dir
	Tst.B	D0
	Bne.b	Get_Dir_Dirname_Loop
	Add.L	#32,Get_Dir_List_Pos-VB(A5)
	Bra.w	Get_Dir_Loop
Get_Dir_Long_Dir
	Add.L	#32,Get_Dir_List_Pos-VB(A5)
	Move.B	#0,-2(A0)
	Move.B	#2,-1(A0)
	Subq.L	#2,A1
	Bra.b	Get_Dir_Dirname_Loop2
Get_Dir_Exit
	Move.L	File_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
; Ende der Liste
	Move.L	Get_Dir_List_Pos-VB(A5),A0
	Move.W	#0,(A0)
	Rts

	Cnop	0,4
File_Info_Block
	Dcb.B	260,0

Save_PropY
; Letzte Position des File Sliders
	Dc.W	0

Get_Dir_Info_Text
	Dc.B	" Change directory... "
	Even

File_Lock
	Dc.L	0

Get_Dir_List_Pos
; Position in der Liste beim holen des Directory
	Dc.L	0


; Suchen
; ~~~~~~

Search
	Lea	Search_Buffer-VB(A5),A0
	Tst.b	(A0)
	Beq.w	Search_Exit
	Move.L	File_Name_Pos-VB(A5),D0
	Beq.w	Search_Exit
	Lea	File_Name-VB(A5),A0
	Add.L	D0,A0
	Move.B	#0,(A0)
; Kein angewählter Titel
	Move.L	#0,Play_Pos-VB(A5)
	Bsr.w	Deselect
; Filelist löschen
	Move.L	File_List_Base-VB(A5),A0
	Move.W	#0,(A0)
; Propgadget nach oben
	Move.W	#0,FileS_PropY-VB(A5)
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
; Liste ausgeben
	Bsr.w	Print_List
; Text transparent
	Moveq.L	#0,D0
	Bsr.w	Set_Dr_Md_D0
; Textfarbe
	Moveq.L	#0,D0
	Bsr.w	Set_A_Pen_D0
; Cursor
	Moveq.L	#120,D0
	Move.L	#140,D1
	Jsr	Move_D0_D1
; Information, daß gesucht wird
	Moveq.L	#12,D0
	Lea	Search_Info_Text-VB(A5),A0
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Text(A6)
; Informationen für Suchergebnisse vorbereiten
	Move.L	File_List_Base-VB(A5),A0
	Lea	File_Name-VB(A5),A6
	Add.L	File_Name_Pos-VB(A5),A6
; Current Dir oben in der Liste einfügen
	Moveq.L	#27,D1
Search_Current_Dir_Loop
	Cmp.B	#":",(A6)
	Beq.b	Search_Current_Dir_Set_Name
	Cmp.B	#"/",(A6)
	Beq.b	Search_Current_Dir_Set_Name
	Subq.L	#1,D1
	Beq.b	Search_Current_Dir_Set_Name
	Subq.L	#1,A6
	Bra.b	Search_Current_Dir_Loop
Search_Current_Dir_Set_Name
	Move.B	#0,(A0)+
	Move.B	#".",(A0)+
	Move.B	#".",(A0)+
	Move.B	#".",(A0)+
	Addq.L	#1,A6
Search_Current_Dir_Set_Name_Loop
	Move.B	(A6)+,D0
	Move.B	D0,(A0)+
	Tst.B	D0
	Bne.b	Search_Current_Dir_Set_Name_Loop
	Move.B	#"/",-1(A0)
	Move.B	#0,(A0)
	Move.L	File_List_Base-VB(A5),A0
	Add.L	#32,A0
	Lea	Search_Result_Text-VB(A5),A1
Search_Results_Info_Loop
	Move.W	(A1)+,D0
	Move.W	D0,(A0)+
	Tst.W	D0
	Bne.b	Search_Results_Info_Loop
	Move.L	#64,Search_List_Pos
; Directoryliste vorbereiten
	Move.L	File_List_Base-VB(A5),A0
	Add.L	#9728,A0
	Move.L	A0,Search_Dir_Adr-VB(A5)
	Lea	File_Name-VB(A5),A1
Search_Dir_Name_Loop
	Move.B	(A1)+,D0
	Move.B	D0,(A0)+
	Tst.B	D0
	Bne.b	Search_Dir_Name_Loop
	Move.B	#0,(A0)
	Move.L	A0,Search_New_Dir_Adr-VB(A5)
Search_Examine
; Lock holen
	Move.L	Search_Dir_Adr-VB(A5),A0
	Move.L	A0,D1
	Moveq.L	#-2,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Lock(A6)
	Move.L	D0,Search_Lock-VB(A5)
	Beq.w	Search_End
; Ersten Eintrag ermitteln
	Move.L	Search_Lock-VB(A5),D1
	Lea	File_Info_Block,A0
	Move.L	A0,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Examine(A6)
Search_Ex_Loop
; Folgeeinträge ermitteln
	Move.L	Search_Lock-VB(A5),D1
	Lea	File_Info_Block-VB(A5),A0
	Move.L	A0,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	ExNext(A6)
	Tst.L	D0
	Beq.b	Search_End_Ex
; Ist es ein Directory, was untersucht werden muß?
	Lea	File_Info_Block-VB(A5),A0
	Tst.L	4(A0)
	Bmi.b	Search_Cont
; Directory in Liste aufnehmen
	Move.L	Search_New_Dir_Adr-VB(A5),A1
	Move.L	File_List_Base-VB(A5),D0
	Add.L	#File_List_Size-1024,D0
	Cmp.L	D0,A1
	Bhs.b	Search_Cont
	Add.L	#8,A0
	Move.L	Search_Dir_Adr-VB(A5),A2
Search_Add_Dir_Loop1
	Move.B	(A2)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Search_Add_Dir_Loop1
	Subq.L	#1,A1
	Cmp.B	#":",-1(A1)
	Beq.b	Search_Add_Dir_Loop2
	Move.B	#"/",(A1)+
Search_Add_Dir_Loop2
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Bne.b	Search_Add_Dir_Loop2
	Move.B	#0,(A1)
	Move.L	A1,Search_New_Dir_Adr-VB(A5)
Search_Cont
	Bsr.w	Search_Compare_And_Add
	Beq.B	Search_End_Ex
	Bra.b	Search_Ex_Loop
Search_End_Ex
; Lock schließen
	Move.L	Search_Lock-VB(A5),D1
	Move.L	Dos_Base-VB(A5),A6
	Jsr	UnLock(A6)
; Ist die Liste voll?
	Move.L	Search_List_Pos-VB(A5),D0
	Cmp.L	#9632,D0
	Bhs.b	Search_End
; Abbruch?
	Move.W	#-1,Push_Gadget-VB(A5)
	Move.L	Window_Hd-VB(A5),A0
	Move.L	86(A0),A0
	Move.L	ExecBase,A6
	Jsr	GetMsg(A6)
	Tst.L	D0
	Beq.b	Search_No_Break
	Move.L	D0,A0
	Move.L	20(A0),D6
	Btst	#6,D6
	Bne.b	Search_End
	Btst	#10,D6
	Bne.b	Search_End
	Move.L	D0,A1
	Move.L	ExecBase,A6
	Jsr	ReplyMsg(A6)
Search_No_Break
; Nächstes Directory
	Move.L	Search_Dir_Adr-VB(A5),A0
Search_Next_Dir_Loop
	Tst.B	(A0)+
	Bne.b	Search_Next_Dir_Loop
	Move.L	A0,Search_Dir_Adr-VB(A5)
	Tst.B	(A0)
	Bne.w	Search_Examine
Search_End
; Ende der Liste makieren
	Move.L	Search_List_Pos-VB(A5),A0
	Cmp.L	#64,A0
	Bls.b	Search_No_Mark_End
	Add.L	File_List_Base-VB(A5),A0
	Move.W	#0,(A0)
Search_No_Mark_End
; Länge der Liste ermitteln
	Bsr.w	Get_List_Len
; Liste ausgeben
	Bsr.w	Print_List
Search_Exit
	Moveq.L	#-1,D0
	Rts

Search_Compare_And_Add
	Lea	File_Info_Block-VB(A5),A0
	Add.L	#8,A0
	Lea	Search_Buffer-VB(A5),A1
Search_Compare_Loop
	Moveq.L	#0,D2
	Tst.B	(A0)
	Beq.w	Search_Compare_Exit
Search_Compare_Line
	Move.B	(A1,D2.W),D1
	Beq.b	Search_Compare_Find
	Move.B	(A0,D2.W),D0
	Beq.b	Search_Compare_Not_Find
	Addq.L	#1,D2
	Or.B	#$20,D0
	Or.B	#$20,D1
	Cmp.B	D0,D1
	Beq.b	Search_Compare_Line
Search_Compare_Not_Find
	Add.L	#1,A0
	Bra.b	Search_Compare_Loop
Search_Compare_Find
; Suchergebnis in die Liste einfügen
	Move.L	Search_List_Pos-VB(A5),D0
	Cmp.L	#9632,D0
	Bhs.w	Search_Compare_Cut_Info
	Move.L	File_List_Base-VB(A5),A1
	Add.L	D0,A1
	Move.B	#31,(A1)+
	Move.B	#" ",(A1)+
	Move.B	#0,(A1)+
	Move.B	#0,(A1)+
	Move.L	Search_Dir_Adr-VB(A5),(A1)+
	Add.L	#24,A1
	Move.B	#31,(A1)+
	Move.L	Search_Dir_Adr-VB(A5),A0
	Moveq.L	#-1,D0
Search_Compare_Dir_Name_Loop
	Addq.L	#1,D0
	Tst.B	(A0,D0.W)
	Bne.b	Search_Compare_Dir_Name_Loop
	Sub.L	#26,D0
	Bpl.b	Search_Compare_Info_Cut
	Moveq.L	#0,D0
	Bra.b	Search_Compare_Info_Loop
Search_Compare_Info_Cut
	Move.B	#".",(A1)+
	Move.B	#".",(A1)+
	Move.B	#".",(A1)+
Search_Compare_Info
	Add.L	D0,A0
Search_Compare_Info_Loop
	Move.B	(A0)+,D1
	Move.B	D1,(A1)+
	Tst.B	D1
	Bne.b	Search_Compare_Info_Loop
	Cmp.B	#":",-2(A1)
	Beq.b	Search_Compare_Info_No_Slash
	Move.B	#"/",-1(A1)
	Move.B	#0,(A1)
Search_Compare_Info_No_Slash
	Add.L	#64,Search_List_Pos-VB(A5)
	Move.L	File_List_Base-VB(A5),A1
	Add.L	Search_List_Pos-VB(A5),A1
	Lea	File_Info_Block-VB(A5),A0
	Add.L	#8,A0
; Farbe für Dir oder File
	Move.B	#8,(A1)+
	Tst.L	-4(A0)
	Bmi.b	Search_Compare_Add
	Move.B	#22,-1(A1)
Search_Compare_Add
	Move.W	#32,D1
Search_Compare_Add_Loop
	Subq.W	#1,D1
	Beq.b	Search_Compare_Long_Name
	Move.B	(A0)+,D0
	Move.B	D0,(A1)+
	Tst.B	D0
	Beq.B	Search_Compare_End
	Bra.b	Search_Compare_Add_Loop
Search_Compare_Long_Name
	Move.B	#".",-3(A1)
	Move.B	#".",-2(A1)
	Move.B	#0,-1(A1)
Search_Compare_End
	Add.L	#32,Search_List_Pos-VB(A5)
Search_Compare_Exit
	Moveq.L	#-1,D0
	Rts
Search_Compare_Cut_Info
; Information, wenn zu viele Suchergebnisse
	Move.L	File_List_Base-VB(A5),A1
	Add.L	D0,A1
	Lea	Search_Result_Cut_Text-VB(A5),A0
Search_Compare_Cut_Loop
	Move.W	(A0)+,D0
	Move.W	D0,(A1)+
	Tst.W	D0
	Bne.b	Search_Compare_Cut_Loop
	Add.L	#32,Search_List_Pos-VB(A5)
	Moveq.L	#0,D0
	Rts

Search_Result_Text
	Dc.B	31,"SEARCH LIST:                  ",0
	Dc.B	13,"[NO RESULTS AT ALL!]          ",0
	Dc.W	0
Search_Result_Cut_Text
	Dc.B	13,"[MORE THAN 100 RESULTS!]      ",0
	Dc.W	0
Search_Info_Text
	Dc.B	"Searching...",0
	Even

Search_Lock
	Dc.L	0

Search_List_Pos
; Position in der Liste beim füllen der Suchergebnisse
	Dc.L	0

Search_Dir_Adr
; Adresse des aktuellen Suchdirectories
	Dc.L	0

Search_New_Dir_Adr
; Adresse des neu zu addierenden Directories
	Dc.L	0


; Allgemeine Grafikfunktionen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~

Move_D0_D1
; Grafik Cursor nach x,y bewegen
; D0 = x
; D1 = y
	Movem.L	D0-D4/A0-A3/A6,-(A7)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	Move(A6)
	Movem.L	(A7)+,D0-D4/A0-A3/A6
	Rts

Set_Dr_Md_D0
; Zeichenmodus festlegen
; D0 = Modus
	Movem.L	D0-D4/A0-A3/A6,-(A7)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	SetDrMd(A6)
	Movem.L	(A7)+,D0-D4/A0-A3/A6
	Rts

Set_A_Pen_D0
; Stiftfarbe bestimmen
; D0 = Farbe
	Movem.L	D0-D4/A0-A3/A6,-(A7)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	SetAPen(A6)
	Movem.L	(A7)+,D0-D4/A0-A3/A6
	Rts

Set_B_Pen_D0
; Hintergundstiftfarbe bestimmen
; D0 = Farbe
	Movem.L	D0-D4/A0-A3/A6,-(A7)
	Move.L	Window_Rast_Port-VB(A5),A1
	Move.L	Graphics_Base-VB(A5),A6
	Jsr	SetBPen(A6)
	Movem.L	(A7)+,D0-D4/A0-A3/A6
	Rts


; Directory "PROGDIR:" setzen
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~

Current_Dir
	Move.L	Start_File_Lock-VB(A5),D1
	Beq.b	Current_Dir_Return
	Move.L	Dos_Base-VB(A5),A6
	Jsr	CurrentDir(A6)
	Moveq.L	#-1,D0
Current_Dir_Return
	Rts


; Gadgets zum Fenster addieren
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add_Playlist_Gadgets
	Move.W	#$500,Error-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Lea	Playlist_Gadgets-VB(A5),A1
	Moveq	#0,D0
	Move.L	#99,D1
	Move.L	#0,D2
	Jsr	AddGList(A6)
	Bne.b	Add_Playlist_Gadgets_Return
; Propgadget Refresh
	Lea	FileS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	Search_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Moveq.L	#0,D0
Add_Playlist_Gadgets_Return
	Rts

Add_Control_Gadgets
	Move.W	#$501,Error-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Lea	Control_Gadgets-VB(A5),A1
	Moveq	#0,D0
	Move.L	#99,D1
	Move.L	#0,D2
	Jsr	AddGList(A6)
	Bne.w	Add_Control_Gadgets_Return
; Propgadget Refresh
	Lea	PosS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	VolS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	TrebleS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Moveq.L	#0,D0
; Propgadget Refresh
	Lea	BassS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	PrefactorS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Rep_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Bsr.w	Play_Refresh_Info
Add_Control_Gadgets_Return
	Rts

Add_Cue_Gadgets
	Move.W	#$503,Error-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Lea	Cue_Gadgets-VB(A5),A1
	Moveq	#0,D0
	Move.L	#99,D1
	Move.L	#0,D2
	Jsr	AddGList(A6)
; Propgadget Refresh
	Lea	AnalyseS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Cue_Rep_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	CueS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Rts

Add_Prefs_Gadgets
	Move.W	#$502,Error-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Lea	Prefs_Gadgets-VB(A5),A1
	Moveq	#0,D0
	Move.L	#99,D1
	Move.L	#0,D2
	Jsr	AddGList(A6)
; Stringgadget Refresh
	Lea	Path_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	PLS_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Stringgadget Refresh
	Lea	SplitTo_String_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	Task_PriS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Propgadget Refresh
	Lea	BufferS_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Assign_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	MP_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Rep_Dir_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Auto_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	CPU_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Random_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Analyse_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
; Toglegadget Refresh
	Lea	Start_Gadget-VB(A5),A0
	Move.L	Window_Hd-VB(A5),A1
	Move.L	#0,A2
	Moveq.L	#1,D0
	Move.L	Intuition_Base-VB(A5),A6
	Jsr	RefreshGList(A6)
	Rts

Add_About_Gadgets
	Move.W	#$503,Error-VB(A5)
	Move.L	Intuition_Base-VB(A5),A6
	Move.L	Window_Hd-VB(A5),A0
	Lea	About_Gadgets-VB(A5),A1
	Moveq	#0,D0
	Move.L	#99,D1
	Move.L	#0,D2
	Jsr	AddGList(A6)
	Rts

Playlist_Gadgets
Playlist_Close_Gadget
	Dc.L	Playlist_Drag_Gadget
	Dc.W	0,0,16,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	000
	Dc.L	0
Playlist_Drag_Gadget
	Dc.L	Playlist_Back_Gadget
	Dc.W	16,0,321,15,3,0,$30
	Dc.L	0,0,0,0,0
	Dc.W	001
	Dc.L	0
Playlist_Back_Gadget
	Dc.L	Playlist_Control_Gadget
	Dc.W	337,1,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	002
	Dc.L	0
Playlist_Control_Gadget
	Dc.L	Playlist_Cue_Gadget
	Dc.W	67,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	101
	Dc.L	0
Playlist_Cue_Gadget
	Dc.L	Playlist_Prefs_Gadget
	Dc.W	127,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	102
	Dc.L	0
Playlist_Prefs_Gadget
	Dc.L	Playlist_About_Gadget
	Dc.W	187,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	103
	Dc.L	0
Playlist_About_Gadget
	Dc.L	DeviceList_Gadget
	Dc.W	247,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	104
	Dc.L	0
DeviceList_Gadget
	Dc.L	Search_Gadget
	Dc.W	2,245,76,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	200
	Dc.L	0
Search_Gadget
	Dc.L	Search_String_Gadget
	Dc.W	213,245,23,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	201
	Dc.L	0
Search_String_Gadget
	Dc.L	Add_All_Gadget
	Dc.W	243,250,102,15,3,2,4
	Dc.L	0,0,0,0,Search_String_Info
	Dc.W	202
	Dc.L	0
Search_String_Info
	Dc.L	Search_Buffer,Search_Undo
	Dc.W	0,30,0,0,0,0,0,0
	Dc.L	0,0,0
Search_Buffer
	Dcb.B	32,0
Search_Undo
	Dcb.B	32,0
Add_All_Gadget
	Dc.L	Del_All_Gadget
	Dc.W	94,245,35,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	203
	Dc.L	0
Del_All_Gadget
	Dc.L	Add_Gadget
	Dc.W	145,245,35,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	204
	Dc.L	0
Add_Gadget
	Dc.L	Del_Gadget
	Dc.W	79,245,14,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	205
	Dc.L	0
Del_Gadget
	Dc.L	MoveUp_Gadget
	Dc.W	130,245,14,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	206
	Dc.L	0
MoveUp_Gadget
	Dc.L	MoveDown_Gadget
	Dc.W	181,245,14,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	207
	Dc.L	0
MoveDown_Gadget
	Dc.L	Top_Gadget
	Dc.W	196,245,14,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	208
	Dc.L	0
Top_Gadget
	Dc.L	Button_Gadget
	Dc.W	337,36,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	210
	Dc.L	0
Button_Gadget
	Dc.L	Up_Gadget
	Dc.W	337,232,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	211
	Dc.L	0
Up_Gadget
	Dc.L	Down_Gadget
	Dc.W	337,50,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	212
	Dc.L	0
Down_Gadget
	Dc.L	FileS_Gadget
	Dc.W	337,218,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	213
	Dc.L	0
FileS_Gadget
	Dc.L	File_1_Gadget
	Dc.W	339,66,9,149,3,1,3
	Dc.L	FileS_Mover,0,0,0,FileS_PropInfo
	Dc.W	220
	Dc.L	0
FileS_PropInfo
	Dc.W	1+4+8,0
FileS_PropY
	Dc.W	0,0
FileS_PropStep
	Dc.W	65535,0,0,0,0,0,0
FileS_Mover
	Dc.W	0,0,0,0
File_1_Gadget
	Dc.L	File_2_Gadget
	Dc.W	4,43,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	231
	Dc.L	0
File_2_Gadget
	Dc.L	File_3_Gadget
	Dc.W	4,58,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	232
	Dc.L	0
File_3_Gadget
	Dc.L	File_4_Gadget
	Dc.W	4,73,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	233
	Dc.L	0
File_4_Gadget
	Dc.L	File_5_Gadget
	Dc.W	4,88,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	234
	Dc.L	0
File_5_Gadget
	Dc.L	File_6_Gadget
	Dc.W	4,103,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	235
	Dc.L	0
File_6_Gadget
	Dc.L	File_7_Gadget
	Dc.W	4,118,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	236
	Dc.L	0
File_7_Gadget
	Dc.L	File_8_Gadget
	Dc.W	4,133,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	237
	Dc.L	0
File_8_Gadget
	Dc.L	File_9_Gadget
	Dc.W	4,148,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	238
	Dc.L	0
File_9_Gadget
	Dc.L	File_10_Gadget
	Dc.W	4,163,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	239
	Dc.L	0
File_10_Gadget
	Dc.L	File_11_Gadget
	Dc.W	4,178,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	240
	Dc.L	0
File_11_Gadget
	Dc.L	File_12_Gadget
	Dc.W	4,193,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	241
	Dc.L	0
File_12_Gadget
	Dc.L	File_13_Gadget
	Dc.W	4,208,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	242
	Dc.L	0
File_13_Gadget
	Dc.L	0
	Dc.W	4,223,331,15,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	243
	Dc.L	0

Control_Gadgets
Control_Close_Gadget
	Dc.L	Control_Drag_Gadget
	Dc.W	0,0,16,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	000
	Dc.L	0
Control_Drag_Gadget
	Dc.L	Control_Back_Gadget
	Dc.W	16,0,321,15,3,0,$30
	Dc.L	0,0,0,0,0
	Dc.W	001
	Dc.L	0
Control_Back_Gadget
	Dc.L	Control_Playlist_Gadget
	Dc.W	337,1,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	002
	Dc.L	0
Control_Playlist_Gadget
	Dc.L	Control_Cue_Gadget
	Dc.W	7,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	100
	Dc.L	0
Control_Cue_Gadget
	Dc.L	Control_Prefs_Gadget
	Dc.W	127,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	102
	Dc.L	0
Control_Prefs_Gadget
	Dc.L	Control_About_Gadget
	Dc.W	187,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	103
	Dc.L	0
Control_About_Gadget
	Dc.L	Play_Gadget
	Dc.W	247,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	104
	Dc.L	0
Play_Gadget
	Dc.L	Stop_Gadget
	Dc.W	177,65,49,49,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	300
	Dc.L	0
Stop_Gadget
	Dc.L	Rev_Gadget
	Dc.W	76,96,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	301
	Dc.L	0
Rev_Gadget
	Dc.L	FF_Gadget
	Dc.W	43,96,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	302
	Dc.L	0
FF_Gadget
	Dc.L	Rep_Gadget
	Dc.W	109,96,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	303
	Dc.L	0
Rep_Gadget
	Dc.L	PosS_Gadget
	Dc.W	142,96,25,17,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	310
	Dc.L	0
PosS_Gadget
	Dc.L	VolS_Gadget
	Dc.W	38,128,193,9,3,1,3
	Dc.L	PosS_Mover,0,0,0,PosS_PropInfo
	Dc.W	320
	Dc.L	0
PosS_PropInfo
	Dc.W	1+2+8
PosS_PropX
	Dc.W	0,0
PosS_PropStep
	Dc.W	8192,0,0,0,0,0,0,0
PosS_Mover
	Dc.W	0,0,0,0
VolS_Gadget
	Dc.L	Vol_Up_Gadget
	Dc.W	10,59,9,64,3,1,3
	Dc.L	VolS_Mover,0,0,0,VolS_PropInfo
	Dc.W	330
	Dc.L	0
VolS_PropInfo
	Dc.W	1+4+8,0
VolS_PropY
	Dc.W	0,0
VolS_PropStep
	Dc.W	8192,0,0,0,0,0,0
VolS_Mover
	Dc.W	0,0,0,0
Vol_Up_Gadget
	Dc.L	Vol_Down_Gadget
	Dc.W	8,43,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	331
	Dc.L	0
Vol_Down_Gadget
	Dc.L	TrebleS_Gadget
	Dc.W	8,126,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	332
	Dc.L	0
TrebleS_Gadget
	Dc.L	Treble_0_Gadget
	Dc.W	264,128,64,9,3,1,3
	Dc.L	TrebleS_Mover,0,0,0,TrebleS_PropInfo
	Dc.W	340
	Dc.L	0
TrebleS_PropInfo
	Dc.W	1+2+8
TrebleS_PropX
	Dc.W	32768,0
TrebleS_PropStep
	Dc.W	8192,0,0,0,0,0,0,0
TrebleS_Mover
	Dc.W	0,0,0,0
Treble_0_Gadget
	Dc.L	Treble_Mid_Gadget
	Dc.W	248,126,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	341
	Dc.L	0
Treble_Mid_Gadget
	Dc.L	BassS_Gadget
	Dc.W	331,126,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	342
	Dc.L	0
BassS_Gadget
	Dc.L	Bass_0_Gadget
	Dc.W	264,94,64,9,3,1,3
	Dc.L	BassS_Mover,0,0,0,BassS_PropInfo
	Dc.W	350
	Dc.L	0
BassS_PropInfo
	Dc.W	1+2+8
BassS_PropX
	Dc.W	32768,0
BassS_PropStep
	Dc.W	8192,0,0,0,0,0,0,0
BassS_Mover
	Dc.W	0,0,0,0
Bass_0_Gadget
	Dc.L	Bass_Mid_Gadget
	Dc.W	248,92,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	351
	Dc.L	0
Bass_Mid_Gadget
	Dc.L	PrefactorS_Gadget
	Dc.W	331,92,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	352
	Dc.L	0
PrefactorS_Gadget
	Dc.L	Prefactor_0_Gadget
	Dc.W	264,60,64,9,3,1,3
	Dc.L	PrefactorS_Mover,0,0,0,PrefactorS_PropInfo
	Dc.W	360
	Dc.L	0
PrefactorS_PropInfo
	Dc.W	1+2+8
PrefactorS_PropX
	Dc.W	0,0
PrefactorS_PropStep
	Dc.W	8192,0,0,0,0,0,0,0
PrefactorS_Mover
	Dc.W	0,0,0,0
Prefactor_0_Gadget
	Dc.L	Prefactor_Mid_Gadget
	Dc.W	248,58,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	361
	Dc.L	0
Prefactor_Mid_Gadget
	Dc.L	Title_String_Gadget
	Dc.W	331,58,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	362
	Dc.L	0
Title_String_Gadget
	Dc.L	Artist_String_Gadget
	Dc.W	7,172,218,15,3,2,4
	Dc.L	0,0,0,0,Title_String_Info
	Dc.W	370
	Dc.L	0
Title_String_Info
	Dc.L	Title_Buffer,Title_Undo
	Dc.W	0,31,0,0
Title_Len
	Dc.W	0,0,0,0
	Dc.L	0,0,0
Title_Buffer
	Dcb.B	32,0
Title_Undo
	Dcb.B	32,0
Artist_String_Gadget
	Dc.L	Album_String_Gadget
	Dc.W	7,198,218,15,3,2,4
	Dc.L	0,0,0,0,Artist_String_Info
	Dc.W	371
	Dc.L	0
Artist_String_Info
	Dc.L	Artist_Buffer,Artist_Undo
	Dc.W	0,31,0,0
Artist_Len
	Dc.W	0,0,0,0
	Dc.L	0,0,0
Artist_Buffer
	Dcb.B	32,0
Artist_Undo
	Dcb.B	32,0
Album_String_Gadget
	Dc.L	Comment_String_Gadget
	Dc.W	7,224,218,15,3,2,4
	Dc.L	0,0,0,0,Album_String_Info
	Dc.W	372
	Dc.L	0
Album_String_Info
	Dc.L	Album_Buffer,Album_Undo
	Dc.W	0,31,0,0
Album_Len
	Dc.W	0,0,0,0
	Dc.L	0,0,0
Album_Buffer
	Dcb.B	32,0
Album_Undo
	Dcb.B	32,0
Comment_String_Gadget
	Dc.L	Year_String_Gadget
	Dc.W	7,250,218,15,3,2,4
	Dc.L	0,0,0,0,Comment_String_Info
	Dc.W	373
	Dc.L	0
Comment_String_Info
	Dc.L	Comment_Buffer,Comment_Undo
	Dc.W	0,31,0,0
Comment_Len
	Dc.W	0,0,0,0
	Dc.L	0,0,0
Comment_Buffer
	Dcb.B	32,0
Comment_Undo
	Dcb.B	32,0
Year_String_Gadget
	Dc.L	GenreS_Gadget
	Dc.W	300,224,44,15,3,$202,4
	Dc.L	0,0,0,0,Year_String_Info
	Dc.W	374
	Dc.L	0
Year_String_Info
	Dc.L	Year_Buffer,Year_Undo
	Dc.W	0,5,0,0
Year_Len
	Dc.W	0,0,0,0
	Dc.L	0,0,0
Year_Buffer
	Dcb.B	6,0
Year_Undo
	Dcb.B	6,0
GenreS_Gadget
	Dc.L	Remove_Gadget
	Dc.W	335,172,9,46,3,1,3
	Dc.L	GenreS_Mover,0,0,0,GenreS_PropInfo
	Dc.W	375
	Dc.L	0
GenreS_PropInfo
	Dc.W	1+4+8,0
GenreS_PropY
	Dc.W	65535,0
GenreS_PropStep
	Dc.W	516,0,0,0,0,0,0
GenreS_Mover
	Dc.W	0,0,0,0
Remove_Gadget
	Dc.L	SaveID_Gadget
	Dc.W	230,244,61,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	380
	Dc.L	0
SaveID_Gadget
	Dc.L	0
	Dc.W	292,244,57,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	381
	Dc.L	0

Cue_Gadgets
Cue_Close_Gadget
	Dc.L	Cue_Drag_Gadget
	Dc.W	0,0,16,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	000
	Dc.L	0
Cue_Drag_Gadget
	Dc.L	Cue_Back_Gadget
	Dc.W	16,0,321,15,3,0,$30
	Dc.L	0,0,0,0,0
	Dc.W	001
	Dc.L	0
Cue_Back_Gadget
	Dc.L	Cue_Playlist_Gadget
	Dc.W	337,1,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	002
	Dc.L	0
Cue_Playlist_Gadget
	Dc.L	Cue_Control_Gadget
	Dc.W	7,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	100
	Dc.L	0
Cue_Control_Gadget
	Dc.L	Cue_Prefs_Gadget
	Dc.W	67,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	101
	Dc.L	0
Cue_Prefs_Gadget
	Dc.L	Cue_About_Gadget
	Dc.W	187,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	103
	Dc.L	0
Cue_About_Gadget
	Dc.L	AnalyseS_Gadget
	Dc.W	247,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	104
	Dc.L	0
AnalyseS_Gadget
	Dc.L	Cue_Play_Gadget
	Dc.W	4,58,343,9,3,1,3
	Dc.L	AnalyseS_Mover,0,0,0,AnalyseS_PropInfo
	Dc.W	500
	Dc.L	0
AnalyseS_PropInfo
	Dc.W	1+2+8
AnalyseS_PropX
	Dc.W	0,0
AnalyseS_PropStep
	Dc.W	65535,0,0,0,0,0,0,0
AnalyseS_Mover
	Dc.W	0,0,0,0
Cue_Play_Gadget
	Dc.L	Cue_Stop_Gadget
	Dc.W	257,38,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	300	; Nummer wie in Control
	Dc.L	0
Cue_Stop_Gadget
	Dc.L	Cue_Rev_Gadget
	Dc.W	224,38,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	301	; Nummer wie in Control
	Dc.L	0
Cue_Rev_Gadget
	Dc.L	Cue_FF_Gadget
	Dc.W	191,38,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	302	; Nummer wie in Control
	Dc.L	0
Cue_FF_Gadget
	Dc.L	Cue_Rep_Gadget
	Dc.W	290,38,25,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	303	; Nummer wie in Control
	Dc.L	0
Cue_Rep_Gadget
	Dc.L	CueS_Gadget
	Dc.W	323,38,25,17,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	310	; Nummer wie in Control
	Dc.L	0
CueS_Gadget
	Dc.L	Add_Track_Gadget
	Dc.W	4,72,9,170,3,1,3
	Dc.L	CueS_Mover,0,0,0,CueS_PropInfo
	Dc.W	510
	Dc.L	0
CueS_PropInfo
	Dc.W	1+4+8,0
CueS_PropY
	Dc.W	0,0
CueS_PropStep
	Dc.W	2048,0,0,0,0,0
CueS_Mover
	Dc.W	0,0,0,0
Add_Track_Gadget
	Dc.L	Add_Index_Gadget
	Dc.W	2,244,74,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	520
	Dc.L	0
Add_Index_Gadget
	Dc.L	Split_Gadget
	Dc.W	77,244,74,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	521
	Dc.L	0
Split_Gadget
	Dc.L	Save_Cue_Gadget
	Dc.W	152,244,74,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	530
	Dc.L	0
Save_Cue_Gadget
	Dc.L	Del_Cue_Gadget
	Dc.W	227,244,74,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	531
	Dc.L	0
Del_Cue_Gadget
	Dc.L	Play0_Gadget
	Dc.W	311,244,39,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	540
	Dc.L	0
Play0_Gadget
	Dc.L	Play1_Gadget
	Dc.W	311,72,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	550
	Dc.L	0
Play1_Gadget
	Dc.L	Play2_Gadget
	Dc.W	311,89,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	551
	Dc.L	0
Play2_Gadget
	Dc.L	Play3_Gadget
	Dc.W	311,106,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	552
	Dc.L	0
Play3_Gadget
	Dc.L	Play4_Gadget
	Dc.W	311,123,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	553
	Dc.L	0
Play4_Gadget
	Dc.L	Play5_Gadget
	Dc.W	311,140,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	554
	Dc.L	0
Play5_Gadget
	Dc.L	Play6_Gadget
	Dc.W	311,157,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	555
	Dc.L	0
Play6_Gadget
	Dc.L	Play7_Gadget
	Dc.W	311,174,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	556
	Dc.L	0
Play7_Gadget
	Dc.L	Play8_Gadget
	Dc.W	311,191,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	557
	Dc.L	0
Play8_Gadget
	Dc.L	Play9_Gadget
	Dc.W	311,208,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	558
	Dc.L	0
Play9_Gadget
	Dc.L	Del0_Gadget
	Dc.W	311,225,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	559
	Dc.L	0
Del0_Gadget
	Dc.L	Del1_Gadget
	Dc.W	329,72,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	560
	Dc.L	0
Del1_Gadget
	Dc.L	Del2_Gadget
	Dc.W	329,89,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	561
	Dc.L	0
Del2_Gadget
	Dc.L	Del3_Gadget
	Dc.W	329,106,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	562
	Dc.L	0
Del3_Gadget
	Dc.L	Del4_Gadget
	Dc.W	329,123,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	563
	Dc.L	0
Del4_Gadget
	Dc.L	Del5_Gadget
	Dc.W	329,140,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	564
	Dc.L	0
Del5_Gadget
	Dc.L	Del6_Gadget
	Dc.W	329,157,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	565
	Dc.L	0
Del6_Gadget
	Dc.L	Del7_Gadget
	Dc.W	329,174,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	566
	Dc.L	0
Del7_Gadget
	Dc.L	Del8_Gadget
	Dc.W	329,191,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	567
	Dc.L	0
Del8_Gadget
	Dc.L	Del9_Gadget
	Dc.W	329,208,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	568
	Dc.L	0
Del9_Gadget
	Dc.L	0
	Dc.W	329,225,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	569
	Dc.L	0

Prefs_Gadgets
Prefs_Close_Gadget
	Dc.L	Prefs_Drag_Gadget
	Dc.W	0,0,16,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	000
	Dc.L	0
Prefs_Drag_Gadget
	Dc.L	Prefs_Back_Gadget
	Dc.W	16,0,321,15,3,0,$30
	Dc.L	0,0,0,0,0
	Dc.W	001
	Dc.L	0
Prefs_Back_Gadget
	Dc.L	Prefs_Playlist_Gadget
	Dc.W	337,1,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	002
	Dc.L	0
Prefs_Playlist_Gadget
	Dc.L	Prefs_Control_Gadget
	Dc.W	7,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	100
	Dc.L	0
Prefs_Control_Gadget
	Dc.L	Prefs_Cue_Gadget
	Dc.W	67,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	101
	Dc.L	0
Prefs_Cue_Gadget
	Dc.L	Prefs_About_Gadget
	Dc.W	127,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	102
	Dc.L	0
Prefs_About_Gadget
	Dc.L	Assign_Gadget
	Dc.W	247,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	104
	Dc.L	0
Assign_Gadget
	Dc.L	MP_Gadget
	Dc.W	8,61,9,9,$80,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	400
	Dc.L	0
MP_Gadget
	Dc.L	Task_PriS_Gadget
	Dc.W	8,77,9,9,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	401
	Dc.L	0
Task_PriS_Gadget
	Dc.L	Rep_Dir_Gadget
	Dc.W	260,75,63,9,3,1,3
	Dc.L	Task_PriS_Mover,0,0,0,Task_PriS_PropInfo
	Dc.W	410
	Dc.L	0
Task_PriS_PropInfo
	Dc.W	1+2+8
Task_PriS_PropX
	Dc.W	16384,0
Task_PriS_PropStep
	Dc.W	3122,0,0,0,0,0,0,0
Task_PriS_Mover
	Dc.W	0,0,0,0
Rep_Dir_Gadget
	Dc.L	Random_Gadget
	Dc.W	8,115,9,9,$80,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	420
	Dc.L	0
Random_Gadget
	Dc.L	Auto_Gadget
	Dc.W	8,131,9,9,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	425
	Dc.L	0
Auto_Gadget
	Dc.L	CPU_Gadget
	Dc.W	8,147,9,9,$80,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	421
	Dc.L	0
CPU_Gadget
	Dc.L	Analyse_Gadget
	Dc.W	8,163,9,9,$80,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	422
	Dc.L	0
Analyse_Gadget
	Dc.L	Start_Gadget
	Dc.W	8,179,9,9,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	423
	Dc.L	0
Start_Gadget
	Dc.L	BufferS_Gadget
	Dc.W	8,195,9,9,0,$101,1
	Dc.L	0,0,0,0,0
	Dc.W	424
	Dc.L	0
BufferS_Gadget
	Dc.L	PLS_String_Gadget
	Dc.W	314,129,9,64,3,1,3
	Dc.L	BufferS_Mover,0,0,0,BufferS_PropInfo
	Dc.W	430
	Dc.L	0
BufferS_PropInfo
	Dc.W	1+4+8,0
BufferS_PropY
	Dc.W	65535,0
BufferS_PropStep
	Dc.W	10924,0,0,0,0,0
BufferS_Mover
	Dc.W	0,0,0,0
PLS_String_Gadget
	Dc.L	PLS_Dir_Gadget
	Dc.W	93,215,136,15,3,2,4
	Dc.L	0,0,0,0,PLS_String_Info
	Dc.W	435
	Dc.L	0
PLS_String_Info
	Dc.L	Playlist_Name,PLS_Undo
	Dc.W	0,254,0,0,0,0,0,0
	Dc.L	0,0,0
PLS_Undo
	Dcb.B	256,0
PLS_Dir_Gadget
	Dc.L	Path_String_Gadget
	Dc.W	231,214,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	436
	Dc.L	0
Path_String_Gadget
	Dc.L	Path_Dir_Gadget
	Dc.W	93,233,136,15,3,2,4
	Dc.L	0,0,0,0,Path_String_Info
	Dc.W	440
	Dc.L	0
Path_String_Info
	Dc.L	Path_Buffer,Path_Undo
	Dc.W	0,254,0,0,0,0,0,0
	Dc.L	0,0,0
Path_Undo
	Dcb.B	256,0
Path_Dir_Gadget
	Dc.L	SplitTo_String_Gadget
	Dc.W	231,232,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	441
	Dc.L	0
SplitTo_String_Gadget
	Dc.L	SplitTo_Dir_Gadget
	Dc.W	93,253,136,15,3,2,4
	Dc.L	0,0,0,0,SplitTo_String_Info
	Dc.W	445
	Dc.L	0
SplitTo_String_Info
	Dc.L	SplitTo_Buffer,SplitTo_Undo
	Dc.W	0,254,0,0,0,0,0,0
	Dc.L	0,0,0
SplitTo_Undo
	Dcb.B	256,0
SplitTo_Dir_Gadget
	Dc.L	Default_Gadget
	Dc.W	231,252,18,17,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	446
	Dc.L	0
Default_Gadget
	Dc.L	Save_Gadget
	Dc.W	255,244,46,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	450
	Dc.L	0
Save_Gadget
	Dc.L	0
	Dc.W	302,244,47,25,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	451
	Dc.L	0

About_Gadgets
About_Close_Gadget
	Dc.L	About_Drag_Gadget
	Dc.W	0,0,16,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	000
	Dc.L	0
About_Drag_Gadget
	Dc.L	About_Back_Gadget
	Dc.W	16,0,321,15,3,0,$30
	Dc.L	0,0,0,0,0
	Dc.W	001
	Dc.L	0
About_Back_Gadget
	Dc.L	About_Playlist_Gadget
	Dc.W	337,1,13,13,0,1,1
	Dc.L	0,0,0,0,0
	Dc.W	002
	Dc.L	0
About_Playlist_Gadget
	Dc.L	About_Control_Gadget
	Dc.W	7,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	100
	Dc.L	0
About_Control_Gadget
	Dc.L	About_Cue_Gadget
	Dc.W	67,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	101
	Dc.L	0
About_Cue_Gadget
	Dc.L	About_Prefs_Gadget
	Dc.W	127,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	102
	Dc.L	0
About_Prefs_Gadget
	Dc.L	0
	Dc.W	187,19,55,15,3,1,1
	Dc.L	0,0,0,0,0
	Dc.W	103
	Dc.L	0


; Fehlerausgabe
; ~~~~~~~~~~~~~

Error_Output
	Tst.L	Dos_Base-VB(A5)
	Beq.b	Error_Return
	Move.L	#Error_WinName,D1
	Move.L	#1005,D2
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Open(A6)
	Move.L	D0,D1
	Beq.b	Error_Return
	Lea	Error_Msg-VB(A5),A0
	Move.W	Error-VB(A5),D2
Error_Nr_Loop
	Cmp.W	(A0)+,D2
	Beq.b	Error_Write
	Add.L	#30,A0
	Bra.b	Error_Nr_Loop
Error_Write
	Move.L	A0,D2
	Move.L	#30,D3
	Move.L	Dos_Base-VB(A5),A6
	Jsr	Write(A6)
Error_Return
	Rts

Error_WinName
	Dc.B	"CON:0/10/300/120/MAS-Player...",0
	Even

Error_Msg
	Dc.W	$100
	Dc.B	"Can´t open DOS library        "
	Dc.W	$101
	Dc.B	"Can´t open intuition library  "
	Dc.W	$102
	Dc.B	"Can´t open graphics library   "
	Dc.W	$103
	Dc.B	"Can´t open diskfont library   "
	Dc.W	$200
	Dc.B	"Can´t allocate memory (BFP)   "
	Dc.W	$201
	Dc.B	"Can´t allocate memory (List)  "
	Dc.W	$202
	Dc.B	"Can´t allocate memory (Buffer)"
	Dc.W	$300
	Dc.B	"Can´t open screen             "
	Dc.W	$400
	Dc.B	"Can´t open window             "
	Dc.W	$500
	Dc.B	"Can´t open gadgets (Playlist) "
	Dc.W	$501
	Dc.B	"Can´t open gadgets (Control)  "
	Dc.W	$502
	Dc.B	"Can´t open gadgets (Prefs)    "
	Dc.W	$503
	Dc.B	"Can´t open gadgets (About)    "
	Dc.W	$600
	Dc.B	"Can´t open skin               "
	Dc.W	$700
	Dc.B	"Can´t open font               "
	Even

Error
; Fehlervariable
	Dc.W	0

Folder
; Zeigt an, welche Falte offen ist
; 0 = Playlist
; 1 = Control
; 2 = Cue Edit
; 3 = Prefs
; 4 = About
	Dc.B	4
	Even


; Variablen für Preferences
; ~~~~~~~~~~~~~~~~~~~~~~~~~

Buffer_Size
; Größe des File Buffers
; 64K, 128K,256K, 512K, 1M, 2M
	Dc.L	64000

Path_Buffer
; Voreingestellter Pfad
	Dcb.B	256,0

SplitTo_Buffer
	Dc.B	"RAM:"
	Dcb.B	252,0

Prefs_Flags
Assign_Flag
; Sollen Assigns in der Geräteliste gezeigt werden?
	Dc.B	1
MP_Flag
; Sollen nur .MP2 und .MP3 gezeigt werden?
	Dc.B	0
Rep_Dir_Flag
; Soll ganzes Directory wiederholt werden?
	Dc.B	1
Auto_Flag
; Sollen die Titel automatisch gestartet werden?
	Dc.B	1
CPU_Flag
; 0 = schnelle CPU, 1 = langsame CPU
	Dc.B	1
Random_Flag
; 0 = kein Zufall, 1 = Zufall
	Dc.B	0
Analyse_Flag
; 0 = kein Analyse, 1 = Analyse
	Dc.B	0
Start_Flag
; 0 = kein Autostart, 1 = Autostart
	Dc.B	0
	Even


; Sendeprogramm
; ~~~~~~~~~~~~~

	Cnop	0,4
Send
; Soll überhaupt gespielt werden?
	Cmp.L	#250,Load_Count-VB(A1)
	Blt.w	Send_Quick_Return
; Ist der MAS empfangsbereit?
	Btst.B	#0,$BFD000
	Beq.w	Send_Quick_Return
Send_From_Test_Hardware
; Register retten
	Movem.L	D3-D7/A3-A4,-(A7)
; Register vorbereiten
	Move.L	Send_Adr-VB(A1),A4
	Lea	$BFE101,A5
	Move.B	Hardware_Flag-VB(A1),D0
	Cmp.B	#1,D0
	Beq.w	Send_Lite
	Cmp.B	#2,D0
	Beq.b	Send_Pro
	Bra.w	Send_Return

Send_Prop_Count
	Dc.W	25

Send_Adr
	Dc.L	0

Send_Size
	Dc.L	250

	Cnop	0,4
Send_Pro
	Moveq.L	#-4,D4
	Moveq.L	#-2,D5
	Moveq.L	#-3,D6
	Moveq.L	#-1,D7
Send_Pro_Block
	Move.W	Send_Size+2-VB(A1),D3
	Subq.W	#1,D3
Send_Pro_Block_Loop
	Moveq.L	#0,D0
	Move.B	(A4)+,D0
	Lsl.W	#2,D0
	Move.L	Send_Pro_TAB(PC,D0.W),A3
	Jmp	(A3)

	Cnop	0,4
Send_Pro_TAB
	Dc.L	Send_Pro_00
	Dc.L	Send_Pro_01
	Dc.L	Send_Pro_02
	Dc.L	Send_Pro_03
	Dc.L	Send_Pro_04
	Dc.L	Send_Pro_05
	Dc.L	Send_Pro_06
	Dc.L	Send_Pro_07
	Dc.L	Send_Pro_08
	Dc.L	Send_Pro_09
	Dc.L	Send_Pro_0A
	Dc.L	Send_Pro_0B
	Dc.L	Send_Pro_0C
	Dc.L	Send_Pro_0D
	Dc.L	Send_Pro_0E
	Dc.L	Send_Pro_0F
	Dc.L	Send_Pro_10
	Dc.L	Send_Pro_11
	Dc.L	Send_Pro_12
	Dc.L	Send_Pro_13
	Dc.L	Send_Pro_14
	Dc.L	Send_Pro_15
	Dc.L	Send_Pro_16
	Dc.L	Send_Pro_17
	Dc.L	Send_Pro_18
	Dc.L	Send_Pro_19
	Dc.L	Send_Pro_1A
	Dc.L	Send_Pro_1B
	Dc.L	Send_Pro_1C
	Dc.L	Send_Pro_1D
	Dc.L	Send_Pro_1E
	Dc.L	Send_Pro_1F
	Dc.L	Send_Pro_20
	Dc.L	Send_Pro_21
	Dc.L	Send_Pro_22
	Dc.L	Send_Pro_23
	Dc.L	Send_Pro_24
	Dc.L	Send_Pro_25
	Dc.L	Send_Pro_26
	Dc.L	Send_Pro_27
	Dc.L	Send_Pro_28
	Dc.L	Send_Pro_29
	Dc.L	Send_Pro_2A
	Dc.L	Send_Pro_2B
	Dc.L	Send_Pro_2C
	Dc.L	Send_Pro_2D
	Dc.L	Send_Pro_2E
	Dc.L	Send_Pro_2F
	Dc.L	Send_Pro_30
	Dc.L	Send_Pro_31
	Dc.L	Send_Pro_32
	Dc.L	Send_Pro_33
	Dc.L	Send_Pro_34
	Dc.L	Send_Pro_35
	Dc.L	Send_Pro_36
	Dc.L	Send_Pro_37
	Dc.L	Send_Pro_38
	Dc.L	Send_Pro_39
	Dc.L	Send_Pro_3A
	Dc.L	Send_Pro_3B
	Dc.L	Send_Pro_3C
	Dc.L	Send_Pro_3D
	Dc.L	Send_Pro_3E
	Dc.L	Send_Pro_3F
	Dc.L	Send_Pro_40
	Dc.L	Send_Pro_41
	Dc.L	Send_Pro_42
	Dc.L	Send_Pro_43
	Dc.L	Send_Pro_44
	Dc.L	Send_Pro_45
	Dc.L	Send_Pro_46
	Dc.L	Send_Pro_47
	Dc.L	Send_Pro_48
	Dc.L	Send_Pro_49
	Dc.L	Send_Pro_4A
	Dc.L	Send_Pro_4B
	Dc.L	Send_Pro_4C
	Dc.L	Send_Pro_4D
	Dc.L	Send_Pro_4E
	Dc.L	Send_Pro_4F
	Dc.L	Send_Pro_50
	Dc.L	Send_Pro_51
	Dc.L	Send_Pro_52
	Dc.L	Send_Pro_53
	Dc.L	Send_Pro_54
	Dc.L	Send_Pro_55
	Dc.L	Send_Pro_56
	Dc.L	Send_Pro_57
	Dc.L	Send_Pro_58
	Dc.L	Send_Pro_59
	Dc.L	Send_Pro_5A
	Dc.L	Send_Pro_5B
	Dc.L	Send_Pro_5C
	Dc.L	Send_Pro_5D
	Dc.L	Send_Pro_5E
	Dc.L	Send_Pro_5F
	Dc.L	Send_Pro_60
	Dc.L	Send_Pro_61
	Dc.L	Send_Pro_62
	Dc.L	Send_Pro_63
	Dc.L	Send_Pro_64
	Dc.L	Send_Pro_65
	Dc.L	Send_Pro_66
	Dc.L	Send_Pro_67
	Dc.L	Send_Pro_68
	Dc.L	Send_Pro_69
	Dc.L	Send_Pro_6A
	Dc.L	Send_Pro_6B
	Dc.L	Send_Pro_6C
	Dc.L	Send_Pro_6D
	Dc.L	Send_Pro_6E
	Dc.L	Send_Pro_6F
	Dc.L	Send_Pro_70
	Dc.L	Send_Pro_71
	Dc.L	Send_Pro_72
	Dc.L	Send_Pro_73
	Dc.L	Send_Pro_74
	Dc.L	Send_Pro_75
	Dc.L	Send_Pro_76
	Dc.L	Send_Pro_77
	Dc.L	Send_Pro_78
	Dc.L	Send_Pro_79
	Dc.L	Send_Pro_7A
	Dc.L	Send_Pro_7B
	Dc.L	Send_Pro_7C
	Dc.L	Send_Pro_7D
	Dc.L	Send_Pro_7E
	Dc.L	Send_Pro_7F
	Dc.L	Send_Pro_80
	Dc.L	Send_Pro_81
	Dc.L	Send_Pro_82
	Dc.L	Send_Pro_83
	Dc.L	Send_Pro_84
	Dc.L	Send_Pro_85
	Dc.L	Send_Pro_86
	Dc.L	Send_Pro_87
	Dc.L	Send_Pro_88
	Dc.L	Send_Pro_89
	Dc.L	Send_Pro_8A
	Dc.L	Send_Pro_8B
	Dc.L	Send_Pro_8C
	Dc.L	Send_Pro_8D
	Dc.L	Send_Pro_8E
	Dc.L	Send_Pro_8F
	Dc.L	Send_Pro_90
	Dc.L	Send_Pro_91
	Dc.L	Send_Pro_92
	Dc.L	Send_Pro_93
	Dc.L	Send_Pro_94
	Dc.L	Send_Pro_95
	Dc.L	Send_Pro_96
	Dc.L	Send_Pro_97
	Dc.L	Send_Pro_98
	Dc.L	Send_Pro_99
	Dc.L	Send_Pro_9A
	Dc.L	Send_Pro_9B
	Dc.L	Send_Pro_9C
	Dc.L	Send_Pro_9D
	Dc.L	Send_Pro_9E
	Dc.L	Send_Pro_9F
	Dc.L	Send_Pro_A0
	Dc.L	Send_Pro_A1
	Dc.L	Send_Pro_A2
	Dc.L	Send_Pro_A3
	Dc.L	Send_Pro_A4
	Dc.L	Send_Pro_A5
	Dc.L	Send_Pro_A6
	Dc.L	Send_Pro_A7
	Dc.L	Send_Pro_A8
	Dc.L	Send_Pro_A9
	Dc.L	Send_Pro_AA
	Dc.L	Send_Pro_AB
	Dc.L	Send_Pro_AC
	Dc.L	Send_Pro_AD
	Dc.L	Send_Pro_AE
	Dc.L	Send_Pro_AF
	Dc.L	Send_Pro_B0
	Dc.L	Send_Pro_B1
	Dc.L	Send_Pro_B2
	Dc.L	Send_Pro_B3
	Dc.L	Send_Pro_B4
	Dc.L	Send_Pro_B5
	Dc.L	Send_Pro_B6
	Dc.L	Send_Pro_B7
	Dc.L	Send_Pro_B8
	Dc.L	Send_Pro_B9
	Dc.L	Send_Pro_BA
	Dc.L	Send_Pro_BB
	Dc.L	Send_Pro_BC
	Dc.L	Send_Pro_BD
	Dc.L	Send_Pro_BE
	Dc.L	Send_Pro_BF
	Dc.L	Send_Pro_C0
	Dc.L	Send_Pro_C1
	Dc.L	Send_Pro_C2
	Dc.L	Send_Pro_C3
	Dc.L	Send_Pro_C4
	Dc.L	Send_Pro_C5
	Dc.L	Send_Pro_C6
	Dc.L	Send_Pro_C7
	Dc.L	Send_Pro_C8
	Dc.L	Send_Pro_C9
	Dc.L	Send_Pro_CA
	Dc.L	Send_Pro_CB
	Dc.L	Send_Pro_CC
	Dc.L	Send_Pro_CD
	Dc.L	Send_Pro_CE
	Dc.L	Send_Pro_CF
	Dc.L	Send_Pro_D0
	Dc.L	Send_Pro_D1
	Dc.L	Send_Pro_D2
	Dc.L	Send_Pro_D3
	Dc.L	Send_Pro_D4
	Dc.L	Send_Pro_D5
	Dc.L	Send_Pro_D6
	Dc.L	Send_Pro_D7
	Dc.L	Send_Pro_D8
	Dc.L	Send_Pro_D9
	Dc.L	Send_Pro_DA
	Dc.L	Send_Pro_DB
	Dc.L	Send_Pro_DC
	Dc.L	Send_Pro_DD
	Dc.L	Send_Pro_DE
	Dc.L	Send_Pro_DF
	Dc.L	Send_Pro_E0
	Dc.L	Send_Pro_E1
	Dc.L	Send_Pro_E2
	Dc.L	Send_Pro_E3
	Dc.L	Send_Pro_E4
	Dc.L	Send_Pro_E5
	Dc.L	Send_Pro_E6
	Dc.L	Send_Pro_E7
	Dc.L	Send_Pro_E8
	Dc.L	Send_Pro_E9
	Dc.L	Send_Pro_EA
	Dc.L	Send_Pro_EB
	Dc.L	Send_Pro_EC
	Dc.L	Send_Pro_ED
	Dc.L	Send_Pro_EE
	Dc.L	Send_Pro_EF
	Dc.L	Send_Pro_F0
	Dc.L	Send_Pro_F1
	Dc.L	Send_Pro_F2
	Dc.L	Send_Pro_F3
	Dc.L	Send_Pro_F4
	Dc.L	Send_Pro_F5
	Dc.L	Send_Pro_F6
	Dc.L	Send_Pro_F7
	Dc.L	Send_Pro_F8
	Dc.L	Send_Pro_F9
	Dc.L	Send_Pro_FA
	Dc.L	Send_Pro_FB
	Dc.L	Send_Pro_FC
	Dc.L	Send_Pro_FD
	Dc.L	Send_Pro_FE
	Dc.L	Send_Pro_FF

	Cnop	0,4
Send_Pro_00
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_01
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_02
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_03
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_04
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_05
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_06
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_07
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_08
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_09
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_0F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_10
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_11
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_12
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_13
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_14
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_15
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_16
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_17
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_18
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_19
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_1F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_20
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_21
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_22
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_23
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_24
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_25
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_26
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_27
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_28
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_29
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_2F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_30
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_31
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_32
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_33
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_34
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_35
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_36
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_37
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_38
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_39
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_3F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_40
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_41
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_42
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_43
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_44
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_45
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_46
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_47
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_48
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_49
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4A
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4B
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4C
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4D
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4E
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_4F
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_50
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_51
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_52
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_53
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_54
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_55
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_56
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_57
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_58
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_59
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5A
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5B
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5C
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5D
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5E
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_5F
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_60
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_61
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_62
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_63
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_64
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_65
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_66
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_67
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_68
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_69
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6A
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6B
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6C
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6D
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6E
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_6F
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_70
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_71
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_72
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_73
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_74
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_75
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_76
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_77
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_78
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_79
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7A
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7B
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7C
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7D
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7E
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_7F
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_80
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_81
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_82
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_83
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_84
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_85
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_86
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_87
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_88
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_89
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8A
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8B
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8C
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8D
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8E
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_8F
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_90
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_91
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_92
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_93
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_94
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_95
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_96
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_97
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_98
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_99
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9A
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9B
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9C
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9D
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9E
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_9F
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A0
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A1
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A2
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A3
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A4
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A5
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A6
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A7
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A8
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_A9
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AA
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AB
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AC
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AD
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AE
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_AF
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B0
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B1
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B2
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B3
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B4
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B5
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B6
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B7
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B8
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_B9
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BA
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BB
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BC
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BD
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BE
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_BF
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_C9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_CF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_D9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_DF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_E9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_EA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_EB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_EC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_ED
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_EE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_EF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_F9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Pro_FF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Pro_Block_Loop
	Bra.w	Send_Block_End

	Cnop	0,4
Send_Lite
	Moveq.L	#-2,D4
	Moveq.L	#-4,D5
	Moveq.L	#-1,D6
	Moveq.L	#-3,D7
Send_Lite_Block
	Move.W	Send_Size+2-VB(A1),D3
	Subq.W	#1,D3
Send_Lite_Block_Loop
	Moveq.L	#0,D0
	Move.B	(A4)+,D0
	Lsl.W	#2,D0
	Move.L	Send_Lite_TAB(PC,D0.W),A3
	Jmp	(A3)

	Cnop	0,4
Send_Lite_TAB
	Dc.L	Send_Lite_00
	Dc.L	Send_Lite_01
	Dc.L	Send_Lite_02
	Dc.L	Send_Lite_03
	Dc.L	Send_Lite_04
	Dc.L	Send_Lite_05
	Dc.L	Send_Lite_06
	Dc.L	Send_Lite_07
	Dc.L	Send_Lite_08
	Dc.L	Send_Lite_09
	Dc.L	Send_Lite_0A
	Dc.L	Send_Lite_0B
	Dc.L	Send_Lite_0C
	Dc.L	Send_Lite_0D
	Dc.L	Send_Lite_0E
	Dc.L	Send_Lite_0F
	Dc.L	Send_Lite_10
	Dc.L	Send_Lite_11
	Dc.L	Send_Lite_12
	Dc.L	Send_Lite_13
	Dc.L	Send_Lite_14
	Dc.L	Send_Lite_15
	Dc.L	Send_Lite_16
	Dc.L	Send_Lite_17
	Dc.L	Send_Lite_18
	Dc.L	Send_Lite_19
	Dc.L	Send_Lite_1A
	Dc.L	Send_Lite_1B
	Dc.L	Send_Lite_1C
	Dc.L	Send_Lite_1D
	Dc.L	Send_Lite_1E
	Dc.L	Send_Lite_1F
	Dc.L	Send_Lite_20
	Dc.L	Send_Lite_21
	Dc.L	Send_Lite_22
	Dc.L	Send_Lite_23
	Dc.L	Send_Lite_24
	Dc.L	Send_Lite_25
	Dc.L	Send_Lite_26
	Dc.L	Send_Lite_27
	Dc.L	Send_Lite_28
	Dc.L	Send_Lite_29
	Dc.L	Send_Lite_2A
	Dc.L	Send_Lite_2B
	Dc.L	Send_Lite_2C
	Dc.L	Send_Lite_2D
	Dc.L	Send_Lite_2E
	Dc.L	Send_Lite_2F
	Dc.L	Send_Lite_30
	Dc.L	Send_Lite_31
	Dc.L	Send_Lite_32
	Dc.L	Send_Lite_33
	Dc.L	Send_Lite_34
	Dc.L	Send_Lite_35
	Dc.L	Send_Lite_36
	Dc.L	Send_Lite_37
	Dc.L	Send_Lite_38
	Dc.L	Send_Lite_39
	Dc.L	Send_Lite_3A
	Dc.L	Send_Lite_3B
	Dc.L	Send_Lite_3C
	Dc.L	Send_Lite_3D
	Dc.L	Send_Lite_3E
	Dc.L	Send_Lite_3F
	Dc.L	Send_Lite_40
	Dc.L	Send_Lite_41
	Dc.L	Send_Lite_42
	Dc.L	Send_Lite_43
	Dc.L	Send_Lite_44
	Dc.L	Send_Lite_45
	Dc.L	Send_Lite_46
	Dc.L	Send_Lite_47
	Dc.L	Send_Lite_48
	Dc.L	Send_Lite_49
	Dc.L	Send_Lite_4A
	Dc.L	Send_Lite_4B
	Dc.L	Send_Lite_4C
	Dc.L	Send_Lite_4D
	Dc.L	Send_Lite_4E
	Dc.L	Send_Lite_4F
	Dc.L	Send_Lite_50
	Dc.L	Send_Lite_51
	Dc.L	Send_Lite_52
	Dc.L	Send_Lite_53
	Dc.L	Send_Lite_54
	Dc.L	Send_Lite_55
	Dc.L	Send_Lite_56
	Dc.L	Send_Lite_57
	Dc.L	Send_Lite_58
	Dc.L	Send_Lite_59
	Dc.L	Send_Lite_5A
	Dc.L	Send_Lite_5B
	Dc.L	Send_Lite_5C
	Dc.L	Send_Lite_5D
	Dc.L	Send_Lite_5E
	Dc.L	Send_Lite_5F
	Dc.L	Send_Lite_60
	Dc.L	Send_Lite_61
	Dc.L	Send_Lite_62
	Dc.L	Send_Lite_63
	Dc.L	Send_Lite_64
	Dc.L	Send_Lite_65
	Dc.L	Send_Lite_66
	Dc.L	Send_Lite_67
	Dc.L	Send_Lite_68
	Dc.L	Send_Lite_69
	Dc.L	Send_Lite_6A
	Dc.L	Send_Lite_6B
	Dc.L	Send_Lite_6C
	Dc.L	Send_Lite_6D
	Dc.L	Send_Lite_6E
	Dc.L	Send_Lite_6F
	Dc.L	Send_Lite_70
	Dc.L	Send_Lite_71
	Dc.L	Send_Lite_72
	Dc.L	Send_Lite_73
	Dc.L	Send_Lite_74
	Dc.L	Send_Lite_75
	Dc.L	Send_Lite_76
	Dc.L	Send_Lite_77
	Dc.L	Send_Lite_78
	Dc.L	Send_Lite_79
	Dc.L	Send_Lite_7A
	Dc.L	Send_Lite_7B
	Dc.L	Send_Lite_7C
	Dc.L	Send_Lite_7D
	Dc.L	Send_Lite_7E
	Dc.L	Send_Lite_7F
	Dc.L	Send_Lite_80
	Dc.L	Send_Lite_81
	Dc.L	Send_Lite_82
	Dc.L	Send_Lite_83
	Dc.L	Send_Lite_84
	Dc.L	Send_Lite_85
	Dc.L	Send_Lite_86
	Dc.L	Send_Lite_87
	Dc.L	Send_Lite_88
	Dc.L	Send_Lite_89
	Dc.L	Send_Lite_8A
	Dc.L	Send_Lite_8B
	Dc.L	Send_Lite_8C
	Dc.L	Send_Lite_8D
	Dc.L	Send_Lite_8E
	Dc.L	Send_Lite_8F
	Dc.L	Send_Lite_90
	Dc.L	Send_Lite_91
	Dc.L	Send_Lite_92
	Dc.L	Send_Lite_93
	Dc.L	Send_Lite_94
	Dc.L	Send_Lite_95
	Dc.L	Send_Lite_96
	Dc.L	Send_Lite_97
	Dc.L	Send_Lite_98
	Dc.L	Send_Lite_99
	Dc.L	Send_Lite_9A
	Dc.L	Send_Lite_9B
	Dc.L	Send_Lite_9C
	Dc.L	Send_Lite_9D
	Dc.L	Send_Lite_9E
	Dc.L	Send_Lite_9F
	Dc.L	Send_Lite_A0
	Dc.L	Send_Lite_A1
	Dc.L	Send_Lite_A2
	Dc.L	Send_Lite_A3
	Dc.L	Send_Lite_A4
	Dc.L	Send_Lite_A5
	Dc.L	Send_Lite_A6
	Dc.L	Send_Lite_A7
	Dc.L	Send_Lite_A8
	Dc.L	Send_Lite_A9
	Dc.L	Send_Lite_AA
	Dc.L	Send_Lite_AB
	Dc.L	Send_Lite_AC
	Dc.L	Send_Lite_AD
	Dc.L	Send_Lite_AE
	Dc.L	Send_Lite_AF
	Dc.L	Send_Lite_B0
	Dc.L	Send_Lite_B1
	Dc.L	Send_Lite_B2
	Dc.L	Send_Lite_B3
	Dc.L	Send_Lite_B4
	Dc.L	Send_Lite_B5
	Dc.L	Send_Lite_B6
	Dc.L	Send_Lite_B7
	Dc.L	Send_Lite_B8
	Dc.L	Send_Lite_B9
	Dc.L	Send_Lite_BA
	Dc.L	Send_Lite_BB
	Dc.L	Send_Lite_BC
	Dc.L	Send_Lite_BD
	Dc.L	Send_Lite_BE
	Dc.L	Send_Lite_BF
	Dc.L	Send_Lite_C0
	Dc.L	Send_Lite_C1
	Dc.L	Send_Lite_C2
	Dc.L	Send_Lite_C3
	Dc.L	Send_Lite_C4
	Dc.L	Send_Lite_C5
	Dc.L	Send_Lite_C6
	Dc.L	Send_Lite_C7
	Dc.L	Send_Lite_C8
	Dc.L	Send_Lite_C9
	Dc.L	Send_Lite_CA
	Dc.L	Send_Lite_CB
	Dc.L	Send_Lite_CC
	Dc.L	Send_Lite_CD
	Dc.L	Send_Lite_CE
	Dc.L	Send_Lite_CF
	Dc.L	Send_Lite_D0
	Dc.L	Send_Lite_D1
	Dc.L	Send_Lite_D2
	Dc.L	Send_Lite_D3
	Dc.L	Send_Lite_D4
	Dc.L	Send_Lite_D5
	Dc.L	Send_Lite_D6
	Dc.L	Send_Lite_D7
	Dc.L	Send_Lite_D8
	Dc.L	Send_Lite_D9
	Dc.L	Send_Lite_DA
	Dc.L	Send_Lite_DB
	Dc.L	Send_Lite_DC
	Dc.L	Send_Lite_DD
	Dc.L	Send_Lite_DE
	Dc.L	Send_Lite_DF
	Dc.L	Send_Lite_E0
	Dc.L	Send_Lite_E1
	Dc.L	Send_Lite_E2
	Dc.L	Send_Lite_E3
	Dc.L	Send_Lite_E4
	Dc.L	Send_Lite_E5
	Dc.L	Send_Lite_E6
	Dc.L	Send_Lite_E7
	Dc.L	Send_Lite_E8
	Dc.L	Send_Lite_E9
	Dc.L	Send_Lite_EA
	Dc.L	Send_Lite_EB
	Dc.L	Send_Lite_EC
	Dc.L	Send_Lite_ED
	Dc.L	Send_Lite_EE
	Dc.L	Send_Lite_EF
	Dc.L	Send_Lite_F0
	Dc.L	Send_Lite_F1
	Dc.L	Send_Lite_F2
	Dc.L	Send_Lite_F3
	Dc.L	Send_Lite_F4
	Dc.L	Send_Lite_F5
	Dc.L	Send_Lite_F6
	Dc.L	Send_Lite_F7
	Dc.L	Send_Lite_F8
	Dc.L	Send_Lite_F9
	Dc.L	Send_Lite_FA
	Dc.L	Send_Lite_FB
	Dc.L	Send_Lite_FC
	Dc.L	Send_Lite_FD
	Dc.L	Send_Lite_FE
	Dc.L	Send_Lite_FF

	Cnop	0,4
Send_Lite_00
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_01
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_02
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_03
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_04
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_05
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_06
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_07
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_08
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_09
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_0F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_10
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_11
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_12
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_13
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_14
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_15
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_16
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_17
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_18
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_19
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_1F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_20
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_21
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_22
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_23
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_24
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_25
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_26
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_27
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_28
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_29
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_2F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_30
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_31
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_32
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_33
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_34
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_35
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_36
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_37
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_38
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_39
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_3F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_40
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_41
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_42
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_43
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_44
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_45
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_46
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_47
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_48
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_49
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_4F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_50
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_51
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_52
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_53
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_54
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_55
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_56
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_57
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_58
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_59
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_5F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_60
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_61
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_62
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_63
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_64
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_65
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_66
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_67
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_68
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_69
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_6F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_70
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_71
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_72
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_73
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_74
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_75
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_76
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_77
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_78
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_79
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7A
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7B
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7C
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7D
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7E
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_7F
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_80
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_81
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_82
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_83
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_84
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_85
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_86
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_87
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_88
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_89
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8A
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8B
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8C
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8D
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8E
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_8F
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_90
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_91
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_92
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_93
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_94
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_95
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_96
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_97
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_98
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_99
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9A
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9B
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9C
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9D
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9E
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_9F
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_A9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_AF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_B9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_BF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_C9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_CF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_D9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_DF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_E9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_EA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_EB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_EC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_ED
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_EE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_EF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F0
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F1
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F2
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F3
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F4
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F5
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F6
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F7
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F8
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_F9
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_FA
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_FB
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.w	Send_Block_End
	Cnop	0,4
Send_Lite_FC
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.b	Send_Block_End
	Cnop	0,4
Send_Lite_FD
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.b	Send_Block_End
	Cnop	0,4
Send_Lite_FE
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D4,(A5)
	Move.B	D5,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.b	Send_Block_End
	Cnop	0,4
Send_Lite_FF
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Move.B	D6,(A5)
	Move.B	D7,(A5)
	Dbf	D3,Send_Lite_Block_Loop
	Bra.b	Send_Block_End

	Cnop	0,4
Send_Block_End
	Move.L	Send_Size-VB(A1),D0
	Sub.L	D0,Load_Count-VB(A1)
; Bufferende erreicht?
	Move.L	Play_Buffer_Base-VB(A1),D0
	Add.L	Buffer_Size-VB(A1),D0
	Cmp.L	D0,A4
	Bne.b	Send_Exit
	Move.L	Play_Buffer_Base-VB(A1),A4
Send_Exit
; Prop Gadget addieren?
	Sub.W	#1,Send_Prop_Count-VB(A1)
	Bne.b	Send_End_Prop
	Move.W	#25,Send_Prop_Count-VB(A1)
; Prop Gadget ein Schritt weiter
	Lea	PosS_PropX-VB(A1),A3
	Move.W	(A3),D0
	Add.W	Play_Step_Size-VB(A1),D0
	Bcc.b	Send_New_Prop
	Moveq.L	#-1,D0
Send_New_Prop
	Move.W	D0,(A3)
; Position zum Analyse-Gadget kopieren
	Tst.B	Analyse_OK_Flag-VB(A1)
	Beq.b	Send_End_Prop
; Wird das Gadget gerade angefasst?
	Btst.B	#0,AnalyseS_PropInfo
	Bne.b	Send_End_Prop
	Move.W	D0,AnalyseS_PropX-VB(A1)
Send_End_Prop
	Move.L	A4,Send_Adr-VB(A1)
; Register zurück und Interrupt verlassen
Send_Return
	Movem.L	(A7)+,D3-D7/A3-A4
Send_Quick_Return
	Rts


; Cue Liste
; ~~~~~~~~~

	Cnop	0,4
Cue_List
	Dc.B	"  TRACK 01 AUDIO      "
	Dc.B	"    INDEX 01 00:00:00 "
	Dcb.B	263*22,32


; Tabelle beim Teilen eines MP3-Stücks
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Cnop	0,4
Split_Div_Tab
	Dcb.L	100,0


; Skins
; ~~~~~

	Cnop	0,4
Skin_Playlist
	INCBIN "Skin_Playlist.IFF"
	Cnop	0,4
Skin_Control
	INCBIN "Skin_Control.IFF"
	Cnop	0,4
Skin_Cue
	INCBIN "Skin_Cue.IFF"
	Cnop	0,4
Skin_Prefs
	INCBIN "Skin_Prefs.IFF"
	Cnop	0,4
Skin_About
	INCBIN "Skin_About.IFF"


; Sound
; ~~~~~

	Cnop	0,4
Sound
; Da der Sound nur einmal beim Start benutzt wird um die Hardware zu testen,
; dient er als Puffer bei der Verarbeitung der Playliste
	INCBIN "Sound96kbps.MP3"
