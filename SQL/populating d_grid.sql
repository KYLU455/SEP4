declare
  start_latitude number := 58; -- 240 * 540 = 129 600
  start_longitude number := 15;
  end_latitide number := 54;
  end_longitude number := 6;
  begin
  while start_latitude >= end_latitide
    loop
      while start_longitude >= end_longitude
        loop
        insert into D_GRID (ID, START_LATITUDE, END_LATITUDE, START_LONGITUDE, END_LONGITUDE)
          values (SQ_GRID.nextval, end_latitide, end_latitide + 1/60, end_longitude, end_longitude + 1/60);
        end_longitude := end_longitude + 1/60;
      end loop;
    end_longitude := 6;
    end_latitide := end_latitide + 1/60;
  end loop;
  commit;
end;