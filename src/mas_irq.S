
	.text
	.even
	.globl _mas_interrupt_entry
_mas_interrupt_entry:
	btst.b #0,0xbfd000
	beq.w Send_Quick_Return
	move.l 12(a1),d0
	cmp.l #202,d0
	blo.w Send_Quick_Return
	move.l 20(a1),d0
	cmp.l 4(a1),d0
	bhs.w Send_Quick_Return
	movem.l d3-d7/a3-a4,-(sp)
	move.l 0(a1),a4
	add.l 20(a1),a4
	lea 0xbfe101,a5
	move.b 16(a1),d0
	cmp.b #1,d0
	beq.w Send_Lite
	cmp.b #2,d0
	beq.w Send_Pro
	bra.w Send_Return

Send_Pro:
	moveq.L	#-4,D4
	moveq.L	#-2,D5
	moveq.L	#-3,D6
	moveq.L	#-1,D7
Send_Pro_Block:
	move.W	#202,D3
	subq.W	#1,D3
Send_Pro_Block_Loop:
	moveq.L	#0,D0
	move.B	(A4)+,D0
	lsl.W	#2,D0
	move.L	Send_Pro_TAB(PC,D0.W),A3
	jmp	(A3)

	.even
Send_Pro_TAB:
	.long	Send_Pro_00
	.long	Send_Pro_01
	.long	Send_Pro_02
	.long	Send_Pro_03
	.long	Send_Pro_04
	.long	Send_Pro_05
	.long	Send_Pro_06
	.long	Send_Pro_07
	.long	Send_Pro_08
	.long	Send_Pro_09
	.long	Send_Pro_0A
	.long	Send_Pro_0B
	.long	Send_Pro_0C
	.long	Send_Pro_0D
	.long	Send_Pro_0E
	.long	Send_Pro_0F
	.long	Send_Pro_10
	.long	Send_Pro_11
	.long	Send_Pro_12
	.long	Send_Pro_13
	.long	Send_Pro_14
	.long	Send_Pro_15
	.long	Send_Pro_16
	.long	Send_Pro_17
	.long	Send_Pro_18
	.long	Send_Pro_19
	.long	Send_Pro_1A
	.long	Send_Pro_1B
	.long	Send_Pro_1C
	.long	Send_Pro_1D
	.long	Send_Pro_1E
	.long	Send_Pro_1F
	.long	Send_Pro_20
	.long	Send_Pro_21
	.long	Send_Pro_22
	.long	Send_Pro_23
	.long	Send_Pro_24
	.long	Send_Pro_25
	.long	Send_Pro_26
	.long	Send_Pro_27
	.long	Send_Pro_28
	.long	Send_Pro_29
	.long	Send_Pro_2A
	.long	Send_Pro_2B
	.long	Send_Pro_2C
	.long	Send_Pro_2D
	.long	Send_Pro_2E
	.long	Send_Pro_2F
	.long	Send_Pro_30
	.long	Send_Pro_31
	.long	Send_Pro_32
	.long	Send_Pro_33
	.long	Send_Pro_34
	.long	Send_Pro_35
	.long	Send_Pro_36
	.long	Send_Pro_37
	.long	Send_Pro_38
	.long	Send_Pro_39
	.long	Send_Pro_3A
	.long	Send_Pro_3B
	.long	Send_Pro_3C
	.long	Send_Pro_3D
	.long	Send_Pro_3E
	.long	Send_Pro_3F
	.long	Send_Pro_40
	.long	Send_Pro_41
	.long	Send_Pro_42
	.long	Send_Pro_43
	.long	Send_Pro_44
	.long	Send_Pro_45
	.long	Send_Pro_46
	.long	Send_Pro_47
	.long	Send_Pro_48
	.long	Send_Pro_49
	.long	Send_Pro_4A
	.long	Send_Pro_4B
	.long	Send_Pro_4C
	.long	Send_Pro_4D
	.long	Send_Pro_4E
	.long	Send_Pro_4F
	.long	Send_Pro_50
	.long	Send_Pro_51
	.long	Send_Pro_52
	.long	Send_Pro_53
	.long	Send_Pro_54
	.long	Send_Pro_55
	.long	Send_Pro_56
	.long	Send_Pro_57
	.long	Send_Pro_58
	.long	Send_Pro_59
	.long	Send_Pro_5A
	.long	Send_Pro_5B
	.long	Send_Pro_5C
	.long	Send_Pro_5D
	.long	Send_Pro_5E
	.long	Send_Pro_5F
	.long	Send_Pro_60
	.long	Send_Pro_61
	.long	Send_Pro_62
	.long	Send_Pro_63
	.long	Send_Pro_64
	.long	Send_Pro_65
	.long	Send_Pro_66
	.long	Send_Pro_67
	.long	Send_Pro_68
	.long	Send_Pro_69
	.long	Send_Pro_6A
	.long	Send_Pro_6B
	.long	Send_Pro_6C
	.long	Send_Pro_6D
	.long	Send_Pro_6E
	.long	Send_Pro_6F
	.long	Send_Pro_70
	.long	Send_Pro_71
	.long	Send_Pro_72
	.long	Send_Pro_73
	.long	Send_Pro_74
	.long	Send_Pro_75
	.long	Send_Pro_76
	.long	Send_Pro_77
	.long	Send_Pro_78
	.long	Send_Pro_79
	.long	Send_Pro_7A
	.long	Send_Pro_7B
	.long	Send_Pro_7C
	.long	Send_Pro_7D
	.long	Send_Pro_7E
	.long	Send_Pro_7F
	.long	Send_Pro_80
	.long	Send_Pro_81
	.long	Send_Pro_82
	.long	Send_Pro_83
	.long	Send_Pro_84
	.long	Send_Pro_85
	.long	Send_Pro_86
	.long	Send_Pro_87
	.long	Send_Pro_88
	.long	Send_Pro_89
	.long	Send_Pro_8A
	.long	Send_Pro_8B
	.long	Send_Pro_8C
	.long	Send_Pro_8D
	.long	Send_Pro_8E
	.long	Send_Pro_8F
	.long	Send_Pro_90
	.long	Send_Pro_91
	.long	Send_Pro_92
	.long	Send_Pro_93
	.long	Send_Pro_94
	.long	Send_Pro_95
	.long	Send_Pro_96
	.long	Send_Pro_97
	.long	Send_Pro_98
	.long	Send_Pro_99
	.long	Send_Pro_9A
	.long	Send_Pro_9B
	.long	Send_Pro_9C
	.long	Send_Pro_9D
	.long	Send_Pro_9E
	.long	Send_Pro_9F
	.long	Send_Pro_A0
	.long	Send_Pro_A1
	.long	Send_Pro_A2
	.long	Send_Pro_A3
	.long	Send_Pro_A4
	.long	Send_Pro_A5
	.long	Send_Pro_A6
	.long	Send_Pro_A7
	.long	Send_Pro_A8
	.long	Send_Pro_A9
	.long	Send_Pro_AA
	.long	Send_Pro_AB
	.long	Send_Pro_AC
	.long	Send_Pro_AD
	.long	Send_Pro_AE
	.long	Send_Pro_AF
	.long	Send_Pro_B0
	.long	Send_Pro_B1
	.long	Send_Pro_B2
	.long	Send_Pro_B3
	.long	Send_Pro_B4
	.long	Send_Pro_B5
	.long	Send_Pro_B6
	.long	Send_Pro_B7
	.long	Send_Pro_B8
	.long	Send_Pro_B9
	.long	Send_Pro_BA
	.long	Send_Pro_BB
	.long	Send_Pro_BC
	.long	Send_Pro_BD
	.long	Send_Pro_BE
	.long	Send_Pro_BF
	.long	Send_Pro_C0
	.long	Send_Pro_C1
	.long	Send_Pro_C2
	.long	Send_Pro_C3
	.long	Send_Pro_C4
	.long	Send_Pro_C5
	.long	Send_Pro_C6
	.long	Send_Pro_C7
	.long	Send_Pro_C8
	.long	Send_Pro_C9
	.long	Send_Pro_CA
	.long	Send_Pro_CB
	.long	Send_Pro_CC
	.long	Send_Pro_CD
	.long	Send_Pro_CE
	.long	Send_Pro_CF
	.long	Send_Pro_D0
	.long	Send_Pro_D1
	.long	Send_Pro_D2
	.long	Send_Pro_D3
	.long	Send_Pro_D4
	.long	Send_Pro_D5
	.long	Send_Pro_D6
	.long	Send_Pro_D7
	.long	Send_Pro_D8
	.long	Send_Pro_D9
	.long	Send_Pro_DA
	.long	Send_Pro_DB
	.long	Send_Pro_DC
	.long	Send_Pro_DD
	.long	Send_Pro_DE
	.long	Send_Pro_DF
	.long	Send_Pro_E0
	.long	Send_Pro_E1
	.long	Send_Pro_E2
	.long	Send_Pro_E3
	.long	Send_Pro_E4
	.long	Send_Pro_E5
	.long	Send_Pro_E6
	.long	Send_Pro_E7
	.long	Send_Pro_E8
	.long	Send_Pro_E9
	.long	Send_Pro_EA
	.long	Send_Pro_EB
	.long	Send_Pro_EC
	.long	Send_Pro_ED
	.long	Send_Pro_EE
	.long	Send_Pro_EF
	.long	Send_Pro_F0
	.long	Send_Pro_F1
	.long	Send_Pro_F2
	.long	Send_Pro_F3
	.long	Send_Pro_F4
	.long	Send_Pro_F5
	.long	Send_Pro_F6
	.long	Send_Pro_F7
	.long	Send_Pro_F8
	.long	Send_Pro_F9
	.long	Send_Pro_FA
	.long	Send_Pro_FB
	.long	Send_Pro_FC
	.long	Send_Pro_FD
	.long	Send_Pro_FE
	.long	Send_Pro_FF

	.even
Send_Pro_00:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_01:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_02:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_03:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_04:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_05:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_06:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_07:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_08:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_09:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_0F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_10:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_11:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_12:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_13:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_14:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_15:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_16:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_17:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_18:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_19:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_1F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_20:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_21:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_22:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_23:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_24:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_25:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_26:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_27:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_28:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_29:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_2F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_30:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_31:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_32:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_33:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_34:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_35:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_36:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_37:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_38:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_39:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_3F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_40:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_41:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_42:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_43:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_44:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_45:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_46:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_47:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_48:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_49:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4A:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4B:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4C:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4D:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4E:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_4F:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_50:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_51:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_52:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_53:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_54:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_55:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_56:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_57:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_58:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_59:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5A:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5B:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5C:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5D:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5E:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_5F:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_60:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_61:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_62:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_63:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_64:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_65:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_66:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_67:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_68:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_69:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6A:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6B:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6C:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6D:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6E:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_6F:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_70:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_71:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_72:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_73:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_74:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_75:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_76:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_77:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_78:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_79:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7A:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7B:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7C:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7D:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7E:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_7F:
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_80:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_81:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_82:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_83:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_84:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_85:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_86:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_87:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_88:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_89:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8A:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8B:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8C:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8D:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8E:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_8F:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_90:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_91:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_92:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_93:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_94:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_95:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_96:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_97:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_98:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_99:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9A:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9B:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9C:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9D:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9E:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_9F:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A0:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A1:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A2:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A3:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A4:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A5:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A6:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A7:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A8:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_A9:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AA:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AB:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AC:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AD:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AE:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_AF:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B0:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B1:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B2:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B3:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B4:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B5:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B6:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B7:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B8:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_B9:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BA:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BB:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BC:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BD:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BE:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_BF:
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_C9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_CF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_D9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_DF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_E9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_EA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_EB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_EC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_ED:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_EE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_EF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_F9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Pro_FF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Pro_Block_Loop
	bra.w	Send_Block_End

	.even
Send_Lite:
	moveq.L	#-2,D4
	moveq.L	#-4,D5
	moveq.L	#-1,D6
	moveq.L	#-3,D7
Send_Lite_Block:
	move.W	#202,D3
	subq.W	#1,D3
Send_Lite_Block_Loop:
	moveq.L	#0,D0
	move.B	(A4)+,D0
	lsl.W	#2,D0
	move.L	Send_Lite_TAB(PC,D0.W),A3
	jmp	(A3)

	.even
Send_Lite_TAB:
	.long	Send_Lite_00
	.long	Send_Lite_01
	.long	Send_Lite_02
	.long	Send_Lite_03
	.long	Send_Lite_04
	.long	Send_Lite_05
	.long	Send_Lite_06
	.long	Send_Lite_07
	.long	Send_Lite_08
	.long	Send_Lite_09
	.long	Send_Lite_0A
	.long	Send_Lite_0B
	.long	Send_Lite_0C
	.long	Send_Lite_0D
	.long	Send_Lite_0E
	.long	Send_Lite_0F
	.long	Send_Lite_10
	.long	Send_Lite_11
	.long	Send_Lite_12
	.long	Send_Lite_13
	.long	Send_Lite_14
	.long	Send_Lite_15
	.long	Send_Lite_16
	.long	Send_Lite_17
	.long	Send_Lite_18
	.long	Send_Lite_19
	.long	Send_Lite_1A
	.long	Send_Lite_1B
	.long	Send_Lite_1C
	.long	Send_Lite_1D
	.long	Send_Lite_1E
	.long	Send_Lite_1F
	.long	Send_Lite_20
	.long	Send_Lite_21
	.long	Send_Lite_22
	.long	Send_Lite_23
	.long	Send_Lite_24
	.long	Send_Lite_25
	.long	Send_Lite_26
	.long	Send_Lite_27
	.long	Send_Lite_28
	.long	Send_Lite_29
	.long	Send_Lite_2A
	.long	Send_Lite_2B
	.long	Send_Lite_2C
	.long	Send_Lite_2D
	.long	Send_Lite_2E
	.long	Send_Lite_2F
	.long	Send_Lite_30
	.long	Send_Lite_31
	.long	Send_Lite_32
	.long	Send_Lite_33
	.long	Send_Lite_34
	.long	Send_Lite_35
	.long	Send_Lite_36
	.long	Send_Lite_37
	.long	Send_Lite_38
	.long	Send_Lite_39
	.long	Send_Lite_3A
	.long	Send_Lite_3B
	.long	Send_Lite_3C
	.long	Send_Lite_3D
	.long	Send_Lite_3E
	.long	Send_Lite_3F
	.long	Send_Lite_40
	.long	Send_Lite_41
	.long	Send_Lite_42
	.long	Send_Lite_43
	.long	Send_Lite_44
	.long	Send_Lite_45
	.long	Send_Lite_46
	.long	Send_Lite_47
	.long	Send_Lite_48
	.long	Send_Lite_49
	.long	Send_Lite_4A
	.long	Send_Lite_4B
	.long	Send_Lite_4C
	.long	Send_Lite_4D
	.long	Send_Lite_4E
	.long	Send_Lite_4F
	.long	Send_Lite_50
	.long	Send_Lite_51
	.long	Send_Lite_52
	.long	Send_Lite_53
	.long	Send_Lite_54
	.long	Send_Lite_55
	.long	Send_Lite_56
	.long	Send_Lite_57
	.long	Send_Lite_58
	.long	Send_Lite_59
	.long	Send_Lite_5A
	.long	Send_Lite_5B
	.long	Send_Lite_5C
	.long	Send_Lite_5D
	.long	Send_Lite_5E
	.long	Send_Lite_5F
	.long	Send_Lite_60
	.long	Send_Lite_61
	.long	Send_Lite_62
	.long	Send_Lite_63
	.long	Send_Lite_64
	.long	Send_Lite_65
	.long	Send_Lite_66
	.long	Send_Lite_67
	.long	Send_Lite_68
	.long	Send_Lite_69
	.long	Send_Lite_6A
	.long	Send_Lite_6B
	.long	Send_Lite_6C
	.long	Send_Lite_6D
	.long	Send_Lite_6E
	.long	Send_Lite_6F
	.long	Send_Lite_70
	.long	Send_Lite_71
	.long	Send_Lite_72
	.long	Send_Lite_73
	.long	Send_Lite_74
	.long	Send_Lite_75
	.long	Send_Lite_76
	.long	Send_Lite_77
	.long	Send_Lite_78
	.long	Send_Lite_79
	.long	Send_Lite_7A
	.long	Send_Lite_7B
	.long	Send_Lite_7C
	.long	Send_Lite_7D
	.long	Send_Lite_7E
	.long	Send_Lite_7F
	.long	Send_Lite_80
	.long	Send_Lite_81
	.long	Send_Lite_82
	.long	Send_Lite_83
	.long	Send_Lite_84
	.long	Send_Lite_85
	.long	Send_Lite_86
	.long	Send_Lite_87
	.long	Send_Lite_88
	.long	Send_Lite_89
	.long	Send_Lite_8A
	.long	Send_Lite_8B
	.long	Send_Lite_8C
	.long	Send_Lite_8D
	.long	Send_Lite_8E
	.long	Send_Lite_8F
	.long	Send_Lite_90
	.long	Send_Lite_91
	.long	Send_Lite_92
	.long	Send_Lite_93
	.long	Send_Lite_94
	.long	Send_Lite_95
	.long	Send_Lite_96
	.long	Send_Lite_97
	.long	Send_Lite_98
	.long	Send_Lite_99
	.long	Send_Lite_9A
	.long	Send_Lite_9B
	.long	Send_Lite_9C
	.long	Send_Lite_9D
	.long	Send_Lite_9E
	.long	Send_Lite_9F
	.long	Send_Lite_A0
	.long	Send_Lite_A1
	.long	Send_Lite_A2
	.long	Send_Lite_A3
	.long	Send_Lite_A4
	.long	Send_Lite_A5
	.long	Send_Lite_A6
	.long	Send_Lite_A7
	.long	Send_Lite_A8
	.long	Send_Lite_A9
	.long	Send_Lite_AA
	.long	Send_Lite_AB
	.long	Send_Lite_AC
	.long	Send_Lite_AD
	.long	Send_Lite_AE
	.long	Send_Lite_AF
	.long	Send_Lite_B0
	.long	Send_Lite_B1
	.long	Send_Lite_B2
	.long	Send_Lite_B3
	.long	Send_Lite_B4
	.long	Send_Lite_B5
	.long	Send_Lite_B6
	.long	Send_Lite_B7
	.long	Send_Lite_B8
	.long	Send_Lite_B9
	.long	Send_Lite_BA
	.long	Send_Lite_BB
	.long	Send_Lite_BC
	.long	Send_Lite_BD
	.long	Send_Lite_BE
	.long	Send_Lite_BF
	.long	Send_Lite_C0
	.long	Send_Lite_C1
	.long	Send_Lite_C2
	.long	Send_Lite_C3
	.long	Send_Lite_C4
	.long	Send_Lite_C5
	.long	Send_Lite_C6
	.long	Send_Lite_C7
	.long	Send_Lite_C8
	.long	Send_Lite_C9
	.long	Send_Lite_CA
	.long	Send_Lite_CB
	.long	Send_Lite_CC
	.long	Send_Lite_CD
	.long	Send_Lite_CE
	.long	Send_Lite_CF
	.long	Send_Lite_D0
	.long	Send_Lite_D1
	.long	Send_Lite_D2
	.long	Send_Lite_D3
	.long	Send_Lite_D4
	.long	Send_Lite_D5
	.long	Send_Lite_D6
	.long	Send_Lite_D7
	.long	Send_Lite_D8
	.long	Send_Lite_D9
	.long	Send_Lite_DA
	.long	Send_Lite_DB
	.long	Send_Lite_DC
	.long	Send_Lite_DD
	.long	Send_Lite_DE
	.long	Send_Lite_DF
	.long	Send_Lite_E0
	.long	Send_Lite_E1
	.long	Send_Lite_E2
	.long	Send_Lite_E3
	.long	Send_Lite_E4
	.long	Send_Lite_E5
	.long	Send_Lite_E6
	.long	Send_Lite_E7
	.long	Send_Lite_E8
	.long	Send_Lite_E9
	.long	Send_Lite_EA
	.long	Send_Lite_EB
	.long	Send_Lite_EC
	.long	Send_Lite_ED
	.long	Send_Lite_EE
	.long	Send_Lite_EF
	.long	Send_Lite_F0
	.long	Send_Lite_F1
	.long	Send_Lite_F2
	.long	Send_Lite_F3
	.long	Send_Lite_F4
	.long	Send_Lite_F5
	.long	Send_Lite_F6
	.long	Send_Lite_F7
	.long	Send_Lite_F8
	.long	Send_Lite_F9
	.long	Send_Lite_FA
	.long	Send_Lite_FB
	.long	Send_Lite_FC
	.long	Send_Lite_FD
	.long	Send_Lite_FE
	.long	Send_Lite_FF

	.even
Send_Lite_00:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_01:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_02:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_03:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_04:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_05:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_06:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_07:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_08:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_09:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_0F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_10:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_11:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_12:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_13:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_14:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_15:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_16:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_17:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_18:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_19:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_1F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_20:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_21:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_22:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_23:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_24:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_25:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_26:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_27:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_28:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_29:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_2F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_30:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_31:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_32:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_33:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_34:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_35:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_36:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_37:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_38:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_39:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_3F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_40:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_41:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_42:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_43:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_44:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_45:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_46:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_47:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_48:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_49:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_4F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_50:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_51:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_52:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_53:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_54:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_55:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_56:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_57:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_58:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_59:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_5F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_60:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_61:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_62:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_63:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_64:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_65:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_66:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_67:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_68:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_69:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_6F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_70:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_71:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_72:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_73:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_74:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_75:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_76:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_77:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_78:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_79:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7A:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7B:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7C:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7D:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7E:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_7F:
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_80:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_81:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_82:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_83:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_84:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_85:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_86:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_87:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_88:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_89:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8A:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8B:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8C:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8D:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8E:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_8F:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_90:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_91:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_92:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_93:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_94:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_95:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_96:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_97:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_98:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_99:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9A:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9B:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9C:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9D:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9E:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_9F:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_A9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_AF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_B9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_BF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_C9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_CF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_D9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_DF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_E9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_EA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_EB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_EC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_ED:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_EE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_EF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F0:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F1:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F2:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F3:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F4:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F5:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F6:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F7:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F8:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_F9:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FA:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FB:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FC:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FD:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FE:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D4,(A5)
	move.B	D5,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End
	.even
Send_Lite_FF:
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	move.B	D6,(A5)
	move.B	D7,(A5)
	dbf	D3,Send_Lite_Block_Loop
	bra.w	Send_Block_End

	.even

	.even
Send_Block_End:
	move.l 20(a1),d0
	add.l #202,d0
	cmp.l 4(a1),d0
	blo.w Send_Store_Read
	moveq.l #0,d0
Send_Store_Read:
	move.l d0,20(a1)
	sub.l #202,12(a1)
Send_Return:
	movem.l (sp)+,d3-d7/a3-a4
Send_Quick_Return:
	rts
