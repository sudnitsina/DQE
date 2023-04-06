class TestDepartments:
    TABLE = "hr.departments"

    def test_unique_locations(self, db):
        """Check count of unique values in location_id column."""
        query = f'SELECT COUNT(DISTINCT(location_id)) from {self.TABLE};'
        result = db.execute_query(query)
        assert float(result[0]) == 7

    def test_most_frequent_location(self, db):
        """Check most frequent value in location_id column."""
        query = (f'SELECT TOP 1 location_id, COUNT(location_id) AS f '
                 f'FROM {self.TABLE} GROUP BY location_id ORDER BY f DESC;')
        result = db.execute_query(query)
        assert float(result[0]) == 1700.0
