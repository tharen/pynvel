c== last modified  9-6-2000
     
      INTEGER I,J
      REAL COFARR(162,10)
     
      DATA ((COFARR(I,J),J=1,10),I=  1,  8)/
     >2,-38.2,289.4365,-0.05931,0.02291,0,0,0,0,0,
     >2,-21.48,363.3879,-0.1322,0.02341,0,0,0,0,0,
     >2,-10.72,69.2563,0.01859,0.01441,0,0,0,0,0,
     >2,2.07,-38.5099,-0.0086,0.01798,0,0,0,0,0,
     >2,59.55,-690.458,0.03282,0.0123,0,0,0,0,0,
     >2,-69.45,710.1958,0.05661,0.01726,0,0,0,0,0,
     >2,-26.63,295.3926,0.06268,0.0151,0,0,0,0,0,
     >2,-70.88,630.8735,0.20594,0.00808,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=  9, 16)/
     >2,-58.8999,512.439,0.1724,0.0127,0,0,0,0,0,
     >2,-89.02,943.3962,-0.00243,0.02461,0,0,0,0,0,
     >2,-73.43,762.7024,0.05875,0.01559,0,0,0,0,0,
     >2,17.34,-185.219,0.00433,0.01848,0,0,0,0,0,
     >2,-37.18,333.5132,0.06549,0.01642,0,0,0,0,0,
     >2,-6.38,79.25591,0.03324,0.01496,0,0,0,0,0,
     >2,-8.69,105.0196,0.00849,0.01776,0,0,0,0,0,
     >2,-45.63,401.2969,0.0566,0.01579,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I= 17, 24)/
     >2,-62.36,664.2004,0.04703,0.01733,0,0,0,0,0,
     >1,-0.2,0.01789,0,0,0,0,0,0,0,
     >9,1.128222,58.99629,-2.48673,-0.83591,1.757875,7.010651,-33.3617,1
     >30.0698,-10.1822,
     >9,13.3354,30.10578,-1.85789,-0.16569,1.648317,1.682036,-11.5179,25
     >.91741,-8.17492,
     >9,1.989711,43.11956,-2.45289,-0.41222,2.256884,3.537383,-32.29,163
     >.4292,-7.717,
     >9,-4.55669,39.0106,-3.51433,-0.37259,3.613258,3.688304,-11.4823,-5
     >.16395,-5.65885,
     >9,33.90157,81.74522,-3.30275,-1.34924,3.186792,9.797209,-107.711,7
     >23.9316,-3.29731,
     >9,8.140944,40.17758,-2.86361,-0.43141,1.930775,3.247007,-44.6815,3
     >67.3958,-2.23581/
C
      DATA ((COFARR(I,J),J=1,10),I= 25, 32)/
     >9,17.71302,52.08328,0.402382,-0.47585,0.503122,3.799348,-49.0471,2
     >46.9717,-22.1629,
     >3,-19.555,0.047369,-0.00358,0.022945,0.000316,0,0,0,0,
     >3,-19.334,0.046832,-0.00354,0.022685,0.000312,0,0,0,0,
     >3,-18.234,0.044169,-0.00333,0.021395,0.000294,0,0,0,0,
     >9,20.40944,43.11118,-3.23381,-0.42666,3.492633,3.557186,-31.0173,1
     >58.0429,-7.36491,
     >9,25.24905,45.56107,-2.78893,-0.45066,3.223523,3.682938,-33.7661,1
     >67.4167,-11.0771,
     >9,4.231734,38.75439,-4.36139,-0.32524,4.541995,2.765073,-21.5457,1
     >12.57,-2.60922,
     >9,9.576885,48.08546,-3.73161,-0.47194,3.859076,3.9772,-33.5125,171
     >.8786,-6.94206/
C
      DATA ((COFARR(I,J),J=1,10),I= 33, 40)/
     >9,25.81757,37.72321,-4.15835,-0.39002,4.791443,3.189236,-24.0426,1
     >26.2147,-3.62941,
     >9,20.78408,37.79404,-2.41221,-0.37024,2.782536,3.02776,-27.6324,13
     >7.2727,-8.99916,
     >9,2.063179,17.40757,-1.58264,-0.11593,1.788546,1.148776,-7.31772,1
     >8.73197,-4.90119,
     >9,-2.25876,38.91236,-2.6619,-0.38859,2.619678,3.375418,-30.3263,15
     >5.7957,-6.47169,
     >9,1.275776,28.90975,-2.38188,-0.17069,2.37362,1.721002,-10.9759,26
     >.5255,-7.06891,
     >9,-0.00511,29.6989,-2.52658,-0.1807,2.489959,1.810809,-11.5807,30.
     >59693,-6.63993,
     >9,-3.30767,32.81035,-3.20565,-0.20269,3.096668,2.048858,-11.6339,3
     >0.94697,-5.11018,
     >9,2.514612,13.03583,-0.90572,-0.07306,0.943639,0.740454,-4.83434,8
     >.692961,-4.10107/
C
      DATA ((COFARR(I,J),J=1,10),I= 41, 48)/
     >9,7.671365,81.68849,-1.52592,-1.56027,1.471497,12.17432,-94.3496,4
     >69.485,-9.33086,
     >9,-9.76627,106.568,-3.83483,-1.69242,3.68345,13.16334,-124.208,711
     >.8766,-7.1025,
     >9,7.666031,54.15705,-2.8081,-0.75991,2.809253,6.088589,-37.2789,12
     >9.4717,-7.48922,
     >9,11.55423,-35.4233,-2.91478,1.239861,2.849438,-9.09426,109.9872,-
     >722.38,-4.67222,
     >9,12.73483,49.16016,-1.97019,-0.48565,1.725519,4.095717,-40.2332,2
     >04.1726,-9.84705,
     >9,-5.31144,33.69361,-4.25353,-0.3363,4.547958,3.697291,17.59323,-2
     >38.903,-5.70078,
     >9,-2.02143,13.37574,-3.527,0.293881,3.435132,-1.30006,41.58611,-36
     >9.066,-5.15462,
     >9,17.97646,-9.80753,-3.61041,0.732441,3.447934,-5.24199,48.3685,-1
     >60.911,-1.91504/
C
      DATA ((COFARR(I,J),J=1,10),I= 49, 56)/
     >9,27.5513,17.76573,-3.57318,0.046488,3.539247,0.001415,12.62598,-1
     >02.422,-1.55102,
     >9,-8.06478,47.12121,-4.62336,-0.72776,5.139664,7.097772,-10.8149,-
     >68.0708,-2.58445,
     >9,10.16697,50.41022,-2.09938,-0.77793,1.320258,7.350351,-25.4106,8
     >9.40071,-8.64242,
     >9,11.24575,61.01016,-1.95984,-0.88645,1.380411,6.985221,-48.4181,2
     >15.6195,-10.0291,
     >9,16.09117,44.97439,-1.93099,-0.5491,1.348508,4.445997,-31.2951,14
     >0.5713,-7.52389,
     >9,10.99943,72.13966,-1.92479,-1.27083,1.159099,10.11479,-61.2436,2
     >66.6985,-8.51473,
     >9,14.32783,55.16116,2.310885,-0.47373,-2.6025,4.264286,-46.6598,21
     >1.947,-26.8281,
     >9,-14.1454,18.8663,-0.06156,0.059181,0.129874,-0.52224,3.016437,-1
     >3.5425,-0.23841/
C
      DATA ((COFARR(I,J),J=1,10),I= 57, 64)/
     >9,-7.95055,14.48169,-0.83291,0.076025,0.758016,-0.65215,6.472296,-
     >26.1614,3.256685,
     >9,5.11929,21.73903,2.902435,-0.00135,-2.71002,-0.04598,-8.87977,26
     >.77165,-12.3777,
     >9,23.63944,103.8745,0.804897,-1.24263,4.856059,8.714891,-135.435,7
     >69.935,-38.3518,
     >9,29.34922,55.65025,2.564187,-0.3463,-3.11986,2.978145,-44.4858,18
     >7.4731,-35.4737,
     >9,23.98061,46.75815,-0.77096,-0.31417,0.24517,2.715168,-31.3204,14
     >2.9201,-19.4614,
     >9,25.23092,49.29762,-0.81124,-0.33321,0.257917,2.884457,-33.0635,1
     >50.8098,-20.4876,
     >9,-2.70029,43.38527,-2.74878,-0.34831,1.425095,2.256538,-21.1893,1
     >23.3338,-6.31483,
     >9,-0.52814,22.33892,-2.10857,0.100159,1.001779,-1.20019,5.640259,-
     >29.1042,-7.34476/
C
      DATA ((COFARR(I,J),J=1,10),I= 65, 72)/
     >9,24.82406,40.62484,-1.65421,-0.45127,1.304827,3.956851,-16.9188,6
     >1.54764,-11.9827,
     >9,14.85293,35.92396,-1.87826,-0.37794,1.247506,3.501006,-10.2872,2
     >8.5024,-8.53251,
     >9,15.99656,39.06613,-1.34217,-0.47228,0.698229,4.360924,-17.7843,6
     >3.89138,-9.81111,
     >9,16.45236,37.32572,-1.76573,-0.42267,1.217913,3.48938,-17.3634,65
     >.27461,-7.80343,
     >9,15.09939,44.56001,-1.9467,-0.64385,1.17421,5.360039,-31.4285,138
     >.076,-5.36836,
     >2,19.88,-92.5433,-0.11626,0.024975,0,0,0,0,0,
     >9,0.388582,46.08353,-0.39003,-0.56966,0.023586,3.746734,-29.2589,1
     >08.8299,-12.727,
     >9,17.06254,55.45506,-1.7723,-0.97968,1.169806,8.722101,-43.3592,18
     >0.0097,-5.53187/
C
      DATA ((COFARR(I,J),J=1,10),I= 73, 80)/
     >9,12.99442,39.15707,-2.99662,-0.53539,2.034086,4.91909,-12.4233,42
     >.32191,-2.95231,
     >9,8.354537,52.68906,-2.82316,-0.96431,1.765472,8.902739,-30.6631,1
     >20.2525,-2.41683,
     >9,3.981751,34.78918,-1.46042,-0.31849,0.72432,3.101707,-6.19793,-2
     >1.1833,-8.05105,
     >9,1.559527,64.30678,-2.42303,-0.80374,1.754333,5.848837,-52.1114,2
     >43.7092,-9.64178,
     >9,2.641469,69.00802,-2.07004,-1.1477,1.138252,9.899774,-47.6752,19
     >6.7583,-11.3731,
     >9,-9.58909,59.15546,-2.0467,-0.82676,1.444023,6.654931,-43.5152,18
     >9.179,-10.2464,
     >9,-19.1195,9.94054,0.38646,0.39283,0.927016,-0.07215,8.351807,-17.
     >9963,-8.11195,
     >9,-46.702,0.037282,-10.798,0.016446,10.18602,4.143653,60.30902,-29
     >7.435,28.70009/
C
      DATA ((COFARR(I,J),J=1,10),I= 81, 88)/
     >9,-4.9276,0.167129,-4.18557,0.438259,3.886483,-1.93622,59.11718,-3
     >73.175,-1.94569,
     >9,22.87012,22.99515,-4.22473,-0.41297,3.262531,5.554002,40.72345,-
     >348.406,-5.7495,
     >9,7.783953,0.365606,-1.52797,0.643561,0.91788,-4.28352,52.25176,-3
     >80.88,-15.5842,
     >9,4.590922,197.1434,-4.4182,-3.57723,2.734224,25.7941,-343.585,251
     >4.705,-0.84342,
     >9,-23.4645,170.3479,2.723017,-3.61746,-7.42028,29.521,-260.963,152
     >3.136,1.846339,
     >2,17.51,-78.0852,-0.0981,0.021074,0,0,0,0,0,
     >2,23.7,-76.1755,-0.10994,0.023307,0,0,0,0,0,
     >9,-3.12753,48.85254,-2.52609,-0.35974,1.967869,3.125574,-30.551,14
     >7.2515,-6.33187/
C
      DATA ((COFARR(I,J),J=1,10),I= 89, 96)/
     >9,8.467401,37.69632,-1.72585,-0.28084,1.350189,2.437876,-25.1513,1
     >19.7463,-6.49732,
     >9,-1.08372,43.83433,-2.01359,-0.32719,1.562444,2.846149,-29.2942,1
     >39.6765,-7.41879,
     >9,-0.36942,44.1977,-2.09478,-0.32721,1.625803,2.856283,-29.3832,14
     >0.5678,-7.11244,
     >9,1.265627,43.85086,-1.98501,-0.32959,1.537414,2.867173,-29.4298,1
     >40.2023,-7.52361,
     >9,3.640889,46.36055,-2.41524,-0.35057,1.925295,3.050737,-29.7741,1
     >43.5715,-6.38511,
     >9,4.502776,42.09381,-1.94391,-0.31297,1.501668,2.725706,-28.0849,1
     >34.0567,-7.06795,
     >9,7.46639,45.3354,-1.84076,-0.3466,1.44542,2.974835,-30.7403,145.0
     >206,-8.79904,
     >9,-17.5461,36.56206,-3.15319,-0.24888,1.444006,2.655647,-22.8317,1
     >25.8351,7.898917/
C
      DATA ((COFARR(I,J),J=1,10),I= 97,104)/
     >9,16.16168,50.2992,-1.00438,-0.38543,1.199413,3.072691,-34.7773,15
     >3.8792,-17.8685,
     >9,14.23973,40.58869,0.430176,-0.29515,-0.61209,2.554493,-29.4541,1
     >10.8982,-14.5066,
     >9,-19.1716,32.4417,-3.68078,-0.18785,1.250719,2.315204,-9.76718,58
     >.23691,9.270677,
     >9,-3.54498,46.77078,-2.61014,-0.34599,2.116291,3.00899,-28.8629,13
     >9.805,-5.4876,
     >9,-0.37825,42.4076,-1.9604,-0.32128,1.498413,2.799385,-28.605,137.
     >0386,-6.82388,
     >9,1.864614,42.068,-2.45162,-0.316,2.028967,2.776485,-26.5952,129.3
     >944,-4.89778,
     >9,2.498534,49.12997,-2.91363,-0.37133,2.611106,3.172641,-29.8675,1
     >44.0582,-6.32676,
     >9,3.832829,45.68233,-2.59046,-0.34807,2.154555,3.04725,-29.3559,14
     >2.1955,-5.63009/
C
      DATA ((COFARR(I,J),J=1,10),I=105,112)/
     >9,2.866352,48.7227,-2.6939,-0.36344,2.181618,3.184013,-30.8509,149
     >.4645,-6.00581,
     >9,1.852866,45.1879,-2.64112,-0.33983,2.180737,2.984713,-28.5679,13
     >9.0615,-5.1983,
     >9,6.235341,59.90568,-3.22509,-0.55475,2.796437,4.801858,-42.7298,2
     >11.2412,-6.84568,
     >1,0.87,0.002972,0,0,0,0,0,0,0,
     >1,1.96,0.002605,0,0,0,0,0,0,0,
     >1,4.45,0.002332,0,0,0,0,0,0,0,
     >1,3.14,0.002837,0,0,0,0,0,0,0,
     >1,4.72,0.002328,0,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=113,120)/
     >1,3.47,0.002897,0,0,0,0,0,0,0,
     >1,3.57,0.002838,0,0,0,0,0,0,0,
     >1,3.84,0.002912,0,0,0,0,0,0,0,
     >1,3.28,0.003133,0,0,0,0,0,0,0,
     >1,2.78,0.002879,0,0,0,0,0,0,0,
     >1,4.04,0.002649,0,0,0,0,0,0,0,
     >1,2.67,0.002984,0,0,0,0,0,0,0,
     >1,2.53,0.003054,0,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=121,128)/
     >1,4.09,0.002607,0,0,0,0,0,0,0,
     >1,3.14,0.002855,0,0,0,0,0,0,0,
     >1,2.14,0.002869,0,0,0,0,0,0,0,
     >1,3.83,0.002864,0,0,0,0,0,0,0,
     >1,2.27,0.002865,0,0,0,0,0,0,0,
     >3,2.32774,0.006932,-0.00049,0.003591,0.000045,0,0,0,0,
     >2,2,0.002,0.002,0.002,0,0,0,0,0,
     >1,-68.4,0.01721,0,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=129,136)/
     >1,-48.8,0.014,0,0,0,0,0,0,0,
     >1,-35,0.01202,0,0,0,0,0,0,0,
     >6,-10.4,-0.06209,-0.32801,0.0152,0,0,0,0,0,
     >1,-30.7,0.01132,0,0,0,0,0,0,0,
     >1,-49.7,0.01502,0,0,0,0,0,0,0,
     >1,-44.2,0.01324,0,0,0,0,0,0,0,
     >1,-46.9,0.0137,0,0,0,0,0,0,0,
     >1,-46.8,0.01355,0,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=137,144)/
     >1,0.74,0.002761,0,0,0,0,0,0,0,
     >1,0.23,0.002627,0,0,0,0,0,0,0,
     >1,0.57,0.002633,0,0,0,0,0,0,0,
     >1,0.96,0.002818,0,0,0,0,0,0,0,
     >5,-1.25,0.3826,0,0,0.002072,0,0,0,0,
     >1,0.6,0.002551,0,0,0,0,0,0,0,
     >5,-1.34,0.3842,0,0,0.002125,0,0,0,0,
     >5,-3.91,0.7925,0,0,0.001951,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=145,152)/
     >5,0.73,-0.0769,0,0,0.00279,0,0,0,0,
     >5,-1.35,0.383,0,0,0.002543,0,0,0,0,
     >5,0.01,0.1179,0,0,0.002532,0,0,0,0,
     >1,1.37,0.002168,0,0,0,0,0,0,0,
     >1,0.63,0.002664,0,0,0,0,0,0,0,
     >1,-0.5,0.002243,0,0,0,0,0,0,0,
     >1,-1.1,0.002168,0,0,0,0,0,0,0,
     >1,-0.9,0.002139,0,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=153,160)/
     >1,-0.9,0.002432,0,0,0,0,0,0,0,
     >7,3.97721,-1.26201,-2.38835,0,0,0,0,0,0,
     >7,3.20596,-1.16038,-3.82453,0,0,0,0,0,0,
     >7,0.78501,-0.83082,-4.21459,0,0,0,0,0,0,
     >7,0.82074,-0.7249,-1.60698,0,0,0,0,0,0,
     >7,0.17651,-0.52585,-3.34391,0,0,0,0,0,0,
     >7,0.41572,-0.63159,-4.759,0,0,0,0,0,0,
     >7,0.28675,-0.55344,-5.01649,0,0,0,0,0,0/
C
      DATA ((COFARR(I,J),J=1,10),I=161,162)/
     >7,1.60262,-0.89085,-3.85897,0,0,0,0,0,0,
     >7,1.49569,-1.03072,-4.40237,0,0,0,0,0,0/