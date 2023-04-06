*** Settings ***
Library    DatabaseLibrary
Library    OperatingSystem

*** Variables ***
${TABLE_NAME}    hr.regions

*** Test Cases ***
Check minimal value in region_name column
    Connect To Database
    @{results}    Query    SELECT MIN(region_name) from ${TABLE_NAME}
    Should Be Equal    ${results}[0][0]  Americas

Check maximum value in region_name column
    Connect To Database
    @{results}    Query    SELECT MAX(region_name) from ${TABLE_NAME}
    Should Be Equal    ${results}[0][0]  Middle East and Africa
