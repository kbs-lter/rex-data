# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Oct 2023


# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir<-Sys.getenv("DATA_DIR")

# Read in data
height_21 <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_Soca_plant_height_postdrought_2021_L0.csv"))
height_22 <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/REX_2022_Individual_Goldenrod_Data.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv"))


# Removing unneeded columns
height_21[ ,c('Length_cm_of_Lower_Stem_without_leaves',
              'Number_of_Ancillary_Galls',
              'Research_Plant_in_ANPP_clip_area_Y_or_N',
              'Date_of_Fruit_Collection',
              'Date_of_Plant_Harvest',
              'Height_to_gall_cm',
              'Height_to_top_of_Plant_cm',
              'Infl_harvested_BEFORE_field_plant_yes_or_no',
              'Infl_height_cm_if_previously_harvested',
              'Percent_of_stem_length_senescence',
              'Reproduction_no_infl_bud_flower_fruit',
              'Type_of_Inflorescence',
              'Spad_1',
              'Spad_2',
              'Spad_3',
              'average_SPAD',
              'Notes',
              'data_entry_order',
              'proofing_notes')] <- list(NULL)
height_22[ ,c('Project',
              'Flower_Date',
              'Fruit_Date',
              'Measurement_Date',
              'Gall_Diameter',
              'Gall_Height',
              'Notes',
              'Unique_Plant_Number')] <- list(NULL)
meta[ ,c('Old.ID',
         'Flowered.',
         'Notes')] <- list(NULL)

# Removing rows w no data in the 'height' column
height_21 <- height_21 %>%
  drop_na(Total_Plant_Height_cm)

# Removing rows that don't have the plant designated as 'galled' or 'not galled'
height_21 <- height_21 %>%
  filter(!(Plant_with_Gall_yes_or_no == ""))

# Fixing plant ID values in 2021 data
height_21 <- height_21 %>%
  filter(!(Unique_Plant_Number == 286.1)) %>% # keeping 286.2 since it was recorded at a later date
  mutate_at(1, round, 0) # rounding unique plant ID to whole integer

# Adding year column to both dataframes
height_21$Year <- 2021
height_22$Year <- 2022

# Renaming information in gall column
height_21$Plant_with_Gall_yes_or_no[height_21$Plant_with_Gall_yes_or_no == "Y"] = 'Galled'
height_21$Plant_with_Gall_yes_or_no[height_21$Plant_with_Gall_yes_or_no == "N"] = 'Non-Galled'
height_21$Plant_with_Gall_yes_or_no[height_21$Plant_with_Gall_yes_or_no == "y"] = 'Galled'
height_21$Plant_with_Gall_yes_or_no[height_21$Plant_with_Gall_yes_or_no == "n"] = 'Non-Galled'
height_22$Gall[height_22$Gall == "gall"] = 'Galled'
height_22$Gall[height_22$Gall == "no gall"] = 'Non-Galled'

# Renaming columns
height_21 <- height_21 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Galling_Status" = "Plant_with_Gall_yes_or_no",
         "Height_cm" = "Total_Plant_Height_cm")
height_22 <- height_22 %>% 
  rename("Subplot" = "Quad",
         "Height_cm" = "Height",
         "Galling_Status" = "Gall")
meta <- meta %>% 
  rename("Climate_Treatment" = "Treatment.1",
         "Unique_ID" = "New.ID")

# Merge data with meta-data
height_21_meta <- left_join(meta, height_21, by = "Unique_ID")
height_21_meta <- height_21_meta %>% # remove rows with NAs for height
  drop_na(Height_cm)
meta$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here
height_22_meta <- left_join(height_22, meta, by = c("Treatment","Rep","Footprint","Subplot"))
height_22_meta <- height_22_meta[!duplicated(height_22_meta), ] # remove duplicated rows
height_22_meta <- height_22_meta %>% # remove rows with NAs for height
  drop_na(Height_cm)

# Fixing NA climate treatment information (all irrigated controls)
height_22_meta$Climate_Treatment[is.na(height_22_meta$Climate_Treatment)] <- "Irrigated Control"

# Removing unneeded columns
height_21_meta[ ,c('Treatment',
                   'Rep',
                   'Footprint',
                   'Subplot',
                   'Unique_ID')] <- list(NULL)
height_22_meta[ ,c('Treatment',
                   'Rep',
                   'Footprint',
                   'Subplot')] <- list(NULL)

# Merge dataframes
height <- rbind(height_21_meta,height_22_meta)

# # Upload cleaned data to L1 folder
write.csv(height, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_soca_height_L1.csv"), row.names=F)
