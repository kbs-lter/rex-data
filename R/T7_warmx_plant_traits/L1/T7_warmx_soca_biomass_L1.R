# AUTHORS:        Emily Parker
# COLLABORATORS:  Kara Dobson, Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Jan 2024

### need more complete 2022 meta data

### assumes 2021 data is dry weight; need to confirm

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
L0dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L0")
L1dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L1")

#read in files
mass21 <- read.csv(file.path(L0dir, "T7_warmx_Soca_stem_mass_diam_2021_L0.csv"))
mass22 <- read.csv(file.path(L0dir, "T7_REX_goldenrod_harvest_2022.csv"))
meta21 <- read.csv(file.path(L0dir, "REX_warmx_Soca_ID_metadata_2021.csv")) # climate treatment
meta22 <- read.csv(file.path(L0dir, "REX_2022_Individual_Goldenrod_Data.csv")) # rep, galling status
heights21 <- read.csv(file.path(L0dir,"T7_warmx_Soca_plant_height_postdrought_2021_L0.csv")) # galling status

#remove rows with no stem mass data
mass21 <- mass21 %>%
  drop_na(Mass_g)

mass22 <- mass22 %>%
  drop_na(stem_dryweight)

# drop rows without plant number in 2022
mass22 <- mass22[!is.na(as.numeric(as.character(mass22$plant_num))),]
  

#remove rows with no data for plant height
heights21 <- heights21 %>%
  drop_na(Total_Plant_Height_cm)

#remove unneeded columns
mass21[,c("Harvest_Date",
          "Lower_Stem_Diameter_mm",
          "Notes")] <- list(NULL)

mass22[,c("harvest_date",
          "inflorescence_present",
          "plant_height",
          "gall_diameter",
          "gall_height",
          "gall_freshweight",
          "gall_dryweight",
          "distance_to_first_green_leaf",
          "notes")] <- list(NULL)

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

#Removing rows that don't have the plant designated as 'galled' or 'not galled'
heights21 <- heights21 %>%
  filter(!(Plant_with_Gall_yes_or_no == ""))

# Fixing plant ID values in 2021 data
heights21 <- heights21 %>%
  filter(!(Unique_Plant_Number == 286.1)) %>% # keeping 286.2 since it was recorded at a later date
  mutate_at(1, round, 0) # rounding unique plant ID to whole integer

#renaming columns
mass21 <- mass21 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Biomass" = "Mass_g")

mass22 <- mass22 %>%
  rename("Unique_ID" = "plant_num",
         "Biomass" = "stem_dryweight")

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
mass21_meta <- left_join(meta21, mass21, by = "Unique_ID") %>%
  left_join(., heights21, by="Unique_ID")
mass21_meta <- mass21_meta %>%  ##drop missing values
  drop_na(Biomass)
mass21_meta$Year <- 2021

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here

class(mass22$Unique_ID) = "numeric" #convert mass21 data to integer

mass22_meta <- left_join(meta22, mass22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
mass22_meta <- mass22_meta %>%  ##drop missing values
  drop_na(Biomass)
mass22_meta$Year <- 2022

# Fixing NA climate treatment information (all irrigated controls)
mass22_meta$Climate_Treatment[is.na(mass22_meta$Climate_Treatment)] <- "Irrigated Control"

# remove rows with NAs for gall
mass22_meta <- mass22_meta %>% 
  drop_na(Galling_Status)
mass21_meta <- mass21_meta %>% 
  drop_na(Galling_Status)

# remove duplicated rows
mass22_meta <- mass22_meta[!duplicated(mass22_meta), ]
mass21_meta <- mass21_meta[!duplicated(mass21_meta), ]

# Merge dataframes
mass <- rbind(mass21_meta,mass22_meta)

#upload to L1 folder
write.csv(mass,file.path(L1dir,"T7_warmx_soca_biomass_L1.csv"),row.names=F)
