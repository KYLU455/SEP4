
/* ----------------------------------------------- */
/* DDL for creating tables for the operational     */
/* systems for the MUU case used in the Data       */
/* Warehousing course at Vitus Bering              */
/*                                                 */
/*------------------------------------------------ */
/* revised, March 2018, BBC, tablespace references */
/*                           removed               */
/* ----------------------------------------------- */

set heading ON;
set feedback ON;


drop table taFlightsVejle;
drop table taFlightsSG70;
drop table taMember;
drop table taClub;
drop table taRegion;


create table taRegion
       (
           Name   varchar2(50)
                  not null
                  constraint coPKtaRegion primary key
       )
;
       
create table taClub
       (
           Mane    varchar2(50)
                   not null
                   constraint coPKtaClub primary key
                 
        ,  Address varchar2(50)
                   not null
                   
        ,  ZipCode char(04)
                   not null
                   
        , Region   varchar2(50)
                   constraint coFKtaClubtaRegion references taRegion
       )
;
       
create table taMember
       (
          MemberNo number(6,0)
                        not null
                        constraint coPKtaMember primary key
                        
        , Initials      char(04)
                        
        , Name          varchar2(50)
                        not null
                        
        , Address       varchar2(50)
                        not null
                        
        , ZipCode       number(4,0)
                        not null
                        
        , DateBorn      date
                        not null
                        
        , DateJoined    date
                        not null
                        
        , DateLeft      date
                        
                        
        , OwnsPlaneReg  char(03)
                        not null
                              
        , StatusStudent  char(01)
                         not null
                         constraint coCHStatusStudent check (StatusStudent in ('Y', 'N'))
                        
        , StatusPilot   char(01)
                        not null
                        constraint coCHStatusPilot check (StatusPilot in ('Y', 'N'))
                        
        , StatusAsCat   char(01)
                        not null
                        constraint coCHStatusErHI check (StatusAsCat in ('Y', 'N'))
                        
        , StatusFullCat char(01)
                        not null
                        constraint coCHStatusFullCat check (StatusFullCat in ('Y', 'N'))
                        
        , Sex           char(01)
                        not null
                        constraint coCHSex check (Sex in ('M', 'F'))
                        
        , Club          varchar2(50)
                        not null
                        constraint coFKtaMemberClub references taClub
       )
;       
       
create table taFlightsVejle
       (
          LaunchTime          date
                              not null
                        
        , LandingTime         date
                        
        , PlaneRegistration  char(03)
                             not null
                          
        , Pilot1Init         char(04)
                             not null
                          
        , Pilot2Init         char(04)
                        
        , LaunchAerotow      char(01)
                             constraint coCHLaunchAerotow check (LaunchAerotow in ('Y' , 'N'))
                           
        , LaunchWinch        char(01)
                             constraint coCHLaunchWinch  check (LaunchWinch in ('Y' , 'N'))
                           
        , LaunchSelfLaunch   char(01)
                             constraint coCHLaunchSelfLaunch check (LaunchSelfLaunch in ('Y' , 'N'))
                           
        , CableBreak        char(01)
                            constraint coCHCableBreak check (CableBreak in ('Y' , 'N'))

                          
        , CrossCountryKM    number(4,0)
                            default 0                  
                          
        , constraint coPKtaFlightsVejle primary key (LaunchTime, LandingTime, PlaneRegistration)  
         
       )
;       
                     
create table taFlightsSG70 as (select *
                                      from taFlightsVejle);
alter table taFlightsSG70
  add  constraint coPKtaFlightsSG70 primary key (LaunchTime, LandingTime, PlaneRegistration)
;                                  

