# TITLE:          REX: T2 plots height and greenness measurements on wheat
# AUTHORS:        Moriah Young, Lisa Leonard
# COLLABORATORS:  
# DATA INPUT:     Data imported as csv files from shared REX Google drive L0 folder
# DATA OUTPUT:    Clean L1 data uploaded to L1 folder
# PROJECT:        REX
# DATE:           July 2022

# Clear all existing data
rm(list=ls())

# Load packages
library(tidyverse)

# Set working directory from .Renviron
dir <- Sys.getenv("DATA_DIR")
list.files(dir)

# Read in data
wheat <- read.csv(file.path(dir, "T2_height_greenness_2022_LO.csv"))
# wheat <- read.csv("/Users/moriahyoung/Downloads/T2_height_greenness_2022_L0 - Sheet1.csv")

