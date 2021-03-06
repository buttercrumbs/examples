
/ \\ exit q process
/ \  enter k language or exit one layer of the debugger
/ \  in a file it means end of a multiline comment
/ no operator precedence, right to left evalution
/ : for assignment and = for equality test
/ strings are char lists
/ for function params and invokation use brackets( may be optional) [a ; b ; c ]
/ ; also used to separate blocks of evaluation and mixed-list item separator when inside parens ()
/ , can be used to join lists run below statements and check the output
/ -16!x gives refcount for x
/ 0N!x would print x and evaluate to x, useful for debugging
(1,2,(2 3))
(1,2;(2 3))
(1;2,(2;3))
(1;2;(2;3))


/ % division, & min, | max 
/ n# to get |n| items from list
/ n?X to get rand till X or from X if X is a list or from whole range if X is 0i , -ve n means without replacement
/ for char random data use n?0Nc - 0Nc is null char
/ v set val - dynamially assign, value of v is a symbol , get v returns the value of the variable whose name is value of v


/io 0-STDIN, 1-STDOUT , 2-STDERR
1 "Hello World!"
-1 "Automatic newlines"


/Genarate Random Data
/ \l /Users/pooja/q/kdb/stat.q
/ t can be replaced by delta of intervals
gbm:{[s;r;t;z] exp(t*r-0.5*s*s) + z*s*sqrt(t)}
bm:{[s;r;t;z] 1+(t*r) + z*s*sqrt(t) }




pi:acos -1

/ normal from x
nx:{abs(x>0)-(exp[-.5*x*x]%sqrt 2*pi)*t*.31938153+t*-.356563782+t*1.781477937+t*-1.821255978+1.330274429*t:1%1+.2316419*abs x}

/ x from normal  (chebychev near 0.5 and log for the tails)
xn:{$[.5>x;0-.z.s 1-x;.92>x;
 (x*2.50662823884+l*-18.61500062529+l*41.39119773534+l*-25.44106049637)%1+l*-8.47351093090+l*23.08336743743+l*-21.06224101826+3.13082909833*l:x*x-:.5;
 0.3374754822726147+l*0.9761690190917186+l*0.1607979714918209+l*0.0276438810333863+l*0.0038405729373609+l*0.0003951896511919+l*0.0000321767881768+l*0.0000002888167364+0.0000003960315187*l:log 0-log 1-x]}

/ random normal distribution, e.g. nor 10
nor:{$[x=2*n:x div 2;raze sqrt[-2*log n?1f]*/:(sin;cos)@\:(2*pi)*n?1f;-1_.z.s 1+x]}

/ builtins: avg var dev med wavg cov cor avgs
mode:{where g=max g:count each group x}

/ covariance matrix (8 times faster than x cov/:\:x)
cvm:{(x+flip(not n=\:n)*x:(n#'0.0),'(x$/:'(n:til count x)_\:x)%count first x)-a*\:a:avg each x}

/ correlation matrix
crm:{cvm[x]%u*/:u:dev each x}

/ quantile of y using method z with percents x
/ qtln[0.9 0.99;til 10; 8]
/ implements method 4 to 9 from https://stat.ethz.ch/R-manual/R-devel/library/stats/html/quantile.html
qtln:{[x;y;z]cf:(0 1;1%2 2;0 0;1 1;1%3 3;3%8 8) z-4;n:count y:asc y;
    ?[hf<1;first y;last y]^y[hf-1]+(h-hf)*y[hf]-y -1+hf:floor h:cf[0]+x*n+1f-sum cf}

/ default quantile using method 8
qtl:qtln[;;8]

/ interquartile range using method 8 for approximation (n.b. R uses method 7 by default)
iqr:{last deltas qtl[0.25 0.75;x]}
100*prds gbm [0.2;0.3;1%252] nor 252

/ Weekdays
/ 2001.01.01 staturday is 0i
wdays:{x where (x mod 7)>1 }
wdays reverse 2019.05.29-(til 1+2019.05.29 - 2019.01.01)


/time intervals
/-16h is timespan, z.z current time .z.Z current time GMT
/0D1 or 0D01 is 1 hour timespan
"i"$10:00
"i"$10:00:00
"i"$10:00:00.000
"j"$10:00:00.000000
type 10:00:00.000000
type 0D

/arithmatic sequqnce/progression
aseq:{[s;d;e] s+d*til ceiling (e-s)%d  }

/function application
3 ~ {x+y} [1;2]
3 ~ {x+y} . 1 2
not 3 ~ {x+y} 1 2 
add12 : {x+y} 1 2 
4 6 ~ add12 3 4

/rounding - multiply truncate and divide
/ for round to 0.01 - 2 decimals multiply by 100 convert to long/int and divide by 100
/ used "type"$x for casting
round:{x*"j"$y%x}

/price generation 30% vol, 20% drift
dates:aseq[2019.01.01;1;2020.01.01]
/dates:wdays dates
show diffs:deltas[first dates;dates]
f:{prd gbm[0.2;0.2;1%365] nor 365}
g:{prd  bm[0.2;0.2;1%365] nor count dates}
f1:{prd  gbm[0.2;0.2;1%252] nor 252}
g1:{sum  1-bm[0.2;0.2;1%365] nor count dates}
0.247%0.2
sdev each[f1] til 100000
sdev each[g1] til 100000

/dictionaty
/many operations that work on scalars also work on dict values like n#d,d+1,sum d etc.
/cow semantics, d:k!v and d is modified then v is not modified, instead a copy of v would be created
/joining two dicts d:d1,d2 may cause dupe keys, only first one if retreived when you use d[k]
show d:(1 2 3)!(3 4 5)
key d
value d
l:(("a",1);("b",2 );("c","4"))      /from list of pairs - pair is a list of 2 items
fl:flip l
(fl 0)! fl 1
d:(!) . (flip l) /flip l contains 2 items(which are passed to !, see the dot operator ), each is a list of 3 items
d "a"
d["a"]
d["?"]



/ simple trades table
n:1000
prices:(1+n?0.03)*100
sizes:(1+n?100)*100
times : 09:30:00.000 + n?(16:00:00 - 09:30:00)
trades:([] price:prices ; size:sizes ; time:times)

/simple bids table
n:100
bid : (1+n?0.03)*100-0.2
ask : bid+0.4
/dates:   n?2019.01.01 + til n
times : 09:30:00.000 + n?(16:00:00 - 09:30:00)


quotes:([] bid:bid; ask:ask ; time:times)



trades:`time xasc trades
quotes:`time xasc quotes


(tables[])


x:"'((",(") (" sv{("\"",(string x),"\"")," (\"",("\" \""sv string cols x),"\")"} each  tables[]),"))"
t:1 x

'("p" ("p" "name" "color" "weight" "city")) ("s" ("s" "name" "status" "city")) ("sp" ("s" "p" "qty"))



(defun keep-output (process output)

 (insert  output 
 ))

(set-process-filter (get-process "q") 'keep-output)
(set-process-filter (get-process "q") nil)

(defun keep-output (process output)
        (setq kept (cons output kept)))

     (setq kept nil)
          ⇒ nil

          ⇒ keep-output




