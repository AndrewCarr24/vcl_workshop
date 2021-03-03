# Installing packages 
install.packages("tidyverse")
install.packages("sf")

# Loading packages 
library(tidyverse)
library(sf)

# Nice plot theme
theme_set(theme_light())


## Reading in data 
## NOTE -- file path needs to be set to the directory where this data is located

# Census data
cleaned_census_data <- sf::st_read("cleaned_census_data/cleaned_census_data.shp")

# Durham school data 
durham_schools_tbl <- read_csv("/durham_school_data.csv")


## Creating maps with cleaned_census_data

# simple ggplot map
cleaned_census_data %>% 
  ggplot() + geom_sf()

# Plotting schools as points on map 
cleaned_census_data %>% 
  ggplot() + geom_sf() +
  geom_point(durham_schools_tbl[1,], mapping = aes(long, lat))

# Woah?! What happend?

# Need to make CRS match 
# Converting coordinate system datum from NAD83 to wgs84
cleaned_census_data <- st_transform(cleaned_census_data, crs = "wgs84")


# Map with durham schools (custom axis ticks and labels)
p1 <- cleaned_census_data %>% 
  ggplot() + geom_sf() + 
  geom_point(durham_schools_tbl, mapping = aes(long, lat), size=.2) + 
  scale_x_continuous(breaks = c(-79, -78.7)) + 
  scale_y_continuous(breaks = seq(35.9, 36.2, .1)) + 
  labs(x = "Longitude", y = "Latitude", title = "Map of Durham Schools")
p1

# Dropping missing data and scaling points by number of students 
p2 <- cleaned_census_data %>% 
  ggplot() + geom_sf() + 
  geom_point(durham_schools_tbl %>% filter(capacity19_20 != -1), mapping = aes(long, lat, size = numstudent)) + 
  scale_x_continuous(breaks = c(-79, -78.7)) + 
  scale_y_continuous(breaks = seq(35.9, 36.2, .1)) + 
  scale_size(range = c(-1.5, 4)) +
  theme(legend.position = "none") +
  labs(x = "Longitude", y = "Latitude", title = "Map of Durham Schools")
p2 

# Color by whether school is overcapacity 
durham_schools_tbl_mod <- durham_schools_tbl %>% filter(capacity19_20 != -1) %>% 
  mutate(over = ifelse(capacity19_20 > numstudent, "Over Capacity", "At or Below Capacity")) %>%
  filter(!is.na(over)) %>% 
  mutate(over = fct_rev(over))

p3 <- cleaned_census_data %>% 
  ggplot() + geom_sf() + 
  geom_point(durham_schools_tbl_mod, mapping = aes(long, lat, size = numstudent, color = over)) + 
  scale_x_continuous(breaks = c(-79, -78.7)) + 
  scale_y_continuous(breaks = seq(35.9, 36.2, .1)) + 
  scale_size(range = c(-1.5, 4), guide = 'none') +
  labs(x = "Longitude", y = "Latitude", title = "Map of Durham Schools")
p3


# Shade census tracts by income level 
p4 <- cleaned_census_data %>% filter(!is.na(med_inc)) %>% 
  mutate(med_inc_std = (med_inc - mean(med_inc))/sd(med_inc)) %>% 
  ggplot() + geom_sf(aes(fill = med_inc_std), alpha = .5) + 
  scale_fill_gradientn(colors = c('red', '#0c88f5', 'blue')) +
  geom_point(durham_schools_tbl_mod, mapping = aes(long, lat, size = numstudent, color = over), alpha = .8) + 
  scale_color_manual(values = c("red", "blue")) + 
  scale_x_continuous(breaks = c(-79, -78.7)) + 
  scale_y_continuous(breaks = seq(35.9, 36.2, .1)) + 
  scale_size(range = c(-1.5, 4), guide = 'none') +
  labs(x = "Longitude", y = "Latitude", 
       title = "Map of Durham Schools", 
       fill = "Std. Median Income", 
       color = "School Status") + 
  theme(plot.title = element_text(hjust = .5))
p4






