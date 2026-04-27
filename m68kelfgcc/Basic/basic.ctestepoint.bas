10 screen 1
20 tc%=0
30 m%=10
40 n%=10
1100 print str$(POINT( 2 * (M% - 1),2 * N%))
1200 IF tc% = 18 AND POINT( 2 * (M% - 1),2 * N%) = 3 THEN M% = M% - 1
