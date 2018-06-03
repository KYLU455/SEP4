-- ETL FOR F_thermal


-- OPTION 1 : first time run -----do not run this from second time=================================

drop table thermalsYesterday;
create table thermalsYesterday 
as select * from thermalToday where 1=0;

drop table thermalsYesterday;
create table thermalsYesterday 
as select * from thermalToday where 1=0;



-------------------------------------------------
------------------------------------------------
----- IM CHANGING ALL THIS
------------------------------------------------
------------------------------------------------

---------- OPTION 2: TO RUN from the 2nd day================and run from here every day

--Make a copy of all the flights from yesterday
drop table thermalsYesterday;
create table thermalsYesterday 
as select * from thermal;



-- Search for the rows that were not in the yesterday table
DROP TABLE newFlights;

CREATE TABLE newFlights AS
  Select * from taFlights 
  MINUS
  SELECT * from taFlightsYesterday;
  
  
  --Validation of data:
  --We declare variables to save the values for each row in a loop, and some flags to keep the audit updated
declare
  temp_date DATE;
  noOfFixedRows           NUMBER(1)  := 0;
  noOfNewRejectedRows NUMBER (1) := 0;
  row_fixed_flag NUMBER(1) := 0;
  row_deleted_flag NUMBER (1) := 0;
  statusNumber NUMBER :=0;
  currentDate DATE := SYSDATE;
  launchtime1 date;
  landingtime1 date;
  
  --We check all the new flights information
begin

  FOR row IN (SELECT * FROM newFlights)
  LOOP
  
    launchtime1 := row.launchTime;
    landingtime1 := row.landingTime;
  
   /*if the launch time or landing time is in the future, delete flight, set flag for deleted row*/
    if (row.launchTime > currentDate OR row.landingTime > currentDate) THEN 
      delete from newFlights where 
      ( launchTime = row.launchTime AND 
        landingTime = row.landingTime AND
        planeRegistration = row.planeRegistration
        );
      row_deleted_flag := 1; 
    END IF;
	
	/*  we wont take into consideration old flights, and we also have not populated the d_date with
dates less than 2014, so we delete those flights and set the flag	*/
    if (extract(year from row.launchTime)<2014) OR (extract(year from row.landingtime) < 2014) THEN 
      delete from newFlights where 
      ( launchTime = row.launchTime AND 
        landingTime = row.landingTime AND
        planeRegistration = row.planeRegistration
        );
      row_deleted_flag := 1;
     END IF;
	 
	 
    /* If the Landing time is smaller than the launching time we swap the dates and set s flag for fixed*/
	IF (row.launchTime > row.landingTime) THEN
      temp_date := row.launchTime;
      row.launchTime := row.landingTime;
      row.landingTime := temp_date;
      row_fixed_flag := 1;
    END IF;
    

    
    /* If there is no main pilot: */
    IF (row.pilot1init is null or row.pilot1init = '    ' ) THEN
      /*  - If there is Pilot2, put that as Pilot1 and pilot 2 as null*/
      IF (row.pilot2init is not null or row.pilot2init != '    ' ) THEN 
        row.pilot1init := row.pilot2init;
        row.pilot2init := null;
        --if there is not a pilot anywhere set a fake initial cause the flight couldnt happen without a pilot
      else
        row.pilot1init := '%%%%';
      end if;
	  --Set fixed flag
      row_fixed_flag := 1;
    end if;
    
    /*If pilot 1 is also pilot 2, then delete pilot 2, set fixed flag*/
    IF (row.pilot1init = row.pilot2init) THEN
      row.pilot2init := null;
      row_fixed_flag := 1;
    END IF;

    /*If we have a self launching plane but there is a cable break, then set the cable break to N*/
    IF (row.launchselflaunch = 'Y') AND (row.cablebreak = 'Y') THEN
      row.cablebreak := 'N';
      row_fixed_flag := 1;
    END IF;
    
	
	--Update the fixed information for the newFlight
    UPDATE newFlights SET
      launchtime = row.launchTime,
      landingtime = row.landingtime,
      pilot1init = row.pilot1init,
      pilot2init = row.pilot2init,
      launchaerotow = row.launchaerotow,
      launchwinch = row.launchwinch,
      launchselflaunch = row.launchselflaunch,
      cablebreak = row.cablebreak
    where 
      (LaunchTime = launchtime1) AND
      (LandingTime = landingtime1) AND
      (PlaneRegistration = row.PlaneRegistration);
	  
	  
	  --Count the row if it was fixed or deleted 
	  	if row_fixed_flag = 1 then
	noOfFixedRows := noOfFixedRows+1;
	end if;
	  
	  if row_deleted_flag  = 1 then
	 noOfNewRejectedRows := noOfNewRejectedRows+1;
	 end if;
 
	   
  END LOOP;

commit;


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
end;
/


/*Creating a new empty table for the transformed flights with the same columns as newFlights
plus columns for planeRegistration, launchMethodName and duration*/
drop table transformedFlights;

CREATE TABLE transformedFlights AS
  (SELECT launchtime,
      landingtime,
      pilot1init,
      pilot2init,
      cablebreak,
      crosscountrykm,
      club_name
    FROM newFlights where 0=1
  ) ;
  

alter table transformedFlights 
  add (
  planeregistration varchar(10),
    launchMethodName varchar2(20),
	--number (*,2) 2 decimals and the rest of the entire number without points or comas
    duration number (*,2)
  );


/*Loading data into the transformedFlights with the transformed data*/
--declaring variables to use for each row
DECLARE
  tempLaunchMethodName varchar2(20);
  duration number;
BEGIN
  for row in (select * from newFlights) 
  LOOP
  
  --Set the launch method name to the variable
    IF row.launchAerotow = 'Y' THEN
      tempLaunchMethodName := 'Aerotow';
   
    ELSIF row.launchWinch = 'Y' THEN
      tempLaunchMethodName := 'Winch';

    ELSIF row.launchSelfLaunch = 'Y' THEN
      tempLaunchMethodName := 'SelfLaunch';
    ELSE 
      tempLaunchMethodName := 'Unknown';
      row.cablebreak := 'N';
    END IF;
    
    --calculate the duration
    duration := (row.landingTime - row.launchTime) * 24 * 60;
    
	--insert the transformed data
    insert into transformedFlights (
      LAUNCHTIME,
      LANDINGTIME,
      PLANEREGISTRATION,
      PILOT1INIT,
      PILOT2INIT,
      CABLEBREAK,
      CROSSCOUNTRYKM,
      LAUNCHMETHODNAME, 
      DURATION
    ) 
    VALUES (
      row.LAUNCHTIME,
      row.LANDINGTIME,
      
	  --all the planes registration should start with OY and they dont have it in the transformed data
	  -- so we add it ussing 'OY' || (concatenate operator) row.planeregistration 
      (Select 'OY' || row.planeregistration from dual ),
    
      row.PILOT1INIT,
      row.PILOT2INIT,
      row.CABLEBREAK,
      row.CROSSCOUNTRYKM,
      tempLaunchMethodName, 
      duration
    );
    
  END LOOP;
  
  COMMIT;
END;
/

/*Loading the data to the dimension, we declare the variables that we will use in the loops for each row*/
DECLARE
  temp_group_id NUMBER;
  member_id NUMBER;
  member_id2 NUMBER;
  age_id NUMBER;
  age_id2 NUMBER;
  weightTemp NUMBER;
  plane_id NUMBER;
  club_id NUMBER;
  launch_time_id NUMBER;
  landing_time_id NUMBER;
  launch_method_id NUMBER;
  ageTemp NUMBER;
  birthdayTemp DATE;
  
BEGIN
  FOR row IN (SELECT * FROM transformedFlights)
  LOOP
  
-------------------------/*IF THERE IS NO PILOT ONE:*/--------------------------------------------------------
     --SET THE WEIGHT TO 1 BECAUSE THERE IS ONLY ONE PILOT
	 if (row.pilot2init IS NULL or row.pilot2init = '    ') 
     THEN weightTemp :=1;
    
     /*sET GROUP ID*/
  temp_group_id := sq_bridge_mf.nextval;
     
    --SEARCH THE MEMBER ID IN THE MEMEBER DIMENSION WITH THE SAME INITIALS 
	--(CHOOSE THE FIRST RESULT IF THERE IS MORE THAN ONE MEMEBER WITH THE SAME INITIALS)
 BEGIN
    SELECT id into member_id from d_member 
      where initials = row.pilot1init
      FETCH First row only;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
		--IF NO MEMBER WAS FOUND MATCH THE BRIDGE TABLE WITH A FAKE MEMBER 
         select id into member_id from d_member where initials='-1-1';
   END;
   
   
 --search the date when the member with that id is born, and transform it to an age
  select d_member.date_born into birthdayTemp from d_member where d_member.id = member_id;
  -- trunc is the function that allows us to get the months between 2 dates , 
  --we divide by 12 to get the years and 0 is to not have decimals
  select trunc (MONTHS_BETWEEN(sysdate,birthdayTemp)/12,0) into ageTemp
                    from dual;
 
 
 --get the age id from the d_date with the same age value stored in the ageTemp
  BEGIN
    SELECT id into age_id from d_age
      where (age = ageTemp);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into age_id from d_age where age=111;
   END; 
  
  --insert all the transformed and validated values to the bridge table
   insert into b_member_flight (
    group_id,
    pilot_id,
    pilot_age_id,
    weight
   )
   VALUES
   (
      temp_group_id,
      member_id,
      age_id,
      weightTemp
      
   );
   
  
  ----------------------/*IF THERE ARE TWO PILOTS: */----------------------------------------

  --set the weight to 0.5 because there are two pilots and set the group id
  elsif(row.pilot2init IS not NULL or row.pilot2init != '    ') then
    weightTemp := 0.5;
    temp_group_id := sq_bridge_mf.nextval;
        
		--FOR THE FIRST PILOT WE DO THE SAME PROCEDURE AS THE QUERIES BEFORE:
		--SEARCH THE MEMBER ID IN THE MEMEBER DIMENSION WITH THE SAME INITIALS 
	--(CHOOSE THE FIRST RESULT IF THERE IS MORE THAN ONE MEMEBER WITH THE SAME INITIALS)
 BEGIN
    SELECT id into member_id from d_member 
      where initials = row.pilot1init
      FETCH First row only;
	  --IF NO MEMBER WAS FOUND MATCH THE BRIDGE TABLE WITH A FAKE MEMBER 
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         select id into member_id from d_member where initials='-1-1';
   END;
   
   --search the date when the member with that id is born, and transform it to an age
  select d_member.date_born into birthdayTemp from d_member where d_member.id = member_id;
  -- trunc is the function that allows us to get the months between 2 dates , 
  --we divide by 12 to get the years and 0 is to not have decimals
  select trunc (MONTHS_BETWEEN(sysdate,birthdayTemp)/12,0) into ageTemp
                    from dual;
            
--get the age id from the d_date with the same age value stored in the ageTemp			
    BEGIN
      SELECT id into age_id from d_age
      where (age = ageTemp);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into age_id from d_age where age=111;
    END;
       

	   --REPEAT THE SAME PROCEDURE FOR PILOT 2 
    BEGIN
      SELECT id into member_id2 from D_member 
      where (initials = row.pilot2init) 
      FETCH First 1 rows only;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into member_id2 from d_member where initials='-1-2';
      
    END;
    
     select d_member.date_born into birthdayTemp from d_member where d_member.id = member_id2;
  -- trunc is the function that allows us to get the months between 2 dates , 
  --we divide by 12 to get the years and 0 is to not have decimals
  select trunc (MONTHS_BETWEEN(sysdate,birthdayTemp)/12,0) into ageTemp
                    from dual;

    BEGIN
      SELECT id into age_id2 from d_age
      where (age = ageTemp);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          select id into age_id2 from d_age where age=111;
    END;  

  --INSERT THE VALUES FOR THE FIRST PILOT (PILOT 2 WILL HAVE THE SAME GROUP_ID CAUSE ITS STORED LOCALLY)
   -- AND THEY ARE IN THE SAME FLIGHT)
   insert into B_MEMBER_FLIGHT (
   group_id,
    pilot_id,
    pilot_age_id,
    weight
   )
   VALUES
   (
      temp_group_id,
      member_id,
      age_id,
      weightTemp
      
   );    
   --INSERT THE VALUES FOR THE SECOND PILOT (PILOT 2 WILL HAVE THE SAME GROUP_ID CAUSE ITS STORED LOCALLY
  -- AND THEY ARE IN THE SAME FLIGHT)
   insert into B_MEMBER_FLIGHT (
   group_id,
    pilot_id,
    pilot_age_id,
    weight
   )
   VALUES
   (
      temp_group_id,
      member_id2,
      age_id2,
      weightTemp
      
   );    
   /*Done handling the group_id and inserting pilots info into the bridge table*/
end if;


--CONTINUING WITH THE REST OF THE INFORMATION FOR THE D_FLIGHT TABLE
/*SEARCHING FOR THE THE PLANE_ID IN D_PLANE*/
   BEGIN
     select id into plane_id from d_plane 
      where registration_no = row.planeregistration ;
      EXCEPTION
        When NO_DATA_FOUND THEN
		--we havent populated the d_plane so we just inserted a fake one manually
          select id into plane_id from d_plane where registration_no = '-1';
   END; 
    
    /*HANDLING CLUB_ID*/
    BEGIN
      select id into club_id from d_club
      where name= row.club_name;
      EXCEPTION
        When NO_DATA_FOUND THEN 
		--we havent populated the d_club so we just inserted a fake one manually
          select id into club_id from d_club where name='-1-1';
    END;
    
    /*SEARCHING FOR THE Launch_time_id from the date*/
    begin
    select id into launch_time_id from d_date
      where (
        year = extract (year from row.launchtime) AND
        month = extract (month from row.launchtime) AND
        day = extract (day from row.launchtime) AND
        hour = to_number(to_char(row.launchtime,'HH24'),'00') AND
        minute = to_number(to_char(row.launchtime,'MI'),'00')
      );
      
       EXCEPTION
        When NO_DATA_FOUND THEN 
		select id into launch_time_id from d_date where year=9999;
      
      end;
    
	/*SEARCHING FOR THE Landing_time_id from the date*/
    begin
    select id into landing_time_id from d_date
      where (
        year = extract (year from row.landingtime) AND
        month = extract (month from row.landingtime) AND
        day = extract (day from row.landingtime) AND
        hour = to_number(to_char(row.landingtime,'HH24'),'00') AND
        minute = to_number(to_char(row.landingtime,'MI'),'00')
      );
         EXCEPTION
        When NO_DATA_FOUND THEN 
          select id into landing_time_id from d_date where year=9999;
      
      end;
      
      /*Searching for the launch_method_id with the same method name and cablebreak info*/
     begin
      select id into launch_method_id from d_launch_method 
        where name = row.launchmethodname and cablebreak = row.cablebreak;
		--we havent populated the d_launch_method so we just inserted a fake one manually
          EXCEPTION
        When NO_DATA_FOUND THEN 
          select id into launch_method_id from d_launch_method where name='-1-1';
      end;
        
		
---------------FINALLY LOADING THE DATA TO F_FLIGHT WITH ALL THE TRANSFORMED VALUES----------------------
      insert into f_flight 
      (
        launch_time_id,
        landing_time_id,
        launch_method_id,
        plane_id,
        club_id,
        group_id,
        distance,
        duration
      ) VALUES
      (
        launch_time_id,
        landing_time_id,
        launch_method_id,
        plane_id,
        club_id,
        temp_group_id,
  
        row.crosscountrykm,
        row.duration
      );

   
  END LOOP;
  commit;
END;
--The end :)

