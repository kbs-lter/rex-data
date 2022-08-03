# TITLE:          REX: 2022 VOC drought data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_VOC L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_VOC L1 folder
# PROJECT:        REX
# DATE:           Aug 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
voc <- read.csv(file.path(dir, "T7_warmx_VOC/L0/REX_T7_VOC_2022_L0.csv"))
unique(voc$Compound)
meta <-  read.csv(file.path(dir, "T7_warmx_VOC/L0/REX_T7_VOC_2022_metadata.csv"))

# removing uneeded columns
voc$Mass <- NULL
voc$Retention.Time <- NULL
voc$Ion.Species <- NULL
voc$Annotations <- NULL

# checking what samples don't have decane - going back to remove 45, 106, 119, 126, and 127
voc_dec <-  voc %>%
  filter(Compound == "Decane")

# convert data format so each row is a sample, each column is a compoud
voc_transpose = as.data.frame(t(voc))
voc_transpose <- tibble::rownames_to_column(voc_transpose, "Compound")

# fix column headers
names(voc_transpose) <- as.matrix(voc_transpose[1, ])
voc_transpose <- voc_transpose[-1, ]
voc_transpose[] <- lapply(voc_transpose, function(x) type.convert(as.character(x)))

# merging meta data with data
names(voc_transpose)[names(voc_transpose) == 'Compound'] <- 'Sample_ID'
voc_merge <- left_join(voc_transpose, meta, by="Sample_ID")

# Upload cleaned data to L1 folder
write.csv(voc_merge, file.path(dir,"T7_warmx_VOC/L1/T7_VOC_2022_L1.csv"), row.names=F)
