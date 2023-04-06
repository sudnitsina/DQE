import pymssql
import os
from dotenv import load_dotenv

load_dotenv()


class MSSQLClient:
    """A client for connecting and interacting
    with a Microsoft SQL Server database."""

    def __init__(self):
        conn = pymssql.connect(
            server=os.getenv("SQL_SERVER_URL"),
            user=os.getenv("SQL_SERVER_USERNAME"),
            password=os.getenv("SQL_SERVER_PASSWORD"),
            database=os.getenv("SQL_SERVER_DATABASE"),
        )
        self.cursor = conn.cursor()

    def execute_query(self, query):
        """Executes an SQL query and returns one row from the result."""
        self.cursor.execute(query)
        return self.cursor.fetchone()
