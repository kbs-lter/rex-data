# Author: Grant Falvo

library(tidyverse)
library(lubridate)

data1 <- read_csv("~/Downloads/L0/REX_Microbial_Soil_GWC.csv")

data1 = data1 %>%
  rename(grav_soil_moisture = gwc) %>%
  mutate(top_depth_cm = 0) %>%
  mutate(bottom_depth_cm = 25) %>%
  mutate(sample_event = 'monitor') %>%
  mutate(subsample = '') %>%
  mutate(notes = '') %>%
  select(date, Treatment, Replicate, Footprint, Subplot, subsample, Sample_ID, sample_event, top_depth_cm, bottom_depth_cm, grav_soil_moisture, notes)

data2 <- read_csv("~/Downloads/L0/REX_Y2_Microbial soils_Soil moisture.csv",
                  na =c( "#VALUE!",""),
                  col_types = cols(
                    Sample_Num = col_double(),
                    `Sample ID` = col_character(),
                    `Plot ID` = col_character(),
                    date = col_character(),
                    comments = col_character(),
                    `bag wt` = col_character(),
                    `bag + wet soil` = col_character(),
                    `bag + dry soil` = col_double(),
                    `wet soil (g)` = col_character(),
                    `dry soil (g)` = col_character(),
                    grav_soil_moisture = col_number(),
                    to_check = col_character(),
                    Notes = col_character(),
                    `who has fresh soil?` = col_character()
                  )) %>%
  separate(`Plot ID`, 
           c('Treatment', 'Replicate', 'Footprint', 'Subplot' ,'subsample'),'_') %>%
  filter(is.na(to_check)) %>%
  separate(date, c('month', 'day', 'year'), '/') %>%
  mutate(year = as.numeric(year) + 2000) %>%
  mutate(date_str = paste(year, month, day, sep="-")) %>%
  mutate(date = as.Date(date_str))  %>%
  rename(Sample_ID= `Sample ID`) %>%
  rename(sample_event = comments) %>%
  mutate(top_depth_cm = 0) %>%
  mutate(bottom_depth_cm = 25) %>%
  mutate(notes = paste(Notes, ' estimated top and bottom depth')) %>%
  select(date, Treatment, Replicate, Footprint, Subplot, subsample, Sample_ID, sample_event, top_depth_cm, bottom_depth_cm, grav_soil_moisture, notes)

data3 <-  read_csv("~/Downloads/L0/T7_warmx_predrought_soil_moisture_2023.csv") %>%
  separate(`Sample_ID`, 
           c('Treatment', 'Replicate', 'Footprint', 'Subplot' ,'subsample'),'_') %>%
  mutate(grav_soil_moisture = (`wet soil + tin` - `dry soil + tin` )/ (`dry soil + tin` - `tin_weight`)) %>%
  rename(Sample_ID = Plot_ID) %>%
  rename(sample_event = Sample_Event) %>%
  mutate(date = '2023-08-01') %>%
  mutate(notes = 'date and depth are estimated') %>%
  mutate(top_depth_cm = 0) %>%
  mutate(bottom_depth_cm = 25) %>%
  select(date, Treatment, Replicate, Footprint, Subplot, subsample, Sample_ID, sample_event, top_depth_cm, bottom_depth_cm, grav_soil_moisture, notes)


gwc <- rbind(data1, data2, data3)

gwc %>%
  write_csv("~/Downloads/L0/gravimetric_soil_moisture.csv")

str(gwc)
gwc %>%
  ggplot(aes(date, grav_soil_moisture)) + geom_point() + 
  facet_grid('Footprint ~ Treatment')

