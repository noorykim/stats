/*Spearman's rank correlation*/
/*- nonparametric test*/
/*- if x and/or y is ordinal*/

/*Deborah Rumsey (2009), ch. 20*/
data grades;
	input aptitude final;
	cards;
59 3
47 2 
58 4
66 3
77 2
57 4
62 3
68 3
69 5
36 1
48 3
65 3
51 2
61 3
40 3
67 4
60 2
56 3
76 3
71 5
;

proc corr data=grades spearman;
	var aptitude;
	with final;
run;
