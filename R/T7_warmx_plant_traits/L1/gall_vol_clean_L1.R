# TITLE:          REX: Gall Volume Data Clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           July 2021; updated Jan 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir<-Sys.getenv("DATA_DIR")

# Read in data
galls_pre <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_Soca_gall_volume_drought_2021_L0.csv"))
galls_post <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_Soca_gall_volume_postdrought_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv"))

# Check dataframe
str(galls_pre)
str(galls_post)
str(meta)

# Convert column names to lower case
colnames(galls_pre) <- tolower(colnames(galls_pre))
str(galls_pre)
colnames(galls_post) <- tolower(colnames(galls_post))
str(galls_post)

# renaming columns in meta-data to match data files
names(meta)[names(meta) == 'New.ID'] <- 'unique_plant_number'

# changing meta-data id to character
meta$unique_plant_number <- as.character(meta$unique_plant_number)
str(meta)

# fixing plant ID values in data
# note: only post- measurements have unique plant ID - these weren't assigned until later in the summer
# note: 
galls_post$unique_plant_number[galls_post$unique_plant_number == "27a"] <- "27"
galls_post$unique_plant_number[galls_post$unique_plant_number == "27b"] <- "27"
galls_post$unique_plant_number[galls_post$unique_plant_number == "116.1"] <- "116"
galls_post$unique_plant_number[galls_post$unique_plant_number == "116.2"] <- "116"

# merge plant id meta data with post- gall data
gall_merge <- left_join(meta, galls_post, by = "unique_plant_number")

# removing rows w no data for gall volume
gall_merge <- gall_merge %>%
  drop_na(sphere_vol_mm3)

# Remove unneeded columns
gall_merge <- gall_merge %>% dplyr::select(-Flowered.)
gall_merge <- gall_merge %>% dplyr::select(-Notes)
gall_merge <- gall_merge %>% dplyr::select(-Treatment)
gall_merge <- gall_merge %>% dplyr::select(-x)
gall_merge <- gall_merge %>% dplyr::select(-field_notes)
gall_merge <- gall_merge %>% dplyr::select(-date_of_measurements)
galls_pre <- galls_pre %>% dplyr::select(-unique_plant_number)
galls_pre <- galls_pre %>% dplyr::select(-notes)

# changing column headers to lowercase
colnames(gall_merge) <- tolower(colnames(gall_merge))

# making sure both gall dataframes have the same treatment names
unique(galls_pre$treatment)
names(gall_merge)[names(gall_merge) == 'treatment.1'] <- 'treatment'
unique(gall_merge$treatment)
galls_pre$treatment[galls_pre$treatment == "s_ambient"] <- "Ambient Drought"
galls_pre$treatment[galls_pre$treatment == "s_warmed"] <- "Warm Drought"
galls_pre$treatment[galls_pre$treatment == "irr_control"] <- "Irrigated Control"
galls_pre$treatment[galls_pre$treatment == "ambient"] <- "Ambient"
galls_pre$treatment[galls_pre$treatment == "warmed"] <- "Warm"

# fixing column names & removing columns to merge the two gall sheets
names(gall_merge)[names(gall_merge) == 'date_of_field_harvest'] <- 'date'
galls_pre <- galls_pre %>% dplyr::select(-gall_present)
gall_merge <- gall_merge %>% dplyr::select(-old.id)
gall_merge <- gall_merge %>% dplyr::select(-freshweight)
gall_merge <- gall_merge %>% dplyr::select(-subplot)

# date is a character column - convert to date format
gall_merge$date <- as.POSIXct(gall_merge$date, format = "%m/%d/%y")
galls_pre$date <- as.POSIXct(galls_pre$date, format = "%m/%d/%y")

# matching up the units from both gall sheets - cm
gall_merge <- gall_merge %>%
  mutate(gall_diameter_cm = gall_diameter_mm / 10) %>%
  mutate(gall_height_cm = gall_height_mm / 10) %>%
  mutate(avg_radius_cm = avg_radius_mm / 10) %>%
  mutate(sphere_vol_cm3 = sphere_vol_mm3 / 1000)
gall_merge <- gall_merge %>% dplyr::select(-gall_diameter_mm)
gall_merge <- gall_merge %>% dplyr::select(-gall_height_mm)
gall_merge <- gall_merge %>% dplyr::select(-avg_radius_mm)
gall_merge <- gall_merge %>% dplyr::select(-sphere_vol_mm3)

# fixing units for august in pre-drought sheet
galls_pre$month <- format(galls_pre$date,format="%m")
galls_pre2 <- galls_pre %>%
  filter(month=="08") %>%
  mutate(gall_diameter_cm = gall_diameter_cm / 10) %>%
  mutate(gall_height_cm = gall_height_cm / 10) %>%
  mutate(avg_radius_cm = avg_radius_cm / 10) %>%
  mutate(sphere_vol_cm3 = sphere_vol_cm3 / 1000)
galls_pre3 <- galls_pre %>%
  filter(month=="07")
galls_pre4 <- rbind(galls_pre3, galls_pre2)

# removing rows w no data for gall volume
galls_pre4 <- galls_pre4 %>%
  drop_na(sphere_vol_cm3)

# checking for duplicated plants in the pre-drought measurements - none
galls_pre4[duplicated(galls_pre4[1:5]) | duplicated(galls_pre4[1:5], fromLast=TRUE),]

# taking the average of duplicated measurements 
gall_merge2 <- gall_merge %>%
  filter(unique_plant_number == 27) %>%
  summarize(gall_diameter_cm = mean(gall_diameter_cm),
            gall_height_cm = mean(gall_height_cm),
            avg_radius_cm = mean(avg_radius_cm),
            sphere_vol_cm3 = mean(sphere_vol_cm3))
gall_merge3 <- gall_merge %>%
  filter(unique_plant_number == 116) %>%
  summarize(gall_diameter_cm = mean(gall_diameter_cm),
            gall_height_cm = mean(gall_height_cm),
            avg_radius_cm = mean(avg_radius_cm),
            sphere_vol_cm3 = mean(sphere_vol_cm3))
gall_merge$gall_diameter_cm[gall_merge$unique_plant_number == 27] = 3.055 # replacing the values w/ the avg of the two measurements
gall_merge$gall_height_cm[gall_merge$unique_plant_number == 27] = 2.572
gall_merge$avg_radius_cm[gall_merge$unique_plant_number == 27] = 1.40675
gall_merge$sphere_vol_cm3[gall_merge$unique_plant_number == 27] = 11.7566
gall_merge$gall_diameter_cm[gall_merge$unique_plant_number == 116] = 6.063
gall_merge$gall_height_cm[gall_merge$unique_plant_number == 116] = 4.5745
gall_merge$avg_radius_cm[gall_merge$unique_plant_number == 116] = 2.659375
gall_merge$sphere_vol_cm3[gall_merge$unique_plant_number == 116] = 79.29281
gall_merge_distinct <- gall_merge %>% distinct() # removing one of the duplicated rows

# assigning drought period to data
gall_merge_distinct$month <- format(gall_merge_distinct$date,format="%m")
gall_merge_distinct$drought_period <- "Post-Drought"
galls_pre4$drought_period = NA
galls_pre4$drought_period[galls_pre4$month == "07"] = "Pre-Drought"
galls_pre4$drought_period[galls_pre4$month == "08"] = "Drought"

# remove plant id column since duplicated plant #s were resolved
gall_merge_distinct <- gall_merge_distinct %>% dplyr::select(-unique_plant_number)
galls_pre4 <- galls_pre4 %>% dplyr::select(-plant_num)

# merge both gall dataframes
both_gall <- rbind(galls_pre4, gall_merge_distinct)

# Upload cleaned data to L1 folder
write.csv(both_gall, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_Soca_gall_vol_L1.csv"), row.names=F)
