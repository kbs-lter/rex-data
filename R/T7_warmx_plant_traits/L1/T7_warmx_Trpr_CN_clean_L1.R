# TITLE:          Leaf Traits: Carbon and Nitrogen Data Cleanup for red clover (Trifolium pratense) 
# AUTHORS:        Moriah Young
# COLLABORATORS:  Adrian Noecker, Mark Hammond
# DATA INPUT:     Data imported as csv files from shared Google drive L0 folder
# DATA OUTPUT:    A csv file containing CN data is uploaded to the L1 T7 warmx plant traits folder
# PROJECT:        REX
# DATE:           July 18, 2023
# NOTES:        

# Clear all existing data
rm(list=ls())

#Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# read in files
meta <- read.csv(file.path(dir, "REX_warmx_metadata.csv"))
weighsheet1 <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_CN_weighsheet_Trpr_alive_dead_2022.csv"))
weighsheet2 <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_CN_weighsheet_Trpr_dead_2022.csv"))
biomass <- read.csv(file.path(dir, "T7_warmx_plant_traits/L0/T7_warmx_CN_biomass_Trpr_2022.csv"))
biomass <- biomass[-c(11)] # remove plate location column

# create function to clean CN data files - this function can be used for data still in the "weighsheets" format
CN_csvdata_initial_prep <- function(cn_data){
        cn_data <- cn_data[-(1:2),] #get rid of the first 2 rows because it's not data
        names(cn_data) <- cn_data[1,] #make the first row the column names
        cn_data <- cn_data[-1,] #get rid of the first row because it's now the column names
        cn_data <- cn_data[-(1:7),] #get rid of first 7 rows because these are the "standards" data
        cn_data <- cn_data[c(3, 4, 10, 11)] #get rid of unwanted columns that don't have data
        cn_data <- cn_data[!(cn_data$Sample=="Blind Standard"),] # get rid of rows that are blind standards
        return(cn_data[!apply(is.na(cn_data) | cn_data == "", 1, all),])
}

# putting the weigh sheets through the function above
cn_samples_1_edited <- CN_csvdata_initial_prep(weighsheet1)
cn_samples_2_edited <- CN_csvdata_initial_prep(weighsheet2)

# merge data frames above together
cn_samples_edited <- merge(cn_samples_1_edited, cn_samples_2_edited, all = TRUE)

names(biomass)[10] <- "Sample" #changing column name

# merge metadata file with biomass file
meta1 <- full_join(meta, biomass, by = "Unique_Field_Location_Code")

# merge new metadata file with cn samples file
cn <- full_join(meta1, cn_samples_edited, by = "Sample")

cn <- na.omit(cn) # removes any rows with NAs (right now we only have non-insecticide plots - 7/18/2023)

# remove redundant columns
cn1 <- subset(cn, select = -c(Subplot_Letter,Field_Treatment_Number, Field_Rep, Footprint_Number, 
                              Unique_Field_Location_Code, Subplot))

# Upload cleaned data to L1 folder
write.csv(cn, file.path(dir,"T7_warmx_plant_traits/L1/T7_warmx_CN_Trpr_2022_L1.csv"), row.names=F)
