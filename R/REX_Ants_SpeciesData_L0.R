# TITLE:          REX: Ant pitfall trap species data
# AUTHORS:        Jamie Smith
# COLLABORATORS:  Nick Haddad, Jackson Helms, Esbeiry Cordova-Ortiz
# DATA INPUT:     Data imported as csv files from shared REX Google drive 'animal' folder
# DATA OUTPUT:    Clean L1 data uploaded to 'animal/Ants' folder
# PROJECT:        REX
# DATE:           October 2021

# Load packages
library(googledrive)
library(tidyverse)
library(readr)

# Read in data
ants <- drive_download(as_id("https://drive.google.com/file/d/1mOKzYSiGVcyPUD3ao089WFGG-qBZRhNa/"))
ants <- read_csv("REX_Ants_SpeciesData_L0.csv")

# Check dataframe
View(ants)
str(ants)
colnames(ants)

# Remove 'Notes' column
ants <- ants %>% select(-Notes)

# Export cleaned data to L1 folder
write.csv(ants, file.path("Ants/L1/AntSpeciesData_L1.csv"), row.names=F)

# Upload to google drive L1 folder 