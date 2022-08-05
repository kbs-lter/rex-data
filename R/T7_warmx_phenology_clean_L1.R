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

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
phen <- read.csv(file.path(dir, "T7_plant_phenology/L0/T7_flwr_sd_2021_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Cleaning data
phen <- phen[,-c(1, 3, 5, 10, 11)] # delete unnecessary columns
names(phen)[3] <- "Footprint_Location" #changing column name
names(phen)[4] <- "Subplot_Location" #changing column name

# phen1 <- merge(phen, meta, by=(c("Rep", "Footprint_Location", "Subplot_Location")))

phen$Date <- mdy(phen$Date) # change date to %m/%d/%Y format
phen[["Date"]] <- as.Date(phen[["Date"]],format="%m/%d/%Y")

unique(sort(phen[["Species"]])) # check that there aren't any misspellings
unique(sort(phen[["Action"]])) # check that there aren't any misspellings
unique(sort(phen[["Date"]])) # check that there are no weird dates

# change action names
phen$Action[phen$Action == "FLower"] <- "Flower"

# change species names
phen$Species[phen$Species == "Tprr"] <- "Trpr"

# change any weird dates
phen$Date[phen$Date == "0211-06-13"] <- "2021-06-13"
phen$Date[phen$Date == "2002-07-09"] <- "2021-07-09"
phen$Date[phen$Date == "2010-10-10"] <- "2021-10-10"
phen$Date[phen$Date == "2012-06-13"] <- "2021-06-13"
phen$Date[phen$Date == "2012-07-12"] <- "2021-07-12"
phen$Date[phen$Date == "2019-06-21"] <- "2021-06-21"

