import pytest
from lib import sql_client

@pytest.fixture(scope="session")
def db():
    """MS SQL Server client."""
    return sql_client.MSSQLClient()
