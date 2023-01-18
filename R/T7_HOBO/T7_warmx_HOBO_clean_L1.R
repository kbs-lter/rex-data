# TITLE:          REX: HOBO data clean-up
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Mark Hammond, Moriah Young, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive L0 HOBO data
# DATA OUTPUT:    Clean L1 HOBO data
# PROJECT:        REX
# DATE:           Jan 2023

# Clear all existing data
rm(list=ls())

# Source functions
source("~/rex-data/R/T7_HOBO/T7_warmx_HOBO_clean_functions.R")

# Set working directory
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Load packages
library(tidyverse)

# Read in data
r1_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R1_F7_A 2022-11-30 15_21_26 EST (Data EST).csv"))[,2:4]
r1_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R1_F7_W 2022-11-08 15_51_40 EST (Data EST)(1).csv"))[,2:4]

r2_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_A 2022-11-08 15_51_52 EST (Data EST).csv"))[,2:4]
r2_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_W 2022-11-08 16_12_14 EST (Data EST).csv"))[,2:4]
r2_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F5_W 2022-11-08 15_31_06 EST (Data EST).csv"))[,2:4]
r2_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F5_A 2022-11-08 15_17_55 EST (Data EST).csv"))[,2:4]

r3_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_A 2022-11-09 12_50_38 EST (Data EST).csv"))[,2:4]
r3_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_W 2022-11-09 13_04_05 EST (Data EST).csv"))[,2:4]
r3_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_A 2022-11-09 13_20_52 EST (Data EST).csv"))[,2:4]
r3_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_W 2022-11-09 13_39_15 EST (Data EST).csv"))[,2:4]

r4_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F1_A 2022-11-09 13_59_11 EST (Data EST).csv"))[,2:4]
r4_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F1_W 2022-11-30 15_15_48 EST (Data EST).csv"))[,2:4]
r4_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_A 2022-11-09 14_20_54 EST (Data EST).csv"))[,2:4]
r4_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_W 2022-11-09 14_32_07 EST (Data EST).csv"))[,2:4]

r5_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R5_F4_A 2022-11-30 16_48_41 EST (Data EST).csv"))[,2:4]
r5_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R5_F4_W 2022-11-30 17_06_28 EST (Data EST).csv"))[,2:4]
r5_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R5_F3_A 2022-11-30 16_34_54 EST (Data EST)(1).csv"))[,2:4]
r5_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R5_F3_W 2022-11-30 15_54_05 EST (Data EST).csv"))[,2:4]

r6_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_A 2022-11-09 15_46_01 EST (Data EST).csv"))[,2:4]
r6_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_W 2022-11-09 15_56_40 EST (Data EST).csv"))[,2:4]
r6_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_A 2022-11-09 15_22_00 EST (Data EST).csv"))[,2:4]
r6_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_W 2022-11-09 15_32_43 EST (Data EST).csv"))[,2:4]

# put dataframes into a list to apply functions
df_list <- list(r1_a=r1_a,r2_a=r2_a,r3_a=r3_a,r4_a=r4_a,r5_a=r5_a,r6_a=r6_a,
                r1_w=r1_w,r2_w=r2_w,r3_w=r3_w,r4_w=r4_w,r5_w=r5_w,r6_w=r6_w,
                r2_d=r2_d,r3_d=r3_d,r4_d=r4_d,r5_d=r5_d,r6_d=r6_d,
                r2_wd=r2_wd,r3_wd=r3_wd,r4_wd=r4_wd,r5_wd=r5_wd,r6_wd=r6_wd)
df_list[1:6] <- lapply(df_list[1:6], add_treat,trt="Ambient")
df_list[7:12] <- lapply(df_list[7:12], add_treat,trt="Warmed")
df_list[13:17] <- lapply(df_list[13:17], add_treat,trt="Drought")
df_list[18:22] <- lapply(df_list[18:22], add_treat,trt="Warmed_Drought")
df_list[c(1,7)] <- lapply(df_list[c(1,7)], add_rep,rep=1)
df_list[c(2,8,13,18)] <- lapply(df_list[c(2,8,13,18)], add_rep,rep=2)
df_list[c(3,9,14,19)] <- lapply(df_list[c(3,9,14,19)], add_rep,rep=3)
df_list[c(4,10,15,20)] <- lapply(df_list[c(4,10,15,20)], add_rep,rep=4)
df_list[c(5,11,16,21)] <- lapply(df_list[c(5,11,16,21)], add_rep,rep=5)
df_list[c(6,12,17,22)] <- lapply(df_list[c(6,12,17,22)], add_rep,rep=6)
df_list <- lapply(df_list, col_names)
df_list <- lapply(df_list, change_POSIX)

# merge into one dataframe
hobo_data <- rbind(df_list$r2_a,df_list$r3_a,df_list$r4_a,df_list$r6_a,
                   df_list$r2_w,df_list$r3_w,df_list$r6_w,
                   df_list$r3_d,df_list$r4_d,df_list$r6_d,
                   df_list$r2_wd,df_list$r3_wd,df_list$r4_wd,df_list$r6_wd)

# upload to drive
write.csv(hobo_data, file.path(dir,"sensors/Phoebe Footprints/L1/T7_warmx_HOBO_L1.csv"), row.names=F)
