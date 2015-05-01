/*
 * Author: Robert Caddell
 * 
 * Create a job called clear wait stats to run weekly, preferably like Sunday night. 
 * 
*/

DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR)