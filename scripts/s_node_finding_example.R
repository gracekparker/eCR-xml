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


# Set up
  # File name
filename <- "C:/Users/parkegk/Documents/Projects/eCR RR Analysis/Rhapsody Files/Examples/test_case_"
  # Read eICR / RR xml files
ecr_file <- read_xml(paste0(filename,"CDA_eICR.xml"))
  # Strip namespaces to fine the nodes
ecr <- xml_ns_strip(ecr_file)

# Find by location of node
plan_of_tx <- ecr %>%
  xml_find_all("./component/structuredBody/component[4]/section/entry/observation/code") %>%
  xml_attr("displayName")
plan_of_tx
plan_of_tx <- paste(plan_of_tx, collapse = "; ")
plan_of_tx

# Find by value in node
plan_of_tx <- ecr %>%
  xml_find_all(".//section[code[contains(@displayName, 'Plan of care')]]/entry/observation/code") %>%
  xml_attr("displayName")
plan_of_tx <- paste(plan_of_tx, collapse = "; ")
plan_of_tx


