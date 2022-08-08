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
plantcomp21 <- read.csv(file.path(dir, "T7_plant_comp/L0/T7_plantcomp_2021_L0.csv"))
plantcomp22 <- read.csv(file.path(dir, "T7_plant_comp/L0/T7_warmx_plantcomp_2022_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

plantcomp22 <- plantcomp22[-c(997:1006),] # delete rows with NAs

# 2021 data
plantcomp21 <- plantcomp21[,-c(1, 3, 5, 10, 11)] # delete unnecessary columns
names(plantcomp21)[names(plantcomp21)=="New_Footprint"] <- "Footprint_Location"
names(plantcomp21)[names(plantcomp21)=="Quad"] <- "Subplot_Location"
names(plantcomp21)[names(plantcomp21)=="Species"] <- "Code"

# 2022 data
plantcomp22 <- plantcomp22[,-c(1, 3, 9, 10)] # delete unnecessary columns
names(plantcomp22)[names(plantcomp22)=="Footprint"] <- "Footprint_Location"
names(plantcomp22)[names(plantcomp22)=="Quad"] <- "Subplot_Location"
names(plantcomp22)[names(plantcomp22)=="Species"] <- "Code"

# merge 2021 and 2022 data together
plantcomp <-  full_join(plantcomp21, plantcomp22)

plantcomp$Date <- mdy(plantcomp$Date) # change date to %m/%d/%Y format
plantcomp[["Date"]] <- as.Date(plantcomp[["Date"]],format="%m/%d/%Y")

# check that there aren't any misspellings
unique(sort(plantcomp[["Code"]])) # check that there aren't any misspellings
unique(sort(plantcomp[["Date"]])) # check that there are no weird dates

# change species names
plantcomp$Code[plantcomp$Code == "Brin "] <- "Brin"
plantcomp$Code[plantcomp$Code == "Hisp "] <- "Hisp"

# combine meta data with plant comp dataframe
plantcomp1 <- merge(plantcomp, meta, by=(c("Rep", "Footprint_Location", "Subplot_Location")))

plantcomp1 <- plantcomp1[,-1] # delete unnecessary columns

plantcomp1[["Date"]] <- as.Date(plantcomp1[["Date"]],format="%m/%d/%Y")

# make a column for Julian date
plantcomp1$Julian <- format(plantcomp1$Date, "%j")

plantcomp1 <- plantcomp1[,c(6, 7, 1, 2, 8, 9, 11, 10, 4, 5, 3, 12)]

# upload L1 data
write.csv(plantcomp1, file.path(dir,"T7_plant_comp/L1/T7_warmx_plantcomp_L1.csv"), row.names=F)
