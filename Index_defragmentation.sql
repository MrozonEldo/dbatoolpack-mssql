DECLARE @name NVARCHAR(128)
DECLARE @sql NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb','distribution') 

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'USE ' + QUOTENAME(@name) + N'; ' + 
               N'SELECT DB_NAME(ps.database_id) AS [DatabaseName], 
                       SCHEMA_NAME(o.[schema_id]) AS [SchemaName],
                       OBJECT_NAME(ps.OBJECT_ID) AS [ObjectName], 
                       i.[name] AS [IndexName], 
                       ps.index_id, 
                       ps.index_type_desc, 
                       ROUND(ps.avg_fragmentation_in_percent, 2) AS avg_fragmentation_in_percent, 
                       ps.fragment_count, 
                       ps.page_count,
                       ROUND(CAST(ps.page_count AS FLOAT) * 8 / 1024 / 1024, 2) AS SizeGB
                FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL , N''LIMITED'') AS ps
                INNER JOIN sys.indexes AS i WITH (NOLOCK)
                    ON ps.[object_id] = i.[object_id] 
                    AND ps.index_id = i.index_id
                INNER JOIN sys.objects AS o WITH (NOLOCK)
                    ON i.[object_id] = o.[object_id]
                WHERE ps.page_count > 1000
                  AND ps.index_id <> 0
                ORDER BY ps.page_count DESC OPTION (RECOMPILE);'

    EXEC sp_executesql @sql

    FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor
