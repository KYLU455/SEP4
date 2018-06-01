--Queries to insert fake data to use in the NOT FOUND ERROR EXCEPTION
-- and to simulate dimensions that we didnt populate
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
      0,
        'PASS',
        'Passanger',
        'M',
        -1,
        'Unknown',
        SYSDATE,
        'Unknown',
        SYSDATE,
        TO_DATE('31.12.9999', 'dd.mm.yyyy')
      );
      
      
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
      -1,
        '-1-1',
        'this is not a member',
        'M',
        -1,
        'Unknown',
        SYSDATE,
        'Unknown',
        SYSDATE,
        TO_DATE('31.12.9999', 'dd.mm.yyyy')
      );
      
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
      -1,
        '-1-2',
        'this is not a member',
        'M',
        -1,
        'Unknown',
        SYSDATE,
        'Unknown',
        SYSDATE,
        TO_DATE('31.12.9999', 'dd.mm.yyyy')
      );
      
      
      insert into d_age ( id , age ) values ( -1 , 111) ;
      
      insert into d_plane (
      id  ,
	 registration_no   ,     
	 class_name ,
      class_description ,
      has_engine        ,
      number_of_seats    ,
      competition_number  ,
      valid_from        ,
      valid_to )
      values ( 0 , '-1' , '-1' ,'-1' , 'Y' , 1, '-1' , SYSDATE,
        TO_DATE('31.12.9999', 'dd.mm.yyyy') );
        
        insert into d_club (id, name ,region_name, address, zip_code, valid_from, valid_to)
        values ( -1, '-1-1' ,  '-1-1' , '-1-1' ,8700, SYSDATE,
        TO_DATE('31.12.9999', 'dd.mm.yyyy') );
        
        insert into d_launch_method(id, name, cablebreak) values (-1, '-1-1', 'N');
        
        INSERT INTO d_date(id, year, month, day, hour, minute, month_name, day_of_week, season, week_number)
     VALUES
     (sq_date.NEXTVAL, 9999, 12, 31, 23, 59, 'DEC', 'SUN', 'WINTER', 53);
