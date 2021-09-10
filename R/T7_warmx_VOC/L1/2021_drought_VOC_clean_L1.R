# TITLE:          REX: 2021 VOC drought data clean-up
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
voc <- read.csv(file.path(dir, "T7_warmx_VOC/L0/REX_T7_VOC_2021drought_L0.csv"))
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
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_024'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_025'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_044'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_045'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_046'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_047'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_071'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_072'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_073'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_074'] = "Warmed_Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_028'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_029'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_030'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_048'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_050'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_051'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_067'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_068'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_069'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_070'] = "Drought"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_031'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_060'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_061'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_062'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_063'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_064'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_065'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_066'] = "Irrigated"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_035'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_036'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_037'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_056'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_057'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_058'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_059'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_075'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_076'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_077'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_078'] = "Ambient"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_040'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_041'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_042'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_052'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_053'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_054'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_055'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_079'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_080'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_081'] = "Warmed"
voc_transpose$Treatment[voc_transpose$Compound == 'A_081621_082'] = "Warmed"


# add field replicate info for each sample
voc_transpose$Rep = 0
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_024'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_025'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_044'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_045'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_046'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_047'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_071'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_072'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_073'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_074'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_028'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_029'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_030'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_048'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_050'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_051'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_067'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_068'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_069'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_070'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_031'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_060'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_061'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_062'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_063'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_065'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_066'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_035'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_036'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_037'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_056'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_057'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_058'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_059'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_075'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_076'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_077'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_078'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_040'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_041'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_042'] = "1"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_052'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_053'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_054'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_055'] = "3"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_079'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_080'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_081'] = "5"
voc_transpose$Rep[voc_transpose$Compound == 'A_081621_082'] = "5"

# grouping all warmed treatments (W and WD) and all control (A and I) just to see how it looks
voc_transpose$Group_treat = 0
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_024'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_025'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_044'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_045'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_046'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_047'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_071'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_072'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_073'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_074'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_028'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_029'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_030'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_048'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_050'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_051'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_067'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_068'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_069'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_070'] = "Drought"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_031'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_060'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_061'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_062'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_063'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_064'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_065'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_066'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_035'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_036'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_037'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_056'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_057'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_058'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_059'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_075'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_076'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_077'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_078'] = "Control"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_040'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_041'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_042'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_052'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_053'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_054'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_055'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_079'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_080'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_081'] = "Warmed"
voc_transpose$Group_treat[voc_transpose$Compound == 'A_081621_082'] = "Warmed"

# Upload cleaned data to L1 folder
write.csv(voc_transpose, file.path(dir,"T7_warmx_VOC/L1/T7_VOC_2021drought_L1.csv"), row.names=F)
