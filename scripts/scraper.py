# Import necessary libraries
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import pandas as pd
import time

# Initialize lists to store data
car_names = []
prices = []
mileages = []
dealer_names = []
dealer_ratings = []
car_links = []
page_num = 1

# Loop through the first 500 pages
while page_num <= 500:
    options = Options()
    options.add_argument("--start-maximized")
    
    driver = webdriver.Chrome(options=options)
    url = f"https://www.cars.com/shopping/results/?zip=60606&maximum_distance=9999&stock_type=used&page={page_num}"
    driver.get(url)
    time.sleep(5)
    
    soup = BeautifulSoup(driver.page_source, "lxml")
    
    cars = soup.find_all('spark-card')
    print(f"Scraping page {page_num} with {len(cars)} cars found.")
    
    for car in cars:
        name_elem = car.find('span', {'class':"spark-body"})
        name = name_elem.text.strip() if name_elem else None
        
        price_elem = car.find('span', {'class':"spark-body-larger"})
        price = price_elem.text.strip() if price_elem else None
        
        mileage_elem = car.find('div', {'class':"datum-icon mileage"})
        mileage = mileage_elem.find('span').text.strip() if mileage_elem and mileage_elem.find('span') else None
        
        dealer_elem = car.find('span', {'class':"spark-body-small"})
        dealer_name = dealer_elem.text.strip() if dealer_elem else None
        
        rating_elem = car.find('div', {'class':"datum-icon review-star"})
        dealer_rating = rating_elem.find('span').text.strip() if rating_elem and rating_elem.find('span') else None
        
        link_elem = car.find('h2')
        car_link = link_elem.find('a').attrs['href'] if link_elem and link_elem.find('a') else None
        
        car_names.append(name)
        prices.append(price)
        mileages.append(mileage)
        dealer_names.append(dealer_name)
        dealer_ratings.append(dealer_rating)
        car_links.append(car_link)
    
    driver.quit()
    page_num += 1

# Create a DataFrame
data = pd.DataFrame({
    'Car Name': car_names,
    'Price': prices,
    'Mileage': mileages,
    'Dealer Name': dealer_names,
    'Dealer Rating': dealer_ratings,
    'Car Link': car_links
})

# Save the DataFrame to a CSV file
data.to_csv('scraped_data/used_cars.csv', index=False)
print("Data saved to used_cars.csv")