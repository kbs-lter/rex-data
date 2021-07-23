# TITLE:          REX: Solidago canadensis Gall Clean-up
# AUTHORS:        Moriah Young
# COLLABORATORS:  Phoebe Zarnetske, Kara Dobson, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           July 2021

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)
library(tidyr)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
galls <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_galls_L0.csv"))

# Check dataframe
str(galls)
unique(galls$Treatment)
unique(galls$Gall_Present)
summary(galls$Gall_Diameter)
summary(galls$Gall_Height)
summary(galls$Plant_Height)

# Convert column names to lower case
colnames(galls) <- tolower(colnames(galls))

# Rename treatment levels for easier understanding of treatments
galls$treatment[galls$treatment == "s_ambient"] <- "drought"
galls$treatment[galls$treatment == "s_warmed"] <- "warmed_drought"
unique(galls$treatment)

galls <- galls %>% select(-notes) # get rid of "notes" column

# Upload cleaned data to L1 folder
write.csv(galls, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_galls_L1.csv"), row.names=F)
