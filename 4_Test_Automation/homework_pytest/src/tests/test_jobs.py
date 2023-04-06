import pytest


class TestJobs:
    TABLE = "hr.jobs"

    @pytest.mark.parametrize(
        "column, exp_result",
        [("min_salary", 6568.421052), ("max_salary", 13210.526315)],
    )
    def test_avg_salary(self, db, column, exp_result):
        """Check average salary value for min_salary and max_salary columns."""
        query = f"SELECT AVG({column}) from {self.TABLE};"
        result = db.execute_query(query)
        assert float(result[0]) == exp_result

    @pytest.mark.parametrize(
        "column", ["job_id", "job_title", "min_salary", "max_salary"]
    )
    def test_nulls(self, db, column):
        """Check number of NULL values in all columns."""
        query = f"SELECT * from {self.TABLE} WHERE {column} IS NULL;"
        result = db.execute_query(query)
        assert not result
