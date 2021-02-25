
# Imports durham school data via API and creates Durham school capacity dataset

library(tidyverse)

durham_schools <- httr::GET("https://services2.arcgis.com/G5vR3cOjh6g2Ed8E/arcgis/rest/services/Schools_by_Student_Capacity/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")

durham_schools_tbl <- content(stuff) %>% 
  jsonlite::fromJSON(flatten = TRUE) %>% .$features %>% 
  as_tibble %>% 
  select(geometry.coordinates, contains("properties")) %>% 
  mutate(geometry.coordinates = purrr::map(geometry.coordinates, setNames, c("long","lat"))) %>%
  unnest_wider(geometry.coordinates) %>% 
  rename_with(~tolower(str_replace(.x, "properties.", ""))) %>%
  # mutate(creationdate = lubridate::as_datetime(creationdate/1000)) %>% 
  select(objectid, name, long, lat, factype, enrollment1920, numstudent, status, capacity19_20)

write_csv(durham_schools_tbl, "~/vcl_workshop/durham_school_data.csv")





# learn this (takes condition argument too)
#durham_schools_tbl %>% 
#  rename_with(~tolower(str_replace(.x, "properties.", "")))




