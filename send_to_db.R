library(yaml) 
library(RJDBC)

#keep username/password etc out of the code itself
pcreds <- yaml.load_file('postgres_creds.yaml')

#connect to db
pDriver <- JDBC(driverClass="org.postgresql.Driver", classPath=pcreds$class_path)
testdb <- dbConnect(pDriver, paste("jdbc:postgresql://",pcreds$host,":",5432,"/",'db7mu5sbessiq1',"?user=",pcreds$user_name,"&password=",pcreds$password,"&ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory" , sep = '') )

dbSendUpdate(testdb,"
  create table if not exists my_schema.customer_records_raw (
    customer_id int,
    first_name varchar,
    last_name varchar,
    address varchar,
    state varchar(2),
    zip varchar(5),
    purchase_status varchar,
    product_id int,
    product_name varchar,
    purchase_amount numeric(12,2), --only allow two digits after decimal
    date_time timestamp
  )")

dbSendUpdate(testdb, "
  copy my_schema.customer_records_raw
  from local 'loadme.txt.gz'
  gzip
  delimiter E'\t' 
  exceptions 'exceptions.txt'")


