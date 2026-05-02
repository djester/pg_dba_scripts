create function kill_devel_sessions(p_time interval default interval '2 minutes') returns boolean as $$
select pg_terminate_backend(pid) 
  from pg_stat_activity pga
 where backend_type = 'client backend' 
   and application_name is not null 
   and client_addr is not null 
   and datname <> 'postgres'
   and not (select datistemplate from pg_database pdb where pdb.datname=pga.datname) 
   and (
   		   application_name ilike '%dbeaver%'
   		or application_name ilike '%datagri%'
   		or application_name ilike '%pgadmin%'
   	   )
   and state <>'idle'
   and pid<>pg_backend_pid()
   and coalesce(clock_timestamp()-xact_start, clock_timestamp()-query_start) > p_time
;
$$ language sql;

