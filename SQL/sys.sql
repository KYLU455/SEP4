create profile dbaprofile
 limit
   sessions_per_user          unlimited
   cpu_per_session            unlimited
   cpu_per_call               unlimited
   connect_time               unlimited
   idle_time                  unlimited
   logical_reads_per_session  unlimited
   logical_reads_per_call     unlimited
   composite_limit            unlimited
   private_sga                unlimited
   failed_login_attempts      unlimited
   password_life_time         unlimited
   password_reuse_time        unlimited
   password_reuse_max         unlimited
   password_lock_time         unlimited
   password_grace_time        unlimited
   password_verify_function   null 
   ;
   

create user sep
  identified by sep
  profile dbaprofile
  quota unlimited on users
  ;

grant dba to sep
;


grant execute on dbms_flashback to sep;
grant execute on DBMS_LOGMNR to sep;
