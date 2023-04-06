*** Settings ***
Library    DatabaseLibrary
Library    OperatingSystem

*** Variables ***
${TABLE_NAME}    hr.departments

*** Test Cases ***
Check count of unique values in location_id column
    Connect To Database
    @{results}    Query    SELECT COUNT(DISTINCT(location_id)) FROM ${TABLE_NAME}
    Should Be Equal As Strings   ${results}[0][0]  7

Check most frequent value in location_id column
    Connect To Database
    @{results}    Query    SELECT TOP 1 location_id, COUNT(location_id) AS f FROM ${TABLE_NAME} GROUP BY location_id ORDER BY f DESC
    Should Be Equal As Strings   ${results}[0][0]  1700
