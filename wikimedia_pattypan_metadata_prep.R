# Combine metadata from source repo and pattypan, 
# in preparation for upload of photo collection to Wikimedia Commons 

library(tidyverse) 
library(here) 
library(readr) 
library(janitor)
library(readxl)
library(stringr)
library(tools)

# Read in metadata from source repo CSV
# df_datashare_metadata <- read_csv(here("metadata", "source_repo_raw_export_UK_comp_collecn10283-4857.csv"))

tbl_source_repo_raw_export_UK_comp_collecn10283_4857 <- read_csv("metadata/source_repo_raw_export_UK_comp_collecn10283-4857.csv", 
                                                             col_types = cols(`dc.contributor.other[en_UK]` = col_skip(), 
                                                                              `dc.contributor[en]` = col_skip(), 
                                                                              `dc.coverage.spatial[en]` = col_character(), 
                                                                              `dc.coverage.spatial[en_UK]` = col_character(), 
                                                                              `dc.description.abstract[en_UK]` = col_character(), 
                                                                              `dc.identifier.uri[]` = col_character(), 
                                                                              `dc.language.iso[]` = col_skip(), 
                                                                              `dc.language.iso[en_UK]` = col_skip(), 
                                                                              `dc.publisher[en_UK]` = col_skip(), 
                                                                              `dc.relation.isreferencedby[en_UK]` = col_skip(), 
                                                                              `dc.relation.isversionof[]` = col_skip(), 
                                                                              `dc.relation.isversionof[en_UK]` = col_skip(), 
                                                                              `dc.rights[]` = col_skip(), 
                                                                              `dc.subject.classification[en_UK]` = col_skip(), 
                                                                              `dc.subject[en_UK]` = col_skip(), 
                                                                              `dc.title[en_UK]` = col_character(), 
                                                                              `dc.type[]` = col_skip(), `dc.type[en_UK]` = col_skip(), 
                                                                              `ds.not-emailable.item[en]` = col_skip())) %>% clean_names()


print("Imported source metadata is a tibble: ")
print(as.character(is_tibble(tbl_source_repo_raw_export_UK_comp_collecn10283_4857)))
print("distinct uri values:")
print(distinct(tbl_source_repo_raw_export_UK_comp_collecn10283_4857, dc_identifier_uri))
print("distinct uri2 values:")
print(distinct(tbl_source_repo_raw_export_UK_comp_collecn10283_4857, dc_identifier_uri_2))

# Read in metadata from pattypan 
tbl_pattypan_intermediate_processed_fileset_UK_Tower_Block <- read_xls("metadata/pattypan_intermediate_processed_fileset_UK_Tower_Block.xls", 
                                                                     col_types = c("text", "text", "text", 
                                                                                   "text", "text", "text", "text"))


print("Imported pattypan table is typeof: ")
print(typeof(tbl_pattypan_intermediate_processed_fileset_UK_Tower_Block))
  
# Identify and then exclude the images already on wikimedia ie Aberdeen collection
filtered_tbl_source <- tbl_source_repo_raw_export_UK_comp_collecn10283_4857 %>%
  filter(! str_detect(collection, "3304"))

# Prep the columns in order to combine by join on the image filename 
# Use basename from base R to extract filename from path
new_pattypan_metadata <- tbl_pattypan_intermediate_processed_fileset_UK_Tower_Block %>% mutate(img_filename = basename(path))

# Use stringr to extract filename from title
# No longer need to avoid changing upper case to lower case, as we're using the intermediate fileset '/processed', already lower case. 
filtered_tbl_source$img_filename <- ""
filtered_tbl_source <- filtered_tbl_source %>% mutate(img_filename = str_replace_all(dc_title, "^.*, ", ""))
filtered_tbl_source <- filtered_tbl_source %>% mutate(year = str_sub(dc_coverage_temporal, start = 7, end = 10))

# Combine the three versions of the spatial coverage column - two of the three are always empty 'NA'
filtered_tbl_source <- filtered_tbl_source %>% mutate(dc_coverage_spatial = paste(filtered_tbl_source$dc_coverage_spatial, dc_coverage_spatial_en, dc_coverage_spatial_en_uk))
  
  
# jettison columns no longer needed in filtered_tb_source
filtered_tbl_source <- select(filtered_tbl_source,-dc_contributor,-dc_contributor_other) 



# Left join on common column ie img_filename - adds all columns
new_pattypan_metadata <-  new_pattypan_metadata %>% 
  left_join(filtered_tbl_source_repo_UK_comp_collection, by = "img_filename") 

# Drop pattypan name, since join has already been carried out


# Replace value in column 'source' with the DataShare DOI, either identifier_uri or identifier_uri_2
# new_pattypan_metadata$source <- ""

# Should be no need to set column permission, since we have used pattypan to set this. 
# OLD!!! new_pattypan_metadata$permission = "Cc-by-sa-4.0"

# Populate the categories column, in line with the Aberdeen pilot data on Wikimedia Commons
new_pattypan_metadata$categories <- "Public housing in the United Kingdom"

# Set pattypan title to the datashare title

# Set pattypan description to datashare description


# Set pattypan depicted_place to the datashare spatial coverage


# Add and set pattypan column date, from chars 7-10 of the temporal coverage field of source
new_pattypan_metadata$date = "YYYY"

# OUtput to a new file, for pasting into the xls
write_delim(new_pattypan_metadata, here("metadata", "new_pattypan_cols.csv"), delim = ",")
