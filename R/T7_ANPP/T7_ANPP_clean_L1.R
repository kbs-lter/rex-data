# TITLE:          REX: T7 plots ANPP, all years
# AUTHORS:        Kara Dobson, Moriah Young, Phoebe Zarnetske
# COLLABORATORS:  Mark Hammond, Jordan Zapata
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           Jan 2023; rev. Aug 2023

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
meta <- read.csv(file.path(dir, "REX_T7_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Make the ANPP data match the meta-data file format
names(anpp19)[names(anpp19)=="Quad"] <- "Subplot_location" 
names(anpp19)[names(anpp19)=="PZ_footprints_Field_Code"] <- "Unique_ID" 
names(anpp19)[names(anpp19)=="Dried_plant_biomass_g_per_metersquare"] <- "plant_biomass_gm2" 

names(anpp21a)[names(anpp21a)=="PZ_footprints_Field_Code"] <- "Subplot_location" 
names(anpp21a)[names(anpp21a)=="Field_Rep"] <- "Rep" 
names(anpp21a)[names(anpp21a)=="Ftpt_Number"] <- "FP_location" 
names(anpp21a)[names(anpp21a)=="Dried_Plant_Biomass_g"] <- "plant_biomass_gm2" 
names(anpp21a)[names(anpp21a)=="Field_Treatment"] <- "Treatment"
names(anpp21a)[names(anpp21a)=="Subplot_Letter"] <- "Subplot_location"

names(anpp21b)[names(anpp21b)=="Field_Treatment"] <- "Treatment"
names(anpp21b)[names(anpp21b)=="Field_Rep_Code"] <- "Replicate"
names(anpp21b)[names(anpp21b)=="Footprint_Code"] <- "FP_treatment"
names(anpp21b)[names(anpp21b)=="Subplot_Location_Letter"] <- "Subplot_location"
names(anpp21b)[names(anpp21b)=="ANPP_.g._per_0.20m2"] <- "plant_biomass_gm2"

names(anpp22)[names(anpp22)=="Date_of_Harvest"] <- "Date"
names(anpp22)[names(anpp22)=="Field_Treatment_Number"] <- "Treatment"
names(anpp22)[names(anpp22)=="Field_Rep"] <- "Rep"
names(anpp22)[names(anpp22)=="Footprint_Number"] <- "FP_location"
names(anpp22)[names(anpp22)=="Subplot_Letter"] <- "Subplot_location"

# making sure data and metadata is in the same format
str(anpp19)
str(anpp21a)
str(anpp21b)
str(anpp22)
str(meta)

# removing columns we don't need
anpp19 = subset(anpp19, select = -c(Old_Footprint_ID_east_to_west,
                                    New_Field_Location_Code,
                                    Old_Field_Code,
                                    New_Footprint_ID_west_to_east))
anpp21a = subset(anpp21a, select = -c(X,X.1,Notes))
anpp21b = subset(anpp21b, select = -c(Field_Loc_Code, Unique_Field_Location_Code
                                      ))
anpp22 = subset(anpp22, select = -c(Unique_Field_Location_Code,
                                    Type_of_Weighing._Direct_or_Indirect,
                                    Dried_Bag.mass_g,
                                    Type_of_Bag,
                                    Sum_Bag_plus_Dried_Plant_Biomass_gram,
                                    Notes,
                                    data_entry_ID,
                                    Mark_needs_to_do_further_proofing))

## 2022: adding together live and dead clover measurements
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

# merging anpp19 data with metadata
anpp19.meta <- left_join(anpp19, meta, by = c("Treatment","Rep","Subplot_location","Unique_ID"))

# merging anpp21a data with metadata
anpp21a.meta <- left_join(anpp21a, meta, by = c("Treatment","Rep","FP_location","Subplot_location"))

# merging anpp21b data with metadata
anpp21b.meta <- left_join(anpp21b, meta, by = c("Treatment","Replicate","FP_treatment","Subplot_location")) 
     
# merging anpp22 data with metadata
anpp22.meta <- left_join(anpp22, meta, by = c("Treatment","Rep","FP_location","Subplot_location")) 

# rename biomass column
names(anpp22.meta)[names(anpp22.meta)=="Dried_Plant_Biomass_gram"] <- "plant_biomass_gm2"
                         
# merging anpp21 data 
anpp21.meta <- full_join(anpp21a.meta, anpp21b.meta)

anpp1921_data <- full_join(anpp19.meta,anpp21.meta)

anpp_data <- full_join(anpp1921_data,anpp22.meta)

### Phoebe stopped updating here Aug 3 2023 ###
# merging data with taxon information
names(taxon)[names(taxon)=="LTER_code"] <- "Species_Code" # making species column the same name
anpp_data[,6] = toupper(taxon[,6]) # capitalizing species codes in comb_data
anpp_data <- left_join(anpp_data, taxon, by = c("Species_Code"))


# making all species capitalized
anpp_data$Species_Code = toupper(anpp_data$Species_Code)

# upload L1 data
write.csv(anpp_data, file.path(dir,"T7_ANPP/L1/T7_ANPP_L1.csv"), row.names=F)

