10 REM POKE 230,32 :  REM page 1
20 REM POKE 230,64  : REM page 2
30 REM POKE 49236,0 : REM display page 1
40 REM POKE 49237,0 : REM display page 2

100 HGR
105 W% = 140 : H% = 90 : SL% = 50
110 TH = 0 
120 SC% = 2
125 GOSUB 1000
130 GOSUB 5400
135 GOSUB 7000
136 HCOLOR=0
137 if SC% = 0 then GOSUB 6000 : REM 5100
140 HCOLOR=3
145 SC% = 1
150 GOSUB 6000 : REM 5100
152 SC% = 0
155 TH = TH + 0.05
170 GOTO 130
1000 DIM PT%(8,3)
1005 DIM RZ(8,3)
1006 DIM RY(8,3)
1007 DIM RX(8,3)
1008 DIM OL(8,3)
1009 DIM AB%(12,2)
1020 PT%(0,0) = -1 : PT%(0,1) = -1 : PT%(0,2) = -1
1030 PT%(1,0) =  1 : PT%(1,1) = -1 : PT%(1,2) = -1
1040 PT%(2,0) =  1 : PT%(2,1) =  1 : PT%(2,2) = -1
1050 PT%(3,0) = -1 : PT%(3,1) =  1 : PT%(3,2) = -1
1060 PT%(4,0) = -1 : PT%(4,1) = -1 : PT%(4,2) =  1
1070 PT%(5,0) =  1 : PT%(5,1) = -1 : PT%(5,2) =  1
1080 PT%(6,0) =  1 : PT%(6,1) =  1 : PT%(6,2) =  1
1090 PT%(7,0) = -1 : PT%(7,1) =  1 : PT%(7,2) =  1
1100 AB%(0,0) = 0 : AB%(0,1) = 1
1110 AB%(1,0) = 1 : AB%(1,1) = 2 
1120 AB%(2,0) = 2 : AB%(2,1) = 3
1130 AB%(3,0) = 3 : AB%(3,1) = 0
1140 AB%(4,0) = 4 : AB%(4,1) = 5
1150 AB%(5,0) = 5 : AB%(5,1) = 6
1160 AB%(6,0) = 6 : AB%(6,1) = 7
1170 AB%(7,0) = 7 : AB%(7,1) = 4
1180 AB%(8,0) = 0 : AB%(8,1) = 4
1190 AB%(9,0) = 1 : AB%(9,1) = 5
1200 AB%(10,0) = 2 : AB%(10,1) = 6
1210 AB%(11,0) = 3 : AB%(11,1) = 7
1300 RETURN
5100 REM DRAW SQUARE
5110 FOR I% = 0 TO 11
5120 A = AB%(I%,0) : B = AB%(I%,1) : GOSUB 6000
5130 NEXT I%
5240 RETURN
5400 REM SWAP SCREENS
5410 REM SCR = NOT SCR
5420 REM POKE 49236+(NOT SCR),0 : REM SHOW OTHER PAGE
5430 REM POKE 230,32*(SCR+1) : REM SWITCH TO THIS PAGE
5440 REM CALL 62450
5470 RETURN
6000 if SC% = 0 then goto 6100
6003 FOR I% = 0 TO 11
6005 X1% = INT(SL% * RX(AB%(I%,0),0) + W%) : Y1% = INT(SL% * RX(AB%(I%,0),1) + H%)
6010 X2% = INT(SL% * RX(AB%(I%,1),0) + W%) : Y2% = INT(SL% * RX(AB%(I%,1),1) + H%)
6015 OL(AB%(I%,0),0) = RX(AB%(I%,0),0) : OL(AB%(I%,0),1) = RX(AB%(I%,0),1)
6016 OL(AB%(I%,1),0) = RX(AB%(I%,1),0) : OL(AB%(I%,1),1) = RX(AB%(I%,1),1)
6020 HPLOT X1%,Y1% TO X2%,Y2%
6025 NEXT I%
6030 RETURN
6100 FOR I% = 0 TO 11
6110 X1% = INT(SL% * OL(AB%(I%,0),0) + W%) : Y1% = INT(SL% * OL(AB%(I%,0),1) + H%)
6120 X2% = INT(SL% * OL(AB%(I%,1),0) + W%) : Y2% = INT(SL% * OL(AB%(I%,1),1) + H%)
6130 HPLOT X1%,Y1% TO X2%,Y2%
6135 NEXT I%
6140 RETURN
7000 CS = COS(TH) : SN = SIN(TH)
7005 FOR I% = 0 TO 8
7010 RZ(I%,0) =  (CS * PT%(I%,0)) - (SN * PT%(I%,1))
7020 RZ(I%,1) =  (SN * PT%(I%,0)) + (CS * PT%(I%,1))
7030 RZ(I%,2) =  (1 * PT%(I%,2))
7040 RY(I%,0) =  (CS * RZ(I%,0)) + (SN * RZ(I%,2))
7050 RY(I%,1) =   1 * RZ(I%,1)
7060 RY(I%,2) = ((-1) * SN * RZ(I%,0)) + (CS * RZ(I%,2))
7070 RX(I%,0) =   1 * RY(I%,0)
7080 RX(I%,1) =   (CS * RY(I%,1)) + (SN * RY(I%,2))
7090 RX(I%,2) =   (SN * RY(I%,1)) + (CS * RY(I%,2))
7100 NEXT I%
7200 RETURN
