# Data Files

The dataset used in this project was generated specifically for the analysis rather than downloaded from an external dataset.

The dimension data was first created in Excel for campaigns, products, channels, and regions. A Python script was then used to generate the campaign performance data for different dates, campaigns, and regions. Values such as spend, impressions, clicks, leads, orders, and revenue were generated using defined business rules so that the data follows a realistic marketing campaign flow.

The generated data was then loaded into MySQL for analysis.

## Files

- `campaigns.csv` – Campaign details and budget information
- `channels.csv` – Marketing channel details
- `products.csv` – Product details and categories
- `regions.csv` – Region and location details
- `campaign_performance.csv` – Daily campaign performance data including spend, impressions, clicks, leads, orders, and revenue
