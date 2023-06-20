# eCR-xml
Used to parse eCR information from xml files

**Scripts:**
1. f_create_table_entry
   - States the function for creating table from eICR/RR pairs
   - Includes xpaths for relevant fields
2. s_read_process_table
   - Uses function above to create a table
3. s_node_finding_example 
   - Shows an example of finding node by location vs value
   - May help in testing new xpaths
3. eCR_DQ_Report
   - Coming soon!

## Instructions for first time use
1. Set up your file structure. Here is an example of how ours is organized:
Main folder:
eCR RR Analysis
Subfolders:
/R scripts
/Rhapsody files
/Output

2. Edit s_read_process_table
   - Open s_read_process_table in RStudio
   - Set working directory to your main folder (line 14)
   - Set dates (line 21-23)
   - Edit write.xlsx function to point to the output folder (line 90)
   - Make other necessary edits that may be unique to your file or folder structure
   - Save changes

3. Edit f_create_table
   - Open f_create_table in RStudio
   - If neccessary, make edits to line 32-33 for eICR and RR file names, ours end in CDA_eICR / CDA_RR
   - If you add any new fields/xpaths, make sure you write them out to the dataframe (beginning on line 450)
   - Save changes
  
4. Run s_read_process_table

## Fields of Interest

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

