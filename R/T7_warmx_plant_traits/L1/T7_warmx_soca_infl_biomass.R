# AUTHORS:        Kara Dobson, Emily Parker
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Oct 2023, Feb 2024

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
L0dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L0")
L1dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L1")

# Read in data
infl21 <- read.csv(file.path(L0dir,"Individual_goldenrod_INFL_oven_dried_biomass_2021.csv"))
infl22 <- read.csv(file.path(L0dir,"Individual_goldenrod_INFL_oven_dried_biomass_2022.csv"))
meta21 <- read.csv(file.path(L0dir, "REX_warmx_Soca_ID_metadata_2021.csv")) # climate treatment
meta22 <- read.csv(file.path(L0dir, "REX_2022_Individual_Goldenrod_Data.csv")) # rep, galling status



#remove unneeded columns
infl21 [ ,c('Oven_dried_biomass_for_INFL_g',
            'Oven_dried_Leaves_g',
            'notes')] <- list(NULL)

infl22 [ ,c('Oven_dried_biomass_for_INFL_g',
            'Oven_dried_Leaves_g',
            'notes')] <- list(NULL)      

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

# Removing rows that don't have the plant designated as 'galled' or 'not galled'
meta22 <- meta22 %>%
  filter(!(Gall == ""))


#Renaming columns
infl21 <- infl21 %>%
  rename("Infl_Mass" = "Oven_dried_biomass_for_trimmed_INFL_g",
         "Unique_ID" = "Unique_plant_ID",
         "Year" = "Year_of_Harvest")

infl22 <- infl22 %>%
  rename("Infl_Mass" = "Oven_dried_biomass_for_trimmed_INFL_g",
         "Unique_ID" = "Unique_plant_ID",
         "Year" = "Year_of_Harvest")

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


#remove any metadata that didn't have height value for 21
## assumes the plant was not harvested and therefore dead
#meta21 <- meta21[(meta21$Unique_ID %in% heights21$Unique_ID),]

# Merge data with meta-data
infl21_meta <- left_join(meta21, infl21, by = "Unique_ID")
infl21_meta$Year <- 2021

#clear 2021 unneeded metadata
meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here
meta21$Galling_Status <- NULL #remove old gall status


infl22_meta <- left_join(meta22, infl22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
infl22_meta$Year <- 2022

# Fixing NA climate treatment information (all irrigated controls)
infl22_meta$Climate_Treatment[is.na(infl22_meta$Climate_Treatment)] <- "Irrigated Control"

# remove rows with NAs for gall
infl22_meta <- infl22_meta %>% 
  drop_na(Galling_Status)
infl21_meta <- infl21_meta %>% 
  drop_na(Galling_Status)

#add zeros for missing mass values
infl21_meta[is.na(infl21_meta)] <- 0
infl22_meta[is.na(infl22_meta)] <- 0

# remove duplicated rows
infl22_meta <- infl22_meta[!duplicated(infl22_meta), ]
infl21_meta <- infl21_meta[!duplicated(infl21_meta), ]

# Merge dataframes
infl <- rbind(infl21_meta,infl22_meta)

#output
write.csv(infl,file.path(L1dir,"T7_warmx_soca_infl_mass_L1.csv"),row.names=F)
