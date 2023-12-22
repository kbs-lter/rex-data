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
# these samples are removed in the L0_2 version
# removing 45 from L0 version
voc_dec <-  voc %>%
  filter(Compound == "Decane")
voc = subset(voc, select = -c(A_071822_045) )

# checking decane abundance over time (i.e., over each sample)
# does decane abundance decrease as samples increase?
voc_dec2 <- voc_dec %>%
  pivot_longer(names_to = "sample", values_to = "abundance", cols = -Compound)
hist(voc_dec2$abundance)
ggplot(voc_dec2,aes(x=sample, y=abundance)) +
  geom_bar(stat = "identity")
# it looks like at 038 things change - abundance declines for decane

# get compound names & remove them from voc dataframe
# also remove mass and retention time
voc_cmpd <- voc[,1, drop=FALSE]
voc2 = subset(voc, select = -c(Compound))

# make all negative values 0 and make all values integers
voc2[voc2 < 0] <- 0
voc2[voc2 <= 1] <- 0
voc2[] <- lapply(voc2, as.integer)

# remerge compound names
voc_bind <- cbind(voc_cmpd, voc2)
  
# convert data format so each row is a sample, each column is a compound
voc_transpose = as.data.frame(t(voc_bind))
voc_transpose <- tibble::rownames_to_column(voc_transpose, "Compound")

# fix column headers
names(voc_transpose) <- as.matrix(voc_transpose[1, ])
voc_transpose <- voc_transpose[-1, ]
voc_transpose[] <- lapply(voc_transpose, function(x) type.convert(as.character(x)))

# removing caprolactam as its contamination from the nylon bag
voc_merge = subset(voc_transpose, select = -c(Caprolactam))

# removing compounds that are present only in 3 samples
#voc_merge2 <- voc_merge[,colSums(voc_merge!=0)>1]
voc_merge2 <- voc_merge %>%
  select(where(~ sum(.x != 0, na.rm = TRUE) > 3))

# normalize by internal standard
# first remove compound name column & meta info columns
voc_cmpd2 <- voc_merge2[,1, drop=FALSE]
voc_merge2 = subset(voc_merge2, select = -c(Compound))
# perform normalization
voc_norm <- voc_merge2/voc_merge2[,552] # this changes if I change sample number above (1087 if 1 sample, 552 if 3)
# remerge compound names
voc_bind2 <- cbind(voc_cmpd2, voc_norm)

# merging meta data with data
names(voc_bind2)[names(voc_bind2) == 'Compound'] <- 'Sample_ID'
voc_merge3 <- left_join(voc_bind2, meta, by="Sample_ID")

# removing decane as its the standard
voc_merge3 = subset(voc_merge3, select = -c(Decane))

# removing background noise data from the samples
# subtracting the compound amounts found in the bag from all samples of the same rep
voc_sub1 <- voc_merge3 %>%
  filter(Rep == 1) %>%
  mutate_at(2:725, funs(c(last(.), (. - last(.))[-1])) )
voc_sub2 <- voc_merge3 %>%
  filter(Rep == 2) %>%
  mutate_at(2:725, funs(c(last(.), (. - last(.))[-1])) )
voc_sub3 <- voc_merge3 %>%
  filter(Rep == 3) %>%
  mutate_at(2:725, funs(c(last(.), (. - last(.))[-1])) )
voc_sub4 <- voc_merge3 %>%
  filter(Rep == 4) %>%
  mutate_at(2:725, funs(c(last(.), (. - last(.))[-1])) )
voc_sub5 <- voc_merge3 %>%
  filter(Rep == 5) %>%
  mutate_at(2:725, funs(c(last(.), (. - last(.))[-1])) )

voc_sub <- rbind(voc_sub1,voc_sub3,voc_sub5,voc_sub4,voc_sub2)

# removing bag samples
voc_sub <- voc_sub[!grepl('A_071822_126',voc_sub$Sample_ID),]
voc_sub <- voc_sub[!grepl('A_071822_127',voc_sub$Sample_ID),]
voc_sub <- voc_sub[!grepl('A_071822_128',voc_sub$Sample_ID),]
voc_sub <- voc_sub[!grepl('A_071822_129',voc_sub$Sample_ID),]
voc_sub <- voc_sub[!grepl('A_071822_130',voc_sub$Sample_ID),]

# make all negative values 0
voc_sub[voc_sub < 0] <- 0

# removing rep 1 - internal standard error (shown above in line 41)
voc_sub_rm <- voc_sub %>%
  filter(!(Rep == 1))

# removing samples w/ abnormally high abundances
# notes:
# 3 samples (rep 4 ambient 79, rep 3 irrigated 39, and rep 5 warmed 62) have abnormally high abundances
# for 79: columns 108, 117, 128, and 160 are high
# for 39: columns 6, 91, 117, 128, 140, 336, and 361 are high
# for 62: columns 91, 128, 156, 160, 260, 336, 383, and 395 are high
# common to these samples are bicyclo[3.1.0] compounds, bicyclo[3.1.1] compounds, etc.
# these compounds seem to function similarly to beta-pinene in anti-bacterial and anti-herbivory manners
# so, I'm removing them because I believe these plants were stressed from factors other than our treatments
voc_test_abun <- voc_sub_rm
voc_test_abun$rowsums <- rowSums(voc_test_abun[2:725])
ggplot(voc_test_abun, aes(x=Sample_ID, y=rowsums)) +
  geom_bar(stat="identity")
voc_sub_rm <- voc_sub_rm %>%
  filter(!(Unique_ID == 79)) %>%
  filter(!(Unique_ID == 39)) %>%
  filter(!(Unique_ID == 62))

# how many individuals were measure per treatment + rep?
# I used this info in the leaf biomass L2 script to determine total biomass for only measured individuals
voc_sub_rm %>% 
  count(Treatment,Rep)
voc_biomass <- read.csv(file.path(dir, "T7_warmx_VOC/L1/VOC_biomass_2022_L1.csv"))
# making biomass treatments match voc data
voc_biomass$Treatment[voc_biomass$Treatment == "Ambient"] <- "Ambient_Control"
voc_biomass$Treatment[voc_biomass$Treatment == "Irrigated"] <- "Irrigated_Control"

# merge voc w/ biomass data
voc_bio <- left_join(voc_sub_rm,voc_biomass,by=c("Treatment","Rep"))

# divide voc abundances by indiv plant biomass per treatment/rep
# first remove compound name column & meta info columns
voc_sample_names <- voc_bio[,1, drop=FALSE]
voc_meta_info <- voc_bio[,726:732, drop=FALSE]
voc_meta_info2 <- voc_bio[,734, drop=FALSE]
voc_transpose_rm2 = subset(voc_bio, select = -c(Sample_ID,Unique_ID,Rep,Footprint,Subplot,Treatment,Notes,Weight_g,time_sampled))
# divide
voc_weighted_abun <- voc_transpose_rm2/voc_transpose_rm2[,725]
# remerging with meta info
voc_transpose_rm3 <- cbind(voc_sample_names,voc_weighted_abun,voc_meta_info,voc_meta_info2)
# removing indiv weight column 
voc_transpose_rm3 = subset(voc_transpose_rm3, select = -c(Weight_indiv_g))

# divide by hours sampled
# first remove compound name column & meta info columns
voc_sample_names_time <- voc_transpose_rm3[,1, drop=FALSE]
voc_meta_info_time <- voc_transpose_rm3[,726:732, drop=FALSE]
voc_transpose_rm_time = subset(voc_transpose_rm3, select = -c(Sample_ID,Unique_ID,Rep,Footprint,Subplot,Treatment,Notes,Weight_g))
# divide
voc_weighted_abun_time <- voc_transpose_rm_time/voc_transpose_rm_time[,725]
# remerging with meta info
voc_transpose_rm4 <- cbind(voc_sample_names_time,voc_weighted_abun_time,voc_meta_info_time)
# removing indiv weight column 
voc_transpose_rm4 = subset(voc_transpose_rm4, select = -c(time_sampled))
# removing weight column
voc_transpose_rm4 = subset(voc_transpose_rm4, select = -c(Weight_g))

# removing unnamed compounds from dataframe
voc_named <- voc_transpose_rm4 %>%
  select(-contains(c("@")))



## Upload cleaned data with all compounds to L1 folder
write.csv(voc_transpose_rm4, file.path(dir,"T7_warmx_VOC/L1/T7_total_VOC_2022_L1.csv"), row.names=F)

## Upload cleaned data with named compounds to L1 folder
write.csv(voc_named, file.path(dir,"T7_warmx_VOC/L1/T7_named_VOC_2022_L1.csv"), row.names=F)

