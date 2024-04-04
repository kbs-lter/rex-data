# TITLE:          REX: HOBO data clean-up
# AUTHORS:        Kara Dobson, Moriah Young
# COLLABORATORS:  Phoebe Zarnetske, Mark Hammond, Emily Parker
# DATA INPUT:     Data imported as csv files from shared REX Google drive L0 HOBO data
# DATA OUTPUT:    Clean L1 HOBO data
# PROJECT:        REX
# DATE:           December 2023

# Clear all existing data
rm(list=ls())

# Source functions
#source("~/rex-data/R/T7_HOBO/T7_warmx_HOBO_clean_functions.R")
source("/Users/moriahyoung/Documents/GitHub/rex-data/R/T7_HOBO/T7_warmx_HOBO_clean_functions.R")

# Set working directory
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Load packages
library(tidyverse)

# Read in data
# this data is from July 2021 - September 2021
hobo_2021 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2021 HOBO pendant data/REX_HOBO_Pendant_2021_7_8_21-9_14_21.csv"))

# dataframe above is in wide format and needs to be converted to long
# delete first column that's not needed
hobo_2021 <- hobo_2021[,-1]

hobo_2021_long <- hobo_2021 %>%
        pivot_longer(cols = starts_with("PLZ"), names_to = "Variable", values_to = "Value", values_drop_na = TRUE) %>%
        separate(Variable, into = c("PI", "Rep", "footprint", "Treatment", "measurement"), sep = "_") %>% 
        spread(key = measurement, value = Value)

hobo_2021_long <- hobo_2021_long[,-c(2,4)]

hobo_2021_long1 <- hobo_2021_long %>%
        mutate(Treatment = ifelse(Treatment == "A", "Ambient", ifelse(Treatment == "W", "Warmed", Treatment)))

hobo_2021_long2 <- hobo_2021_long1 %>%
        mutate(Rep = sub("R", "", Rep))

# Convert the result to numeric
hobo_2021_long2$Rep <- as.numeric(hobo_2021_long2$Rep)

# rename temp and light columns to match what we'll do below
names(hobo_2021_long2)[1] <- "Date_Time"
names(hobo_2021_long2)[4] <- "Light_lux"
names(hobo_2021_long2)[5] <- "Temperature_C"

# Convert the date column to POSIXct format
hobo_2021_long2$Date_Time <- as.POSIXct(strptime(hobo_2021_long2$Date_Time, format = "%m/%d/%y %H:%M:%S"))

# Format the date column to the desired format
hobo_2021_long2$Date_Time <- format(hobo_2021_long2$Date_Time, format = "%Y-%m-%d %H:%M:%S")

hobo_2021_long2$Date_Time <- as.POSIXct(hobo_2021_long2$Date_Time, format = "%Y-%m-%d %H:%M:%S")


# these files have September 2021 data and 2022 data up to November
r1_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R1_F7_A 2022-11-30 15_21_26 EST (Data EST).csv"))[,2:4]
r1_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R1_F7_W 2022-11-08 15_51_40 EST (Data EST)(1).csv"))[,2:4]

r2_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_A 2022-11-08 15_51_52 EST (Data EST).csv"))[,2:4]
r2_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R2_F2_W 2022-11-08 16_12_14 EST (Data EST).csv"))[,2:4]
r2_wd <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R2_F5_W 2022-11-08 15_31_06 EST (Data EST).csv"))[,2:4]
r2_d <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R2_F5_A 2022-11-08 15_17_55 EST (Data EST).csv"))[,2:4]

r3_d <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_A 2022-11-09 12_50_38 EST (Data EST).csv"))[,2:4]
r3_wd <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R3_F4_W 2022-11-09 13_04_05 EST (Data EST).csv"))[,2:4]
r3_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_A 2022-11-09 13_20_52 EST (Data EST).csv"))[,2:4]
r3_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R3_F5_W 2022-11-09 13_39_15 EST (Data EST).csv"))[,2:4]

r4_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R4_F1_A 2022-11-09 13_59_11 EST (Data EST).csv"))[,2:4]
r4_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R4_F1_W 2022-11-30 15_15_48 EST (Data EST).csv"))[,2:4]
r4_d <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_A 2022-11-09 14_20_54 EST (Data EST).csv"))[,2:4]
r4_wd <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R4_F6_W 2022-11-09 14_32_07 EST (Data EST).csv"))[,2:4]

r5_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R5_F4_A 2022-11-30 16_48_41 EST (Data EST).csv"))[,2:4]
r5_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R5_F4_W 2022-11-30 17_06_28 EST (Data EST).csv"))[,2:4]
r5_d <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R5_F3_A 2022-11-30 16_34_54 EST (Data EST)(1).csv"))[,2:4]
r5_wd <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R5_F3_W 2022-11-30 15_54_05 EST (Data EST).csv"))[,2:4]

r6_a <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_A 2022-11-09 15_46_01 EST (Data EST).csv"))[,2:4]
r6_w <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R6_F1_W 2022-11-09 15_56_40 EST (Data EST).csv"))[,2:4]
r6_d <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_A 2022-11-09 15_22_00 EST (Data EST).csv"))[,2:4]
r6_wd <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2022 HOBO pendant data/PLZ_R6_F2_W 2022-11-09 15_32_43 EST (Data EST).csv"))[,2:4]

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
hobo_data <- rbind(df_list$r1_a,df_list$r2_a,df_list$r3_a,df_list$r4_a,df_list$r5_a,df_list$r6_a,
                   df_list$r1_w,df_list$r2_w,df_list$r3_w,df_list$r4_w,df_list$r5_w,df_list$r6_w,
                   df_list$r2_d,df_list$r3_d,df_list$r4_d,df_list$r5_d,df_list$r6_d,
                   df_list$r2_wd,df_list$r3_wd,df_list$r4_wd,df_list$r5_wd,df_list$r6_wd)

# these files have end of 2022 data through March 2023 (when shelters were taken off for annual burn)
r1_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R1_F7_A 2023-03-28 11_09_42 EDT (Data EDT).csv"))[,2:4]
r1_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R1_F7_W 2023-03-28 10_56_57 EDT (Data EDT).csv"))[,2:4]
r1_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R1_F1_A 2023-03-28 11_06_37 EDT (Data EDT).csv"))[,2:4]
r1_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R1_F1_W 2023-03-28 11_01_25 EDT (Data EDT).csv"))[,2:4]

r2_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R2_F2_A 2023-03-28 11_46_51 EDT (Data EDT).csv"))[,2:4]
r2_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R2_F2_W 2023-03-28 11_41_19 EDT (Data EDT).csv"))[,2:4]
r2_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R2_F5_W 2023-03-28 11_33_38 EDT (Data EDT).csv"))[,2:4]
r2_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R2_F5_A 2023-03-28 11_40_25 EDT (Data EDT).csv"))[,2:4]

r3_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R3_F4_A 2023-03-28 11_24_22 EDT (Data EDT).csv"))[,2:4]
r3_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R3_F4_W 2023-03-28 11_25_18 EDT (Data EDT).csv"))[,2:4]
r3_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R3_F5_A 2023-03-28 11_29_25 EDT (Data EDT).csv"))[,2:4]
r3_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R3_F5_W 2023-03-28 11_22_04 EDT (Data EDT).csv"))[,2:4]

r4_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R4_F1_A 2023-03-28 11_37_09 EDT (Data EDT).csv"))[,2:4]
r4_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R4_F1_W 2023-03-28 11_45_39 EDT (Data EDT).csv"))[,2:4]
r4_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R4_F6_A 2023-03-28 11_42_26 EDT (Data EDT).csv"))[,2:4]
r4_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R4_F6_W 2023-03-28 11_26_30 EDT (Data EDT).csv"))[,2:4]

r5_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R5_F4_A 2023-03-28 10_58_22 EDT (Data EDT).csv"))[,2:4]
r5_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R5_F4_W 2023-03-28 11_04_05 EDT (Data EDT).csv"))[,2:4]
r5_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R5_F3_A 2023-03-28 11_14_03 EDT (Data EDT).csv"))[,2:4]
r5_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R5_F3_W 2023-03-28 11_12_58 EDT (Data EDT).csv"))[,2:4]

r6_a_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R6_F1_A 2023-03-28 11_16_56 EDT (Data EDT).csv"))[,2:4]
r6_w_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R6_F1_W 2023-03-28 11_30_21 EDT (Data EDT).csv"))[,2:4]
r6_d_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R6_F2_A 2023-03-28 11_35_14 EDT (Data EDT).csv"))[,2:4]
r6_wd_2 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/March/PLZ_R6_F2_W 2023-03-28 11_18_21 EDT (Data EDT).csv"))[,2:4]

# put dataframes into a list to apply functions
df_list2 <- list(r1_a_2=r1_a_2,r2_a_2=r2_a_2,r3_a_2=r3_a_2,r4_a_2=r4_a_2,r5_a_2=r5_a_2,r6_a_2=r6_a_2,
                r1_w_2=r1_w_2,r2_w_2=r2_w_2,r3_w_2=r3_w_2,r4_w_2=r4_w_2,r5_w_2=r5_w_2,r6_w_2=r6_w_2,
                r1_d_2=r1_d_2,r2_d_2=r2_d_2,r3_d_2=r3_d_2,r4_d_2=r4_d_2,r5_d_2=r5_d_2,r6_d_2=r6_d_2,
                r1_wd_2=r1_wd_2,r2_wd_2=r2_wd_2,r3_wd_2=r3_wd_2,r4_wd_2=r4_wd_2,r5_wd_2=r5_wd_2,r6_wd_2=r6_wd_2)
df_list2[1:6] <- lapply(df_list2[1:6], add_treat,trt="Ambient")
df_list2[7:12] <- lapply(df_list2[7:12], add_treat,trt="Warmed")
df_list2[13:18] <- lapply(df_list2[13:18], add_treat,trt="Drought")
df_list2[19:24] <- lapply(df_list2[19:24], add_treat,trt="Warmed_Drought")
df_list2[c(1,7,13,19)] <- lapply(df_list2[c(1,7,13,19)], add_rep,rep=1)
df_list2[c(2,8,14,20)] <- lapply(df_list2[c(2,8,14,20)], add_rep,rep=2)
df_list2[c(3,9,15,21)] <- lapply(df_list2[c(3,9,15,21)], add_rep,rep=3)
df_list2[c(4,10,16,22)] <- lapply(df_list2[c(4,10,16,22)], add_rep,rep=4)
df_list2[c(5,11,17,23)] <- lapply(df_list2[c(5,11,17,23)], add_rep,rep=5)
df_list2[c(6,12,18,24)] <- lapply(df_list2[c(6,12,18,24)], add_rep,rep=6)
df_list2 <- lapply(df_list2, col_names)
df_list2 <- lapply(df_list2, change_POSIX)

# merge into one dataframe
hobo_data2 <- rbind(df_list2$r1_a_2,df_list2$r2_a_2,df_list2$r3_a_2,df_list2$r4_a_2,df_list2$r5_a_2,df_list2$r6_a_2,
                   df_list2$r1_w_2,df_list2$r2_w_2,df_list2$r3_w_2,df_list2$r4_w_2,df_list2$r5_w_2,df_list2$r6_w_2,
                   df_list2$r1_d_2,df_list2$r2_d_2,df_list2$r3_d_2,df_list2$r4_d_2,df_list2$r5_d_2,df_list2$r6_d_2,
                   df_list2$r1_wd_2,df_list2$r2_wd_2,df_list2$r3_wd_2,df_list2$r4_wd_2,df_list2$r5_wd_2,df_list2$r6_wd_2)

# these files have data starting April 2023 (when shelters were placed back on plots after annual burn) through November 2023
r1_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R1_F7_A_2023_11_10.csv"))[,2:4]
r1_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R1_F7_W_2023_11_10.csv"))[,2:4]
r1_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R1_F1_A_2023_11_10.csv"))[,2:4]
r1_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R1_F1_W_2023_11_10.csv"))[,2:4]

r2_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R2_F2_A_2023_11_10.csv"), check.names = F)[,2:4]
r2_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R2_F2_W_2023_11_10.csv"))[,2:4]
r2_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R2_F5_W_2023_11_10.csv"))[,2:4]
r2_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R2_F5_A_2023_11_10.csv"))[,2:4]

r3_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R3_F4_A_2023_11_10.csv"))[,2:4]
r3_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R3_F4_W_2023_11_10.csv"))[,2:4]
r3_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R3_F5_A_2023_11_10.csv"))[,2:4]
r3_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R3_F5_W_2023_11_10.csv"))[,2:4]

r4_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R4_F1_A_2023_11_10.csv"))[,2:4]
r4_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R4_F1_W_2023_11_10.csv"))[,2:4]
r4_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R4_F6_A_2023_11_10.csv"))[,2:4]
r4_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R4_F6_W_2023_11_13.csv"))[,2:4]

r5_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R5_F4_A_2023_11_10.csv"))[,2:4]
r5_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R5_F4_W_2023_11_10.csv"))[,2:4]
r5_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R5_F3_A_2023_11_10.csv"))[,2:4]
r5_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R5_F3_W_2023_11_10.csv"))[,2:4]

r6_a_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R6_F1_A_2023_11_10.csv"))[,2:4]
r6_w_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R6_F1_W_2023_11_10.csv"))[,2:4]
r6_d_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R6_F2_A_2023_11_10.csv"))[,2:4]
r6_wd_3 <- read.csv(file.path(dir, "sensors/OTC Footprints/L0/2023 HOBO pendant data/November/PLZ_R6_F2_W_2023_11_10.csv"))[,2:4]

# put dataframes into a list to apply functions
df_list3 <- list(r1_a_3=r1_a_3,r2_a_3=r2_a_3,r3_a_3=r3_a_3,r4_a_3=r4_a_3,r5_a_3=r5_a_3,r6_a_3=r6_a_3,
                 r1_w_3=r1_w_3,r2_w_3=r2_w_3,r3_w_3=r3_w_3,r4_w_3=r4_w_3,r5_w_3=r5_w_3,r6_w_3=r6_w_3,
                 r1_d_3=r1_d_3,r2_d_3=r2_d_3,r3_d_3=r3_d_3,r4_d_3=r4_d_3,r5_d_3=r5_d_3,r6_d_3=r6_d_3,
                 r1_wd_3=r1_wd_3,r2_wd_3=r2_wd_3,r3_wd_3=r3_wd_3,r4_wd_3=r4_wd_3,r5_wd_3=r5_wd_3,r6_wd_3=r6_wd_3)
df_list3[1:6] <- lapply(df_list3[1:6], add_treat,trt="Ambient")
df_list3[7:12] <- lapply(df_list3[7:12], add_treat,trt="Warmed")
df_list3[13:18] <- lapply(df_list3[13:18], add_treat,trt="Drought")
df_list3[19:24] <- lapply(df_list3[19:24], add_treat,trt="Warmed_Drought")
df_list3[c(1,7,13,19)] <- lapply(df_list3[c(1,7,13,19)], add_rep,rep=1)
df_list3[c(2,8,14,20)] <- lapply(df_list3[c(2,8,14,20)], add_rep,rep=2)
df_list3[c(3,9,15,21)] <- lapply(df_list3[c(3,9,15,21)], add_rep,rep=3)
df_list3[c(4,10,16,22)] <- lapply(df_list3[c(4,10,16,22)], add_rep,rep=4)
df_list3[c(5,11,17,23)] <- lapply(df_list3[c(5,11,17,23)], add_rep,rep=5)
df_list3[c(6,12,18,24)] <- lapply(df_list3[c(6,12,18,24)], add_rep,rep=6)
df_list3 <- lapply(df_list3, col_names)
df_list3 <- lapply(df_list3, change_POSIX)

# lists the column names to check if they are all the same or not (if not then you might have to add to the HOBO clean col_names function)
column_names <- lapply(df_list3, colnames)
column_names
df_list3 <- lapply(df_list3, col_names)

# merge into one dataframe
hobo_data3 <- rbind(df_list3$r1_a_3,df_list3$r2_a_3,df_list3$r3_a_3,df_list3$r4_a_3,df_list3$r5_a_3,df_list3$r6_a_3,
                    df_list3$r1_w_3,df_list3$r2_w_3,df_list3$r3_w_3,df_list3$r4_w_3,df_list3$r5_w_3,df_list3$r6_w_3,
                    df_list3$r1_d_3,df_list3$r2_d_3,df_list3$r3_d_3,df_list3$r4_d_3,df_list3$r5_d_3,df_list3$r6_d_3,
                    df_list3$r1_wd_3,df_list3$r2_wd_3,df_list3$r3_wd_3,df_list3$r4_wd_3,df_list3$r5_wd_3,df_list3$r6_wd_3)

hobo_data_all <- full_join(hobo_data, hobo_data2)
hobo_data_all <- full_join(hobo_data_all, hobo_data3)
hobo_data_all <- full_join(hobo_data_all, hobo_2021_long2)

# Info to know for cleaning:
# 2022-- pendants removed 3/27/2022. Date of burn 3/29/2022.  Date REX pendants start up. 4/15/2023.  So, no pendant data from 3/27/2022 thru 4/15/2022.
# 2023 – pendants removed 3/27/2023. Date of burn 3/28/2022.  Date REX pendants start up. 4/19/2023. So, no pendant data from 3/27/2023 thru 4/19/2023

# delete data that falls in the ranges specified above
# 2022
hobo_data_all_filtered <- hobo_data_all[!(hobo_data_all$Date_Time >= "2022-03-27 00:00:00" & hobo_data_all$Date_Time <= "2022-04-15 00:00:00"), ]
# 2023
hobo_data_all_filtered <- hobo_data_all[!(hobo_data_all$Date_Time >= "2022-03-27 00:00:00" & hobo_data_all$Date_Time <= "2022-04-19 00:00:00"), ]

# upload to drive
write.csv(hobo_data_all_filtered, file.path(dir,"sensors/OTC Footprints/L1/T7_warmx_HOBO_L1.csv"), row.names=F)
