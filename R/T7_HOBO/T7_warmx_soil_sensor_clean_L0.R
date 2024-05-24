# TITLE:          REX: soil sensor data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Mark Hammond, Moriah Young, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive L0 soil sensor data
# DATA OUTPUT:    Clean L1 soil sensor data for OTC plots + irrigated control
# PROJECT:        REX
# DATE:           May 2023

# Clear all existing data
rm(list=ls())

# Set working directory
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Load packages
library(tidyverse)

# Read in data
soil <- read.csv(file.path(dir, "sensors/L0/REX_soil_probe_download_May2024.csv"))
meta_rex <- read.csv(file.path(dir, "REX_template.csv"))
meta_warmx <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))

# fix header
soil <- soil[-1,]

# convert date + time column to POSIX
soil$sample_datetime <- as.POSIXct(soil$sample_datetime,tryFormats = c("%Y-%m-%d %H:%M:%S"), tz="UTC")

# convert temp and moisture to numeric
soil$temperature <- as.numeric(soil$temperature)
soil$vwc <- as.numeric(soil$vwc)
str(soil)

# removing the error in temperature data (where temp is >800)
soil <- soil %>%
  filter(!(temperature > 800))

# merging in rex meta-data for treatments
# this merge gets our plot ID's in the same format as the warmx meta data plot IDs
colnames(meta_rex)[which(names(meta_rex) == "Experimental_Unit_ID")] <- "plot"
soil_meta <- left_join(soil,meta_rex,by=c("plot")) # some plots don't have a match - they end with "SP2"

# subsetting out OTC plots + irrigated control for L1 version
soil_otc <- soil_meta %>%
  filter(Treatment == "T7")
soil_otc <- soil_otc %>%
  filter(Footprint_Treatment_full == "Control (irrigated)" |
         Footprint_Treatment_full == "OTC controls (ambient)" |
         Footprint_Treatment_full == "OTC under rainout")

# removing columns
soil_otc <- subset(soil_otc, select=-c(plot,comment,Footprint_ID,Treatment,Replicate,Footprint,Subplot,FP_location,Subplot_location))

# merging in warmx meta-data for treatments
# this merge gets the correct treatment names for each sensor and rep
colnames(meta_warmx)[which(names(meta_warmx) == "Unique_ID")] <- "Plot_ID"
soil_meta2 <- left_join(soil_otc,meta_warmx,by=c("Plot_ID"))

# remove extra irrigated control rows we didn't use in warmx
soil_clean <- soil_meta2[!is.na(soil_meta2$Subplot_Descriptions),]

# checking which treatments have missing reps
unique(soil_clean[,c('Rep',"Subplot_Descriptions")])

# upload clean data
write.csv(soil_clean, file.path(dir,"sensors/OTC Footprints/L1/T7_warmx_soil_sensors_L1.csv"), row.names=F)

