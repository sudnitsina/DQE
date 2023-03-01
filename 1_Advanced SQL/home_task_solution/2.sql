CREATE PROCEDURE get_statistics @p_DatabaseName NVARCHAR(MAX),
                                @p_SchemaName NVARCHAR(MAX),
                                @p_TableName NVARCHAR(MAX)
AS
BEGIN
    EXEC ('USE ' + @p_DatabaseName )

    DECLARE @v_schema_id INT
    SET @v_schema_id = (SELECT SCHEMA_ID(@p_SchemaName));

-- get tables list to count rows
    DECLARE @v_Tableslist TABLE
                          (
                              [Table_Name] VARCHAR(100)
                          );
    INSERT
    INTO @v_Tableslist
    SELECT [name]
    FROM [sys].[all_objects]
    WHERE [schema_id] = @v_schema_id
      AND [type_desc] = 'USER_TABLE'
      AND [name] LIKE @p_TableName;

-- get columns list
    DECLARE @v_ColumnsList TABLE
                           (
                               [TABLE_CATALOG] VARCHAR(100),
                               [TABLE_SCHEMA]  VARCHAR(100),
                               [TABLE_NAME]    VARCHAR(100),
                               [COLUMN_NAME]   VARCHAR(100),
                               [DATA_TYPE]     VARCHAR(100)
                           );
    INSERT
    INTO @v_ColumnsList
    SELECT [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [COLUMN_NAME], [DATA_TYPE]
    FROM [information_schema].[columns]
    WHERE [TABLE_SCHEMA] = @p_SchemaName;

-- create dynamic query for list of tables
    DECLARE @v_Query NVARCHAR(MAX);

    WITH tbl_list AS (SELECT [Table_Name], LEAD([Table_Name]) OVER (ORDER BY [Table_Name]) [lead_row]
                      FROM @v_Tableslist)
       , query_not_agg AS (SELECT 'SELECT COUNT(*) [rows_cnt], ''' + [Table_Name] + ''' [Table_Name] FROM [' +
                                  @p_SchemaName + '].[' +
                                  [Table_Name] + '] ' +
                                  CASE
                                      WHEN [lead_row] IS NOT NULL THEN 'UNION ALL '
                                      ELSE ''
                                      END [query_text]
                           FROM tbl_list)

    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    DECLARE @v_count AS TABLE
                        (
                            rows_cnt   INT,
                            Table_Name varchar(100)
                        )
    INSERT into @v_count EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: distinct vals
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'COUNT(DISTINCT ' + [COLUMN_NAME] + ') [cnt] ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data AS TABLE
                             (
                                 Column_Name       varchar(100),
                                 Table_Name        varchar(100),
                                 distinct_vals_cnt INT
                             )
    INSERT into @columns_data EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: null count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' + 'COUNT(CASE WHEN ' + [COLUMN_NAME] +
                                  ' IS NULL THEN 1 END) AS null_count ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    DECLARE @columns_data_null AS TABLE
                                  (
                                      Column_Name varchar(100),
                                      Table_Name  varchar(100),
                                      null_count  INT
                                  )
    INSERT into @columns_data_null EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: empty or 0 count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'COUNT(CASE WHEN COALESCE(LEN(' + [COLUMN_NAME] +
                                  '), 0) = 0 THEN 1 END) AS empty_count ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_empty AS TABLE
                                   (
                                       Column_Name varchar(100),
                                       Table_Name  varchar(100),
                                       empty_count INT
                                   )
    INSERT into @columns_data_empty EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: uppercase count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' + 'COUNT(CASE WHEN ' + [COLUMN_NAME] + ' = UPPER(' +
                                  [COLUMN_NAME] +
                                  ') COLLATE Latin1_General_CS_AS  THEN 1 END) AS lowercase_count ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_upper AS TABLE
                                   (
                                       Column_Name     varchar(100),
                                       Table_Name      varchar(100),
                                       uppercase_count INT
                                   )
    INSERT into @columns_data_upper EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: uppercase count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'COUNT(CASE WHEN ' + [COLUMN_NAME] + ' = LOWER(' + [COLUMN_NAME] +
                                  ') COLLATE Latin1_General_CS_AS  THEN 1 END) AS lowercase_count ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_lower AS TABLE
                                   (
                                       Column_Name     varchar(100),
                                       Table_Name      varchar(100),
                                       lowercase_count INT
                                   )
    INSERT into @columns_data_lower EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: with non-printable count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'COUNT(CASE WHEN LEN(' + [COLUMN_NAME] + ') <> LEN(RTRIM(LTRIM(' + [COLUMN_NAME] +
                                  '))) THEN 1 END) AS empty_count ' + 'FROM [' + @p_SchemaName + '].[' + [Table_Name] +
                                  '] ' +
                                  CASE
                                      WHEN [lead_row] IS NOT NULL THEN 'UNION ALL '
                                      ELSE ''
                                      END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_non_print AS TABLE
                                       (
                                           Column_Name     varchar(100),
                                           Table_Name      varchar(100),
                                           non_print_count INT
                                       )
    INSERT into @columns_data_non_print EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: most frequent value
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'CAST(' + [COLUMN_NAME] + ' AS VARCHAR(100)), f' +
                                  ' FROM (SELECT TOP 1 ' + [COLUMN_NAME] + ', COUNT(*) AS f FROM [' + @p_SchemaName +
                                  '].[' +
                                  [Table_Name] +
                                  '] GROUP BY ' + [COLUMN_NAME] + ' ORDER BY f DESC) AS [most_freq] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_most_freq AS TABLE
                                       (
                                           Column_Name varchar(100),
                                           Table_Name  varchar(100),
                                           most_freq   varchar(100),
                                           f           INT
                                       )
    INSERT into @columns_data_most_freq EXEC SP_EXECUTESQL @v_Query;

-- create query to get columns information: max min count
    WITH col_list AS (SELECT [Table_Name]
                           , [COLUMN_NAME]
                           , LEAD([COLUMN_NAME]) OVER (ORDER BY [COLUMN_NAME]) [lead_row]
                      FROM @v_ColumnsList)
       , query_not_agg AS (SELECT 'SELECT ''' + [COLUMN_NAME] + ''' [COLUMN_NAME], ''' + [Table_Name] +
                                  ''' [Table_Name], ' +
                                  'CAST (MIN(' + [COLUMN_NAME] + ') AS varchar(100)) AS min, ' +
                                  'CAST (MAX(' + [COLUMN_NAME] + ') AS varchar(100)) AS max ' +
                                  'FROM [' + @p_SchemaName + '].[' + [Table_Name] + '] ' +
                                  CASE WHEN [lead_row] IS NOT NULL THEN 'UNION ALL ' ELSE '' END [query_text]
                           FROM col_list)
    SELECT @v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
    FROM query_not_agg;
    SELECT @v_Query;
    DECLARE @columns_data_extremum AS TABLE
                                      (
                                          Column_Name varchar(100),
                                          Table_Name  varchar(100),
                                          min         varchar(100),
                                          max         varchar(100)
                                      )
    INSERT into @columns_data_extremum EXEC SP_EXECUTESQL @v_Query;

    select [TABLE_CATALOG]                [Database name],
           [TABLE_SCHEMA]                 [Schema name],
           col_list.[TABLE_NAME]          [Table name],
           [rows_cnt]                     [Total row count],
           col_list.[COLUMN_NAME]         [Column name],
           [DATA_TYPE]                    [Data type],
           c.[distinct_vals_cnt]          [Count of DISTINCT values],
           c_n.[null_count]               [Count of NULL values],
           c_e.[empty_count]              [Count of empty/zero values],
           c_u.[uppercase_count]          [Only UPPERCASE strings],
           c_l.[lowercase_count]          [Only LOWERCASE strings],
           c_np.[non_print_count]         [Rows with non-printable characters at the beginning/end],
           c_mf.[most_freq]               [Most used value],
           c_mf.[f] * 100 / [rows_cnt] AS [% rows with most used value],
           c_ext.[min]                    [MIN value],
           c_ext.[max]                    [MAX value]
    from @v_ColumnsList AS col_list
             JOIN @v_count as count on col_list.TABLE_NAME = count.Table_Name
             JOIN @columns_data as c
                  on col_list.TABLE_NAME = c.Table_Name and
                     col_list.COLUMN_NAME = c.Column_Name
             JOIN @columns_data_null as c_n
                  on col_list.TABLE_NAME = c_n.Table_Name and
                     col_list.COLUMN_NAME = c_n.Column_Name
             JOIN @columns_data_empty as c_e
                  on col_list.TABLE_NAME = c_e.Table_Name and
                     col_list.COLUMN_NAME = c_e.Column_Name
             JOIN @columns_data_upper as c_u
                  on col_list.TABLE_NAME = c_u.Table_Name and
                     col_list.COLUMN_NAME = c_u.Column_Name
             JOIN @columns_data_lower as c_l
                  on col_list.TABLE_NAME = c_l.Table_Name and
                     col_list.COLUMN_NAME = c_l.Column_Name
             JOIN @columns_data_non_print as c_np
                  on col_list.TABLE_NAME = c_np.Table_Name and
                     col_list.COLUMN_NAME = c_np.Column_Name
             JOIN @columns_data_most_freq as c_mf
                  on col_list.TABLE_NAME = c_mf.Table_Name and
                     col_list.COLUMN_NAME = c_mf.Column_Name
             JOIN @columns_data_extremum as c_ext
                  on col_list.TABLE_NAME = c_ext.Table_Name and
                     col_list.COLUMN_NAME = c_ext.Column_Name;
END
