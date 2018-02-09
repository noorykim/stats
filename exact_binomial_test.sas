options symbolgen mprint mprintnest;

/* Inner Macro: %__ExactBinomialTest:
	Input parameters:
		np = # of those counted in numerator; # yeses
		n = # in denominator; sample size
		alpha = 1 - level of significance
		ndecimals = # decimal places

	Return values:
		p = proportion of yeses (num)
		lcln = lower confidence limit (num)
		ucln = upper confidence limit (num)
		lcl = lower confidence limit (char)
		ucl = upper confidence limit (char)
		ci = confidence interval decimals = (lcl, ucl)  (char)
		ci_pct = confidence interval, percentages = (lcl%, ucl%)  (char)

	Assumptions:
	- Input data set 
		- Each row has np and n
*/
%macro __ExactBinomialTest;

	/*Input parameters - default values*/
	%if &np eq . %then %let np = 0;
	%if &n eq . %then %let n = 0;
	%if &alpha eq . %then %let alpha = 0.05;
	%if &ndecimals eq . %then %let ndecimals = 1;

	/*# of no's*/
	%let nq = %eval(&n - &np);

	data _freqin;
		group=1; wt=&np; output;
		group=2; wt=&nq; output;
	run;

	ods exclude all;
	/*calculate proportion and confidence interval*/
	proc freq data=_freqin;
		weight wt / zeros;	
		tables group / binomial (exact) alpha=&alpha;
		output out=_freqout binomial;
	run;
	ods exclude none;

	/*assign return values*/
	/*note: no length statement needed for a _null_ data set*/
	data _null_;
		set _freqout;
		call symputx('p', _BIN_);

		/*lower bound of ci*/
		if 0 le XL_BIN le 1 then do;
			lcln = XL_BIN;
			lcl  = strip(put(XL_BIN, 8.&ndecimals));
			lcl_pct = strip(put(XL_BIN, percent9.&ndecimals));
		end;
		else do;
			lcln = .;
			lcl  = "NA";
			lcl_pct = "NA";
		end;
		call symputx('LCLN', lcln);
		call symputx('LCL', lcl);
		call symputx('LCL_PCT', lcl_pct);

		/*upper bound of ci*/
		if 0 le XU_BIN le 1 then do;
			ucln = XU_BIN;
			ucl = strip(put(XU_BIN, 8.&ndecimals));
			ucl_pct = strip(put(XU_BIN, percent9.&ndecimals));
			end;
		else do;
			ucln = .;
			ucl = "NA";
			ucl_pct = "NA";
		end;
		call symputx('UCLN', ucln);
		call symputx('UCL', ucl);
		call symputx('UCL_PCT', ucl_pct);

		/*concatenate lower and upper bounds*/
		ci     = '(' || strip(lcl) || ', ' || strip(ucl) || ')';
		ci_pct = '(' || strip(lcl_pct) || ', ' || strip(ucl_pct) || ')';
		call symputx('CI', ci);
		call symputx('CI_PCT', ci_pct);
	run;

%mend __ExactBinomialTest;


/* Middle Function: _ExactBinomialTest() */
proc fcmp outlib=work.funcs.pvals;
	subroutine _ExactBinomialTest(np, n,  p, lcln, ucln, lcl $, ucl $, ci $, ci_pct $);
		outargs p, lcln, ucln, lcl, ucl, ci, ci_pct;
		rc = run_macro('__ExactBinomialTest',  np, n,  p, lcln, ucln, lcl, ucl, ci, ci_pct);
	endsub;
run;
options cmplib=work.funcs;


/* Outer Macro: %ExactBinomialTest
	Input parameters:
		inset = data set to input
		countvar = inset column with # of yeses
		ssvar = inset column with sample size
		alpha = 1 - level of significance
		ndecimals = # decimal places

	Return values (returned as columns):
		_p = proportion of yeses (num)
		_lcln = lower confidence limit (num)
		_ucln = upper confidence limit (num)
		_lcl = lower confidence limit (char)
		_ucl = upper confidence limit (char)
		_ci = confidence interval decimals = (lcl, ucl)  (char)
		_ci_pct = confidence interval, percentages = (lcl%, ucl%)  (char)

	Assumptions:
	- Inset is a data set with summary counts: a column for # yeses and a column for sample size
	  - This could be the output of, say, a PROC SQL step
	- No columns in the inset have the same name as any of the return values
*/
%macro ExactBinomialTest(inset, countvar, ssvar, alpha=0.05, ndecimals=1);
	data &inset;
		set &inset;

		/*initialize variables*/
		length _lcl _ucl _ci _ci_pct $50;
		call missing(_p, _lcln, _ucln, _lcl, _ucl, _ci, _ci_pct);
	
		call _ExactBinomialTest(&countvar, &ssvar, _p, _lcln, _ucln, _lcl, _ucl, _ci, _ci_pct);
	run;
%mend ExactBinomialTest;

data test;
	y = 2; n = 10; output;
	y = 0; n = 10; output;
	y = 10; n = 10;	output;
	y = 20; n = 110; output;
run;

%ExactBinomialTest(test, y, n, alpha=0.10, ndecimals=2);



proc print data=&syslast (obs=10);
run;

/*check scope of macro variables*/
%put _user_;
%put _local_;

/*Reference:
	On 'macro function sandwiches'
	https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

	Rationale:
	- FCMP functions don't allow the assigning of default values to parameters
*/
