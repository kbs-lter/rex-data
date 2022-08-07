# TITLE:          REX: warmx plant composition data cleaning
# AUTHORS:        Moriah Young
# COLLABORATORS:  Kara Dobson, Phoebe Zarnetske, Mark Hammond, 
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_plant_comp L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_plant_comp L1 folder
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
plantcomp22 <- read.csv(file.path(dir, "T7_plant_comp/L0/T7_warmx_plantcomp_2022_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

plantcomp22 <- plantcomp22[-c(997:1006),]

# 2022 data
plantcomp22 <- plantcomp22[,-c(1, 3, 9, 10)] # delete unnecessary columns
names(plantcomp22)[names(plantcomp22)=="Footprint"] <- "Footprint_Location"
names(plantcomp22)[names(plantcomp22)=="Quad"] <- "Subplot_Location"
names(plantcomp22)[names(plantcomp22)=="Species"] <- "Code"

plantcomp22$Date <- mdy(plantcomp22$Date) # change date to %m/%d/%Y format
plantcomp22[["Date"]] <- as.Date(plantcomp22[["Date"]],format="%m/%d/%Y")

# check that there aren't any misspellings
unique(sort(plantcomp22[["Code"]])) # check that there aren't any misspellings
unique(sort(plantcomp22[["Date"]])) # check that there are no weird dates

# change species names
plantcomp22$Code[plantcomp22$Code == "Brin "] <- "Brin"

# combine meta data with plant comp dataframe
plantcomp22 <- merge(plantcomp22, meta, by=(c("Rep", "Footprint_Location", "Subplot_Location")))

plantcomp22 <- plantcomp22[,-1] # delete unnecessary columns

plantcomp22[["Date"]] <- as.Date(plantcomp22[["Date"]],format="%m/%d/%Y")

# make a column for Julian date
plantcomp22$Julian <- format(plantcomp22$Date, "%j")

plantcomp22 <- plantcomp22[,c(6, 7, 1, 2, 8, 9, 11, 10, 4, 5, 3, 12)]

# upload L1 data
write.csv(plantcomp22, file.path(dir,"T7_plant_comp/L1/T7_warmx_plantcomp_L1.csv"), row.names=F)
