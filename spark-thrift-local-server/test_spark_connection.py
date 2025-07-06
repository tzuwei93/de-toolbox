from pyhive import hive
import sys

def test_connection():

    # Connect to the HiveServer2 server
    conn = hive.Connection(
        host='localhost',
        port=10000,
        username='anonymous',
        auth='NOSASL',
        database='default'
    )
    cursor = conn.cursor()
    
    # Execute a simple query
    cursor.execute('SHOW DATABASES')
    print("Available databases:", cursor.fetchall())

    cursor.execute('show tables')
    print("Available tables:", cursor.fetchall())

    # You can check access to your local table or s3 table via executing sql code here. For Example:
    # cursor.execute('CREATE OR REPLACE TEMP VIEW stg_raw__beverage_places USING parquet OPTIONS (path "s3a://nearby-beverage-explorer-data/analytics/25.041171_121.565227/beverage_analytics");')
    """
    cursor.execute('CREATE OR REPLACE TEMP VIEW stg_raw__beverage_places USING hudi OPTIONS (path "s3a://nearby-beverage-explorer-data/hudi/25.041171_121.565227/beverage_tables/beverage_basic_info_table");')
    cursor.execute('select * from stg_raw__beverage_places limit 1')
    """
    print("Data :", cursor.fetchall())
    
    print("Connected successfully!")

    cursor.close()
    conn.close()
    return True


if __name__ == "__main__":
    print("Testing Spark Thrift Server connection...")
    success = test_connection()
    sys.exit(0 if success else 1)
