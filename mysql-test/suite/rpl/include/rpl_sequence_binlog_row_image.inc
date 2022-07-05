#
#   This include file validates that a sequence event is properly binlogged
# and replicated.
#
# Parameters:
#   expected_results (string, in): A string which describes the columns that
#       appear in the verbose mysqlbinlog output
#

--connection master
--source include/save_master_gtid.inc

--echo # Tag and close the current master binary log to analyze for correctness
--let MYSQLD_DATADIR=`select @@datadir`
--let BINLOG_FILE= query_get_value(SHOW MASTER STATUS, File, 1)

FLUSH LOGS;

--echo # Ensure replication works without error
--connection slave
--source include/sync_with_master_gtid.inc

--echo # Validate sequence s1 is equivalent on both master and slave
--let $diff_tables= master:test.s1,slave:test.s1
--source include/diff_tables.inc

--echo # Validate sequence event was binlogged with the correct columns
--echo # MYSQL_BINLOG MYSQLD_DATADIR/BINLOG_FILE -vv > mysqlbinlog_out_file
--exec $MYSQL_BINLOG $MYSQLD_DATADIR/$BINLOG_FILE -vv > $mysqlbinlog_out_file

--echo # Expected Search Results:
--echo #    $expected_results
--let SEARCH_PATTERN=@1
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@2
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@3
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@4
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@5
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@6
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@7
--source include/search_pattern_in_file.inc
--let SEARCH_PATTERN=@8
--source include/search_pattern_in_file.inc
