-- Method 1: Using EXPLAIN ANALYZE with actual values
-- Replace @Id and @TrapProperties with actual values
EXPLAIN ANALYZE
UPDATE hardware_records 
SET trap_properties = '{"key": "value"}'::jsonb
WHERE hardware_record_id = 123;

-- Method 2: Using EXPLAIN ANALYZE with a variable (in psql)
-- First set the variables, then run EXPLAIN ANALYZE
\set trap_properties '''{"key": "value"}'''
\set id 123

EXPLAIN ANALYZE
UPDATE hardware_records 
SET trap_properties = :trap_properties::jsonb
WHERE hardware_record_id = :id;

-- Method 3: Using EXPLAIN ANALYZE with a prepared statement
PREPARE update_trap_properties(jsonb, bigint) AS
UPDATE hardware_records 
SET trap_properties = $1
WHERE hardware_record_id = $2;

EXPLAIN ANALYZE EXECUTE update_trap_properties('{"key": "value"}'::jsonb, 123);

-- Method 4: Using pg_stat_statements extension (if enabled)
-- This shows statistics for all executed queries
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
WHERE query LIKE '%UPDATE hardware_records%SET trap_properties%'
ORDER BY total_exec_time DESC;

-- Method 5: Check if there's an index on hardware_record_id
-- This is important for UPDATE performance
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'hardware_records'
AND indexdef LIKE '%hardware_record_id%';

-- Method 6: Check table statistics
SELECT 
    schemaname,
    tablename,
    n_tup_upd as updates,
    n_live_tup as live_rows,
    n_dead_tup as dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE tablename = 'hardware_records';
