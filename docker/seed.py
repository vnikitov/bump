import pymysql
import os

hostname = os.environ['MYSQL_HOST']
username = os.environ['MYSQL_USER']
password = os.environ['MYSQL_PASSWORD']
dbname = os.environ['MYSQL_PASSWORD']
dbport = os.environ['MYSQL_PORT']

con = pymysql.connect(host=hostname, user=username,
                      password=password, database=dbname, port=dbport)
con.autocommit = True
cur = con.cursor()

while True:
    query = "SHOW DATABASES;"
    cur.execute(query)
    data = cur.fetchall()
    print(data)
