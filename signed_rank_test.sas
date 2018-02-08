/*signed rank test*/
/*- matched pair data*/
/*- H_0: median change is zero*/

/*Deborah Rumsey 2009, ch 17*/
data wtloss;
  input person before after;
  cards;
1 200 205
2 180 160
3 134 110
;

data wtloss;
  set wtloss;
  diff = after - before;
run;

/*note: p-value is two sided*/
/*- to get one-sided p-value, divide by 2*/
proc univariate data=wtloss;
  var diff;
run;
