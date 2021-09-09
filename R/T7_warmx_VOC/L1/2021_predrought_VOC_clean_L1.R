# TITLE:          REX: 2021 VOC pre-drought data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_VOC L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_VOC L1 folder
# PROJECT:        REX
# DATE:           July 2021

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
voc <- read.csv(file.path(dir, "T7_warmx_VOC/L0/REX_T7_VOC_2021predrought_L0.csv"))
unique(voc$Compound)

# Removing unknown compounds for now - can go back and try to figure out what these are
# According to Casey: most people remove the unknowns because they don't know what they are,
# but these may actually be more interesting because they haven't been named/discovered for this yet
voc <- voc[!grepl("@", voc$Compound),]
unique(voc$Compound)

# removing uneeded columns
voc$Mass <- NULL
voc$Retention.Time <- NULL
voc$Ion.Species <- NULL
voc$Annotations <- NULL

# convert data format so each row is a sample, each column is a compoud
voc_transpose = as.data.frame(t(voc))
voc_transpose <- tibble::rownames_to_column(voc_transpose, "Compound")

# fix column headers
names(voc_transpose) <- as.matrix(voc_transpose[1, ])
voc_transpose <- voc_transpose[-1, ]
voc_transpose[] <- lapply(voc_transpose, function(x) type.convert(as.character(x)))

# add treatment info for each sample
voc_transpose$Treatment = 0
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_006'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_007'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_008'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_009'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_010'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_072121_011'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_001'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_002'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_018'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_019'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_020'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_003A'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_004'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_015'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_016'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_017'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_005'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_006'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_007'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_008'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_021'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_009'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_010'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_011'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_012'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_013'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_014'] = "Irrigated"

# add field replicate info for each sample
voc_transpose$Rep = 0
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_006'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_007'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_008'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_009'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_010'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_072121_011'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_001'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_002'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_018'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_019'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_020'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_003A'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_004'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_015'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_016'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_017'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_005'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_006'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_007'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_008'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_021'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_009'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_010'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_011'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_012'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_013'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_014'] = "5"

# Upload cleaned data to L1 folder
write.csv(voc_transpose, file.path(dir,"T7_warmx_VOC/L1/T7_VOC_2021predrought_L1.csv"), row.names=F)
