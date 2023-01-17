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
source("~/rex-data/R/T7_HOBO/T7_warmx_HOBO_clean_functions_L1.R")

# Set working directory
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Load packages
library(tidyverse)

# Read in data
r2_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_A 2022-11-08 15_51_52 EST (Data EST).csv"))[,2:4]
r2_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_W 2022-11-08 16_12_14 EST (Data EST).csv"))[,2:4]
r2_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R2_F5_W 2022-11-08 15_31_06 EST (Data EST).csv"))[,2:4]

r3_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_A 2022-11-09 12_50_38 EST (Data EST).csv"))[,2:4]
r3_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_W 2022-11-09 13_04_05 EST (Data EST).csv"))[,2:4]
r3_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_A 2022-11-09 13_20_52 EST (Data EST).csv"))[,2:4]
r3_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_W 2022-11-09 13_39_15 EST (Data EST).csv"))[,2:4]

r4_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F1_A 2022-11-09 13_59_11 EST (Data EST).csv"))[,2:4]
r4_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_A 2022-11-09 14_20_54 EST (Data EST).csv"))[,2:4]
r4_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_W 2022-11-09 14_32_07 EST (Data EST).csv"))[,2:4]

r6_a <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_A 2022-11-09 15_46_01 EST (Data EST).csv"))[,2:4]
r6_w <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_W 2022-11-09 15_56_40 EST (Data EST).csv"))[,2:4]
r6_d <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_A 2022-11-09 15_22_00 EST (Data EST).csv"))[,2:4]
r6_wd <- read.csv(file.path(dir, "sensors/Phoebe Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_W 2022-11-09 15_32_43 EST (Data EST).csv"))[,2:4]

# put dataframes into a list to apply functions
df_list <- list(r2_a=r2_a,r3_a=r3_a,r4_a=r4_a,r6_a=r6_a,
                r2_w=r2_w,r3_w=r3_w,r6_w=r6_w,
                r3_d=r3_d,r4_d=r4_d,r6_d=r6_d,
                r2_wd=r2_wd,r3_wd=r3_wd,r4_wd=r4_wd,r6_wd=r6_wd)
df_list[1:4] <- lapply(df_list[1:4], add_treat,trt="Ambient")
df_list[5:7] <- lapply(df_list[5:7], add_treat,trt="Warmed")
df_list[8:10] <- lapply(df_list[8:10], add_treat,trt="Drought")
df_list[11:14] <- lapply(df_list[11:14], add_treat,trt="Warmed_Drought")
df_list <- lapply(df_list, col_names)
df_list <- lapply(df_list, change_POSIX)


