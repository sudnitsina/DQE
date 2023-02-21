WITH
    json_string AS
        (
            SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' [my_str]
        ),
    split_json as
        (
            SELECT
                CHARINDEX('{', my_str) AS StartIndex,
                CHARINDEX('}', my_str) AS EndIndex,
                REPLACE(LEFT(my_str, CHARINDEX('}', my_str) -1), '[{', '') AS data_string,
                STUFF(my_str, 1, CHARINDEX('}', my_str), '') as leftover
            FROM json_string
            UNION ALL
            SELECT
                CHARINDEX('{', leftover) AS StartIndex,
                CHARINDEX('}', leftover) AS EndIndex,
                REPLACE(LEFT(leftover, CHARINDEX('}', leftover)), '[{', '') AS data_string,
                STUFF(leftover, 1, CHARINDEX('}', leftover), '') as leftover
            FROM split_json
            where leftover != ']'
        ),
    split_rows as
        (
            SELECT
                SUBSTRING(
                    data_string,
                    CHARINDEX('employee_id', data_string) + LEN('employee_id": "'),
                    CHARINDEX('department_id', data_string) - CHARINDEX('employee_id', data_string) - LEN('", "employee_id": "')
                ) AS employee_id,
                NULLIF(
                    SUBSTRING(
                        data_string,
                        CHARINDEX('department_id', data_string) + LEN('department_id": "'),
                        CHARINDEX('class', data_string) - CHARINDEX('department_id', data_string) - LEN('", "department_id": "')
                    ), ''
                ) AS department_id
            from split_json
        )
SELECT
    CAST(employee_id AS BIGINT),
    CAST(department_id AS INT)
FROM split_rows;
