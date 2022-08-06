# TITLE:          REX: Phoebe's plots ANPP
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond, Jordan Zapata
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
plz_plots <- read.csv(file.path(dir, "T7_ANPP/L0/Phoebe_KBS_LTER_REX_2021_ANPP_PZ_footprints_only.csv"))
jen_plots <- read.csv(file.path(dir, "T7_ANPP/L0/LTER_T7_REX_ANPP_LAU_2021_MHfinal_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# For Zarnetske Lab purposes, we only are analyzing five treatments in REX:
# warmed, drought, warmed + drought, ambient control, and irrigated control
# The first four treatments are in Phoebe's data, and the irr. control is in Jen's data

# Isolating the irrigated control from Jen's data
irr_control <- jen_plots %>%
  filter(Full_Treatment_Description == "Control (irrigated)_Control")

# Renaming columns in Phoebe's data to match the metadata file
names(plz_plots)[names(plz_plots)=="Field_Treatment"] <- "Treatment"
names(plz_plots)[names(plz_plots)=="Field_Rep"] <- "Replicate"
names(plz_plots)[names(plz_plots)=="Ftpt_Number"] <- "Footprint_Location"
names(plz_plots)[names(plz_plots)=="Subplot_Letter"] <- "Subplot_Location"

# Renaming reps in Phoebe's data to match metadata
plz_plots$Replicate[plz_plots$Replicate == 1] = "R1"
plz_plots$Replicate[plz_plots$Replicate == 2] = "R2"
plz_plots$Replicate[plz_plots$Replicate == 3] = "R3"
plz_plots$Replicate[plz_plots$Replicate == 4] = "R4"
plz_plots$Replicate[plz_plots$Replicate == 5] = "R5"
plz_plots$Replicate[plz_plots$Replicate == 6] = "R6"
plz_plots$Treatment <- "T7"

# making sure PLZ data and metadata is in the same format
str(plz_plots)
str(meta)

# removing columns we don't need
meta = subset(meta, select = -c(Footprint,Subplot))
plz_plots = subset(plz_plots, select = -c(X,X.1,Notes))

# merging PLZ data with metadata
plz_data <- left_join(plz_plots, meta, by = c("Treatment","Replicate","Footprint_Location","Subplot_Location"))

# renaming reps in irr. control data to match PLZ data
names(irr_control)[names(irr_control)=="Field_Treatment"] <- "Treatment"
names(irr_control)[names(irr_control)=="Field_Rep_Code"] <- "Replicate"
names(irr_control)[names(irr_control)=="Footprint_Code"] <- "Footprint_Location"
names(irr_control)[names(irr_control)=="Subplot_Location_Letter"] <- "Subplot_Location"
names(irr_control)[names(irr_control)=="Field_Unique_Location_ID"] <- "Field_Loc_Code"
names(irr_control)[names(irr_control)=="Full_Treatment_Description"] <- "Subplot_Descriptions"
names(irr_control)[names(irr_control)=="ANPP_.g._per_0.20m2"] <- "Dried_Plant_Biomass_g"

# Renaming footprints and treatments
irr_control$Footprint_Location[irr_control$Footprint_Location == "F2"] = 2
irr_control$Footprint_Location[irr_control$Footprint_Location == "F3"] = 3
irr_control$Footprint_Location[irr_control$Footprint_Location == "F4"] = 4
irr_control$Footprint_Location[irr_control$Footprint_Location == "F6"] = 6
irr_control$Subplot_Descriptions[irr_control$Subplot_Descriptions == "Control (irrigated)_Control"] = "irrigated_control"

# merging irrigated control data with metadata
irr_control <- merge(irr_control, meta, by = c("Treatment","Replicate","Footprint_Location","Subplot_Location", 
                                               "Subplot_Descriptions"))

# combining irr. control & PLZ data into one dataframe
comb_data <- rbind(plz_data,irr_control)

# merging data with taxon information
names(taxon)[names(taxon)=="LTER_code"] <- "Species_Code" # making species column the same name
comb_data[,6] = toupper(comb_data[,6]) # capitalizing species codes in comb_data
data <- left_join(comb_data, taxon, by = c("Species_Code"))

# removing unneeded columns
data = subset(data, select = -c(code, USDA_code, site, old_name, old_code, resolution, note1, note2))

# upload L1 data
write.csv(data, file.path(dir,"T7_ANPP/L1/T7_warmx_ANPP_20121_L1.csv"), row.names=F)
