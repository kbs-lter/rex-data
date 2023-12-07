# AUTHORS:        Kara Dobson, Emily Parker
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Oct 2023, Dec 2023


# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022")

# Read in data
mass21 <- read.csv(file.path(dir, "T7_warmx_Soca_infl_mass_2021_L0.csv"))
mass22 <- read.csv(file.path(dir, "T7_warmx_Soca_infl_mass_2022_L0.csv"))
meta21 <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv"))
meta22 <- read.csv(file.path(dir, "REX_2022_Individual_Goldenrod_Data.csv"))
heights21 <- read.csv(file.path(dir,"T7_warmx_Soca_plant_height_postdrought_2021_L0.csv"))


# Removing unneeded columns
mass21[ ,c('Date_.of_Field_Harvest',
           'Date_of_fruit_Dissection',
           'Initials_of_Dissector',
           'hardcopy_page_number',
           'INFL_only_freshweight_g',
           'Leaves_only_freshweight__g',
           'notes')] <- list(NULL)
mass22[ ,c('Date_of_fruit_Dissection',
           'INFL_only_freshweight_g',
           'Leaves_only_freshweight__g',
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

# Removing rows w no data in the 'mass' column
mass21 <- mass21 %>%
  drop_na(Total_INFL_freshweight_g)
mass22 <- mass22 %>%
  drop_na(Total_INFL_freshweight_g)

#Removing rows that don't have the plant designated as 'galled' or 'not galled'
heights21 <- heights21 %>%
  filter(!(Plant_with_Gall_yes_or_no == ""))

# Fixing plant ID values in 2021 data
heights21 <- heights21 %>%
  filter(!(Unique_Plant_Number == 286.1)) %>% # keeping 286.2 since it was recorded at a later date
  mutate_at(1, round, 0) # rounding unique plant ID to whole integer


# Renaming columns

mass21 <- mass21 %>% 
  rename("Unique_ID" = "Individual_Plant_Number",
         "Total_Mass" = "Total_INFL_freshweight_g")

mass22 <- mass22 %>% 
  rename("Unique_ID" = "Individual_Plant_Number",
         "Total_Mass" = "Total_INFL_freshweight_g")

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


# Adding year column to all dataframes
mass21$Year <- 2021
mass22$Year <- 2022


# Merge data with meta-data
mass21_meta <- left_join(meta21, mass21, by = "Unique_ID") %>%
  left_join(., heights21, by="Unique_ID") 

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here

mass22_meta <- left_join(meta22, mass22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment


# remove duplicated rows
mass22_meta <- mass22_meta[!duplicated(mass22_meta), ]
mass21_meta <- mass21_meta[!duplicated(mass21_meta), ]

# remove rows with NAs for length / mass / gall
mass22_meta <- mass22_meta %>% 
  drop_na(Total_Mass)
mass21_meta <- mass21_meta %>% 
  drop_na(Total_Mass)
mass22_meta <- mass22_meta %>% 
  drop_na(Galling_Status)
mass21_meta <- mass21_meta %>% 
  drop_na(Galling_Status)


# Fixing NA climate treatment information (all irrigated controls)
mass22_meta$Climate_Treatment[is.na(mass22_meta$Climate_Treatment)] <- "Irrigated Control"

# Removing unneeded columns
#height_21_meta[ ,c('Unique_ID')] <- list(NULL)

# Merge dataframes
mass <- rbind(mass21_meta,mass22_meta)

# # Upload cleaned data to L1 folder
#write.csv(mass, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_soca_infl_mass_L1.csv"), row.names=F)