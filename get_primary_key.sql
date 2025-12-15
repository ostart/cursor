-- Method 1: Get primary key constraint name and columns for a specific table
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    kcu.ordinal_position
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_name = 'hardware_records'
ORDER BY kcu.ordinal_position;

-- Method 2: Using pg_catalog (more detailed, PostgreSQL-specific)
SELECT
    a.attname AS column_name,
    a.attnum AS column_position,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
JOIN pg_namespace n ON t.relnamespace = n.oid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'p'
    AND t.relname = 'hardware_records'
    AND n.nspname = 'public'  -- Change schema if needed
ORDER BY a.attnum;

-- Method 3: Simple query using pg_indexes (shows index, not constraint details)
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'hardware_records'
    AND indexdef LIKE '%PRIMARY KEY%';

-- Method 4: Get all primary keys in a schema
SELECT
    tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    STRING_AGG(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) AS primary_key_columns
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'  -- Change schema if needed
GROUP BY tc.table_schema, tc.table_name, tc.constraint_name
ORDER BY tc.table_name;

-- Method 5: Check if a specific column is part of primary key
SELECT
    CASE 
        WHEN COUNT(*) > 0 THEN 'YES'
        ELSE 'NO'
    END AS is_primary_key
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_name = 'hardware_records'
    AND kcu.column_name = 'hardware_record_id';

-- Method 6: Get primary key with data type information
SELECT
    kcu.column_name,
    kcu.ordinal_position,
    c.data_type,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.columns c
    ON kcu.table_name = c.table_name
    AND kcu.column_name = c.column_name
    AND kcu.table_schema = c.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_name = 'hardware_records'
ORDER BY kcu.ordinal_position;
