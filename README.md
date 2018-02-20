# atl

Running `R -f run_app.R` will launch a super bare bones Shiny UI with a file upload field, and once an input file is sent, will perform
two checks: 

1) Are zips all 5 characters?
2) Are all cancelled orders ones that were listed as "new"? I dont include currently-in-DB records in this check, which would probably be
logically correct. If I were to do that, depending on dataset scale, I'd either 
  a) (small scale comparison) use dbGetQuery to pull down all of the consumer+item IDs listed as "new" in the DB into R then do the comparison    in R, or
  b) (large scale comparison) load the data into the DB then do the join comparison there.
  I didnt do either of these for expedience.
  
Anyway, if the input file fails one or both checks, appropriate error messages will appear. If both checks pass, `send_to_db.R` gets
executed to copy the input data into the database. I use gzip in case there's a lot of input data.

I wasn't able to get a working local db (possibly due to hardcoded security settings on my computer) and didn't want to burn too much time on it. So code in the shipping-to-db part would work if there were a db to connect to, but as is will throw a connection error when
an input file passes the checks.

test.txt is the sample input you provided, and should pass both checks.
both failtest.txt files are slightly mangled versions of test.txt and should fail one check apiece.