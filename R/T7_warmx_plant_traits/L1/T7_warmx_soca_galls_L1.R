# TITLE:          REX: Gall Volume Data Clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           July 2021; updated June 2024

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
L0dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L0")
L1dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L1")

# Read in data
galls21 <- read.csv(file.path(L0dir, "T7_warmx_Soca_gall_mass_2021_L0.csv"))
galls22 <-read.csv(file.path(L0dir, "T7_REX_goldenrod_harvest_2022.csv" ))

meta21 <- read.csv(file.path(L0dir, "REX_warmx_Soca_ID_metadata_2021.csv"))
meta22 <- read.csv(file.path(L0dir, "REX_2022_Individual_Goldenrod_Data.csv"))

#removing unneeded columns
meta21[ ,c('Old.ID',
           'Flowered.',
           'Notes')] <- list(NULL)

meta22[,c('Project',
          'Flower_Date',
          'Fruit_Date',
          'Measurement_Date',
          'Height',
          'Gall',
          'Gall_Diameter',
          'Gall_Height',
          'Notes')] <- list(NULL)

galls21[,c('Fresh_Weigh_Date',
           'Dried_Weigh_Date',
           'Leaf_Color',
           'Notes')] <- list(NULL)

galls22[,c('inflorescence_present',
           'plant_height',
           'stem_dryweight',
           'gall_diameter',
           'gall_height',
           'distance_to_first_green_leaf',
           'notes',
          'harvest_date')] <- list(NULL)

# Removing nongalled plants 2022
galls22 <- galls22 %>%
  drop_na(gall_freshweight) %>%
  drop_na(gall_dryweight)

# fixing plant ID values in data
# note: only post- measurements have unique plant ID - these weren't assigned until later in the summer
galls21$Unique_Plant_Number[galls21$Unique_Plant_Number == "27a"] <- "27"
galls21$Unique_Plant_Number[galls21$Unique_Plant_Number == "27b"] <- "27"
galls21$Unique_Plant_Number[galls21$Unique_Plant_Number == "116a"] <- "116"
galls21$Unique_Plant_Number[galls21$Unique_Plant_Number == "116b"] <- "116"


# taking the average of duplicated measurements 2021
galls21 <- galls21 %>% 
  group_by(Unique_Plant_Number) %>% 
  summarize(Fresh_Weight_g = mean(Fresh_Weight_g),
            Dried_Weight_g = mean(Dried_Weight_g))

#renaming columns
meta21 <- meta21 %>% 
  rename("Climate_Treatment" = "Treatment.1",
         "Unique_ID" = "New.ID")

meta22 <- meta22 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Subplot" = "Quad")

galls21 <- galls21 %>%
  rename("Unique_ID" = "Unique_Plant_Number",
         "Fresh_Weight" = "Fresh_Weight_g",
         "Dried_Weight" = "Dried_Weight_g")

galls22 <- galls22 %>%
  rename("Unique_ID" = "plant_num",
         "Fresh_Weight" = "gall_freshweight",
         "Dried_Weight" = "gall_dryweight")

##convert unique id data to integer
class(galls21$Unique_ID) = "numeric"
class(galls22$Unique_ID) = "numeric"

#merge dataframes
galls21_meta <- left_join(meta21, galls21, by = "Unique_ID")
galls21_meta <- galls21_meta %>% # remove rows with NAs for height
  drop_na("Dried_Weight")

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height22 refer to different plots, so removing this here

galls22_meta <- left_join(galls22,meta22, by = c("Unique_ID")) #merge plot information
galls22_meta <- left_join(galls22_meta, meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
galls22_meta <- galls22_meta %>% # remove rows with NAs for height
  drop_na("Dried_Weight")

#fixing irr control
galls22_meta$Climate_Treatment[is.na(galls22_meta$Climate_Treatment)] <- "Irrigated Control"

# remove duplicated rows
galls22_meta <- galls22_meta[!duplicated(galls22_meta), ]
galls21_meta <- galls21_meta[!duplicated(galls21_meta), ]

#add year
galls21_meta$Year <- 2021
galls22_meta$Year <- 2022

# Merge dataframes
galls <- rbind(galls21_meta,galls22_meta)

# Upload cleaned data to L1 folder
write.csv(galls, file.path(L1dir,"T7_warmx_Soca_galls_L1.csv"), row.names=F)
