# TITLE:          REX: Solidago canadensis Gall Survey Clean-up
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
galls <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_gall_survey_L0.csv"))

str(galls)
unique(galls$treatment)

galls <- galls %>% select(-notes) # get rid of "notes" column

# Upload cleaned data to L1 folder
write.csv(galls, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_gall_survey_L1.csv"), row.names=F)

