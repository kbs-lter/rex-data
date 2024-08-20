# TITLE:          REX: T7 warmx plots soil moisture (GWC)
# AUTHORS:        Moriah Young
# COLLABORATORS:  
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_soil L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_soil L1 folder
# PROJECT:        REX
# DATE:           Jan 2023; updated June 2024

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
soil22 <- read.csv(file.path(dir, "soil/L0/REX_Microbial_Soil_GWC_2022_L0.csv"))
predrought23 <- read.csv(file.path(dir, "soil/L0/T7_warmx_predrought_Microbial_Soil_GWC_2023_L0.csv"))
soil <- read.csv(file.path(dir, "soil/L0/Falvo_REX_Microbial_Soil_GWC.csv"))
microbe_meta <- read.csv(file.path(dir, "REX_Microbial_sampling_IDs_complete.csv"))
meta <- read.csv(file.path(dir, "REX_T7_metadata.csv"))

# make plot ID columns the same name
names(soil22)[names(soil22)=="Plot.ID"] <- "Unique_ID"

# merge both data frames by "Unique_ID"
soil_1 <- left_join(soil22, meta, by = "Unique_ID")

# Exclude rows where Footprint_Treatment_full is NA (non T7 footprints):
soil_2 <- soil_1 %>% filter(!is.na(Footprint_Treatment_full))

# check Subplot_Description names
unique(soil_2$Subplot_Description)
# check FB_Description names
unique(soil_2$FP_treatment)
        
# removing unneeded columns
soil_3 <- subset(soil_2, select = -c(bag.wt, bag...wet.soil, bag...dry.soil, wet.soil..g., dry.soil..g., to_check, Notes, 
                                    who.has.fresh.soil., Sample_Num))

# rename "comments" column to "time_of_sampling"
colnames(soil_3)[colnames(soil_3) == "comments"] = "time_of_sampling"
colnames(soil_3)[colnames(soil_3) == "grav_soil_moisture"] = "gwc"
colnames(soil_3)[colnames(soil_3) == "Sample.ID"] = "Sample_ID"

# code below is to get a dataframe for just T7 warmx plots
# select for irrigated control, OTCs under rainout shelters, and OTC control footprints
warmx_1 <- soil_3 %>% filter(FP_treatment %in% c("IR", "OR", "OC"))

# we want to filter out fungicide, nematicide, and sorghum subplot manipulations
warmx_2 <- warmx_1 %>% filter(!Subplot_Description %in% c("Fungicide", "Nematicide", "Sorghum"))
# remove first two rows
warmx_2 <- warmx_2[-c(1,2),]

# upload L1 data
write.csv(soil_3, file.path(dir,"soil/L1/T7_soil_moisture_2022_L1.csv"), row.names=F) # all T7s

write.csv(warmx_2, file.path(dir,"soil/L1/T7_warmx_soil_moisture_2022_L1.csv"), row.names=F) # just warmx plots

###############################################################################
# 2021-2023 
# From Grant's dataframe

# delete columns
microbe_meta <- microbe_meta[,1:14]

soil_join <- full_join(soil, microbe_meta, by = c("Sample_ID", "Treatment", "Replicate"))

# removing unneeded columns
soil_join <- soil_join %>% select (-Order, -Subplot, -comments, -Datetime_UTC)

# rename "Sampling.Time.Point" column to "time_of_sampling"
colnames(soil_join)[colnames(soil_join) == "Sampling.Time.Point"] = "time_of_sampling"

colnames(soil_join)[colnames(soil_join) == "Plot_ID"] = "Unique_ID"

# reorder columns in dataframe
soil_join <- soil_join[, c("date", "Sample_ID", "Unique_ID", "Year", "gwc", "Treatment", "Replicate", 
                           "Footprint", "FP_location", "FP_treatment", "Subplot_location", "Subplot_treatment",
                           "Footprint_Treatment_full", "flood_compromised", "time_of_sampling")]

# code below is to get a dataframe for just T7 warmx plots
# select for irrigated control, OTCs under rainout shelters, and OTC control footprints
warmx_3 <- soil_join %>% filter(Treatment %in% c("T7"))
warmx_4 <- warmx_3 %>% filter(FP_treatment %in% c("IR", "OR", "OC"))
warmx_5 <- warmx_4 %>% filter(!Subplot_treatment %in% c("F","S","N"))
warmx_6 <- na.omit(warmx_5)

write.csv(warmx_6, file.path(dir,"soil/L1/T7_warmx_Microbial_Soil_GWC_L1.csv"), row.names=F) # just warmx plots

###############################################################################
# pre drought 2023

# calculate gwc
predrought_gwc <- predrought23 %>% 
        mutate(gwc = (wet.soil...tin - dry.soil...tin) - tin_weight)
# hmmm this is not right

        
        
