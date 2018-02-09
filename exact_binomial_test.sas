/* %_ExactBinomialTest:
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
	%if &n eq . %then	%let n = 0;
	%if &alpha eq . %then	%let alpha = 0.05;
	%if &ndecimals eq . %then	%let ndecimals = 1;

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
		tables group / binomial (exact) alpha=0.05;
		output out=_freqout binomial;
	run;
	ods exclude none;

	/*assign return values*/
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
			_ucl     = "NA";
			_ucl_pct = "NA";
		end;
		call symputx('UCL', _ucl);
		call symputx('UCL_PCT', _ucl_pct);

		/*concatenate lower and upper bounds*/
		_ci     = '(' || strip(_lcl) || ', ' || strip(_ucl) || ')';
		_ci_pct = '(' || strip(_lcl_pct) || ', ' || strip(_ucl_pct) || ')';
		call symputx('CI', _ci);
		call symputx('CI_PCT', _ci_pct);
	run;

%mend __ExactBinomialTest;

proc fcmp outlib=work.funcs.pvals;
	subroutine _ExactBinomialTest(np, n,  p, lcl $, ucl $, ci $);
		outargs p, lcl, ucl, ci;
		rc = run_macro('_ExactBinomialTest',  np, n,  p, lcl, ucl, ci);
	endsub;

/*	subroutine ExactBinomialTest_ci(np, n, ci $);*/
/*		outargs ci;*/
/*		rc = run_macro('_ExactBinomialTest', y, n, ci);*/
/*	endsub;*/
/**/
/*	subroutine ExactBinomialTest_ci_pct(np, n, ci_pct $);*/
/*		outargs ci_pct;*/
/*		rc = run_macro('_ExactBinomialTest', np, n, ci_pct);*/
/*	endsub;*/
run;

options cmplib=work.funcs;

data test;
	y = 2; n = 10; output;
	y = 0; n = 10; output;
	y = 10; n = 10;	output;
	y = 20; n = 110; output;
run;

data test;
	set test;
	length lcl ucl ci ci2 ci_pct $50;
	call missing(p, lcl, ucl, ci, ci2, ci_pct);

/*specify # decimal places*/
	call symputx('ndecimals', 2);
	call symputx('alpha', 0.10);

	/*	initialize variables;*/
	call ExactBinomialTest(y, n, p, lcl, ucl, ci);
	call ExactBinomialTest_ci(y, n, ci2);
	call ExactBinomialTest_ci_pct(y, n, ci_pct);
run;


/*Reference:
On 'macro function sandwiches'
https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
*/
