/*Kruskal-Wallis test*/
/*- non-parametric test*/
/*- to compare ranks for 3 groups or more*/

/*Deborah Rumsey (2009), ch. 19*/
data ratings;
	input airline $ rating;
	cards;
a 4
a 3
a 4
a 4
a 3
a 3
a 2
a 3
a 4
b 2
b 3
b 3
b 3
b 4
b 4
b 3
b 4
b 3
c 2
c 3
c 3
c 2
c 2
c 1
c 3
c 2
c 2
;

/*note: test statistics is already adjusted for ties*/
proc npar1way data=ratings wilcoxon;
	class airline;
	var rating;
run;
