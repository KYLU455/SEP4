/* --------------------------------------------------- */
/*   ETLMemberExtract                                  */
/* --------------------------------------------------- */
/* extracts added, deleted and changed rows from the   */
/* members table + members who have a birthday on the  */
/* current date (since this represents a change of     */
/* age                                                 */
/*                                                     */
/* --------------------------------------------------- */

/* --------------------------------------------------- */
/*  Note                                
/* --------------------------------------------------- */
/* there is no age column in our d_member, it is 
/* a different dimension, because d_member is
/*  a slowly changing dimension (type-2 processing).
/* the age causes the member to change at least once
/* every year and we avoid this using the minidimension d_Age*/
/*                                                     */
/* --------------------------------------------------- */

--OPTION 1: (FIRST TIME) The following queries are to create the memberToday and 
--memberYesterday tables for the first time

/*Create table with the current members information*/
DROP TABLE memberToday;
CREATE TABLE memberToday AS
SELECT 
    memberNo        AS      member_number,
    initials,
    name,
    sex, 
    zipcode         AS      zip_code,
    address,
    dateborn        AS      date_born,
    StatusStudent, 
    StatusPilot, 
    StatusAscat, 
    StatusFullcat
FROM taMember;

/* Creating a yesterday table WHERE 1 = 0 used to create a table of identical structure, without data*/
/*because the first day of populating data will be considered as today and there is no yesterday*/
drop table memberYesterday;
create table memberYesterday 
as select * from memberToday where 1=0;



-- --------------------------------------------
-- pre-extract report
-- --------------------------------------------

--OPTION 2: The following queries are to USE FROM THE SECOND DAY - NOT FIRST TIME
/*Procedure to make before extracting on each day  
1. Delete yesterday's yesterday table and fill it with yesterday's today table
*/
drop table memberYesterday;
create table memberYesterday 
as select * from memberToday;

/*2. Delete yesterday's today table and update today table*/
DROP TABLE memberToday;
CREATE TABLE memberToday AS
SELECT 
    memberNo        AS      member_number,
    initials,
    name,
    sex, 
    zipcode         AS      zip_code,
    address,
    dateborn        AS      date_born,
    StatusStudent, 
    StatusPilot, 
    StatusAscat, 
    StatusFullcat
FROM taMember;

/*Empty the ETLMembersExtractTable*/
drop table ETLMembersExtract;
create table ETLMembersExtract 
as select * from memberToday where 1=0;


--Make a pre-extract report
select 'Extract Members at: ' || to_char(sysdate,'YYYY-MM-DD HH24:MI') as extractTime
  from dual
  ;

  select 'Row counts before: '
    from dual
union all
  select 'Rows in extract table before (should be zero)' || to_char(count(*))
   from ETLMembersExtract
union all
  select 'Rows in Members table ' || to_char(count(*))
   from taMember
union all
  select 'Rows in Members table (yesterday copy) ' || to_char(count(*))
   from memberYesterday
 ;



-- --------------------------------------------
-- extract procedure
-- --------------------------------------------

-- **** here goes the extract of added rows 
-- **** (i.e. rows from today whose primary key is in the set of (PKs from today minus PKs yesterday)
/*Create NEW  - all the rows that haven't been there Yesterday*/
DROP TABLE newMember;
CREATE TABLE newMember AS
    SELECT *
    FROM memberToday
    WHERE memberToday.member_number NOT IN
  ( SELECT member_number FROM memberYesterday);


-- **** here goes the extract of deleted rows 
-- **** (i.e. rows from yesterday whose primary key is in the set of (PKs from yesterday minus PKs today)
/*Create DELETE - all the rows that have been deleted since yesterday*/
DROP TABLE deletedMember;
CREATE TABLE deletedMember AS
    SELECT *
    FROM memberYesterday
    WHERE memberYesterday.member_number NOT IN
  ( SELECT member_number FROM memberToday);


-- **** here goes the extract of changed rows 
-- **** (i.e. (rows from today minus rows from yesterday) - new rows )
/*Create Changed - all the rows that have been changed */
DROP TABLE alteredMember;
CREATE TABLE alteredMember AS
    SELECT * FROM memberToday
    MINUS
    SELECT * FROM memberYesterday
    MINUS
    SELECT * FROM newMember;

-- **** here goes the extract of Members whose age changed (i.e. those who have a birthday today) 
-- **** (i.e. (rows from today with dateBorn(DDMM) = current date(DDMM) - already extracted PKs)
DROP TABLE newAgeMember;
CREATE TABLE newAgeMember AS
    SELECT * FROM memberToday where TO_CHAR
    (date_born, 'DDMM') = TO_CHAR(SYSDATE, 'DDMM')
    MINUS
    SELECT * FROM memberYesterday
    MINUS
    SELECT * FROM newMember;

-- insert in ETLextract to see the extracted new,changed and deleted rows

INSERT INTO  ETLMembersExtract
SELECT * FROM newMember;
INSERT INTO  ETLMembersExtract
SELECT * FROM deletedMember;
INSERT INTO  ETLMembersExtract
SELECT * FROM alteredMember;
INSERT INTO  ETLMembersExtract
SELECT * FROM NewAgeMember;

commit;


-- --------------------------------------------
-- post-extract report
-- --------------------------------------------

select 'Rows in extract table after'
 from dual
;

select  count(*)
from ETLMembersExtract
 ; 
 select * from ETLMembersExtract;
 
 -------==============--TRANSFORMATION--============================
 
 
 /*Validation part*/
 
 /*We declare variables to count all the fixed and rejected rows plus some flags or booleans
 that will help us decide if we need to count or ignore the rows*/
DECLARE
  noOfFixedRows           NUMBER(1)  := 0;
  flagForFixedRows        NUMBER(1)  :=0;
  noOfNewRejectedRows     NUMBER (1) := 0;
  noOfAlteredRejectedRows NUMBER (1) := 0;
  isCorrectZipcode                NUMBER (5, 0) := 0;
BEGIN
  /*Search for rows that have null for member number, name or initials and reject them*/
  --Search in newMembers table,  save the number in variable and delete those rows
  SELECT COUNT(*)
  INTO noOfNewRejectedRows
  FROM newMember
  WHERE member_number IS NULL OR name IS NULL OR initials IS NULL;
  DELETE FROM newMember WHERE member_number IS NULL OR name IS NULL OR initials IS NULL;

  --Search in alteredMembers table, save the number in variable and delete those rows
  SELECT COUNT(*)
  INTO noOfAlteredRejectedRows
  FROM alteredMember
  WHERE member_number IS NULL OR name IS NULL OR initials IS NULL;
  DELETE FROM alteredMember WHERE member_number IS NULL OR name IS NULL OR initials IS NULL;

  /*Summarizing both rejected results (total deleted rows)*/
  noOfNewRejectedRows       := noOfNewRejectedRows + noOfAlteredRejectedRows;

  
  /* Fix other columns in the rest of the rows */
  
  /*Starting with newMembers, check all rows*/
  FOR row IN
  (SELECT * FROM newMember
  )
  LOOP
  /*set the variable of fixed Rows to 0 for each row checked*/
    flagForFixedRows := 0;
   
   /*Fix invalid zip_code*/
  --We have saved all the valid Danish zip-codes in a table called dk_zipcodes
--the DDL and populating of the table is attached in this project  
    SELECT count(zipcode)
    INTO isCorrectZipcode
    FROM dk_zipcodes
    WHERE zipcode = row.zip_code;
    --we check every row, if the zipcode is correct, 
-- if the zipcode matches a valid one then isCorrectZipCode will have
-- the value of 1. If it is not a valid zipcode, the count(and isCorrectZipCode) will be 0	
--if it is 0, then the zip code is not valid, so we set a flag and we set the zipcode to -1
    IF isCorrectZipcode       = 0 THEN
       flagForFixedRows := 1;
       row.zip_code := -1;
    END IF;

    /*We fix address null with a string called unknown*/
    If row.address IS NULL THEN
        flagForFixedRows := 1;
        row.address := 'Unknown';
    END IF;

    /*Fix date born; if the date is in the future we set the date to 0000/00/00*/
    IF row.date_born >= SYSDATE THEN
        flagForFixedRows := 1;
        row.date_born := TO_DATE('0000/00/00', 'YYYY/MM/DD');
    END IF;
	
    /*We update the current row in newMember*/
    UPDATE newMember
    SET zip_code            = row.zip_code,
      address       = row.address,
      date_born              = row.date_born
    WHERE member_number = row.member_number;
	
	/*Update the numberOfFixedRows if this row was fixed*/
	if flagForFixedRows = 1 then
	noOfFixedRows := noOfFixedRows+1;
	end if;
  END LOOP;

  /* now we checked the alteredMember table and 
  make the same validation of zip_code, address and date_born*/
  FOR row IN
  (SELECT * FROM alteredMember
  )
  LOOP
    flagForFixedRows := 0;
     /*Fix invalid zip_code*/
    SELECT count(zipcode)
    INTO isCorrectZipcode
    FROM dk_zipcodes
    WHERE zipcode = to_number(row.zip_code);
    IF isCorrectZipcode       = 0 THEN
       flagForFixedRows := 1;
       row.zip_code := -1;
    END IF;

    /*Fix address null*/
    If row.address IS NULL THEN
        flagForFixedRows := 1;
        row.address := 'Unknown';
    END IF;

    /*Fix date born*/
    IF row.date_born >= SYSDATE THEN
        flagForFixedRows := 1;
        row.date_born := TO_DATE('0000/00/00', 'YYYY/MM/DD');
    END IF;
    /*Update current row in newMember*/
    UPDATE alteredMember
    SET zip_code            = row.zip_code,
      address       = row.address,
      date_born              = row.date_born
    WHERE member_number = row.member_number;
	
	/*Update the numberOfFixedRows if this row was fixed*/
	if flagForFixedRows = 1 then
	noOfFixedRows := noOfFixedRows+1;
	end if;
	
END LOOP;


  /*Insert the counts for rejected and fixed rows in the audit*/
  INSERT
  INTO d_audit
    (
      id,
      audit_date,
      member_rejected,
      member_fixed
    )
    VALUES
    (
      sq_audit.nextval,
      SYSDATE,
      noOfNewRejectedRows,
      noOfFixedRows
    );
  COMMIT;
END;
/

/*-----------Transformation for the member status------------*/
/*Creating a new table for the transformed member for both new and altered*/
drop table transformedNewMember;
CREATE TABLE transformedNewMember AS 
    (SELECT member_number, 
            initials, 
            name, 
            sex, 
            zip_code, 
            address, 
            date_born 
        FROM newMember where 0=1
    );

	--add the status column to the new members
alter table transformedNewMember 
  add (
    status varchar2(20)
  );

drop table transformedAlteredMember;
CREATE TABLE transformedAlteredMember AS 
    (SELECT * 
        FROM transformedNewMember where 0=1
    );
    
------=============================================================----------

/*Load data into the transformedFlights tables with transformed data*/
/*the status is changed to only one column with the status name*/
DECLARE
  tempStatusName varchar2(20);
BEGIN
    /* transform all the rows newmember, set status */
  for row in (select * from newMember) 
  LOOP
    IF row.StatusFullcat = 'Y' THEN
        tempStatusName := 'Fullcat';
    ELSIF row.StatusAscat = 'Y' THEN
        tempStatusName := 'Ascat';
    ELSIF row.StatusPilot = 'Y' THEN
        tempStatusName := 'Pilot';
    ELSE
        tempStatusName := 'Student';
    END IF;

	--insert validated information plus the status name
    INSERT INTO transformedNewMember (
        member_number, 
        initials, 
        name, 
        sex, 
        zip_code, 
        address, 
        date_born,
        status
    )
    VALUES (
        row.member_number, 
        row.initials, 
        row.name, 
        row.sex, 
        row.zip_code, 
        row.address, 
        row.date_born,
        tempStatusName
    );
  END LOOP;
  
  
    /*the same transformation is made for alteredmember */
    
    for row in (select * from alteredMember) 
  LOOP
    IF row.StatusFullcat = 'Y' THEN
        tempStatusName := 'Fullcat';
    ELSIF row.StatusAscat = 'Y' THEN
        tempStatusName := 'Ascat';
    ELSIF row.StatusPilot = 'Y' THEN
        tempStatusName := 'Pilot';
    ELSE
        tempStatusName := 'Student';
    END IF;

    INSERT INTO transformedAlteredMember (
        member_number, 
        initials, 
        name, 
        sex, 
        zip_code, 
        address, 
        date_born,
        status
    )
    VALUES (
        row.member_number, 
        row.initials, 
        row.name, 
        row.sex, 
        row.zip_code, 
        row.address, 
        row.date_born,
        tempStatusName
    );
  END LOOP;
  COMMIT;
END;
/
--========================================================================
/*Now the information has been transformed and it is ready to be added to the dimension d_member*/
/*Starting with the transformedNewMembers, we set an end-date,
the end-date stablished until when this dimension is valid but the member information
can be used for many purposes so we set is as the end of time (31.12.9999)*/
DECLARE
  end_date DATE;
BEGIN
  SELECT TO_DATE('31.12.9999', 'dd.mm.yyyy')
  INTO end_date
  FROM dual;
  
  FOR row IN
  (SELECT * FROM transformedNewMember
  )
  LOOP
  
  --for each member we insert all the transformed information,
  -- a valid_from date which is the date when the ETL is done,
  --and en end date which is the end of time as mentioned before
    INSERT
    INTO d_member
      (
        id,
        member_no,
        initials,
        name,
        sex,
        zip_code,
        address,
        date_born,
        status,
        valid_from,
        valid_to
      )
      VALUES
      (
       sq_member.nextval,
        row.member_number,
        row.initials,
        row.name,
        row.sex,
        row.zip_code,
        row.address,
        row.date_born,
        row.status,
        SYSDATE,
        end_date
      );
  END LOOP;
  
  /*The same procedure is done for the altered members with an exception in the dates*/
  FOR row IN
  (SELECT * FROM transformedAlteredMember
  )
  LOOP
   
    /*We set the valit_to to today because it is the date when the information was changed,
	we keep that row but it is an old information which help us keep track of changes
	over time*/
	/*We set the end_date to the end of time, until the member is altered again*/
    UPDATE d_member
    SET valid_to      = SYSDATE
   WHERE member_no = row.member_number
    AND valid_to      = end_date;
    /*Insert the new row into d_member*/
    INSERT
    INTO d_member
      (
        id,
        member_no,
        initials,
        name,
        sex,
        zip_code,
        address,
        date_born,
        status,
        valid_from,
        valid_to
      )
      VALUES
      (
        sq_member.nextval,
       row.member_number,
        row.initials,
        row.name,
        row.sex,
        row.zip_code,
        row.address,
        row.date_born,
        row.status,
        SYSDATE,
        end_date
      );
  END LOOP;
  
  
  
  /*For the deleted members we search them in the d_member dimension and
  set their end_date to today (no longer valid)*/
  FOR row IN
  (SELECT * FROM deletedMember
  )
  LOOP
    /*Update member for existing row*/
    UPDATE d_member
    SET valid_to      = SYSDATE
     WHERE member_no = row.member_number
    AND valid_to      = end_date;
  END LOOP;
  
  COMMIT;
END;
/
