drop table  flight;
drop table  weather;
drop sequence idFlightSequence;
drop sequence idWeatherSequence;

CREATE TABLE flight  (
ID number NOT NULL CONSTRAINT flight_id PRIMARY KEY,
gps_altitude number NOT NULL,
pressure_altitude number NOT NULL,
satellite_coverage VARCHAR(1) NOT NULL,
position_longitude VARCHAR(20) NOT NULL,
position_latitude VARCHAR(20) NOT NULL,
log_time date NOT NULL);

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
--THE DATE DOESNT HAVE A MONTH IN THE FILE
date_time date,
issuing_airport VARCHAR(20) NOT NULL);

create SEQUENCE idWeatherSequence START WITH 1
INCREMENT BY 1
NOMAXVALUE;

