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

#remove rows with no stem mass data
mass21 <- mass21 %>%
  drop_na(Mass_g)

mass22 <- mass22 %>%
  drop_na(stem_dryweight)

# drop rows without plant number in 2022
mass22 <- mass22[!is.na(as.numeric(as.character(mass22$plant_num))),]
  

#remove unneeded columns
mass21[,c("Lower_Stem_Diameter_mm",
          "Notes")] <- list(NULL)

mass22[,c("inflorescence_present",
          "plant_height",
          "gall_diameter",
          "gall_height",
          "gall_freshweight",
          "gall_dryweight",
          "distance_to_first_green_leaf",
          "notes")] <- list(NULL)

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

#Change old ID to galling status
meta21$Old.ID <- str_extract(meta21$Old.ID, "[aA-zZ]+")
meta21$Old.ID <- replace_na(meta21$Old.ID,"N")

#renaming columns
mass21 <- mass21 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Biomass" = "Mass_g")

mass22 <- mass22 %>%
  rename("Unique_ID" = "plant_num",
         "Biomass" = "stem_dryweight",
         "Harvest_Date" = "harvest_date")

meta21 <- meta21 %>% 
  rename("Climate_Treatment" = "Treatment.1",
         "Unique_ID" = "New.ID",
         "Galling_Status" = "Old.ID")

meta22 <- meta22 %>% 
  rename("Unique_ID" = "Unique_Plant_Number",
         "Galling_Status" = "Gall",
         "Subplot" = "Quad")

#standarize gall status
meta22$Galling_Status[meta22$Galling_Status == "gall"] = 'Galled'
meta22$Galling_Status[meta22$Galling_Status == "no gall"] = 'Non-Galled'
meta21$Galling_Status[meta21$Galling_Status == "N"] = "Non-Galled"
meta21$Galling_Status[meta21$Galling_Status == "G"] = "Galled"

# Merge data with meta-data
mass21_meta <- left_join(meta21, mass21, by = "Unique_ID")
mass21_meta <- mass21_meta %>%  ##drop missing values
  drop_na(Biomass)
mass21_meta$Year <- 2021

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here
meta21$Galling_Status <- NULL 

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
