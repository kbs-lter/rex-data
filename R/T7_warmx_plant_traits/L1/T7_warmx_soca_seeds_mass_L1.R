# AUTHORS:        Kara Dobson, Emily Parker
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Oct 2023, Dec 2023

### need more complete 2022 meta data

### have infl presence for 2021 and 2022, can use instead of height data later

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
L0dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L0")
L1dir <- setwd("/Users/emilyparker/Documents/R/Goldenrod Project 2022/L1")

# Read in data
mass21 <- read.csv(file.path(L0dir, "2021 Goldenrod INFL seed mass MH check.csv"))
mass22 <- read.csv(file.path(L0dir, "T7_warmx_Soca_infl_mass_2022_L0.csv"))
mass22_MH <- read.csv(file.path(L0dir,"LTER_REX_2022_INFL_seed_mass_MH.csv"), header=T)
meta21 <- read.csv(file.path(L0dir, "REX_warmx_Soca_ID_metadata_2021.csv")) # climate treatment
meta22 <- read.csv(file.path(L0dir, "REX_2022_Individual_Goldenrod_Data.csv")) # rep, galling status
height21 <- read.csv(file.path(L0dir, "T7_warmx_Soca_plant_height_postdrought_2021_L0.csv"))


#remove header rows from mass21
mass21 <- mass21[-c(1,2,3),]
names(mass21) <- mass21[1,]
mass21<- mass21[-1,]

# Removing rows w no data in the 'height' column
height21 <- height21 %>%
  drop_na(Total_Plant_Height_cm)


# Removing unneeded columns
mass21[ ,c('Year_of_Harvest',
           'Notes')] <- list(NULL)

mass22[ ,c('Date_of_fruit_Dissection',
           'Leaves_only_freshweight__g',
           'Total_INFL_freshweight_g',
           'notes')] <- list(NULL)

mass22_MH[,c('field.and.proofing.notes', 
             'Weighed.and.Processed.by')] <- list(NULL)

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


# Removing rows w no data in the 'mass' column
mass21 <- mass21 %>%
  drop_na(Freshweight_of_seeds_g)
mass22 <- mass22 %>%
  drop_na(INFL_only_freshweight_g)
mass22_MH <- mass22_MH %>%
  drop_na(Seeds..g.)


#Change old ID to galling status
meta21$Old.ID <- str_extract(meta21$Old.ID, "[aA-zZ]+")
meta21$Old.ID <- replace_na(meta21$Old.ID,"N")


# Fixing plant ID values in 2022 MH data
mass22_MH <- mass22_MH %>%
  mutate_at(1,round,0) %>%
  group_by(Unique.Plant.ID.Number) %>%
  transmute(Seeds_Mass = sum(Seeds..g.))

#remove duplicates
mass22_MH <-mass22_MH[!duplicated(mass22_MH),]
  
# Renaming columns

mass21 <- mass21 %>% 
  rename("Unique_ID" = "Plant_ID_Number",
         "Seeds_Mass" = "Freshweight_of_seeds_g")

mass22 <- mass22 %>% 
  rename("Unique_ID" = "Individual_Plant_Number",
         "Seeds_Mass" = "INFL_only_freshweight_g")

mass22_MH <- mass22_MH %>%
  rename ("Unique_ID" = "Unique.Plant.ID.Number")

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


#combine 2022 entries
mass22 <- rbind(mass22,mass22_MH)

#convert mass21 data to integer
class(mass21$Unique_ID) = "numeric"

#remove any metadata that didn't have height value for 21
## assumes the plant was not harvested and therefore dead
meta21 <- meta21[(meta21$Unique_ID %in% height21$Unique_Plant_Number),]

# Merge data with meta-data
mass21_meta <- left_join(meta21, mass21, by = "Unique_ID")
mass21_meta$Year <- 2021

meta21$Unique_ID <- NULL # note: unique ID between meta-data and height_22 refer to different plots, so removing this here
meta21$Galling_Status <- NULL #remove old gall status


mass22_meta <- left_join(meta22, mass22, by = "Unique_ID") %>% #merge galling status
  left_join(., meta21, by = c("Treatment","Rep","Footprint","Subplot")) #merge climate treatment
mass22_meta$Year <- 2022


# Fixing NA climate treatment information (all irrigated controls)
mass22_meta$Climate_Treatment[is.na(mass22_meta$Climate_Treatment)] <- "Irrigated Control"

# remove rows with NAs for gall
mass22_meta <- mass22_meta %>% 
  drop_na(Galling_Status)
mass21_meta <- mass21_meta %>% 
  drop_na(Galling_Status)


#add zeros for missing mass values
mass21_meta[is.na(mass21_meta)] <- 0
mass22_meta[is.na(mass22_meta)] <- 0

# remove duplicated rows
mass22_meta <- mass22_meta[!duplicated(mass22_meta), ]
mass21_meta <- mass21_meta[!duplicated(mass21_meta), ]
  
#height_21_meta[ ,c('Unique_ID')] <- list(NULL)

# Merge dataframes
mass <- rbind(mass21_meta,mass22_meta)

# # Upload cleaned data to L1 folder
#write.csv(mass, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_soca_infl_mass_L1.csv"), row.names=F)
write.csv(mass,file.path(L1dir,"T7_warmx_soca_seeds_mass_L1.csv"),row.names=F)
