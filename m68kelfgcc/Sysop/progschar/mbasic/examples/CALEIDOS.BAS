PROC MAIN
  SCREEN 2
  C%=1
  FOR I=1 TO 40
    X=INT(RND(1)*250) + 10
    Y=INT(RND(1)*170) + 10

    CIRCLE X,Y,10,C%
    PAINT X,Y,C%
    
    C%=C%+1

    IF C%=16 THEN C%=1
  NEXT I
ENDPROC
