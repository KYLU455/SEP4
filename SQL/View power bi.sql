drop view sep_power_bi;

create view sep_power_bi as
select F_THERMAL.VALID_TO, D_FLIGHT.LOG_NAME,
  D_DATE.YEAR, D_DATE.MONTH, D_DATE.day, D_DATE.HOUR, D_DATE.MINUTE, D_DATE.WEEK_NUMBER, D_DATE.DAY_OF_WEEK, D_DATE.SEASON,
  D.START_LATITUDE, D.END_LATITUDE, D.START_LONGITUDE, D.END_LONGITUDE,
  DEW_POINT_TEMPERATURE, SURFACE_TEMPERATURE, CLOUD_COVER, cloud_cover_name, WIND_DIRECTION, WIN_SPEED_IN_KNOTS, ISSUING_AIRPORT from F_THERMAL
  left outer join D_FLIGHT on F_THERMAL.FLIGHT_ID = D_FLIGHT.ID
  left outer JOIN D_DATE on F_THERMAL.DATE_FOUND_ID = D_DATE.ID
  left outer join D_GRID D on F_THERMAL.GRID_ID = D.ID
  left outer join F_WEATHER on D_DATE.ID = F_WEATHER.DATE_ID;
  
  --Check the right amount with the following count the results should be the same.
  --select count(log_name) from sep_power_bi;
  --select count(flight_id) from f_thermal;