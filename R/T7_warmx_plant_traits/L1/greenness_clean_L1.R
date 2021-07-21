# TITLE:          REX: Greenness clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           July 2021

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
green <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_greenness_L0.csv"))

# Check dataframe
str(green)
unique(green$Treatment)
unique(green$Gall_Present)
summary(green$Greenness)

# Convert column names to lower case - just my preference
colnames(green) <- tolower(colnames(green))

# Rename treatment levels for easier understanding of treatments
green$treatment[green$treatment == "s_ambient"] <- "drought"
green$treatment[green$treatment == "s_warmed"] <- "warmed_drought"
unique(green$treatment)

# Upload cleaned data to L1 folder
write.csv(green, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_greenness_L1.csv"), row.names=F)

