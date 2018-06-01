create or replace directory planesLocation as 'C:\temp'
;
grant read, write on directory  planesLocation to public
;

drop table extClass
;
create table extClass
  (
     type              varchar2(50)
    , class         varchar2(100)
  )
  organization external
  (
     type oracle_loader
     default directory planesLocation
     access parameters
        (
            records delimited by newline
             CHARACTERSET WE8ISO8859P1
      STRING SIZES ARE IN CHARACTERS
                        BADFILE 'class.bad'
    DISCARDFILE 'class.dis'
    LOGFILE 'class.log'    
            fields terminated by ';' optionally enclosed by '"'
         )
  location ('Class.csv')
   )
   ;

select * 
  from extClass
  ;
  
  