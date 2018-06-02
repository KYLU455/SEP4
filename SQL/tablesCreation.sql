drop table  flight;
drop table  weather;
drop sequence idFlightSequence;
drop sequence idWeatherSequence;

create table FLIGHT
(
  ID                 NUMBER                      not null
    constraint FLIGHT_ID
    primary key,
  FLIGHT_ID          VARCHAR2(15)                not null,
  GPS_ALTITUDE       NUMBER                      not null,
  PRESSURE_ALTITUDE  NUMBER                      not null,
  SATELLITE_COVERAGE VARCHAR2(1)                 not null,
  POSITION_LONGITUDE VARCHAR2(20)                not null,
  POSITION_LATITUDE  VARCHAR2(20)                not null,
  LOG_TIME           TIMESTAMP(6) WITH TIME ZONE not null
);

create SEQUENCE idFlightSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE TABLE weather(
id number NOT NULL CONSTRAINT weather_id PRIMARY KEY,
pressure varchar(20) NOT NULL,
dew_point_temperature number NOT NULL,
surface_temperature number NOT NULL,
cloud_cover VARCHAR(20) NOT NULL,
visibility VARCHAR(20) NOT NULL,
wind_direction_speed VARCHAR(20) NOT NULL,
date_time date,
issuing_airport VARCHAR(20) NOT NULL);

create SEQUENCE idWeatherSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

drop table thermal;
drop sequence idThermalSequence;

create SEQUENCE idThermalSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE table thermal(
  id int not null constraint thermal_id primary key,
  flight_id varchar2 (15) not null,
  date_found date not null,
  maxLatitude number not null,
	minLatitude number not null,
  maxLongitude number not null,
  minLongitude number not null
);
