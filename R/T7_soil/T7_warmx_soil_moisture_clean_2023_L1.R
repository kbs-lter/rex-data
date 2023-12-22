#Title: Cleaning T7 Pre Drought Soil Moisture Data
#Authors: Adrian Noecker
#Collaborators: Moriah Young
#Input: csv file of raw data in L0 soil folder "T7_warmx_pre_drought_soil_moisture.csv"
#Output: clean L1 data saved as excel file "T7_Predrought_Moisture_L1.csv"
#Project: WarmX
#Date: 5/30-5/31

#clear directory
rm(list=ls())

#load tidyverse
library(tidyverse)

#import data set
T7_warmx_pre_drought_soil_moisture <- read.csv("G:\Shared drives\KBS_LTER_REX\data\soil\L0\T7_warmx_pre_drought_soil_moisture.csv")

#check names
unique(T7_warmx_pre_drought_soil_moisture$Sample_ID)
unique(T7_warmx_pre_drought_soil_moisture$Plot_ID)

#check to verify all are pre drought
unique(T7_warmx_pre_drought_soil_moisture$Sample_Event)

#save changes
write.csv(T7_warmx_pre_drought_soil_moisture, "C:/Users/amn42/My Drive/Soil/T7_Predrought_Moisture_L1.csv", row.names=FALSE)