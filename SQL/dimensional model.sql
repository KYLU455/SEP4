drop table D_Date_Time;
drop table d_audit;
drop table b_passengers;
drop table f_club_membership;
drop table f_ownership;
drop table f_flight;
drop table d_person;
drop table d_plane;
drop table d_club;
drop sequence sq_audit;
drop sequence sq_person;

CREATE SEQUENCE sq_person START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table d_person(
  id int not null constraint co_pk_d_person primary key,
  name varchar(30) not null,
  sex char(1) not null constraint co_ch_f_person_sex check(sex in ('M', 'F')),
  age number not null,
  address varchar(50) not null,
  zip_code number (4,0) not null,
  status varchar (10) constraint co_ch_status check(status in ('student','pilot','cat','fullcat', 'not pilot')),
  valid_from date not null,
  valit_to date not null
) pctfree 0;

create table d_plane(
  plane_registration varchar(3) not null constraint co_pk_d_plane primary key,
  model varchar (30),
  number_of_seats int,
  has_engine char(1) constraint co_ch_has_engine check (has_engine in ('Y','N')),
  valid_from date not null,
  valit_to date not null
) pctfree 0;

create table d_club(
  club_name varchar (30) not null constraint co_pk_club_name primary key,
  address varchar(50) not null,
  zip_code number (4,0) not null,
  region varchar (20) not null,
  valid_from date not null,
  valit_to date not null
) pctfree 0;

CREATE SEQUENCE sq_club_membership START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table f_club_membership(
  id int not null constraint f_club_membership primary key ,
  person_id int not null constraint co_fk_person_clubmembership  references d_person,
  club_name varchar (30) not null constraint co_fk_clubname_clubmembership  references d_club,
  date_join date not null,
  date_left date not null
) pctfree 0;

CREATE SEQUENCE sq_flight START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table f_flight(
  id int not null constraint co_pk_f_flight primary key,
  launch_time date not null,
  landing_time date not null,
  launch_type varchar(11) not null constraint co_ch_launch_type check(launch_type in ('winch', 'self launch', 'aerotow')),
  cable_break char(1) not null constraint co_ch_cable_break check (cable_break in('Y', 'N')),
  cross_country_km int not null,
  plane_registration varchar(3) constraint co_fk_planeregistration references d_plane,
  clubname varchar(30) not null constraint co_fk_clubname_flight references d_club
) pctfree 0;

CREATE SEQUENCE sq_ownership START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table f_ownership(
  id int not null constraint co_pk_f_ownership primary key,
  owner_id int not null constraint co_fk_ownerid_ownership references d_person,
  plane_registration varchar(3) not null constraint co_fk_planeid_ownership references d_plane,
  start_date date not null,
  end_date date not null
) pctfree 0;

create table b_passengers(
  person_id int not null constraint co_fk_personid_passengers references d_person,
  flight_id int not null constraint co_fk_flightid_passengers references f_flight) pctfree 0;

CREATE SEQUENCE sq_Date_Time START WITH 1 INCREMENT BY 1 NOMAXVALUE;

CREATE TABLE D_Date_Time(
  date_Time_ID Integer NOT NULL CONSTRAINT PkDateTime_D PRIMARY KEY,
	date_Time Date NOT NULL,
	day_Name Char(10),
	day_Of_Week Integer,
	day_Of_Month Integer,
	day_Of_Year Integer,
	week_Of_Year Integer,
	month_Name Char(10),
	month_Of_Year Integer,
	year_Number Integer,
  hour_Of_Day Integer,
  minute_Of_Day Integer,
  season_of_year varchar(6)
) pctfree 0;

CREATE SEQUENCE sq_audit START WITH 1 INCREMENT BY 1 NOMAXVALUE;

CREATE TABLE d_audit(
  id NUMBER NOT NULL,
  audit_date DATE NOT NULL,
  airplane_rejected NUMBER,
  airplane_fixed NUMBER,
  flight_rejected NUMBER,
  flight_fixed NUMBER,
  member_rejected NUMBER,
  member_fixed NUMBER,
  club_rejected NUMBER,
  club_fixed NUMBER,
  CONSTRAINT coUniqueDate UNIQUE(audit_date),
  CONSTRAINT dAuditPK PRIMARY KEY (id)
) pctfree 0;

CREATE SEQUENCE sq_weather START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table weather(
id number NOT NULL CONSTRAINT weather_id PRIMARY KEY,
pressure varchar(20) NOT NULL,
dew_point_temperature number NOT NULL,
surface_temperature number NOT NULL,
cloud_cover VARCHAR(20) NOT NULL,
visibility VARCHAR(20) NOT NULL,
wind_direction_speed VARCHAR(20) NOT NULL,
date_time date,
issuing_airport VARCHAR(20) NOT NULL
) pctfree 0;

CREATE SEQUENCE sq_thermal START WITH 1 INCREMENT BY 1 NOMAXVALUE;

create table d_thermal(
  id int not null constraint co_pk_thermalid primary key,
  date_found date not null,
  rectangle_side_A number not null,
  rectangle_side_C number not null,
  valid_until date not null
) pctfree 0;

create table location(
  position_longitude VARCHAR(20) NOT NULL,
  position_latitude VARCHAR(20) NOT NULL,
  zip_code int not null,
  city_name varchar(20) not null,
  thermal_id int not null constraint co_fk_thermal_location references d_thermal
) pctfree 0;