PROC MAIN
  SCREEN 2
  COLOR 15,1

  FOR K=1 TO 100:
    PLOT INT(RND(1)*256), INT (RND(1)*192)
  NEXT K

  FOR T=1 TO 8
    XC=INT(RND(1) *195)+30
    YC=INT (RND(1) *131)+30
    CL=INT(RND(1)*3)
    ' CL=CL-(CL=3)
    S=INT(RND(1)*25)+5

    FOR K=-S TO S
      IF K=1 AND INT(RND(1)*4)=1 THEN CIRCLE XC, YC,8*1.5,9,0,,0.25
      
      X=SQRT(S*S-K*K)
      X2=2*X

      FOR L=-X TO X STEP 2
        IF INT(RND(1)*X2)-X<L THEN
          COLOR CL 
        ELSE 
          COLOR 3
        ENDIF

        PLOT XC-L,YC-K 

      NEXT L
    NEXT K
  NEXT T

  LBL150:
  GOTO LBL150
END PROC
