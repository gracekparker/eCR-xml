#-------------------------------------------------------------------------------------------------------------------------#
# Program to read and process XML files and append the data into a data table
# Created: 04-2022
# Created by: Chelsea McMullen
# Edited: 08-2022
# Edited by: Grace Parker
#-------------------------------------------------------------------------------------------------------------------------#

rm(list=ls()) #clear history


#### Set working directory ####
# recommend creating a project in RStudio, and then that will be the automatic working directory
setwd("C:/Users/parkegk/Documents/Projects/eCR RR Analysis")
getwd()

# Set date range & get folder names
monthyear <- "May 2023"
year <- "2023"
datestring <- seq(as.Date("2023-05-07"), by = "day", length.out = 7)
#datestring <- as.Date(c("2022-08-15"))
datelist <- paste0("archive_",datestring)
datelist

# Set report date
rptdate <- gsub("-", ".", Sys.Date())
rptdate

# Install packages as necessary
# install.packages("janitor")

# #load libraries
library(XML)
library(dplyr)
library(xml2)
library(lubridate)
library(stringr)
library(plyr)
library(tidyr)
library(janitor)
library(openxlsx)

# read in files containing relevant functions
#----------------------------------
# Unzips all files in directory, xml_dirs
# source(file = paste0(getwd(), "/R scripts/", "f_unzip_files.R"))

# Processes information from one XML file at a time and appends each dataframe generated into a big table.
source(file = paste0(getwd(), "/R scripts/", "f_create_table_entry_v4.R"))

# directory location where all XML files live in subdirectories
# to test functions below, I would recommend pointing to 1 folder, so that you can quickly test if they are working

xml_dirs <- NULL

for (date in datelist) {
  ecr_file <- paste0(getwd(),"/Rhapsody Files/",year,"/",monthyear,"/",date)
  xml_folder <- dir(path = ecr_file, recursive = TRUE, full.names = TRUE, pattern = "\\.xml$")
  xml_dirs <- c(xml_dirs, xml_folder)
  
}

# If needed to create subset to run small amount of data
# xml_dirs <- xml_dirs[1:100]

# call function to read and process eCR and RR files into a big_table
# get run times (time.taken)
start.time <- Sys.time()

big_table <- f_create_table_entry(xml_dirs)

# create date difference columns
big_table <- big_table %>%
  mutate(rpt_date_chr = as.Date(rpt_date_chr, format = "%m/%d/%Y"),
         enc_lowdate_chr = as.Date(enc_lowdate_chr, format = "%m/%d/%Y"),
         enc_highdate_chr = as.Date(enc_highdate_chr, format = "%m/%d/%Y"),
         datediff_low = rpt_date_chr - enc_lowdate_chr,
         datediff_high = rpt_date_chr - enc_highdate_chr)

write.xlsx(big_table, file = paste0(getwd(),"/Output/ecr_",min(datestring),"_",max(datestring),".xlsx"))
write.xlsx(big_table, file = paste0("L:/PHIN/Systems Documentation/eICR/eCR data evaluation and QA/eCR RR Analysis/Output/Monthly/2023/ecr_",min(datestring),"_",max(datestring),".xlsx"))

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
nrow(big_table)
