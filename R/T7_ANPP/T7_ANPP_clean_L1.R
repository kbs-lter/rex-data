# TITLE:          REX: T7 plots ANPP, all years
# AUTHORS:        Kara Dobson, Moriah Young, Phoebe Zarnetske
# COLLABORATORS:  Mark Hammond, Jordan Zapata, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           Jan 2023; rev. Aug 2023 (incorporated all indiv. yr scripts into this one as master ANPP script); March 2024 (adding 2023 ANPP data)

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
# 2022
anpp22 <- read.csv(file.path(dir, "T7_ANPP/L0/2022ANPP/T7_REX_ANPP_2022_L0.csv"))
# 2023
anpp23 <- read.csv(file.path(dir, "T7_ANPP/L0/2023ANPP/T7_REX_ANPP_2023_L0.csv"))
anpp23_meta <- read.csv(file.path(dir, "T7_ANPP/L0/2023ANPP/Prep work and methods/REX 2023 ANPP bag labeling - T7 only.csv"))
names(anpp23_meta)[names(anpp23_meta)=="Subplot_ID_Number"] <- "Subplot_Unique_ID_Number" 
# merge the two 2023 files together
anpp23 <- full_join(anpp23, anpp23_meta, by = "Subplot_Unique_ID_Number")
# site and species look-ups
site <- read.csv(file.path(dir, "REX_template.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Subset out just T7
site <- site[grepl('T7',site$Treatment),]

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
anpp23 = subset(anpp23, select = -c(Subplot_Unique_ID_Number,
                                    Bag_or_Envelope,
                                    Bag_Size,
                                    Direct_or_Indirect_Weighing_Measurement,
                                    Dried_Biomass_g_with_Bag_mass,
                                    Field_Notes,
                                    Original_Data_entry_order,
                                    Proofing_Notes,
                                    Person_who_sorted_to_species,
                                    Experimental_Unit_ID,
                                    Plot_Location_ID,
                                    Footprint_Treatment_full,
                                    Experimental_Unit_ID,
                                    Footprint_ID_Number,
                                    X, X.1, X.2, X.3, X.4, X.5, X.6, X.7, X.8, X.9))

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
names(anpp22)[names(anpp22)=="Dried_Plant_Biomass_gram"] <- "plant_biomass_gm2"

names(anpp23)[names(anpp23)=="Date_of_Harvest"] <- "Date"
names(anpp23)[names(anpp23)=="Dried_Biomass_grams"] <- "plant_biomass_gm2"
names(anpp23)[names(anpp23)=="Scale._meter_square"] <- "Scale_meter_square"

# making sure data and site data is in the same format
str(anpp19)
str(anpp21a)
str(anpp21b)
str(anpp22)
str(anpp23)

# Add "Year"
anpp19$Year<-2019
anpp21a$Year<-2021
anpp21b$Year<-2021
anpp22$Year<-2022
anpp23$Year<-2023

# Add "Scale_meter_square"
anpp19$Scale_meter_square <- 1.0
anpp21a$Scale_meter_square <- 0.2
anpp21b$Scale_meter_square <- 0.2
anpp22$Scale_meter_square <- 0.2

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
# first, renaming all clover to "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "TRFPR (ALIVE)"] <- "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "TRFPR (DEAD)"] <- "TRFPR"

# calculate sums of alive and dead
anpp22_sum <- anpp22 %>%
  group_by(Field_Loc_Code) %>%
  filter(Species_Code == "TRFPR") %>%
  mutate(plant_biomass_gm2 = sum(plant_biomass_gm2)) %>%
  distinct(Field_Loc_Code, .keep_all = TRUE)

# remove clover from original anpp22 data
anpp22 <- anpp22 %>%
  filter(!(Species_Code == "TRFPR"))

# merge summed TRFPR with anpp data
anpp22 <- bind_rows(anpp22, anpp22_sum)

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

## 2023
anpp23$Date <- mdy(anpp23$Date) # change date to %m/%d/%Y format
anpp23[["Date"]] <- as.Date(anpp23[["Date"]],format="%m/%d/%Y")

# actually probably don't want to do this in this cleaning script!!
# calculate sums of 0.2 and 0.8 scales together
#anpp23_sum <- anpp23 %>%
#        group_by(Plot_ID, Species_Code) %>%
#        mutate(plant_biomass_gm2 = sum(plant_biomass_gm2)) %>%
#        distinct(Plot_ID, .keep_all = TRUE)
#
## remove scale column
#anpp23_sum <- anpp23_sum[,-2]

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

anpp1921_data <- full_join(anpp19.site, anpp21.site)

anpp192122 <- full_join(anpp1921_data, anpp22.site)

anpp_data <- full_join(anpp192122, anpp23)

# remove "SDEAD" and "SURFL" from original anpp data because this does not count towards ANPP
anpp_data <- anpp_data[!grepl('SDEAD',anpp_data$Species_Code),]
anpp_data <- anpp_data[!grepl('SURFL',anpp_data$Species_Code),]

# change species name to all uppercase
anpp_data$Species_Code = toupper(anpp_data$Species_Code)

# check species code names
unique(anpp_data$Species_Code)

# merging data with taxon information
names(taxon)[names(taxon)=="LTER_code"] <- "Species_Code" # making species column the same name
anpp_data <- left_join(anpp_data, taxon, by = c("Species_Code"))

# removing unneeded columns
anpp_data = subset(anpp_data, select = -c(code, 
                                          USDA_code, 
                                          site, 
                                          old_name, 
                                          old_code, 
                                          resolution, 
                                          note1, 
                                          note2, 
                                          MH_rhizomatous_suggestion,
                                          rhizomatous,
                                          Footprint_ID))

# upload L1 data
write.csv(anpp_data, file.path(dir,"T7_ANPP/L1/T7_ANPP_L1.csv"), row.names=F)

