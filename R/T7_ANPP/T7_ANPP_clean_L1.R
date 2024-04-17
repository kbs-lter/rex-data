# TITLE:          REX: T7 plots ANPP, all years
# AUTHORS:        Kara Dobson, Moriah Young, Phoebe Zarnetske
# COLLABORATORS:  Mark Hammond, Jordan Zapata, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           Jan 2023; rev. Aug 2023 (incorporated all indiv. yr scripts into this one as master ANPP script); 
#                       rev. April 2024 (adding 2023 ANPP data)

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# NOTES/TO DO
# Under "Species_Code" sometimes there is "BULK" in 2022 or "PLOT LEVEL" in 2021. I'm pretty sure these mean the same thing
# We should choose one name and change the other to match, either bulk or plot level. Some plots were only harvested at the 
# plot level (not sorted to species or by group), so there is only one ANPP biomass measure associated with that plot,
# which is where the plot level or bulk labeling comes in under "Species_Code"

# Read in data (no data in 2020 due to COVID)
anpp19 <- read.csv(file.path(dir, "T7_ANPP/L0/2019PreTreatmentANPP/T7_REX_ANPP_2019_L0.csv"))
# 2021: subplots from warmed x insecticide treatment set only
anpp21a <- read.csv(file.path(dir, "T7_ANPP/L0/2021ANPP/T7_REX_ANPP_warmx_2021_L0 (1).csv"))
# 2021: subplots from other treatment set (Jen Lau)
anpp21b <-read.csv(file.path(dir, "T7_ANPP/L0/2021ANPP/LTER_T7_REX_ANPP_LAU_2021_MHfinal_L0.csv"))
# 2022
anpp22 <- read.csv(file.path(dir, "T7_ANPP/L0/2022ANPP/T7_REX_ANPP_2022_L0.csv"))
# 2023: subplots from warmed x insecticide treatment set only
anpp23a <- read.csv(file.path(dir, "T7_ANPP/L0/2023ANPP/T7_warmx_REX_ANPP_2023_L0.csv"))
# 2023:subplots from other treatment set (Jen Lau)
anpp23b <- read.csv(file.path(dir, "T7_ANPP/L0/2023ANPP/KBS_REX_T7_2023_ANPP_0.2_and_0.8m_scales_sort_to_species_Jen.csv"))
anpp23b <- anpp23b[-c(822:1258),]
anpp23_meta <- read.csv(file.path(dir, "T7_ANPP/L0/2023ANPP/Prep work and methods/REX 2023 ANPP bag labeling - T7 only.csv"))
names(anpp23_meta)[names(anpp23_meta)=="Subplot_ID_Number"] <- "Subplot_Unique_ID_Number" 
# merge the two 2023 files together
anpp23a <- full_join(anpp23a, anpp23_meta, by = "Subplot_Unique_ID_Number")
anpp23a <- anpp23a[!is.na(anpp23a$Date_of_Harvest),]
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
anpp21a = subset(anpp21a, select = -c(Notes,Field_Loc_Code))
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
anpp23a = subset(anpp23a, select = -c(Subplot_Unique_ID_Number,
                                    Bag_or_Envelope,
                                    Bag_Size,
                                    Direct_or_Indirect_Weighing_Measurement,
                                    Dried_Biomass_g_with_Bag_mass,
                                    Field_Notes,
                                    Original_Data_entry_order,
                                    Proofing_Notes,
                                    Person_who_sorted_to_species,
                                    Plot_Location_ID,
                                    Footprint_ID_Number,
                                    X, X.1, X.2, X.3, X.4, X.5, X.6, X.7, X.8, X.9))

anpp23b = subset(anpp23b, select = -c(Subplot_ID,
                                      Footprint_ID,
                                      Subplot_Scale,
                                      Bulk_or_Species_Sort,
                                      page_number,
                                      data_entry_unique_number,
                                      Used_in_ANPP.calculaton,
                                      proofing_notes,
                                      Species_Name))

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

names(anpp23a)[names(anpp23a)=="Date_of_Harvest"] <- "Date"
names(anpp23a)[names(anpp23a)=="Dried_Biomass_grams"] <- "plant_biomass_gm2"
names(anpp23a)[names(anpp23a)=="Scale._meter_square"] <- "Scale_meter_square"

names(anpp23b)[names(anpp23b)=="Date_of_Harvest"] <- "Date"
names(anpp23b)[names(anpp23b)=="Dried_Plant_Biomass_grams"] <- "plant_biomass_gm2"
names(anpp23b)[names(anpp23b)=="Scale_of_Harvest_meter_square"] <- "Scale_meter_square"
names(anpp23b)[names(anpp23b)=="Subplot_Treatment"] <- "Subplot"

# making sure data and site data is in the same format
str(anpp19)
str(anpp21a)
str(anpp21b)
str(anpp22)
str(anpp23a)
str(anpp23b)

# Add "Year" column
anpp19$Year<-2019
anpp21a$Year<-2021
anpp21b$Year<-2021
anpp22$Year<-2022
anpp23a$Year<-2023
anpp23b$Year<-2023

# Add "Scale_meter_square" column - area clipped is different depending on year
anpp19$Scale_meter_square <- 1.0 # should check what size area LTER core plots were harvested this year
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
#anpp19 <- anpp19[-which(anpp19$Plot_ID == ""), ]

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
# check that there aren't any misspellings for species codes
unique(sort(anpp21a[["Species_Code"]]))
unique(sort(anpp21b[["Species_Code"]]))
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
anpp21b$FP_location[anpp21b$FP_location == "F7"] = 7

anpp21b$FP_location<-as.numeric(anpp21b$FP_location)

## 2022
# check that there aren't any misspellings for species codes
unique(sort(anpp22[["Species_Code"]]))
anpp22$Species_Code[anpp22$Species_Code == "ROBPSE"] <- "Rubsp" # change species names
unique(sort(anpp22[["Field_Loc_Code"]])) # check that there aren't any weird typos

# adding together live and dead clover measurements
# first, renaming all clover to "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "Trfpr (alive)"] <- "TRFPR"
anpp22$Species_Code[anpp22$Species_Code == "Trfpr (dead)"] <- "TRFPR"

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

## 2023a
# check that there aren't any misspellings for species codes
unique(sort(anpp23a[["Species_Code"]]))
anpp23a$Species_Code[anpp23a$Species_Code == "ROBPSE"] <- "RUBSP" # change species names
anpp23a$Species_Code[anpp23a$Species_Code == "ROBSPE"] <- "RUBSP" # change species names
anpp23a$Species_Code[anpp23a$Species_Code == "HYPEE"] <- "HYPPE" # change species names

anpp23a$Date <- mdy(anpp23a$Date) # change date to %m/%d/%Y format
anpp23a[["Date"]] <- as.Date(anpp23a[["Date"]],format="%m/%d/%Y")

## 2023b
# check that there aren't any misspellings for species codes
unique(sort(anpp23b[["Species_Code"]]))

anpp23b$Date <- mdy(anpp23b$Date) # change date to %m/%d/%Y format
anpp23b[["Date"]] <- as.Date(anpp23b[["Date"]],format="%m/%d/%Y")

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

anpp_data <- full_join(anpp192122, anpp23a)

anpp_data <- full_join(anpp_data, anpp23b)

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
                                          Footprint_ID,
                                          Subplot_ID))

# order columns
# 
col_order <- c("Year", "Date", "Treatment", "Replicate", "Footprint", "FP_location", "Subplot", "Subplot_location",
               "Experimental_Unit_ID", "Plot_ID", "Footprint_Treatment_full","Scale_meter_square", "plant_biomass_gm2", 
               "Species_Code", "Group_Code", "scientific_name", "common_name", "origin", "group", "family", "duration", 
               "growth_habit")
anpp_data <- anpp_data[,col_order]

# upload L1 data
write.csv(anpp_data, file.path(dir,"T7_ANPP/L1/T7_ANPP_L1.csv"), row.names=F)

# making a warmx only (with irrigated controls) data frame to upload to L1 folder

meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))

# filter out just warmx plots and irrigated controls
anpp_warmx <- anpp_data %>% filter(Footprint == c("OC", "OR"))
anpp_IR <- anpp_data %>% filter(Footprint == "IR" & Subplot == "C")

# join the two data frames above together
anpp_warmx1 <- full_join(anpp_warmx, anpp_IR)

names(anpp_warmx1)[names(anpp_warmx1)=="Plot_ID"] <- "Unique_ID"
anpp_warmx1 <- anpp_warmx1[,-9] # remove "Experimental_Unit_ID"
meta <- meta[,-c(5,10,13)] # remove "Footprint_Location", "Subplot_Location", "Unique_Field_Location_Code"

anpp_warmx <- full_join(anpp_warmx1, meta, by = c("Unique_ID", "Subplot", "Treatment", "Replicate", "Footprint"))

col_order1 <- c("Year", "Date", "Treatment", "Replicate", "Rep", "Footprint", "FP_location", "Subplot", "Subplot_location",
               "Unique_ID", "Footprint_Treatment_full", "Subplot_Descriptions", "Drought", "Warming", "Insecticide", 
               "Scale_meter_square", "plant_biomass_gm2", "Species_Code", "Group_Code", "scientific_name", "common_name", 
               "origin", "group", "family", "duration", "growth_habit")
anpp_warmx <- anpp_warmx[,col_order1]

#In 2023, plots were harvested at 0.2 and 0.8 areas. Below sums the 0.2 and 0.8 values for each unique subplot and species
#and then adds those back into the anpp data set
# filter out 2023 data
anpp23 <- anpp_warmx %>% filter(Year == 2023)

# create new data frame that sums the 0.2 and 0.8 values for each unique subplot and species
anpp23_sum <- anpp23 %>%
        group_by(Unique_ID, Species_Code) %>%
        mutate(plant_biomass_gm2 = sum(plant_biomass_gm2)) %>%
        distinct(Unique_ID, .keep_all = TRUE)

anpp23_sum <- anpp23_sum[,-16] # remove scale column

anpp23_sum$Scale_meter_square <- 1 # create scale column again and put "1" for all of them

anpp_warmx <- full_join(anpp_warmx, anpp23_sum) # merge back with the anpp_warmx data frame

# NOTE: After the previous step, for 2023 there's the 1.0, 0.2 and 0.8 scale data in the cleaned uploaded data set.
# 0.2 and 0.8 were added together to create the 1.0 meter square scale data 
# (so in a way there is duplicate data in the 2023 anpp data)

# upload L1 data
write.csv(anpp_warmx, file.path(dir,"T7_ANPP/L1/T7_warmx_ANPP_L1.csv"), row.names=F)

