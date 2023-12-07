# TITLE:          REX: HOBO data clean-up functions
# AUTHORS:        Kara Dobson
# COLLABORATORS:  Phoebe Zarnetske, Mark Hammond, Moriah Young, Emily Parker
# DATA:           Functions for cleaning the HOBO data in 
# PROJECT:        REX
# DATE:           Jan 2023

# adding treatment column to the data
add_treat <- function(df, trt) {
  df$Treatment <- trt
  return(df)
}

# adding rep column to the data
add_rep <- function(df, rep) {
  df$Rep <- rep
  return(df)
}

# change column names
col_names <- function(df){
  colnames(df) <- sub("Date.Time..EST.EDT.", "Date_Time", colnames(df))
  colnames(df) <- sub("Ch..1...Temperature.....C..", "Temperature_C", colnames(df))
  colnames(df) <- sub("Ch..2...Light....lux.", "Light_lux", colnames(df))
  colnames(df) <- sub("Date-Time (EST/EDT)", "Date_Time", colnames(df))
  colnames(df) <- sub("Ch..1...Temperature", "Temperature_C", colnames(df))
  colnames(df) <- sub("Temperature_C.....C.", "Temperature_C", colnames(df))
  return(df)
}

# change date format to POSIX format
change_POSIX <- function(df){
  df[["Date_Time"]] <- as.POSIXct(df[["Date_Time"]],tryFormats = c("%m/%d/%y %I:%M:%S %p",
                                                                   "%m/%d/%Y %H:%M",
                                                                   "%m/%d/%y %H:%M",
                                                                   "%m/%d/%Y %I:%M:%S",
                                                                   "%m/%d/%Y %H:%M:%S",
                                                                   "%F %H:%M:%S"), tz="UTC")
  return(df)
}
