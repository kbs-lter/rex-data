# TITLE:          REX: Insect preference trial clean-up
# AUTHORS:        Moriah Young
# COLLABORATORS:  
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_insect L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_insect L1 folder
# PROJECT:        REX
# DATE:           August 2021

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
insects <- read.csv(file.path(dir, "T7_warmx_insect/L0/2021/T7_warmx_insect_preference_L0.csv"))

View(insects)
str(insects)
summary(insects$sla_before)
summary(insects$sla_after)

# Upload cleaned data to L1 folder
write.csv(insects, file.path(dir,"T7_warmx_insect/L1/T7_warmx_insect_preference_L1.csv"), row.names=F)

