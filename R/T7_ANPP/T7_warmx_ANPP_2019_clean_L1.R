# TITLE:          REX: Phoebe's plots ANPP 2019
# AUTHORS:        Moriah Young
# COLLABORATORS:  Phoebe Zarnetske, Kara Dobson, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           August 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
anpp19 <- read.csv(file.path(dir, "T7_ANPP/L0/REX_T7_ANPP_all_plots_2019.csv")) 
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Renaming columns in Phoebe's data to match the metadata file
names(anpp19)[names(anpp19)=="Quad"] <- "Suplot_Location"
names(anpp19)[names(anpp19)=="New_Footprint_ID_west_to_east"] <- "Footprint_Location"
names(anpp19)[names(anpp19)=="PZ_footprints_Field_Code"] <- "Unique_ID"

# delete unnecessary columns
anpp19 <- anpp19[,-c(4, 6, 9, 10)] 

# When ANPP was collected in 2019, the irrigated control footprint location and subplot treatment locations 
# had not been determined. ANPP was taken in 1mx2m(?) sq area around the center of the footprint location.
# irrigated controls are in T7: R1F2, R2F4, R3F6, R4F3, R5F2, R6F4

# delete rows that are not complete with data (should be footprints that aren't Phoebe's and aren't irrigated control)
anpp19 <- anpp19[-which(anpp19$Unique_ID == ""), ]

unique(sort(anpp19[["Group_Code"]])) # check that there aren't any misspellings
anpp19$Group_Code[anpp19$Group_Code == "Robpse"] <- "Rubsp" # change species names
unique(sort(anpp19[["Unique_ID"]])) # check that there aren't any weird typos

str(anpp19)
anpp19$Date <- mdy(anpp19$Date) # change date to %m/%d/%Y format
anpp19[["Date"]] <- as.Date(anpp19[["Date"]],format="%m/%d/%Y")

anpp19$Year <- 2019  # create column with just the year of data collection

anpp19_merge <- merge(anpp19, meta)

# upload cleaned L1 data
write.csv(anpp19_merge, file.path(dir,"T7_ANPP/L1/T7_warmx_ANPP_2019_L1.csv"), row.names=F)

