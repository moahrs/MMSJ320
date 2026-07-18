PROC MAIN

	START:
	SCREEN 1

	LET F = 99999
	LET M% = 18: LET N% = 4
	LET D% = 0:TP%=0

	FOR I% = 0 TO 15
		READ A$

		FOR J% = 1 TO 19
			IF MID$ (A$,J%,1) = "A" THEN 
				COLOR 3,1
				PLOT 2 * J%,2 * I%
				PLOT 2 * J% + 1,2 * I%
				PLOT 2 * J%, 2 * I% + 1
				PLOT 2 * J% + 1,2 * I% + 1
			ENDIF

			IF MID$ (A$,J%,1) = "." THEN 
				COLOR 12,1
				PLOT 2 * J%,2 *I%
				COLOR 1,1
				PLOT 2 * J% + 1, 2 * I%
				TP%=TP%+1
			ENDIF
		NEXT J%
	NEXT I%

	LET TI% = 0

	TP% = TP% - 1
	D% = TP%

	LOCATE 5,35
	PRINT D%

	LBL1080:
	COLOR 6,1
	PLOT 2 * M%,2 * N%
	PLOT 2* M% + 1,2 * N%
	PLOT 2 * M%,2 * N% + 1
	PLOT 2* M% + 1,2 * N% + 1

	LET PM% = M%
	LET PN% = N%

	GET X$
	TC%=ASC(X$)

	IF TC% = 18 AND POINT( 2 * (M% - 1),2 * N%) <> 3 THEN 
		LET M% = M% - 1
	ENDIF

	IF TC% = 20 AND POINT( 2 * (M% + 1),2 * N%) <> 3 THEN 
		LET M% = M% + 1
	ENDIF

	IF TC% = 17 AND POINT( 2 * M%,2 * (N% - 1)) <> 3 THEN 
		LET N% = N% - 1
	ENDIF

	IF TC% = 19 AND POINT( 2 * M%,2 * (N% + 1)) <> 3 THEN 
		LET N% = N% + 1
	ENDIF

	IF POINT( 2 * M%,2 * N%) = 12 THEN 
		LET D% = D% - 1
		LOCATE 5,35
		PRINT STR$(D%)+"  "
	ENDIF

	COLOR 1,1
	PLOT 2 * PM%,2 * PN%
	PLOT 2 * PM% + 1,2 * PN%
	PLOT 2 * PM%,2 * PN% + 1
	PLOT 2 * PM% + 1,2 * PN% + 1

	IF D% = 0 THEN 
		GOTO LBL1180
	ENDIF

	GOTO LBL1080

	LBL1180:
	COLOR 1,1
	PLOT 2 * M%,2 *N%
	PLOT 2 * M%+ 1,2 * N%
	PLOT 2*M%,2* N%+1
	PLOT 2 *M% +1,2*N%+1

	SCREEN 0
	CLS

	LOCATE 4,10
	PRINT "SEU TEMPO FOI DE ";INT(TI% / 5);" SEC"

	IF F > TI% THEN 
		LET F = TI%
	ENDIF

	LOCATE 4,12
	PRINT "MELHOR TEMPO: ";INT(F / 5);" SEC"
	LOCATE 7,18
	PRINT "PRESSIONE RETURN PARA CONTINUAR"

	KEYQST:
	GET TS$

	IF ASC(TS$) <> 13 THEN 
		GOTO KEYQST
	ENDIF

	RESTORE

	GOTO START
ENDPROC

DATA "AAAAAAAAAAAAAAAAAAA"
DATA "A.......AAA.......A"
DATA "A.AA.AA.....AA.AA.A"
DATA "A.A.....AAA.....A.A"
DATA "A...A.A.....A.A...A"
DATA "A.AAA.AA.A.AA.AAA.A"
DATA "A...A.........A...A"
DATA "AAA...A.AAA.A...AAA"
DATA "AAA...A.AAA.A...AAA"
DATA "A...A.........A...A"
DATA "A.AAA.AA.A.AA.AAA.A"
DATA "A...A.A.....A.A...A"
DATA "A.A.....AAA.....A.A"
DATA "A.AA.AA.....AA.AA.A"
DATA "A.......AAA.......A"
DATA "AAAAAAAAAAAAAAAAAAA"
