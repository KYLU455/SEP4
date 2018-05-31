----------------------------------------------------------------------
------------------------ QUERIES FOR THE TESTS!!! --------------------------------------
-----------------------------------------------------------------------------

insert into taMember (MemberNo, Initials, name, address, zipcode,
 dateBorn, dateJoined, dateLeft, ownsPlaneReg, statusStudent, statusPilot, 
 statusAsCat, statusFullCat, sex, club ) 
 values(    510 , 'dwhg' , 'data ' , 'Horsens' ,  8700 , 
 to_date('1991-07-13','YYYY-MM-DD') , to_date('2013-07-26','YYYY-MM-DD') ,
 to_date('2016-01-28','YYYY-MM-DD') , '   ' , 'N' , 'N' , 'N' , 'Y' , 'F' , 'Vejle' );


update tamember 
set name = 'warehousing'
 where memberno = 510;




delete tamember where MemberNo = 510;


insert into taFlightsSG70 (launchTime, landingTime, planeRegistration, pilot1Init, pilot2Init,
launchAerotow, launchWinch,launchSelfLaunch, cableBreak, CrossCountryKm)  values 
( to_date('2018-04-29 11:31', 'YYYY-MM-DD HH24:MI' ) ,  to_date('2018-04-29 17:58', 'YYYY-MM-DD HH24:MI' ) ,
'DWH' , 'DIDI' , '    ' , 'Y' , 'N' , 'N' , 'N' ,  464);


insert into taFlightsSG70 (launchTime, landingTime, planeRegistration, pilot1Init, pilot2Init,
launchAerotow, launchWinch,launchSelfLaunch, cableBreak, CrossCountryKm)  values 
( to_date('2017-06-17 12:02', 'YYYY-MM-DD HH24:MI' ) ,  to_date('2017-06-17 16:04', 'YYYY-MM-DD HH24:MI' )
, 'DAM' , 'DADA' , 'MJFF' , 'N' , 'N' , 'Y' , 'N' ,    0);



delete from taFlightsSG70 where launchTime = to_date('2017-06-17 12:02', 'YYYY-MM-DD HH24:MI' )  and
landingTime = to_date('2017-06-17 16:04', 'YYYY-MM-DD HH24:MI' ) and planeRegistration = 'DAM';


delete from taFlightsSG70 where launchTime =  to_date('2018-04-29 11:31', 'YYYY-MM-DD HH24:MI' )  and
landingTime = to_date('2018-04-29 17:58', 'YYYY-MM-DD HH24:MI' ) and planeRegistration = 'DWH';



insert into taFlightsSG70 (launchTime, landingTime, planeRegistration, pilot1Init, pilot2Init,
launchAerotow, launchWinch,launchSelfLaunch, cableBreak, CrossCountryKm)  values 
( to_date('2017-06-17 12:02', 'YYYY-MM-DD HH24:MI' ) ,  to_date('2017-06-17 16:04', 'YYYY-MM-DD HH24:MI' )
, 'YYY' , '    ' , 'MJFF' , 'N' , 'N' , 'Y' , 'N' ,    0);

insert into taFlightsSG70 (launchTime, landingTime, planeRegistration, pilot1Init, pilot2Init,
launchAerotow, launchWinch,launchSelfLaunch, cableBreak, CrossCountryKm)  values 
( to_date('2017-06-17 12:02', 'YYYY-MM-DD HH24:MI' ) ,  to_date('2017-06-17 16:04', 'YYYY-MM-DD HH24:MI' )
, NULL , '    ' , 'MJFF' , 'N' , 'N' , 'Y' , 'N' ,    0);

    insert into taMember (MemberNo, Initials, name, address, zipcode, dateBorn, dateJoined, dateLeft, ownsPlaneReg, 
statusStudent, statusPilot, statusAsCat, statusFullCat, sex, club ) values(    
999 , null , 'null' , 'Horsens' ,  8700 , to_date('1991-07-13','YYYY-MM-DD') ,
to_date('2013-07-26','YYYY-MM-DD') , to_date('2016-01-28','YYYY-MM-DD') , '   ' , 'N' , 'N' , 'N' , 'Y' , 'F' , 'Vejle' );
  
   
