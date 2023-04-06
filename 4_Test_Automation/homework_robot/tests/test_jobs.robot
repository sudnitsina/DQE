*** Settings ***
Library    DatabaseLibrary
Library    OperatingSystem

*** Variables ***
${TABLE_NAME}    hr.jobs

*** Test Cases ***    Expression    Expected

Check number of NULL values     [Template]    Check number of NULL values in column
                                job_id
                                job_title
                                min_salary
                                max_salary

Check average salary            [Template]    Check average value in column
                                min_salary    6568.421052
                                max_salary    13210.526315

*** Keywords ***

Check number of NULL values in column
    [Arguments]    ${column}
    Connect To Database
    @{results}    Query    SELECT * from ${TABLE_NAME} WHERE ${column} IS NULL
    Should Be Empty   ${results}

Check average value in column
    [Arguments]    ${column}    ${expected}
    Connect To Database
    @{results}    Query    SELECT AVG(${column}) from ${TABLE_NAME}
    Should Be Equal As Strings   ${results}[0][0]  ${expected}
