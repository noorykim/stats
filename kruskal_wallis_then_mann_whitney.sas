/*Non-parametric tests*/

/*Kruskal-Wallis test*/
/*- to compare ranks for 3 groups or more*/
/*- can be followed by pairwise group comparisons using the Wilcoxon rank sum test (aka Mann-Whitney test)*/
/*- assumptions/conditions: */
/*  - samples from different populations are independent*/
/*  - population distributions have same shape and amount of spread*/
/*- test statistic distribution: chi-square with k-1 df, where k = # of groups*/

/*Mann-Whitney test*/
/*- to compare ranks for 2 groups*/

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

/*Kruskal-Wallis test*/
/*note: test statistic is already adjusted for ties*/
/*before adjustment = 8.52; after = 9.70*/
proc npar1way data=ratings wilcoxon;
	class airline;
	var rating;
	exact wilcoxon;
run;

/*Mann-Whitney tests*/
proc npar1way data=ratings(where=(airline in ('a', 'b') ) ) wilcoxon;
	class airline;
	var rating;
	exact wilcoxon;
run;

proc npar1way data=ratings(where=(airline in ('a', 'c') ) ) wilcoxon;
	class airline;
	var rating;
	exact wilcoxon;
run;

proc npar1way data=ratings(where=(airline in ('b', 'c') ) ) wilcoxon;
	class airline;
	var rating;
	exact wilcoxon;
run;
