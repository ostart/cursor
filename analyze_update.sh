#!/bin/bash
# Script to analyze UPDATE query performance
# Usage: ./analyze_update.sh <database_name> <hardware_record_id> <trap_properties_json>

DB_NAME="${1:-your_database}"
RECORD_ID="${2:-1}"
TRAP_PROPS="${3:-'{}'}"

psql -d "$DB_NAME" -c "
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT JSON)
UPDATE hardware_records 
SET trap_properties = $TRAP_PROPS::jsonb
WHERE hardware_record_id = $RECORD_ID;
"
