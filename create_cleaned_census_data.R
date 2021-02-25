# Reads raw census shapefile/data and creates cleaned shapefile with tract-level data

library(sf)

# Reading geographic data (shapefile)
usa_tracts <- sf::st_read("~/vcl_workshop/raw_census_data/shapefile_folder/US_tract_2018.shp")

# Limiting to tracts in Durham county (state/county fips = 37063)
durham_tracts <- usa_tracts %>% filter(STATEFP == "37" & COUNTYFP == "063")

# Getting gisjoin ids 
durham_tract_gisjoin_ids <- durham_tracts %>% distinct(GISJOIN) %>% pull(GISJOIN)

# Reading tract dataframe (race, sex, age, income, ect)
tract_tbl <- read_csv("~/vcl_workshop/raw_census_data/tract_data_2014_2018.csv")

# Filtering to get durham tracts and formatting data (colnames short because st_write abbreviates field names)
tract_tbl <- tract_tbl %>% filter(GISJOIN %in% durham_tract_gisjoin_ids) %>% 
  rename(pop = AJWME001, male = AJWBE002, female = AJWBE026, white = AJWNE002, 
         black = AJWNE003, asian = AJWNE005, hisp = AJWVE012, 
         med_inc = AJZAE001) %>% 
  mutate(ba = rowSums(across(AJYPE022:AJYPE025)), 
         no_ba = rowSums(across(AJYPE002:AJYPE021))) %>% 
  select(GISJOIN, pop, male, female, white, black, asian, hisp, med_inc, 
         ba, no_ba)

# Adding census data to shapefile and saving new shapefile (ignore warnings - values of land/water areas)
durham_tracts %>% select(GISJOIN, geometry) %>% 
left_join(tract_tbl, "GISJOIN") %>% 
  sf::st_write(., "~/vcl_workshop/cleaned_census_data/cleaned_census_data.shp")



