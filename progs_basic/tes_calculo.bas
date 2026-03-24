10 HOME
100 I = 0:CS=COS(0) : SN=SIN(0)
105 GOSUB 1000
110 RZ(I,0) =  (CS * PT(I,0)) - (SN * PT(I,1))
120 RZ(I,1) =  (SN * PT(I,0)) + (CS * PT(I,1))
130 RZ(I,2) =  (1 * PT(I,2))
140 RY(I,0) =  (CS * RZ(I,0)) + (SN * RZ(I,2))
150 RY(I,1) =   1 * RZ(I,1)
160 RY(I,2) = ((-1) * SN * RZ(I,0)) + (CS * RZ(I,2))
170 RX(I,0) =   1 * RY(I,0)
180 RX(I,1) =   (CS * RY(I,1)) + (SN * RY(I,2))
190 RX(I,2) =   (SN * RY(I,1)) + (CS * RY(I,2))
200 print RZ(I,0);RZ(I,1);RZ(I,2)
210 print RY(I,0);RY(I,1);RY(I,2)
220 print RX(I,0);RX(I,1);RX(I,2)
230 END
1000 DIM PT(8,3)
1005 DIM RZ(8,3)
1006 DIM RY(8,3)
1007 DIM RX(8,3)
1020 PT(0,0) = -1 : PT(0,1) = -1 : PT(0,2) = -1
1030 PT(1,0) =  1 : PT(1,1) = -1 : PT(1,2) = -1
1040 PT(2,0) =  1 : PT(2,1) =  1 : PT(2,2) = -1
1050 PT(3,0) = -1 : PT(3,1) =  1 : PT(3,2) = -1
1060 PT(4,0) = -1 : PT(4,1) = -1 : PT(4,2) =  1
1070 PT(5,0) =  1 : PT(5,1) = -1 : PT(5,2) =  1
1080 PT(6,0) =  1 : PT(6,1) =  1 : PT(6,2) =  1
1090 PT(7,0) = -1 : PT(7,1) =  1 : PT(7,2) =  1
1100 RETURN
