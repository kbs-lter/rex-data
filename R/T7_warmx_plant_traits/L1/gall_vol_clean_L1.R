# TITLE:          REX: Gall Volume Data Clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           July 2021

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir<-Sys.getenv("DATA_DIR")

# Read in data
galls <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_gallvolume_L0.csv"))
height <- read.csv(file.path(dir, "T7_warmx_plant_traits/L1/T7_warmx_galls_L1.csv"))

# Check dataframe
str(galls)
unique(galls$Treatment)

# Convert column names to lower case
colnames(galls) <- tolower(colnames(galls))

# Rename treatment levels for easier understanding of treatments
galls$treatment[galls$treatment == "s_ambient"] <- "drought"
galls$treatment[galls$treatment == "s_warmed"] <- "warmed_drought"
unique(galls$treatment)

# Remove uneeded columns
galls <- galls %>% dplyr::select(-date)
galls <- galls %>% dplyr::select(-gall_present)

# Merging data with height data, first making columns lower case for height
colnames(height) <- tolower(colnames(height))

# Selecting only heights for galled plants and removing uneeded columns
gall_only <- height[!(height$gall_present == "no_gall"),]
gall_only <- gall_only %>% dplyr::select(-gall_diameter)
gall_only <- gall_only %>% dplyr::select(-gall_height)
gall_only <- gall_only %>% dplyr::select(-date)
gall_only <- gall_only %>% dplyr::select(-gall_present)

# Removing NAs and merging volume data with height data
gall_only <- gall_only[complete.cases(gall_only),]
merged_gall <- left_join(galls, gall_only, by = c("rep", "footprint", "treatment", "plant_num"))

# Remove rows w/ NAs for plots that weren't samples from
gall_clean <- merged_gall[complete.cases(merged_gall),]

# Upload cleaned data to L1 folder
write.csv(gall_clean, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_gall_vol_L1.csv"), row.names=F)
