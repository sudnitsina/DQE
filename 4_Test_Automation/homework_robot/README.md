# Getting Started
To run the test suite, you will need to have Python 3.x installed on your machine.
MS SQL SERVER instance is running. TRN database from Module 1 created and filled with values (script can be found here 1_Advanced SQL/home_task/TrainingDB.sql).

1. Navigate to `4_Test_Automation/homework_robot` directory in a terminal
2. Install dependencies
    > pip install -r requirements.txt
3. Update `4_Test_Automation/homework_robot/resources/db.cfg` configuration using real data to connect your database server

4. To run the test suite, and run the following command:
    > robot tests/

    This will execute all tests in the tests/ directory and generate a report and log file in the results/ directory.

# Testcases
https://github.com/sudnitsina/DQE/blob/main/4_Test_Automation/homework_robot/testcases.md

# Test report
https://github.com/sudnitsina/DQE/blob/main/4_Test_Automation/homework_robot/report.html