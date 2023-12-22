# TITLE:          REX: warmx Phenology - flowering and seed set cleaning
# AUTHORS:        Moriah Young
# COLLABORATORS:  Kara Dobson, Phoebe Zarnetske, Mark Hammond, 
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_phenology L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_phenology L1 folder
# PROJECT:        REX
# DATE:           August 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)
library(lubridate)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
phen21 <- read.csv(file.path(dir, "T7_plant_phenology/L0/T7_flwr_sd_2021_L0.csv"))
phen22 <- read.csv(file.path(dir, "T7_plant_phenology/L0/T7_flwr_sd_2022_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Cleaning data
# 2021 data
phen21 <- phen21[,-c(1, 3, 5, 10, 11)] # delete unnecessary columns
names(phen21)[names(phen21)=="New_Footprint"] <- "Footprint_Location"
names(phen21)[names(phen21)=="Quad"] <- "Subplot_Location"
names(phen21)[names(phen21)=="Species"] <- "Code"

# 2022 data
phen22 <- phen22[,-c(1, 3, 9)] # delete unnecessary columns
names(phen22)[names(phen22)=="Footprint"] <- "Footprint_Location"
names(phen22)[names(phen22)=="Quad"] <- "Subplot_Location"
names(phen22)[names(phen22)=="Species_Code"] <- "Code"
phen22$Subplot_Location <- tolower(phen22$Subplot_Location)

phen_all <- full_join(phen21, phen22)
phen_all <- merge(phen_all, meta, by=(c("Rep", "Footprint_Location", "Subplot_Location")))

phen_all$Date <- mdy(phen_all$Date) # change date to %m/%d/%Y format
phen_all[["Date"]] <- as.Date(phen_all[["Date"]],format="%m/%d/%Y")

unique(sort(phen_all[["Code"]])) # check that there aren't any misspellings
unique(sort(phen_all[["Action"]])) # check that there aren't any misspellings
unique(sort(phen_all[["Date"]])) # check that there are no weird dates
unique(sort(phen_all[["Subplot_Descriptions"]])) # check for any misspellings

# change action names
phen_all$Action[phen_all$Action == "FLower"] <- "Flower"
phen_all$Action[phen_all$Action == "Flwr"] <- "Flower"
phen_all$Action[phen_all$Action == "Flwr/Fr"] <- "Flower"
phen_all$Action[phen_all$Action == "Fr"] <- "Seed"

# change species names
phen_all$Code[phen_all$Code == "Tprr"] <- "Trpr"
phen_all$Code[phen_all$Code == "Tpr"] <- "Trpr"
phen_all$Code[phen_all$Code == "Tp"] <- "Trpr"
phen_all$Code[phen_all$Code == "Silene Alba"] <- "Sila"

# change any weird dates
phen_all$Date[phen_all$Date == "0202-06-08"] <- "2022-06-08"
phen_all$Date[phen_all$Date == "0211-06-13"] <- "2021-06-13"
phen_all$Date[phen_all$Date == "2002-07-09"] <- "2021-07-09"
phen_all$Date[phen_all$Date == "2010-10-10"] <- "2021-10-10"
phen_all$Date[phen_all$Date == "2012-06-13"] <- "2021-06-13"
phen_all$Date[phen_all$Date == "2012-07-12"] <- "2021-07-12"
phen_all$Date[phen_all$Date == "2019-06-21"] <- "2021-06-21"

phen_all <- phen_all[,-1] # delete unnecessary columns

phen_all[["Date"]] <- as.Date(phen_all[["Date"]],format="%m/%d/%Y")

# make a column for Julian date
phen_all$Julian <- format(phen_all$Date, "%j")

phen_all <- phen_all[,c(6, 7, 1, 2, 8, 9, 11, 10, 4, 5, 3, 12)]

# upload L1 data
write.csv(phen_all, file.path(dir,"T7_plant_phenology/L1/T7_warmx_plant_phenology_L1.csv"), row.names=F)
