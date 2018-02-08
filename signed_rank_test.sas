/*signed rank test*/
/*- matched pair data*/

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

proc univariate data=wtloss;
  var diff;
run;
