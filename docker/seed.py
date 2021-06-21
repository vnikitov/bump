import pymysql

con = pymysql.connect(host='bump.c7jtcbmjqu7g.eu-central-1.rds.amazonaws.com', user='admins',
                  password='strojg&dsgh342', database='bump', port=21321)
con.autocommit = True
cur = con.cursor()

while True:
    query = "SHOW DATABASES;"
    cur.execute(query)
    data = cur.fetchall()
    print(data)