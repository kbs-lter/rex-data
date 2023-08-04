# TITLE:          REX: T7 plots ANPP, all years
# AUTHORS:        Kara Dobson, Moriah Young, Phoebe Zarnetske
# COLLABORATORS:  Mark Hammond, Jordan Zapata, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           Jan 2023; rev. Aug 2023 (incorporated all indiv. yr scripts into this one as master ANPP script)

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data (no data in 2020 due to COVID)
anpp19 <- read.csv(file.path(dir, "T7_ANPP/L0/2019PreTreatmentANPP/T7_REX_ANPP_2019_L0.csv"))
# 2021: subplots from warmed x insecticide treatment set only
anpp21a <- read.csv(file.path(dir, "T7_ANPP/L0/2021ANPP/T7_REX_ANPP_warmX_2021_L0.csv"))
# 2021: subplots from other treatment set (Jen Lau)
anpp21b <-read.csv(file.path(dir, "T7_ANPP/L0/2021ANPP/LTER_T7_REX_ANPP_LAU_2021_MHfinal_L0.csv"))
anpp22 <- read.csv(file.path(dir, "T7_ANPP/L0/2022ANPP/T7_REX_ANPP_2022_L0.csv"))
# site and species look-ups
site <- read.csv(file.path(dir, "REX_template.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Subset out just T7
site<-site[grepl('T7',site$Treatment),]

# Make the ANPP data match the site file format
names(anpp19)[names(anpp19)=="Quad"] <- "Subplot_location" 
names(anpp19)[names(anpp19)=="PZ_footprints_Field_Code"] <- "Plot_ID" 
names(anpp19)[names(anpp19)=="Dried_plant_biomass_g_per_metersquare"] <- "plant_biomass_gm2" 
names(anpp19)[names(anpp19)=="Rep"] <- "Replicate"

names(anpp21a)[names(anpp21a)=="PZ_footprints_Field_Code"] <- "Subplot_location" 
names(anpp21a)[names(anpp21a)=="Field_Rep"] <- "Replicate" 
names(anpp21a)[names(anpp21a)=="Ftpt_Number"] <- "FP_location" 
names(anpp21a)[names(anpp21a)=="Dried_Plant_Biomass_g"] <- "plant_biomass_gm2" 
names(anpp21a)[names(anpp21a)=="Field_Treatment"] <- "Treatment"
names(anpp21a)[names(anpp21a)=="Subplot_Letter"] <- "Subplot_location"

names(anpp21b)[names(anpp21b)=="Field_Treatment"] <- "Treatment"
names(anpp21b)[names(anpp21b)=="Field_Rep_Code"] <- "Replicate"
names(anpp21b)[names(anpp21b)=="Footprint_Code"] <- "FP_location"
names(anpp21b)[names(anpp21b)=="Subplot_Location_Letter"] <- "Subplot_location"
names(anpp21b)[names(anpp21b)=="ANPP_.g._per_0.20m2"] <- "plant_biomass_gm2"

names(anpp22)[names(anpp22)=="Date_of_Harvest"] <- "Date"
names(anpp22)[names(anpp22)=="Field_Treatment_Number"] <- "Treatment"
names(anpp22)[names(anpp22)=="Field_Rep"] <- "Replicate"
names(anpp22)[names(anpp22)=="Footprint_Number"] <- "FP_location"
names(anpp22)[names(anpp22)=="Subplot_Letter"] <- "Subplot_location"

# making sure data and site data is in the same format
str(anpp19)
str(anpp21a)
str(anpp21b)
str(anpp22)
str(site)

# removing columns we don't need
anpp19 = subset(anpp19, select = -c(Old_Footprint_ID_east_to_west,
                                    New_Field_Location_Code,
                                    Old_Field_Code,
                                    New_Footprint_ID_west_to_east,
                                    Footprint_Owner))
anpp21a = subset(anpp21a, select = -c(X,X.1,Notes,Field_Loc_Code))
anpp21b = subset(anpp21b, select = -c(Field_Unique_Location_ID,Full_Treatment_Description))
anpp22 = subset(anpp22, select = -c(Unique_Field_Location_Code,
                                    Footprint_Owner,
                                    Type_of_Weighing._Direct_or_Indirect,
                                    Dried_Bag.mass_g,
                                    Type_of_Bag,
                                    Sum_Bag_plus_Dried_Plant_Biomass_gram,
                                    Notes,
                                    data_entry_ID,
                                    Mark_needs_to_do_further_proofing))

# Add "Year"
anpp19$Year<-2019
anpp21a$Year<-2021
anpp21b$Year<-2021
anpp22$Year<-2022

## 2019
# When ANPP was collected in 2019, the irrigated control footprint location and subplot treatment locations 
# had not been determined. ANPP was taken in 1mx2m(?) sq area around the center of the footprint location.
# irrigated controls are in T7: R1F2, R2F4, R3F6, R4F3, R5F2, R6F4
unique(sort(anpp19[["Group_Code"]])) # check that there aren't any misspellings
anpp19$Group_Code[anpp19$Group_Code == "Robpse"] <- "Rubsp" # change species names
unique(sort(anpp19[["Plot_ID"]])) # check that there aren't any weird typos

# Rows without Plot_ID are footprints that aren't involving warmX and aren't irrigated control; 
# They are LTER CORE.
# Comment out if you do not want to remove them
anpp19 <- anpp19[-which(anpp19$Plot_ID == ""), ]

anpp19$Date <- mdy(anpp19$Date) # change date to %m/%d/%Y format
anpp19[["Date"]] <- as.Date(anpp19[["Date"]],format="%m/%d/%Y")

# Renaming reps to match site template
anpp19$Replicate[anpp19$Replicate == 1] = "R1"
anpp19$Replicate[anpp19$Replicate == 2] = "R2"
anpp19$Replicate[anpp19$Replicate == 3] = "R3"
anpp19$Replicate[anpp19$Replicate == 4] = "R4"
anpp19$Replicate[anpp19$Replicate == 5] = "R5"
anpp19$Replicate[anpp19$Replicate == 6] = "R6"

## 2021
# Renaming reps to match site template
anpp21a$Replicate[anpp21a$Replicate == 1] = "R1"
anpp21a$Replicate[anpp21a$Replicate == 2] = "R2"
anpp21a$Replicate[anpp21a$Replicate == 3] = "R3"
anpp21a$Replicate[anpp21a$Replicate == 4] = "R4"
anpp21a$Replicate[anpp21a$Replicate == 5] = "R5"
anpp21a$Replicate[anpp21a$Replicate == 6] = "R6"

# Renaming FP_location to match site template
anpp21b$FP_location[anpp21b$FP_location == "F1"] = 1
anpp21b$FP_location[anpp21b$FP_location == "F2"] = 2
anpp21b$FP_location[anpp21b$FP_location == "F3"] = 3
anpp21b$FP_location[anpp21b$FP_location == "F4"] = 4
anpp21b$FP_location[anpp21b$FP_location == "F5"] = 5
anpp21b$FP_location[anpp21b$FP_location == "F6"] = 6

anpp21b$FP_location<-as.numeric(anpp21b$FP_location)

## 2022
# adding together live and dead clover measurements
# making all species capitalized
anpp22$Species_Code = toupper(anpp22$Species_Code)

# first, renaming all clover to "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "TRFPR (ALIVE)"] <- "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "TRFPR (DEAD)"] <- "TRFPR"

# calculate sums of alive and dead
anpp22_sum <- anpp22 %>%
  group_by(Field_Loc_Code) %>%
  filter(Species_Code == "TRFPR") %>%
  mutate(Dried_Plant_Biomass_gram = sum(Dried_Plant_Biomass_gram)) %>%
  distinct(Field_Loc_Code, .keep_all = TRUE)

# remove clover from original anpp22 data
anpp22 <- anpp22 %>%
  filter(!(Species_Code == "TRFPR"))

# merge summed TRFPR with anpp data
anpp22 <- bind_rows(anpp22, anpp22_sum)

# check species code names
unique(anpp22$Species_Code)

# remove "SDEAD" and "SURFL" from original anpp data because this does not count towards ANPP
anpp22 <- anpp22[!grepl('SDEAD',anpp22$Species_Code),]
anpp22 <- anpp22[!grepl('SURFL',anpp22$Species_Code),]

# check species code names
unique(anpp22$Species_Code)

# omit Field_Loc_Code
anpp22$Field_Loc_Code<-NULL

anpp22$Date <- mdy(anpp22$Date) # change date to %m/%d/%Y format
anpp22[["Date"]] <- as.Date(anpp22[["Date"]],format="%m/%d/%Y")

# Renaming reps to match site template
anpp22$Replicate[anpp22$Replicate == 1] = "R1"
anpp22$Replicate[anpp22$Replicate == 2] = "R2"
anpp22$Replicate[anpp22$Replicate == 3] = "R3"
anpp22$Replicate[anpp22$Replicate == 4] = "R4"
anpp22$Replicate[anpp22$Replicate == 5] = "R5"
anpp22$Replicate[anpp22$Replicate == 6] = "R6"

# rename biomass column
names(anpp22)[names(anpp22)=="Dried_Plant_Biomass_gram"] <- "plant_biomass_gm2"

# merging anpp19 data with sitedata
anpp19.site <- left_join(anpp19, site, by = c("Treatment","Replicate","Subplot_location","Plot_ID"))

# merging anpp21a data with sitedata
anpp21a.site <- left_join(anpp21a, site, by = c("Treatment","Replicate","FP_location","Subplot_location"))

# merging anpp21b data with sitedata
anpp21b.site <- left_join(anpp21b, site, by = c("Treatment","Replicate","FP_location","Subplot_location")) 
     
# merging anpp22 data with sitedata
anpp22.site <- left_join(anpp22, site, by = c("Treatment","Replicate","FP_location","Subplot_location")) 

# merging anpp21 data 
anpp21.site <- full_join(anpp21a.site, anpp21b.site)

anpp1921_data <- full_join(anpp19.site,anpp21.site)

anpp_data <- full_join(anpp1921_data,anpp22.site)

### Phoebe stopped updating here Aug 3 2023 ###
# merging data with taxon information
names(taxon)[names(taxon)=="LTER_code"] <- "Species_Code" # making species column the same name
anpp_data$Species_Code = toupper(anpp_data$Species_Code)
anpp_data <- left_join(anpp_data, taxon, by = c("Species_Code"))

# removing unneeded columns
anpp_data = subset(anpp_data, select = -c(code, USDA_code, site, old_name, old_code, resolution, note1, note2))

# upload L1 data
write.csv(anpp_data, file.path(dir,"T7_ANPP/L1/T7_ANPP_L1.csv"), row.names=F)

