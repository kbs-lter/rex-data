# AUTHORS:        Emily Parker, Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Feb 15 2024


# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
L0dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L0")
L1dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L1")


# Read in data
height21 <- read.csv(file.path(L0dir, "T7_warmx_Soca_plant_height_postdrought_2021_L0.csv"))
height22 <- read.csv(file.path(L0dir, "T7_REX_goldenrod_harvest_2022.csv"))
meta21 <- read.csv(file.path(L0dir, "REX_warmx_Soca_ID_metadata_2021.csv"))
meta22 <- read.csv(file.path(L0dir, "REX_2022_Individual_Goldenrod_Data.csv")) # rep, galling status


# Removing unneeded columns
height21[ ,c('Length_cm_of_Lower_Stem_without_leaves',
              'Number_of_Ancillary_Galls',
              'Research_Plant_in_ANPP_clip_area_Y_or_N',
              'Date_of_Fruit_Collection',
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
              'proofing_notes',
             'Plant_with_Gall_yes_or_no')] <- list(NULL)

height22[ ,c( 'inflorescence_present',
              'stem_dryweight',
              'gall_freshweight',
              'gall_dryweight',
              'gall_diameter',
              'gall_height',
              'notes',
              'distance_to_first_green_leaf')] <- list(NULL)

meta21[ ,c('Flowered.',
         'Notes')] <- list(NULL)

meta22[ ,c('Project',
           'Flower_Date',
           'Fruit_Date',
           'Measurement_Date',
           'Height',
           'Gall_Diameter',
           'Gall_Height',
           'Notes')] <- list(NULL)

# Removing rows w no data in the 'height' column
height21 <- height21 %>%
  drop_na(Total_Plant_Height_cm)

height22 <- height22 %>%
  drop_na(plant_height)

#Change old ID to galling status
meta21$Old.ID <- str_extract(meta21$Old.ID, "[aA-zZ]+")
meta21$Old.ID <- replace_na(meta21$Old.ID,"N")

# Removing rows that don't have the plant designated as 'galled' or 'not galled'
meta22 <- meta22 %>%
  filter(!(Gall == ""))

# Fixing plant ID values in 2021 data
height21 <- height21 %>%
  filter(!(Unique_Plant_Number == 286.1)) %>% # keeping 286.2 since it was recorded at a later date
  mutate_at(1, round, 0) # rounding unique plant ID to whole integer

# Adding year column to both dataframes
height21$Year <- 2021
height22$Year <- 2022

# Renaming information in gall column
meta21$Old.ID[meta21$Old.ID == "N"] = "Non-Galled"
meta21$Old.ID[meta21$Old.ID == "G"] = "Galled"

meta22$Gall[meta22$Gall == "gall"] = 'Galled'
meta22$Gall[meta22$Gall == "no gall"] = 'Non-Galled'

# Renaming columns
height21 <- height21 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Height_cm" = "Total_Plant_Height_cm",
        'Harvest_Date' = 'Date_of_Plant_Harvest')

height22 <- height22 %>% 
  rename("Unique_ID" = "plant_num",
         "Height_cm" = "plant_height",
        'Harvest_Date' = 'harvest_date')

meta21 <- meta21 %>% 
  rename("Climate_Treatment" = "Treatment.1",
         "Unique_ID" = "New.ID",
         "Galling_Status" = "Old.ID")

meta22 <- meta22 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Subplot" = "Quad",
         "Galling_Status" = "Gall")

##convert height21 data to integer
class(height21$Unique_ID) = "numeric"
class(height22$Unique_ID) = "numeric"

#remove NAs from conversion
height22 <- height22 %>%
  drop_na(Unique_ID)

# Merge data with meta-data
height21_meta <- left_join(meta21, height21, by = "Unique_ID")
height21_meta <- height21_meta %>% # remove rows with NAs for height
  drop_na(Height_cm)

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height22 refer to different plots, so removing this here
meta21$Galling_Status <- NULL #remove old gall status

height22_meta <- left_join(meta22, height22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
height22_meta <- height22_meta %>% # remove rows with NAs for height
  drop_na(Height_cm)

# Fixing NA climate treatment information (all irrigated controls)
height22_meta$Climate_Treatment[is.na(height22_meta$Climate_Treatment)] <- "Irrigated Control"


# remove duplicated rows
height22_meta <- height22_meta[!duplicated(height22_meta), ]
height21_meta <- height21_meta[!duplicated(height21_meta), ]


# Merge dataframes
height_harv <- rbind(height21_meta,height22_meta)

# # Upload cleaned data to L1 folder
write.csv(height_harv, file.path(L1dir,"T7_warmx_soca_height_harvest_L1.csv"), row.names=F)
