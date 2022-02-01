# TITLE:          REX: Gall dissection data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Kristin Wolford, Emily Parker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_plant_traits L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_plant_traits L1 folder
# PROJECT:        REX
# DATE:           Jan 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory
dir<-Sys.getenv("DATA_DIR")

# Read in data
gall <- read.csv(file.path(dir, "T7_warmx_insect/L0/T7_warmx_Soca_gall_dissection_L0.csv"))
meta <- read.csv(file.path(dir, "REX_warmx_Soca_ID_metadata_2021.csv"))

# Convert column names to lower case
colnames(gall) <- tolower(colnames(gall))
colnames(meta) <- tolower(colnames(meta))

# check data
str(gall)

# removing unneeded columns
gall <- gall %>% dplyr::select(-date_of_dissection)
gall <- gall %>% dplyr::select(-normal_stem_diameter_mm)
gall <- gall %>% dplyr::select(-gall_stem_diameter_mm)
gall <- gall %>% dplyr::select(-chamber.open...y.n.)
gall <- gall %>% dplyr::select(-insect_present..y.n.)
gall <- gall %>% dplyr::select(-life_stage)
gall <- gall %>% dplyr::select(-insect_length_mm)
gall <- gall %>% dplyr::select(-notes)
meta <- meta %>% dplyr::select(-treatment)
meta <- meta %>% dplyr::select(-old.id)
meta <- meta %>% dplyr::select(-flowered.)
meta <- meta %>% dplyr::select(-notes)
meta <- meta %>% dplyr::select(-subplot)

# fixing column names
names(meta)[names(meta) == 'new.id'] <- 'unique_plant_number'
names(meta)[names(meta) == 'treatment.1'] <- 'treatment'

# merge meta-data with gall data
meta$unique_plant_number <- as.character(meta$unique_plant_number)
gall_merge <- left_join(meta, gall, by = "unique_plant_number")

# removing rows w no data
gall_merge <- gall_merge %>%
  drop_na(date_of_harvest)

# splitting gall chamber count and gall chamber volume into separate data frames
gall_chmb_count <- gall_merge[,1:6]
gall_chmb_vol <- gall_merge[,-c(6)]

# removing rows w no data
gall_chmb_vol <- gall_chmb_vol %>%
  drop_na(chamber_volume_mm3)

# keeping only the max chamber count value
gall_chmb_count2 <- gall_chmb_count %>%
  group_by(rep, footprint, treatment, unique_plant_number) %>%
  summarize(chamber_number = max(chamber_number))
names(gall_chmb_count2)[names(gall_chmb_count2) == 'chamber_number'] <- 'num_of_chambers'

# Upload cleaned data to L1 folder
write.csv(gall_chmb_vol, file.path(dir,"T7_warmx_insect/L1/T7_warmx_Soca_gall_chmb_vol_L1.csv"), row.names=F)
write.csv(gall_chmb_count2, file.path(dir,"T7_warmx_insect/L1/T7_warmx_Soca_gall_chmb_count_L1.csv"), row.names=F)


