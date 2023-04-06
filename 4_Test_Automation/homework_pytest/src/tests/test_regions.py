class TestRegions:
    TABLE = "hr.regions"

    def test_min_region_name(self, db):
        """Check minimal value in region_name column."""
        query = f'SELECT MIN(region_name) from {self.TABLE};'
        result = db.execute_query(query)
        assert result[0] == "Americas"

    def test_max_region_name(self, db):
        """Check maximum value in region_name column."""
        query = f'SELECT MAX(region_name) from {self.TABLE};'
        result = db.execute_query(query)
        assert result[0] == "Middle East and Africa"
