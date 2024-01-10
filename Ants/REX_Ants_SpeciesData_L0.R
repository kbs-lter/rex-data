# TITLE:          REX: Ant pitfall trap species data
# AUTHORS:        Jamie Smith
# COLLABORATORS:  Nick Haddad, Jackson Helms, Esbeiry Cordova-Ortiz
# DATA INPUT:     Data imported as csv files from shared REX Google drive 'animal' folder
# DATA OUTPUT:    Clean L1 data uploaded to 'animal/Ants' folder
# PROJECT:        REX
# DATE:           January 2023

# Load packages
library(googledrive)
library(tidyverse)
library(readr)

# Read in data
ants <- drive_download(as_id("https://drive.google.com/drive/folders/1UTsunRst5iaktG9xPIEQ7IKBu8KrKeG0"))
ants <- read_csv("REX_Ants_SpeciesData_L0.csv")

# Check dataframe
View(ants)
str(ants)
colnames(ants)

# Export data to L1 folder
write.csv(ants, file.path("Ants/L1/AntSpeciesData_L1.csv"), row.names=F)

# Upload to google drive L1 folder 