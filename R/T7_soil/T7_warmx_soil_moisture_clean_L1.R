# TITLE:          REX: T7 plots soil moisture
# AUTHORS:        Moriah Young
# COLLABORATORS:  
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_soil L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_soil L1 folder
# PROJECT:        REX
# DATE:           Jan 2023

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
soil <- read.csv(file.path(dir, "soil/L0//REX_Y2_Microbial soils_Soil moisture.csv"))
meta <- read.csv(file.path(dir, "REX_T7_metadata.csv"))

# make plot ID columns the same name
names(soil)[names(soil)=="Plot.ID"] <- "Unique_ID"

# merge both data frames by "Unique_ID"
soil_1 <- left_join(soil, meta, by = "Unique_ID")

# Exclude rows where Footprint_Treatment_full is NA (non T7 footprints):
soil_2 <- soil_1 %>% filter(!is.na(Footprint_Treatment_full))

# check Subplot_Description names
unique(soil_2$Subplot_Description)
# check FB_Description names
unique(soil_2$FP_treatment)
        
# removing unneeded columns
soil_3 <- subset(soil_2, select = -c(bag.wt, bag...wet.soil, bag...dry.soil, wet.soil..g., dry.soil..g., to_check, Notes, 
                                    who.has.fresh.soil.))

# code below is to get a dataframe for just T7 warmx plots
# select for irrigated control, OTCs under rainout shelters, and OTC control footprints
warmx_1 <- soil_3 %>% filter(FP_treatment %in% c("IR", "OR", "OC"))

# we want to filter out fungicide, nematicide, and sorghum subplot manipulations
warmx_2 <- warmx_1 %>% filter(!Subplot_Description %in% c("Fungicide", "Nematicide", "Sorghum"))

# upload L1 data
write.csv(soil_3, file.path(dir,"soil/L1/T7_soil_moisture_2022_L1.csv"), row.names=F) # all T7s

write.csv(warmx_2, file.path(dir,"soil/L1/T7_warmx_soil_moisture_2022_L1.csv"), row.names=F) # just warmx plots

