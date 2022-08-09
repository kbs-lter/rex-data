# TITLE:          REX: Plant height data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Jan 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir<-Sys.getenv("DATA_DIR")

# Read in data
height_pre <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_Soca_plant_height_drought_2021_L0.csv"))
height_post <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_Soca_plant_height_postdrought_2021_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv"))

# check data
str(height_pre)
str(height_post)

# removing unneeded columns from post-drought
height_post <- height_post %>% dplyr::select(-Length_cm_of_Lower_Stem_without_leaves)
height_post <- height_post %>% dplyr::select(-Number_of_Ancillary_Galls)
height_post <- height_post %>% dplyr::select(-Research_Plant_in_ANPP_clip_area_Y_or_N)
height_post <- height_post %>% dplyr::select(-Date_of_Fruit_Collection)
height_post <- height_post %>% dplyr::select(-Plant_with_Gall_yes_or_no)
height_post <- height_post %>% dplyr::select(-Height_to_gall_cm)
height_post <- height_post %>% dplyr::select(-Height_to_top_of_Plant_cm)
height_post <- height_post %>% dplyr::select(-Infl_harvested_BEFORE_field_plant_yes_or_no)
height_post <- height_post %>% dplyr::select(-Infl_height_cm_if_previously_harvested)
height_post <- height_post %>% dplyr::select(-Percent_of_stem_length_senescence)
height_post <- height_post %>% dplyr::select(-Reproduction_no_infl_bud_flower_fruit)
height_post <- height_post %>% dplyr::select(-Type_of_Inflorescence)
height_post <- height_post %>% dplyr::select(-Spad_1)
height_post <- height_post %>% dplyr::select(-Spad_2)
height_post <- height_post %>% dplyr::select(-Spad_3)
height_post <- height_post %>% dplyr::select(-average_SPAD)
height_post <- height_post %>% dplyr::select(-Notes)
height_post <- height_post %>% dplyr::select(-data_entry_order)
height_post <- height_post %>% dplyr::select(-proofing_notes)

# removing unneeded columns from pre-drought
height_pre <- height_pre %>% dplyr::select(-Unique_Plant_Number)
height_pre <- height_pre %>% dplyr::select(-Notes)

# removing rows w no data
height_pre <- height_pre %>%
  drop_na(Plant_Height_cm)
height_post <- height_post %>%
  drop_na(Total_Plant_Height_cm)

# Convert column names to lower case
colnames(height_pre) <- tolower(colnames(height_pre))
colnames(height_post) <- tolower(colnames(height_post))

# fixing date column & adding month column
height_pre$date <- as.POSIXct(height_pre$date, format = "%m/%d/%y")
height_post$date_of_plant_harvest <- as.POSIXct(height_post$date_of_plant_harvest, format = "%m/%d/%Y")
height_pre$month <- format(height_pre$date,format="%m")
height_post$month <- format(height_post$date_of_plant_harvest,format="%m")

# removing date column - its not really needed since we have month, and it messes up further cleaning
height_post <- height_post %>% dplyr::select(-date_of_plant_harvest)
height_pre <- height_pre %>% dplyr::select(-date)

# manual check of the post drought data shows these plants have duplicate measurements:
# 150.1, 150.2
# 167.2 (not duplicated - just need to fix the .2)
# 240.1, 240.2
# 286.1, 286.2

# fixing plant ID values in data
# note: only post- measurements have unique plant ID - these weren't assigned until later in the summer
height_post$unique_plant_number[height_post$unique_plant_number == "150.1"] <- "150"
height_post$unique_plant_number[height_post$unique_plant_number == "150.2"] <- "150"
height_post$unique_plant_number[height_post$unique_plant_number == "240.1"] <- "240"
height_post$unique_plant_number[height_post$unique_plant_number == "240.2"] <- "240"
height_post$unique_plant_number[height_post$unique_plant_number == "286.1"] <- "286"
height_post$unique_plant_number[height_post$unique_plant_number == "286.2"] <- "286"
height_post$unique_plant_number[height_post$unique_plant_number == "167.2"] <- "167"
n_occur <- data.frame(table(height_post$unique_plant_number))

# taking the average of duplicated measurements
height_post2 <- height_post %>%
  filter(unique_plant_number == 150) %>%
  summarize(total_plant_height_cm = mean(total_plant_height_cm))
height_post3 <- height_post %>%
  filter(unique_plant_number == 240) %>%
  summarize(total_plant_height_cm = mean(total_plant_height_cm))
height_post4 <- height_post %>%
  filter(unique_plant_number == 286) %>%
  summarize(total_plant_height_cm = mean(total_plant_height_cm))
# replacing the values w/ the avg of the two measurements
height_post$total_plant_height_cm[height_post$unique_plant_number == 150] = 65.75
height_post$total_plant_height_cm[height_post$unique_plant_number == 240] = 50.7
height_post$total_plant_height_cm[height_post$unique_plant_number == 286] = 62.5
height_post_distinct <- height_post %>%
  select(unique_plant_number, total_plant_height_cm) %>%
  distinct() # removing one of the duplicated rows

# re-adding month info for post-drought
height_post_distinct$month <- 10

# cleaning up meta-data to merge with post-drought height data
colnames(meta) <- tolower(colnames(meta))
meta <- meta %>% dplyr::select(-treatment)
meta <- meta %>% dplyr::select(-flowered.)
meta <- meta %>% dplyr::select(-notes)
meta <- meta %>% dplyr::select(-subplot)
names(meta)[names(meta) == 'treatment.1'] <- 'treatment'
names(meta)[names(meta) == 'new.id'] <- 'unique_plant_number'
names(meta)[names(meta) == 'old.id'] <- 'gall_present'
meta$gall_present[meta$gall_present == 1] <- "no_gall"
meta$gall_present[meta$gall_present == 2] <- "no_gall"
meta$gall_present[meta$gall_present == 3] <- "no_gall"
meta$gall_present[meta$gall_present == 4] <- "no_gall"
meta$gall_present[meta$gall_present == 5] <- "no_gall"
meta$gall_present[meta$gall_present == "G1"] <- "gall"
meta$gall_present[meta$gall_present == "G2"] <- "gall"
meta$gall_present[meta$gall_present == "G3"] <- "gall"
meta$gall_present[meta$gall_present == "G4"] <- "gall"
meta$gall_present[meta$gall_present == "G5"] <- "gall"

# making sure both gall dataframes have the same treatment names
unique(meta$treatment)
unique(height_pre$treatment)
height_pre$treatment[height_pre$treatment == "s_ambient"] <- "Ambient Drought"
height_pre$treatment[height_pre$treatment == "s_warmed"] <- "Warm Drought"
height_pre$treatment[height_pre$treatment == "irr_control"] <- "Irrigated Control"
height_pre$treatment[height_pre$treatment == "ambient"] <- "Ambient"
height_pre$treatment[height_pre$treatment == "warmed"] <- "Warm"

# merging post-drought height with meta-data
meta$unique_plant_number <- as.character(meta$unique_plant_number)
height_post_merge <- left_join(meta, height_post_distinct, by = "unique_plant_number")
# removing rows w no data
height_post_merge<- height_post_merge %>%
  drop_na(total_plant_height_cm)

# making the columns the same for both height dataframes
names(height_post_merge)[names(height_post_merge) == 'total_plant_height_cm'] <- 'plant_height_cm'
height_post_merge <- height_post_merge %>% dplyr::select(-unique_plant_number)
height_pre <- height_pre %>% dplyr::select(-plant_num)

# merge both gall dataframes
both_height <- rbind(height_post_merge, height_pre)

# assigning drought treatment to each month
both_height$drought_period = NA
both_height$drought_period[both_height$month == "07"] = "Pre-Drought"
both_height$drought_period[both_height$month == "08"] = "Drought"
both_height$drought_period[both_height$month == "10"] = "Post-Drought"
# removing rows w no data
both_height<- both_height %>%
  drop_na(plant_height_cm)

# Upload cleaned data to L1 folder
write.csv(both_height, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_Soca_plant_height_L1.csv"), row.names=F)

