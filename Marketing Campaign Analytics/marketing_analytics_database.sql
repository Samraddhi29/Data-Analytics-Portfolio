CREATE DATABASE IF NOT EXISTS marketing_campaign_data;
USE marketing_campaign_data;
 
CREATE TABLE IF NOT EXISTS channels(
channel_id VARCHAR(6) PRIMARY KEY,
channel_name VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS products(
product_id VARCHAR(5) PRIMARY KEY,
product_name VARCHAR(50) NOT NULL,
category VARCHAR(50),
unit_price DECIMAL(10,2),
unit_cost DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS regions(
region_id VARCHAR(5) PRIMARY KEY,
city VARCHAR(25),
state VARCHAR(30),
zone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS campaigns(
id VARCHAR(10) PRIMARY KEY,
c_name VARCHAR(50),
channel_id VARCHAR(6),
product_id VARCHAR(5),
objective VARCHAR(50),
start_date DATE,
end_date DATE,
budget DECIMAL(10,2),
FOREIGN KEY (channel_id) REFERENCES channels(channel_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS campaign_performance(
p_date DATE,
campaign_id VARCHAR(10),
product_id VARCHAR(5),
region_id VARCHAR(5),
device VARCHAR(25),
gender VARCHAR(25),
age_group VARCHAR(25),
spend DECIMAL(12,2),
impressions INT,
clicks INT,
leads INT,
orders INT,
revenue DECIMAL(12,2),
FOREIGN KEY (campaign_id) REFERENCES campaigns(id),
FOREIGN KEY (product_id) REFERENCES products(product_id),
FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Channels table
LOAD DATA LOCAL INFILE 'E:/Python Project/Marketing_Analytics/Channels.csv'
INTO TABLE channels
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Products table
LOAD DATA LOCAL INFILE 'E:/Python Project/Marketing_Analytics/Products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Regions table
LOAD DATA LOCAL INFILE 'E:/Python Project/Marketing_Analytics/Regions.csv'
INTO TABLE regions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Campaigns table
LOAD DATA LOCAL INFILE 'E:/Python Project/Marketing_Analytics/Campaigns.csv'
INTO TABLE campaigns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
id,
c_name,
channel_id,
product_id,
objective,
@start_date,
@end_date,
budget
)
SET
start_date = STR_TO_DATE(@start_date,'%d-%m-%Y'),
end_date = STR_TO_DATE(@end_date,'%d-%m-%Y');

-- Campaign_performance table
LOAD DATA LOCAL INFILE 'E:/Python Project/Marketing_Analytics/CampaignPerformance.csv'
INTO TABLE campaign_performance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
@p_date,
campaign_id,
product_id,
region_id,
device,
gender,
age_group,
spend,
impressions,
clicks,
leads,
orders,
revenue
)
SET
p_date = STR_TO_DATE(@p_date,'%d-%m-%Y')
;

