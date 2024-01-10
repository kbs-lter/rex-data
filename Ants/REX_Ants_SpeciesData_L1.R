# TITLE:          REX: Ant pitfall trap species data
# AUTHORS:        Jamie Smith
# COLLABORATORS:  Nick Haddad, Jackson Helms, Esbeiry Cordova-Ortiz
# DATA INPUT:     Data imported as csv files from shared REX Google drive shared L0 Folder
# DATA OUTPUT:    Clean L1 data uploaded to 'animal/Ants' L1 folder
# PROJECT:        REX
# DATE:           May 2023

# Load packages
library(googledrive)
library(tidyverse)
library(readr)

# Read in data
ants <- drive_download(as_id("https://drive.google.com/drive/folders/1UTsunRst5iaktG9xPIEQ7IKBu8KrKeG0/"))
ants <- read_csv("REX_Ants_SpeciesData_L0.csv")

# Check dataframe
View(ants)
str(ants)
colnames(ants)

# Remove 'Notes' column
ants <- ants %>% select(-Notes)

# Export cleaned data to L1 folder
write.csv(ants, file.path("R/Ants/L1/AntSpeciesData_L1.csv"), row.names=F)