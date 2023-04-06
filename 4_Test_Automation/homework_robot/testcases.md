### Test cases for 'regions' table

1.  Check minimal value in region_name column.
    > Expected result: Americas
2.  Check maximum value in region_name column
    > Expected result: Middle East and Africa

### Test cases for 'departments' table

3.  Check count of unique values in location_id column
    > Expected result: 7

4.  Check most frequent value in location_id column
    > Expected result: 1700.0

#### Test cases for 'jobs' table

5.  Check average salary value for min_salary and max_salary columns

    | Column | Expected Result |
    |----------|----------|
    | min_salary | 6568.421052 |
    | max_salary | 13210.526315 |

6.  Check if there are any null values in columns:
     - job_id
     - job_title
     - min_salary
     - max_salary
     > Expected result: No null values
