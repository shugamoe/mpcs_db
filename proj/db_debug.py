import MySQLdb

conn = MySQLdb.connect(host="mpcs53001.cs.uchicago.edu",
        user="jmcclellan", passwd="udaeTh5b")
conn.select_db("jmcclellanDB")
