-- 1) sab sy pehly hm object banaty han ur is project me query ke wo sary column hoty hn jo hm nay show karwany hoty han 

create or replace TYPE Request_of_bank_statement AS OBJECT (
      id number,
      BANK_NAME varchar(100),
      BANK_BRANCH VARCHAR2(100),
      ACCOUNT_NO NUMBER,
   
      COMPANY_NAME VARCHAR2(100),
      FROM_DATE date,
      TO_DATES date,
      CREATED_BY varchar2(100),
      UPDATED_ON date,
      UPDATED_BY varchar2(100),
      ORG_ID number,
      STATUS varchar2(10)
);

-- 2) us ke baad hm type banaty han  us type me pehly hm type ur phir object dety hn , is ki wja sy ye ke wo type jo hm ne banai ha wo object me sy data fatch krti ha 

create or replace TYPE  Request_of_bank_statement_TYPE AS TABLE  OF Request_of_bank_statement
