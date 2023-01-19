# TITLE:          REX: Phoebe's plots ANPP
# AUTHORS:        Kara Dobson, Moriah Young
# COLLABORATORS:  Phoebe Zarnetske, Mark Hammond, Jordan Zapata
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_ANPP L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_ANPP L1 folder
# PROJECT:        REX
# DATE:           Jan 2023

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
anpp_data <- read.csv(file.path(dir, "T7_ANPP/L0/2022 All footprints/REX_ANPP_2022_biomass_final.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
taxon <- read.csv(file.path(dir, "REX_warmx_taxon.csv"))

# Making meta-data file match the format of the ANPP data
meta$Treatment <- 7
meta$Field_Loc_Code <- paste0(meta$Treatment, "_", meta$Rep, "_", meta$Footprint_Location, "_", meta$Subplot_Location)

# removing unneeded columns in ANPP
anpp_data = subset(anpp_data, select = -c(Date_of_Harvest,Field_Treatment_Number,Field_Rep,Footprint_Number,Subplot_Letter,
                                          Unique_Field_Location_Code,Type_of_Weighing._Direct_or_Indirect,Dried_Bag.mass_g,
                                          Type_of_Bag,Sum_Bag_plus_Dried_Plant_Biomass_gram,Notes,data_entry_ID,Mark_needs_to_do_further_proofing))

# merging meta data with ANPP data
anpp <- left_join(anpp_data, meta, by = c("Field_Loc_Code"))

# subset out Phoebe's plots and the irrigated control
anpp <- anpp %>%
  filter(Footprint_Owner == "PZ" | Subplot_Descriptions == "irrigated_control")

# removing unneeded columns
anpp = subset(anpp, select = -c(Footprint_Owner, Replicate, Footprint, Subplot,Unique_ID))

# making all species capitalized
anpp$Species_Code = toupper(anpp$Species_Code)

## adding together live and dead clover measurements
# first, renaming all clover to "TRFPR"
anpp$Species_Code[anpp$Species_Code == "TRFPR (ALIVE)"] <- "TRFPR"
anpp$Species_Code[anpp$Species_Code == "TRFPR (DEAD)"] <- "TRFPR"

# calculate sums of alive and dead
anpp_sum <- anpp %>%
  group_by(Field_Loc_Code) %>%
  filter(Species_Code == "TRFPR") %>%
  mutate(Dried_Plant_Biomass_gram = sum(Dried_Plant_Biomass_gram)) %>%
  distinct(Field_Loc_Code, .keep_all = TRUE)

# remove clover from original anpp data
anpp <- anpp %>%
  filter(!(Species_Code == "TRFPR"))

# merge summed TRFPR with anpp data
anpp2 <- bind_rows(anpp, anpp_sum)

# merging species info with anpp data
names(taxon)[names(taxon)=="LTER_code"] <- "Species_Code" # making species column the same name
anpp3 <- left_join(anpp2, taxon, by = c("Species_Code"))

# remove unnecessary columns
anpp4 = subset(anpp3, select = -c(note1, note2))

# check species code names
unique(anpp4$Species_Code)

# check subplot descriptions
unique(anpp4$Subplot_Descriptions)

# remove "SDEAD" and "SURFL" from original anpp data because this does not count towards ANPP
anpp5 <- anpp4[!grepl('SDEAD',anpp4$Species_Code),]
anpp6 <- anpp5[!grepl('SURFL',anpp5$Species_Code),]

# check species code names again
unique(anpp6$Species_Code)
                                          
# upload L1 data
write.csv(anpp6, file.path(dir,"T7_ANPP/L1/T7_warmx_ANPP_2022_L1.csv"), row.names=F)
