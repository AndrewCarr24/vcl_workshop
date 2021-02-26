
import numpy as np
import geopandas
import os 
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

## Plot theme
sns.set_style("whitegrid")

# Census data
cleaned_census_data = geopandas.read_file("vcl_workshop/cleaned_census_data/cleaned_census_data.shp")
  
# Durham school data 
durham_schools_tbl = pd.read_csv("vcl_workshop/durham_school_data.csv")

## p1
cleaned_census_data['geometry'].plot()
plt.show()

### Changing crs projection 
cleaned_census_data = cleaned_census_data.to_crs("EPSG:4326")

## p2

# Turning school pandas df into geopandas df 
gdf = geopandas.GeoDataFrame(
    durham_schools_tbl, geometry=geopandas.points_from_xy(durham_schools_tbl.long, durham_schools_tbl.lat))
    
gdf.plot(ax = cleaned_census_data['geometry'].plot(color='white', edgecolor='black'), 
  color = 'red', markersize = 3)
plt.xticks((-79, -78.85, -78.7), (-79, -78.85, -78.7))
plt.yticks(np.arange(35.9, 36.3, .1))
plt.xlabel("Longitude")
plt.ylabel("Latitude")
plt.title("Map of Durham Schools")
plt.show()

## p3 - same plot except schools w missing capacity data are removed and remaining point sizes are adjusted to show
# number of students in school

# Dropping rows with missing data 
gdf = gdf.loc[gdf['capacity19_20'] != -1]

cleaned_census_data['geometry'].plot(color='white', edgecolor='black')
plt.xticks((-79, -78.85, -78.7), (-79, -78.85, -78.7))
plt.yticks(np.arange(35.9, 36.3, .1))
plt.xlabel("Longitude")
plt.ylabel("Latitude")
plt.title("Map of Durham Schools")
plt.scatter(durham_schools_tbl.long, durham_schools_tbl.lat, color = 'red', 
s = np.array([i/25 for i in np.array(durham_schools_tbl.numstudent)]))
plt.show()

# p4 - shade by income level / color code points by whether over capacity 
cleaned_census_data = cleaned_census_data[cleaned_census_data['med_inc'].notna()]

# standardized med inc 
cleaned_census_data['med_inc'] = (cleaned_census_data['med_inc']
  .apply(lambda x: (x - np.mean(cleaned_census_data['med_inc']))/np.std(cleaned_census_data['med_inc'])))

# over capacity
durham_schools_tbl = durham_schools_tbl.assign(
    over = lambda dataframe: dataframe['numstudent'] >  dataframe['capacity19_20']  
    )

# final plot 
cleaned_census_data.plot(column=cleaned_census_data['med_inc'], cmap='RdBu', edgecolor='black')
plt.xticks((-79, -78.85, -78.7), (-79, -78.85, -78.7))
plt.yticks(np.arange(35.9, 36.3, .1))
plt.xlabel("Longitude")
plt.ylabel("Latitude")
plt.title("Map of Durham Schools")
plt.scatter(durham_schools_tbl.long, durham_schools_tbl.lat, c = durham_schools_tbl.over, cmap='RdBu', label = [False, True], s = np.array([i/25 for i in np.array(durham_schools_tbl.numstudent)]))
plt.show()







