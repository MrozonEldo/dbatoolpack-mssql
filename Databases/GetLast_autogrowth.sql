DECLARE @current_trace_filename VARCHAR(500);

SELECT @current_trace_filename = [path]
FROM sys.traces
WHERE is_default = 1;

SELECT 
    t.DatabaseName AS [DatabaseName],
    t.FileName AS [Logical FileName],
    t.FileName AS [Physical FileName],
    t.StartTime AS [Timestamp],
    CAST((t.IntegerData * 8.0) / 1024 AS DECIMAL(10, 2)) AS [Autogrowth (MB)],
    CAST(t.Duration / 1000.0 AS DECIMAL(10, 2)) AS [Duration (ms)],
    t.NTUserName AS [User],
    t.HostName AS [Host]
FROM sys.fn_trace_gettable(@current_trace_filename, DEFAULT) t
WHERE t.EventClass = 92 OR t.EventClass = 93
/*92 - data file, 93 - log file*/
ORDER BY t.StartTime DESC;