# TITLE:          REX: 2022 VOC drought data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Moriah Young, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared REX Google drive T7_warmx_VOC L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to T7_warmx_VOC L1 folder
# PROJECT:        REX
# DATE:           Aug 2022

# Notes:
# everything is normalized by internal standard
# next steps:
  # Figure out best way to remove background sample noise from bags
  # idea for this: in normalized dataframe, subtract average bag value sample for each compound (except decane)



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
# these samples are removed in the L0_2 version
# removing 45 from L1 version
voc_dec <-  voc %>%
  filter(Compound == "Decane")
voc = subset(voc, select = -c(A_071822_045) )

# skipping this part for now
# get average values for the air control
#voc$bag <- rowMeans(subset(voc, select = c(A_071822_128, A_071822_129, A_071822_130)), na.rm = TRUE)

# subtract average air control values from each sample
#voc2 <- voc %>%
#  mutate_at(vars(-matches('Compound')), ~ . - bag)

# get compound names & remove them from voc dataframe
voc_cmpd <- voc[,1, drop=FALSE]
voc2 = subset(voc, select = -c(Compound))

# make all negative values 0 and make all values integers
voc2[voc2 < 0] <- 0
voc2[voc2 <= 1] <- 0
voc2[] <- lapply(voc2, as.integer)

# remerge compound names
voc_bind <- cbind(voc_cmpd, voc2)

# remove air control columns
#voc_bind = subset(voc_bind, select = -c(bag, A_071822_128, A_071822_129, A_071822_130))
  
# convert data format so each row is a sample, each column is a compoud
voc_transpose = as.data.frame(t(voc_bind))
voc_transpose <- tibble::rownames_to_column(voc_transpose, "Compound")

# fix column headers
names(voc_transpose) <- as.matrix(voc_transpose[1, ])
voc_transpose <- voc_transpose[-1, ]
voc_transpose[] <- lapply(voc_transpose, function(x) type.convert(as.character(x)))

# removing caprolactam as its contamination from the nylon bag
voc_merge = subset(voc_transpose, select = -c(Caprolactam))

# removing compounds that are present only in 1 sample
#voc_merge2 <- voc_merge[,colSums(voc_merge!=0)>1]
voc_merge2 <- voc_merge %>%
  select(where(~ sum(.x != 0, na.rm = TRUE) > 1))

# normalize by internal standard
# first remove compound name column & meta info columns
voc_cmpd2 <- voc_merge2[,1, drop=FALSE]
voc_merge2 = subset(voc_merge2, select = -c(Compound))
# perform normalization
voc_norm <- voc_merge2/voc_merge2[,1087]
# remerge compound names
voc_bind2 <- cbind(voc_cmpd2, voc_norm)

# merging meta data with data
names(voc_bind2)[names(voc_bind2) == 'Compound'] <- 'Sample_ID'
voc_merge3 <- left_join(voc_bind2, meta, by="Sample_ID")


# Upload cleaned data to L1 folder
write.csv(voc_merge2, file.path(dir,"T7_warmx_VOC/L1/T7_VOC_2022_L1.csv"), row.names=F)
