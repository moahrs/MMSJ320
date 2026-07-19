PROC MAIN
  SCREEN 2

  W% = 140
  H% = 90
  SL% = 50
  TH = 0 

  COLOR 15,1
  SC% = 1

  ' Define desenhar sempre na memoria RAM
  BUFDRAW 1

  ' Inicializa Variaveis
  CALL SETVARS

  LBL160:
  CALL CALCANGLES
  CALL CALCVERTS

  ' Apaga cubo
  FILL 48,0,240,191,1

  ' Redesenha cubo na memoria
  CALL DRAWCUBE

  ' Copia memoria para VDP
  BUFCOPY 1,0,48,0,240,191

  TH = TH + 0.05

  GOTO LBL160
ENDPROC

PROC SETVARS
  DIM PT%(8,3)
  DIM RZ(8,3)
  DIM RY(8,3)
  DIM RX(8,3)
  DIM DX%(12,2)
  DIM DY%(12,2)
  DIM AB%(12,2)
  PT%(0,0) = -1
  PT%(0,1) = -1
  PT%(0,2) = -1
  PT%(1,0) =  1
  PT%(1,1) = -1
  PT%(1,2) = -1
  PT%(2,0) =  1
  PT%(2,1) =  1
  PT%(2,2) = -1
  PT%(3,0) = -1
  PT%(3,1) =  1
  PT%(3,2) = -1
  PT%(4,0) = -1
  PT%(4,1) = -1
  PT%(4,2) =  1
  PT%(5,0) =  1
  PT%(5,1) = -1
  PT%(5,2) =  1
  PT%(6,0) =  1
  PT%(6,1) =  1
  PT%(6,2) =  1
  PT%(7,0) = -1
  PT%(7,1) =  1
  PT%(7,2) =  1
  AB%(0,0) = 0
  AB%(0,1) = 1
  AB%(1,0) = 1
  AB%(1,1) = 2 
  AB%(2,0) = 2
  AB%(2,1) = 3
  AB%(3,0) = 3
  AB%(3,1) = 0
  AB%(4,0) = 4
  AB%(4,1) = 5
  AB%(5,0) = 5
  AB%(5,1) = 6
  AB%(6,0) = 6
  AB%(6,1) = 7
  AB%(7,0) = 7
  AB%(7,1) = 4
  AB%(8,0) = 0
  AB%(8,1) = 4
  AB%(9,0) = 1
  AB%(9,1) = 5
  AB%(10,0) = 2
  AB%(10,1) = 6
  AB%(11,0) = 3
  AB%(11,1) = 7
ENDPROC

PROC CALCVERTS
  FOR I% = 0 TO 11
    DX%(I%,0) = INT(SL% * RX(AB%(I%,0),0) + W%)
    DY%(I%,0) = INT(SL% * RX(AB%(I%,0),1) + H%)
    DX%(I%,1) = INT(SL% * RX(AB%(I%,1),0) + W%)
    DY%(I%,1) = INT(SL% * RX(AB%(I%,1),1) + H%)
  NEXT I%
ENDPROC

PROC DRAWCUBE
  FOR I% = 0 TO 11
    LINE DX%(I%,0),DY%(I%,0) TO DX%(I%,1),DY%(I%,1)
  NEXT I%
ENDPROC

PROC CALCANGLES
  CS = COS(TH)
  SN = SIN(TH)
  FOR I% = 0 TO 8
    RZ(I%,0) =  (CS * PT%(I%,0)) - (SN * PT%(I%,1))
    RZ(I%,1) =  (SN * PT%(I%,0)) + (CS * PT%(I%,1))
    RZ(I%,2) =  (1 * PT%(I%,2))
    RY(I%,0) =  (CS * RZ(I%,0)) + (SN * RZ(I%,2))
    RY(I%,1) =   1 * RZ(I%,1)
    RY(I%,2) = ((-1) * SN * RZ(I%,0)) + (CS * RZ(I%,2))
    RX(I%,0) =   1 * RY(I%,0)
    RX(I%,1) =   (CS * RY(I%,1)) + (SN * RY(I%,2))
    RX(I%,2) =   (SN * RY(I%,1)) + (CS * RY(I%,2))
  NEXT I%
ENDPROC
