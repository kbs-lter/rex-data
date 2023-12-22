# AUTHORS:        Kara Dobson, Emily Parker
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Oct 2023, Dec 2023

 ## need more complete 2022 meta data

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022")

# Read in data
length21 <- read.csv(file.path(dir, "T7_warmx_Soca_infl_length_2021_L0.csv"))
length22 <- read.csv(file.path(dir, "T7_warmx_Soca_infl_length_2022_L0.csv"))
meta21 <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv")) # climate treatment
meta22 <- read.csv(file.path(dir, "REX_2022_Individual_Goldenrod_Data.csv")) # rep, galling
heights21 <- read.csv(file.path(dir,"T7_warmx_Soca_plant_height_postdrought_2021_L0.csv")) # galling


# Removing unneeded columns
length21[ ,c('hardcopy_page_number',
              'notes')] <- list(NULL)
length22[ ,c('hardcopy_page_number',
              'notes')] <- list(NULL)

meta21[ ,c('Old.ID',
         'Flowered.',
         'Notes')] <- list(NULL)

meta22[ ,c('Project',
        'Flower_Date',
        'Fruit_Date',
        'Measurement_Date',
        'Height',
        'Gall_Diameter',
        'Gall_Height',
      'Notes')] <- list(NULL)

heights21[ ,c('Length_cm_of_Lower_Stem_without_leaves',
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
         'proofing_notes',
         'Total_Plant_Height_cm')] <- list(NULL)

# Removing rows w no data in the 'height' column
length21 <- length21 %>%
  drop_na(Length_of_stem_.cm)
length22 <- length22 %>%
  drop_na(Length_of_stem_.cm)


#Removing rows that don't have the plant designated as 'galled' or 'not galled'
heights21 <- heights21 %>%
  filter(!(Plant_with_Gall_yes_or_no == ""))

# Fixing plant ID values in 2021 data
heights21 <- heights21 %>%
  filter(!(Unique_Plant_Number == 286.1)) %>% # keeping 286.2 since it was recorded at a later date
  mutate_at(1, round, 0) # rounding unique plant ID to whole integer


# Renaming columns

length21 <- length21 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Length" = "Length_of_stem_.cm",
         "Count" = "INFL_Stem_Count_per_length",
         "Type" = "Type_of_INF_.stem")

length22 <- length22 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Length" = "Length_of_stem_.cm",
         "Count" = "INFL_Stem_Count_per_length",
         "Type" = "Type_of_INF_.stem")

meta21 <- meta21 %>% 
  rename("Climate_Treatment" = "Treatment.1",
         "Unique_ID" = "New.ID",)

meta22 <- meta22 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Galling_Status" = "Gall",
         "Subplot" = "Quad")

heights21 <- heights21 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Galling_Status" = "Plant_with_Gall_yes_or_no")

#standarize gall status
meta22$Galling_Status[meta22$Galling_Status == "gall"] = 'Galled'
meta22$Galling_Status[meta22$Galling_Status == "no gall"] = 'Non-Galled'
heights21$Galling_Status[heights21$Galling_Status == "Y"] = 'Galled'
heights21$Galling_Status[heights21$Galling_Status == "N"] = 'Non-Galled'
heights21$Galling_Status[heights21$Galling_Status == "y"] = 'Galled'
heights21$Galling_Status[heights21$Galling_Status == "n"] = 'Non-Galled'





# Merge data with meta-data
length21_meta <- left_join(meta21, length21, by = "Unique_ID") %>%
  left_join(., heights21, by="Unique_ID")
length21_meta$Year <- 2021
  
meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here

length22_meta <- left_join(meta22, length22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
length22_meta$Year <- 2022

# Fixing NA climate treatment information (all irrigated controls)
length22_meta$Climate_Treatment[is.na(length22_meta$Climate_Treatment)] <- "Irrigated Control"

# remove duplicated rows
length22_meta <- length22_meta[!duplicated(length22_meta), ] 
length21_meta <- length21_meta[!duplicated(length21_meta), ]

# remove rows with NAs for gall
length22_meta <- length22_meta %>% 
  drop_na(Galling_Status)
length21_meta <- length21_meta %>% 
  drop_na(Galling_Status)

# Fixing NA climate treatment information (all irrigated controls)
length22_meta$Climate_Treatment[is.na(length22_meta$Climate_Treatment)] <- "Irrigated Control"

#fill in missing values with 0s
length21_meta$Count[is.na(length21_meta$Count)] <- 0
length22_meta$Count[is.na(length22_meta$Count)] <- 0
length21_meta$Length[is.na(length21_meta$Length)] <- 0
length22_meta$Length[is.na(length22_meta$Length)] <- 0

#fill in missing types with "Primary"
length21_meta$Type[is.na(length21_meta$Type)] <- "Primary"
length22_meta$Type[is.na(length22_meta$Type)] <- "Primary"

# Fixing NA climate treatment information (all irrigated controls)
length22_meta$Climate_Treatment[is.na(length22_meta$Climate_Treatment)] <- "Irrigated Control"



# Merge dataframes
length <- rbind(length21_meta,length22_meta)

# # Upload cleaned data to L1 folder
#write.csv(length, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_soca_infl_length_L1.csv"), row.names=F)
write.csv(length,file.path(dir,"Outputs/T7_warmx_soca_infl_length_L1.csv"),row.names=F)
