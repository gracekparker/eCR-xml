### Read function to transform them to a dataframe
# Edited 3/6

f_create_table_entry <- function(dir) {
  
  #### Initialize dataframes
  full.df <- NULL
  
  #### For testing, comment out
  dir <- xml_dirs
  
  #### Create unique file ID list
  filelist2 <- str_extract(dir, "^([^_]*_){3}")
  filelist <- unique(filelist2)
  #filename <- filelist[1]
  #filename <- "type example filepath here for testing"
  
  # Initializes the progress bar
  pb <- txtProgressBar(min = 0,                     # Minimum value of the progress bar
                       max = length(filelist),   # Maximum value of the progress bar
                       style = 3,
                       width = 50,
                       char = "=")
  
    
  for (filename in filelist)  {
  
  tryCatch({  
  #### 1. read in eCR file and RR file ####
  ecr_file <- read_xml(paste0(filename,"CDA_eICR.xml"))
  rr_file <- read_xml(paste0(filename,"CDA_RR.xml"))
  
  #rr_file <- read_xml(filename)
  
  # strip namespaces, so that you can find the nodes
  ecr <- xml_ns_strip(ecr_file)
  rr <- xml_ns_strip(rr_file)
  
  #### 2. Create unique ID #### 
  # https://aphlinformatics.atlassian.net/wiki/spaces/EKM/pages/195067945/How+to+link+eICRs+from+the+same+encounter+together 
  # XPath: ClinicalDocument/setId/@extension + XPath: /ClinicalDocument/versionNumber/@value
  # SetID is unique to the encompassing encounter, and versionNumber is the version of the message sent
  # combine them for a unique ID for the eCR message
  
  
  # find node "setId" and find value of @extension within node setId
  setid <- ecr %>%
    xml_find_first( "//setId") %>%
    xml_attr( "extension")
  
  # find node VersionNumber and find value of @value within node versionNumber
  version <- ecr %>%
    xml_find_first( "//versionNumber") %>%
    xml_attr( "value")
  
  
  # paste setId and versionNumber into one unique ID
  UID <- paste0(setid, "-", version)
  
  
  
  #### 3. Map other fields in the eCR message #### 
  # primary and secondary demos, date and time of message, HCO and facility and encounter type
  
  #----
  # get file name so you can easily reference the file when needed
  # file_name <- str_sub(dir, start= -35)
  
  #----
  # get folder name in order to assign facility (each HCO has its own folder, otherwise find field  or location that tells you the HCO)
  # folder <- str_match(dir, "(work/ecr/(.*?)/2022)")[[3]]
  
  #----
  # get file name by removing file path
  filename_short <- sub(".*/", "", filename)
  
  #----
  # grab first name
  fname <- ecr %>%
    xml_find_first( "//name[@use='L']/given[1]") %>%
    xml_text()
  
  #----
  # grab last name
  lname <- ecr %>%
    xml_find_first( "//name[@use='L']/family[1]") %>%
    xml_text()
  
  #----
  # grab birth date
  dob <- ecr %>%
    xml_find_all( ".//patient/birthTime") %>%
    xml_attr("value")
  
  # parse dob into date 
  y <- substr(dob, start = 1, stop = 4)
  m <- substr(dob, start = 5, stop = 6)
  d <- substr(dob, start = 7, stop = 8)
  
  dob_chr <- paste0(m, "/", d, "/", y)
  
  # # format dob as date
  # dob <- mdy(dob_chr)
  
  
  #----
  # get MRN
  # mrn <- ecr %>%
  #   xml_find_first( "./recordTarget/PatientRole/id") %>%
  #   xml_attr("extension")
  
  
  #----
  # grab race
  race <- ecr %>%
    xml_find_all( ".//patient/raceCode") %>%
    xml_attr("displayName")
  
  #----
  # grab ethnicity
  ethnic <- ecr %>%
    xml_find_all( ".//patient/ethnicGroupCode") %>%
    xml_attr("displayName")
  
  #----
  #grab gender
  gender <- ecr %>%
    xml_find_all( ".//patient/administrativeGenderCode") %>%
    xml_attr("displayName")
  
  #----
  # grab state
  state <- ecr %>%
    xml_find_first( ".//addr/state") %>%
    xml_text()
  
  #----
  # grab street address
  street <- ecr %>%
    xml_find_first( ".//addr/streetAddressLine") %>%
    xml_text()
  
  #----
  #grab city
  city <- ecr %>%
    xml_find_first( ".//addr/city") %>%
    xml_text()
  
  #----
  #grab zip
  zip <- ecr %>%
    xml_find_first( ".//addr/postalCode") %>%
    xml_text()
  
  #----
  #grab home phone
  home_tel <- ecr %>%
    xml_find_first( ".//telecom[@use='HP']") %>%
    xml_attr("value")
  
  
  #----
  #grab cell phone
  cell_tel <- ecr %>%
    xml_find_first( ".//telecom[@use='MC']") %>%
    xml_attr("value")
  
  #----
  #grab email
  email <- ecr %>%
    xml_find_first( ".//telecom[contains(@value, 'mailto:')]") %>%
    xml_attr("value")

  
  #----
  #grab occupation
  # occupation <- ecr %>%
  #   xml_find_first(" ./component/structuredBody/component[8]/section/text/table[3]/tbody/tr/td[contains(@ID, 'sochist18')]") %>%
  #   xml_text()
  
  #----
  #grab industry
  # industry <- ecr %>%
  #   xml_find_first(" ./component/structuredBody/component[8]/section/text/table[3]/tbody/tr/td[contains(@ID, 'sochist19')]") %>%
  #   xml_text()
  
  #----
  #grab HCO
  hco <- ecr %>%
    xml_find_first( ".//representedOrganization/name") %>%
    xml_text()
  
  #----
  #grab HCO ID
  hco_id <- ecr %>%
    xml_find_first( ".//representedOrganization/id") %>%
    xml_attr("extension")
  
  #----
  #grab custodian
  custodian <- ecr %>%
    xml_find_first( ".//representedCustodianOrganization/name") %>%
    xml_text()
  
  #----
  #grab custodian ID
  custodian_id <- ecr %>%
    xml_find_first( ".//representedCustodianOrganization/id") %>%
    xml_attr("extension")
  custodian_id
  
  #----
  #grab facility
  facility <- ecr %>%
    xml_find_first( ".//encompassingEncounter/location/healthCareFacility/location/name") %>%
    xml_text()
  
  #----
  #grab facility state
  facility_state <- ecr %>%
    xml_find_first( ".//encompassingEncounter/location/healthCareFacility/serviceProviderOrganization/addr/state") %>%
    xml_text() 
  
  #----
  #grab assigned author address
  assigned_author_address <- ecr %>%
    xml_find_first(".//assignedAuthor/addr/streetAddressLine") %>%
    xml_text()
  
  
  #----
  #grab Encounter type
  enc_type <- ecr %>%
    xml_find_first( ".//encompassingEncounter/code") %>%
    xml_attr("displayName")
  
  #grab encompassing encounter datetime
  #encompassing encounter - low date
  enc_ldt <- ecr %>%
    xml_find_first(".//encompassingEncounter/effectiveTime/low") %>%
    xml_attr("value")
  
  enc_ly <- substr(enc_ldt, start = 1, stop = 4)
  enc_lm <- substr(enc_ldt, start = 5, stop = 6)
  enc_ld <- substr(enc_ldt, start = 7, stop = 8)
  
  enc_lowdate_chr <- paste0(enc_lm, "/", enc_ld, "/", enc_ly)
  
  #encompassing encounter - high date
  enc_hdt <- ecr %>%
    xml_find_first(".//encompassingEncounter/effectiveTime/high") %>%
    xml_attr("value")
  
  enc_hy <- substr(enc_hdt, start = 1, stop = 4)
  enc_hm <- substr(enc_hdt, start = 5, stop = 6)
  enc_hd <- substr(enc_hdt, start = 7, stop = 8)
  
  enc_highdate_chr <- paste0(enc_hm, "/", enc_hd, "/", enc_hy)
  
  #reason for visit
  reason_for_visit <- ecr %>%
    xml_find_all( ".//tr/td[contains(@ID, 'reasonrfv')]") %>%
    xml_text()
  reason_for_visit <- paste(reason_for_visit, collapse = "; ")

  #history of present illness
  hx_present_illness <- ecr %>%
    xml_find_first( ".//section[code[contains(@displayName, 'HISTORY OF PRESENT ILLNESS')]]/text/list/item/content") %>%
    xml_attr("ID") # ID does not pull content, just pulls Note2, nof2, etc. to determine whether the field was completed
  
  #history of present illness
  hx_present_illness_txt <- ecr %>%
    xml_find_all( "./component/structuredBody/component/section/text/list/item/content/content[1]") %>%
    xml_text() # ID does not pull content, just pulls Note2, nof2, etc.
  hx_present_illness_txt <- paste(hx_present_illness_txt, collapse = "; ")
  
  #patient care coordination note
  pcc_note <- ecr %>%
    xml_find_first( ".//tr/td/content[contains(@ID, 'PCCnote')]") %>%
    xml_text()
  
  
  #medication - not on file tag
  medication_noftag <- ecr %>%
    xml_find_first( "./component/structuredBody/component[3]/section/text/content") %>%
    xml_attr("ID") # This should only come up if not on file
  
  #medication list
  medication <- ecr %>%
    xml_find_all(".//tr/td/paragraph[contains(@ID, 'med')]") %>%
    xml_text() 
  medication <- paste(medication, collapse = "; ") 
  
  #plan of treatment
  plan_of_tx <- ecr %>%
    xml_find_all(".//section[code[contains(@displayName, 'Plan of care')]]/entry/observation/code") %>%
    xml_attr("displayName")
  plan_of_tx <- paste(plan_of_tx, collapse = "; ")
  plan_of_tx
  
  #problem list
  problem_list <- ecr %>%
    xml_find_all(".//tr[contains(@ID, 'problem')]/td[contains(@ID, 'name')]") %>%
    xml_text()
  problem_list <- paste(problem_list, collapse = "; ")
  
  #rctc code set
  #code vs value nodes - files use both
  rctc_code_set <- ecr %>%
    xml_find_first(".//code[@sdtc:valueSetVersion]") %>%
    xml_attr("valueSetVersion")
  rctc_code_set_v2 <- ecr %>%
    xml_find_first(".//value[@sdtc:valueSetVersion]") %>%
    xml_attr("valueSetVersion")
  rctc_code_set <- ifelse(!is.na(rctc_code_set), rctc_code_set, rctc_code_set_v2)
  
  #----
  #grab date and time of message
  rpt_time <- ecr %>%
    xml_find_all( "./effectiveTime") %>%
    xml_attr("value")
  
  # parse rpt_time into date 
  rpt_y <- substr(rpt_time, start = 1, stop = 4)
  rpt_m <- substr(rpt_time, start = 5, stop = 6)
  rpt_d <- substr(rpt_time, start = 7, stop = 8)
  
  rpt_date_chr <- paste0(rpt_m, "/", rpt_d, "/", rpt_y)
  
  # parse rpt_time into time
  h <- substr(rpt_time, start = 9, stop = 10)
  m <- substr(rpt_time, start = 11, stop = 12)
  s <- substr(rpt_time, start = 13, stop = 14)
  
  # concat date and time for lubridate formatting
  rpt_date_time_chr <- paste0(rpt_date_chr, " ",h, ":", m, ":", s)
  
  
  # manually triggered flag
  manual <- ecr %>%
    xml_find_first( "./documentationOf/serviceEvent/code") %>%
    xml_attr("displayName")
  
  # smoking variable code
  # smoker_code <- ecr %>%
  #   xml_find_first( "./component/structuredBody/component/section/entry/observation[templateId[contains(@root, '2.16.840.1.113883.10.20.22.4.78')]]/value") %>%
  #   xml_attr("code")
  
  # smoking variable
  smoker <- ecr %>%
    xml_find_first( ".//observation[templateId[contains(@root, '2.16.840.1.113883.10.20.22.4.78')]]/value") %>%
    xml_attr("displayName")

  
  
  
  #### 4. Map fields from RR, set unique ID to same as eCR message #### 
  
  # eCR report date
  rpt_date_rr <- rr %>%
    xml_find_all( "./effectiveTime") %>%
    xml_attr("value")
  
  # parse rpt_time into date 
  rpt_y <- substr(rpt_date_rr, start = 1, stop = 4)
  rpt_m <- substr(rpt_date_rr, start = 5, stop = 6)
  rpt_d <- substr(rpt_date_rr, start = 7, stop = 8)
  
  rpt_date_chr_rr <- paste0(rpt_m, "/", rpt_d, "/", rpt_y)
  
  # parse rpt_time into time
  h <- substr(rpt_date_rr, start = 9, stop = 10)
  m <- substr(rpt_date_rr, start = 11, stop = 12)
  s <- substr(rpt_date_rr, start = 13, stop = 14)
  
  # concat date and time for lubridate formatting
  rpt_date_time_chr_rr <- paste0(rpt_date_chr_rr, " ",h, ":", m, ":", s)
  
  # get number of reported conditions
  n_conditions <- rr %>%
    xml_find_all( "./component/structuredBody/component/section/entry/organizer/component/observation/value") %>%
    xml_attr("code") %>%
    length()
  i <- c(1:n_conditions)

  rr.df <- NULL
  
  big_rr.df <- NULL
  
  for (n in i) {
  
  # root id 
  # root_id <- rr %>%
  #   xml_find_first(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/id")) %>%
  #   xml_attr("root")
  
  # condition code
  condition_code <- rr %>%
    xml_find_first(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/value")) %>%
    xml_attr("code")
  
  # condition name
  condition <- rr %>%
    xml_find_all(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/value")) %>%
    xml_attr("displayName")
  
  # reportability status
  reportability <- rr %>%
    xml_find_first(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/entryRelationship/organizer/component/observation[code[contains(@displayName, 'Determination of reportability')]]/value")) %>%
    xml_attr("displayName")
  
  # determination of reportability
  reportability_determination <- rr %>%
    xml_find_all(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/entryRelationship/organizer/component/observation/entryRelationship/observation/value")) %>%
    xml_text()
  # Set to NA if length is 0 - otherwise will be character(0) which breaks the script
  if(length(reportability_determination) == 0) {
    reportability_determination = NA
  }
  
  # rules authoring agency
  rules_authoring_agency <- rr %>%
    xml_find_first(paste0("./component/structuredBody/component/section/entry/organizer/component[",n,"]/observation/entryRelationship/organizer/participant/participantRole/playingEntity/name")) %>%
    xml_text()
  
  rr.df <- data.frame(condition_code, condition, reportability, reportability_determination, rules_authoring_agency)
  
  big_rr.df <- rbind(big_rr.df, rr.df)
  }
 
  # eICR info paragraph
  eICR_info <- rr %>%
    xml_find_first( "./component/structuredBody/component[2]/section/text/paragraph") %>%
    xml_text()
  
  # eICR processing status
  eICR_process_status <- rr %>%
    xml_find_first( "./component/structuredBody/component[2]/section/entry[2]/act/code") %>%
    xml_attr("displayName")
  
  # eICR processing code
  eICR_process_warning <- rr %>%
    xml_find_first( "./component/structuredBody/component/section/entry/act/entryRelationship/observation/value") %>%
    xml_attr("displayName")
  
  
  
  #### 5. link the sections of the ecr and RR messages into a data.frame #### 
  
  ecr.df <- data.frame(
                        # Patient Information
                        UID, filename_short, dob_chr, gender, race, ethnic, 
                        fname, lname, street, city, state, zip, smoker, email, cell_tel, home_tel,
                        reason_for_visit, hx_present_illness, hx_present_illness_txt, 
                        pcc_note, medication, plan_of_tx, problem_list, rctc_code_set,
                        # Facility Information
                        hco, hco_id, custodian, custodian_id,
                        facility, facility_state, assigned_author_address, enc_type, 
                        # Message Information
                        rpt_time, rpt_date_chr, rpt_date_time_chr, 
                        rpt_date_chr_rr, rpt_date_time_chr_rr,
                        enc_lowdate_chr, enc_highdate_chr,
                        eICR_process_status, eICR_process_warning)
  
  ecr_rr.df <- cbind(ecr.df, big_rr.df)

  full.df <- rbind(full.df, ecr_rr.df)
  
  }, 
  
  setTxtProgressBar(pb, filename),
  
  error=function(e){cat("ERROR :",paste0(conditionMessage(e),"| FILE: ",filename), "\n")})
    
    
  }
  
  close(pb)
  return(full.df)
}
