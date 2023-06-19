# eCR-xml
Used to parse eCR information from xml files

**Scripts:**
1. f_create_table
   - States the function for creating table from eICR/RR pairs
   - Includes xpaths for relevant fields
3. s_read_process_table
   - Uses function above to create a table

**Patient Information:**
- UID
- Date of birth
- Gender
- Race
- Ethnicity
- First and last name
- Street address
- City
- State
- Zip code
- Smoking status
- Email address
- Cell telephone number
- Home telephone number

**Visit Information:**
- Encounter type
- Reason for visit
- History of present illness
- Patient care coordination note
- Medication
- Plan of treatment
- Problem list
- RCTC code set
- Report date and time
- Encounter date (low and high)
- eICR process status
- eICR process warning

**Facility Information:**
- Health care organization (name & ID)
- Custodian (name & ID)
- Facility name
- Facility state
- Assigned author address

