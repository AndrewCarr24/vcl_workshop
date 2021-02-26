
import numpy as np
import requests
import json
import pandas as pd
import re

# Read from api as json
durham_schools = requests.get("https://services2.arcgis.com/G5vR3cOjh6g2Ed8E/arcgis/rest/services/Schools_by_Student_Capacity/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")

# load json
durham_schools_json = json.loads(durham_schools.text)

# json to pandas dataframe 
durham_schools_df = pd.io.json.json_normalize(durham_schools_json.get('features'))

# Limiting to coordinates and all columns with 'propoerties' or 'geometry.coordinates' in name 
durham_schools_df = durham_schools_df.loc[:, durham_schools_df.columns.str.contains(r'properties|geometry.coordinates')]

# Splitting geometry coords and storing as long and lat 
durham_schools_df[["long", "lat"]] = durham_schools_df["geometry.coordinates"].apply(lambda r: (r[0], r[1])).apply(pd.Series)
  
# Dropping geometry.coordinates 
durham_schools_df = durham_schools_df.drop("geometry.coordinates", 1)

# Changing 'properties' from colnames
durham_schools_df.rename(columns= lambda x:re.sub('properties.', '', x).lower(), inplace = True)

# Pulling relevant cols
durham_schools_df = durham_schools_df[["objectid", "name", "long", "lat", "factype", 
"enrollment1920", "numstudent", "status", "capacity19_20"]]

# Saving school data as csv 
durham_schools_df.to_csv("durham_school_data.csv")

  
  
  
  
