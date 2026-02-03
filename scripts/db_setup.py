# Importing required libraries
import mysql.connector

# Connect with MySQL server
connect = mysql.connector.connect(
    host = "localhost",
    user = "root",
    passwd = "00000",
)

# Preparing a cursor object
cursor = connect.cursor()

# Ensure if database name is not exists
cursor.execute("DROP DATABASE IF EXISTS `usedcars`")

# Creating Database
cursor.execute("CREATE DATABASE `usedcars`")

# Use the database
cursor.execute("USE `usedcars`")

# Create the raw table
raw_table = """CREATE TABLE IF NOT EXISTS used_cars_info(
                `CarID` mediumint NOT NULL AUTO_INCREMENT,
                `CarName` varchar(100),
                `Price` varchar(50),
                `Mileage` varchar(50),
                `DealerName` varchar(100),
                `DealerRating` float,
                `Link` text,
                PRIMARY KEY (`CarID`)
                )"""

cursor.execute(raw_table)

# Close the connection
connect.close()