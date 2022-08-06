# TITLE:          REX: Phoebe's plots flowering
# AUTHORS:        Moriah Young
# COLLABORATORS:  Kara Dobson, Phoebe Zarnetske, Mark Hammond, 
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           June 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)
library(lubridate)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
phen <- read.csv(file.path(dir, "T7_plant_phenology/L0/T7_flwr_sd_2021_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Cleaning data
phen <- phen[,-c(1, 3, 5, 10, 11)] # delete unnecessary columns
names(phen)[names(phen)=="New_Footprint"] <- "Footprint_Location"
names(phen)[names(phen)=="Quad"] <- "Subplot_Location"

phen1 <- merge(phen, meta, by=(c("Rep", "Footprint_Location", "Subplot_Location")))

phen1$Date <- mdy(phen1$Date) # change date to %m/%d/%Y format
phen1[["Date"]] <- as.Date(phen1[["Date"]],format="%m/%d/%Y")

unique(sort(phen1[["Species"]])) # check that there aren't any misspellings
unique(sort(phen1[["Action"]])) # check that there aren't any misspellings
unique(sort(phen1[["Date"]])) # check that there are no weird dates
unique(sort(phen1[["Subplot_Descriptions"]])) # check for any misspellings

# change action names
phen1$Action[phen1$Action == "FLower"] <- "Flower"

# change species names
phen1$Species[phen1$Species == "Tprr"] <- "Trpr"

# change any weird dates
phen1$Date[phen1$Date == "0211-06-13"] <- "2021-06-13"
phen1$Date[phen1$Date == "2002-07-09"] <- "2021-07-09"
phen1$Date[phen1$Date == "2010-10-10"] <- "2021-10-10"
phen1$Date[phen1$Date == "2012-06-13"] <- "2021-06-13"
phen1$Date[phen1$Date == "2012-07-12"] <- "2021-07-12"
phen1$Date[phen1$Date == "2019-06-21"] <- "2021-06-21"

phen1 <- phen1[,-1] # delete unnecessary columns

phen2 <- phen1[,c(6, 7, 1, 2, 8, 9, 11, 10, 4, 5, 3)]