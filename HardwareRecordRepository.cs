using System;
using System.Text.Json;
using System.Threading.Tasks;
using Dapper;

public class HardwareRecordRepository
{
    private readonly IDbConnection _connection;

    public HardwareRecordRepository(IDbConnection connection)
    {
        _connection = connection;
    }

    public async Task InsertHardwareRecord(HardwareRecord hardwareRecord)
    {
        long id;
        do
        {
            id = await _connection
                .ExecuteScalarAsync<long>(
                    @"
WITH i AS (
    INSERT INTO hardware_records (crate_id, occurred_at, severity, event, object_type, object_id, object_name, permissions, port_name, message, modified_at, port_id, parameter_id)
    VALUES (@CrateId, @OccurredAt, @Severity, @Event, @ObjectType, @ObjectId, @ObjectName, @Permissions, @PortName, @Message, @ModifiedAt, @PortId, @ParameterId)
    ON CONFLICT ON CONSTRAINT ak__hardware_records__identifier DO NOTHING
    RETURNING hardware_record_id)
SELECT hardware_record_id FROM i
UNION ALL
SELECT hardware_record_id FROM hardware_records
WHERE crate_id = @CrateId AND object_id = @ObjectId AND message_hash = (CAST(md5(@Message) AS uuid)) AND occurred_at = @OccurredAt
LIMIT 1;",
                    new
                    {
                        hardwareRecord.CrateId,
                        hardwareRecord.OccurredAt,
                        hardwareRecord.Severity,
                        hardwareRecord.Event,
                        hardwareRecord.ObjectType,
                        hardwareRecord.ObjectId,
                        hardwareRecord.ObjectName,
                        hardwareRecord.Permissions,
                        hardwareRecord.PortName,
                        hardwareRecord.Message,
                        hardwareRecord.ModifiedAt,
                        hardwareRecord.PortId,
                        hardwareRecord.ParameterId,
                    })
                .ConfigureAwait(false);
        }
        while (id == default);
        hardwareRecord.Id = id;

        // Update TrapProperties only if it has content
        if (hardwareRecord.TrapProperties != null && hardwareRecord.TrapProperties.Length > 0)
        {
            await _connection
                .ExecuteAsync(
                    @"UPDATE hardware_records 
                      SET trap_properties = @TrapProperties 
                      WHERE hardware_record_id = @Id",
                    new
                    {
                        TrapProperties = JsonSerializer.Serialize(hardwareRecord.TrapProperties),
                        Id = id
                    })
                .ConfigureAwait(false);
        }
    }
}
