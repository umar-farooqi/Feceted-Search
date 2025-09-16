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
---========================================================================================================
--3)   phir hm function banaty han ur funcation me hm type ki jga type ur object ki jga object pass krty han 

CREATE OR REPLACE FUNCTION REQ_BANK_STATEMENT (   <-- ye function ka name ha 
    p_org_id IN NUMBER                             <-- ye hm ne p_org_id ko number me promt diya ha 
) RETURN Request_of_bank_statement_TYPE PIPELINED      <-- ye wo type ha jo hm ne uppar bani ha ur ye type object sy data fatch krti ha 
AS
BEGIN
    FOR rec IN (                                           <-- ye loop start ho rhi ha  ur hmri loop ka name ha rec
        WITH OPENING_BALANCE AS (                                                         <<---- yaha sy hmri query start ho rhi ha 
            SELECT
                ACCOUNT_ID,
                TR_DATE AS TRANSCATION_DATE,
                TR_AMOUNT AS OPENING_BALANCE,
                DEPOSIT_AMOUNT AS SECURITY_DEPOSIT
            FROM AB_FIN_TRANSACTION TR
            WHERE TR_TYPE = 625
              AND ORG_ID = p_org_id
              AND STATUS = 'Y'
        ),
        ACCOUNT_NOO AS (
            SELECT DISTINCT
                ASM.ACCOUNT_NUMBER AS ACCOUNT_NO,
                ASM.SR_ID AS ACCOUNT_ID,
                OB.OPENING_BALANCE,
                OB.SECURITY_DEPOSIT
            FROM AB_SETUP_REGISTRATION ASM
            JOIN AB_SETUP_REGISTRATION AST 
                ON AST.SR_ID = ASM.BANK_ID 
               AND AST.REG_TYPE = 'BANK'
            LEFT JOIN AB_SETUP_REGISTRATION ASRC 
                ON ASRC.SR_ID = ASM.COMPANY_ID 
               AND ASRC.REG_TYPE = 'COMPANY'
            LEFT JOIN OPENING_BALANCE OB 
                ON OB.ACCOUNT_ID = ASM.SR_ID
            WHERE ASM.REG_TYPE IN ('BANK LOV','624')
              AND ASM.REG_STATUS = 'Y'
              AND ASM.ORG_ID = p_org_id
        )
        SELECT
            RBS.ID,
            RBS.BANK_NAME,
            RBS.BANK_BRANCH,
            RBS.ACCOUNT_NO AS ACCOUNT_ID,
            AC.ACCOUNT_NO,
            AC.OPENING_BALANCE,
            AC.SECURITY_DEPOSIT,
            RBS.COMPANY_NAME,
            RBS.FROM_DATE,
            RBS.TO_DATES,
            TO_CHAR(RBS.CREATED_ON,'DD-MON-YYYY') || ' - ' || RBS.CREATED_BY AS ADD_BY,
            RBS.CREATED_BY,
            RBS.UPDATED_ON,
            RBS.UPDATED_BY,
            RBS.ORG_ID,
            RBS.STATUS,
            RBS.SUBJECT,
            RBS.AUTHORIZE_NAME,
            RBS.SON_NAME,
            RBS.CNIC,
            RBS.REQUEST_DATE,
            RBS.SUBJECT_DETAIL
        FROM REQUEST_BANK_STATEMENTS RBS
        LEFT JOIN ACCOUNT_NOO AC 
               ON AC.ACCOUNT_ID = RBS.ACCOUNT_NO
        ORDER BY RBS.ID DESC
    ) LOOP                                           <---- yha par loop khatam ho rhi ha  ur agy hm wo column sho karwany waly ha jo object me bi diye hoy han 
        PIPE ROW (
                         Request_of_bank_statement(              <<<--------------   ye hamra wo object ha jo hm ne bana ha ur isi object me wo column diye hoy ha jo hm ne show karwany han
      REC.ID ,
      REC.BANK_NAME ,
      REC.BANK_BRANCH ,
      REC.ACCOUNT_NO ,
      REC.COMPANY_NAME ,
      REC.FROM_DATE,
      REC.TO_DATES ,
      REC.CREATED_BY ,
      REC.UPDATED_ON ,
      REC.UPDATED_BY,
      REC.ORG_ID ,
      REC.STATUS
            )
        );
    END LOOP;

    RETURN;
END;
/

--ye ha object , type ur function   hm function me jo promt pass diya ha wo ha p_org_id       is tarha hmara piplined function banata ha 


---phir agr ap ne esy hi function use krna ha to kr skty han agr is ko package ma add krna ha to ap is ko package me add kr skty han 
-- chaly hm package bi bana lety han 
                                                                 ---- ab hm ne aik package banaye ha -----------------
 create or replace package "AB_REQUEST_STATEMENT" as
  TYPE  Request_of_bank_statement_TYPE IS TABLE  OF Request_of_bank_statement; --<----  ye ham ne pehly type di ha phir hm ne object diya ha  is ka matlb ye ha ke jo object me jo value ha wo type me jay gi

  FUNCTION REQ_BANK_STATEMENT(P_ORG_ID NUMBER) RETURN Request_of_bank_statement_TYPE PIPELINED;  --<<--------- ab hm ne function ka name ur promt idr de diya ha ur ye function phir type return kry ga us type me alredy object ki value aa rhi ha 
end "AB_REQUEST_STATEMENT";
/

-- ab hm pacakge ki body banaey gy 
create or replace package body "AB_REQUEST_STATEMENT" as


FUNCTION REQ_BANK_STATEMENT (
    p_org_id IN NUMBER
) RETURN Request_of_bank_statement_TYPE PIPELINED
AS
BEGIN
    FOR rec IN (
        WITH OPENING_BALANCE AS (
            SELECT
                ACCOUNT_ID,
                TR_DATE AS TRANSCATION_DATE,
                TR_AMOUNT AS OPENING_BALANCE,
                DEPOSIT_AMOUNT AS SECURITY_DEPOSIT
            FROM AB_FIN_TRANSACTION TR
            WHERE TR_TYPE = 625
              AND ORG_ID = p_org_id
              AND STATUS = 'Y'
        ),
        ACCOUNT_NOO AS (
            SELECT DISTINCT
                ASM.ACCOUNT_NUMBER AS ACCOUNT_NO,
                ASM.SR_ID AS ACCOUNT_ID,
                OB.OPENING_BALANCE,
                OB.SECURITY_DEPOSIT
            FROM AB_SETUP_REGISTRATION ASM
            JOIN AB_SETUP_REGISTRATION AST 
                ON AST.SR_ID = ASM.BANK_ID 
               AND AST.REG_TYPE = 'BANK'
            LEFT JOIN AB_SETUP_REGISTRATION ASRC 
                ON ASRC.SR_ID = ASM.COMPANY_ID 
               AND ASRC.REG_TYPE = 'COMPANY'
            LEFT JOIN OPENING_BALANCE OB 
                ON OB.ACCOUNT_ID = ASM.SR_ID
            WHERE ASM.REG_TYPE IN ('BANK LOV','624')
              AND ASM.REG_STATUS = 'Y'
              AND ASM.ORG_ID = p_org_id
        )
        SELECT
            RBS.ID,
            RBS.BANK_NAME,
            RBS.BANK_BRANCH,
            RBS.ACCOUNT_NO AS ACCOUNT_ID,
            AC.ACCOUNT_NO,
            AC.OPENING_BALANCE,
            AC.SECURITY_DEPOSIT,
            RBS.COMPANY_NAME,
            RBS.FROM_DATE,
            RBS.TO_DATES,
            TO_CHAR(RBS.CREATED_ON,'DD-MON-YYYY') || ' - ' || RBS.CREATED_BY AS ADD_BY,
            RBS.CREATED_BY,
            RBS.UPDATED_ON,
            RBS.UPDATED_BY,
            RBS.ORG_ID,
            RBS.STATUS,
            RBS.SUBJECT,
            RBS.AUTHORIZE_NAME,
            RBS.SON_NAME,
            RBS.CNIC,
            RBS.REQUEST_DATE,
            RBS.SUBJECT_DETAIL
        FROM REQUEST_BANK_STATEMENTS RBS
        LEFT JOIN ACCOUNT_NOO AC 
               ON AC.ACCOUNT_ID = RBS.ACCOUNT_NO
        ORDER BY RBS.ID DESC
    ) LOOP
        PIPE ROW (
                         Request_of_bank_statement(
      REC.ID ,
      REC.BANK_NAME ,
      REC.BANK_BRANCH ,
      REC.ACCOUNT_NO ,
      REC.COMPANY_NAME ,
      REC.FROM_DATE,
      REC.TO_DATES ,
      REC.CREATED_BY ,
      REC.UPDATED_ON ,
      REC.UPDATED_BY,
      REC.ORG_ID ,
      REC.STATUS
            )
        );
    END LOOP;

    RETURN;
END;
end "AB_REQUEST_STATEMENT";
/     

---------------------------------------- ye hm ne package ke body bana di ha is me hm ne wo Function add kr diya ha 

---------------  AB HM IS PACKAGE KO CHALA RHY HAN  IS ME WO SARA DATA AYE GA JO HMY CHAYE 

SELECT * 
FROM TABLE(AB_REQUEST_STATEMENT.REQ_BANK_STATEMENT(:GV_ORG_ID));    -- Ab is me pehly package ha ur phir is package me sy jo function ha us ko hm ne get kia hoa ha phir ye jo :GV_ORG_ID HA wo promt ha
--- us ki base par wo data aa rha  
