# TITLE:          REX: VOC data clean-up
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
voc <- read.csv(file.path(dir, "T7_warmx_VOC/L0/REX_T7_VOC_data_L0.csv"))[,1:7]
unique(voc$Compound)

# Removing unknown compounds
voc <- voc[!grepl("@", voc$Compound),]
unique(voc$Compound)

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

# Upload cleaned data to L1 folder
write.csv(voc_transpose, file.path(dir,"T7_warmx_VOC/L1/T7_Soca_VOC_L1.csv"), row.names=F)
