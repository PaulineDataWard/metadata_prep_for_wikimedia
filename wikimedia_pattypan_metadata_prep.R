# Combine metadata from source repo and pattypan, 
# in preparation for upload of photo collection to Wikimedia Commons 

library(tidyverse) 
library(here) 
library(readr) 
library(janitor)
library(readxl)
library(stringr)
library(tools)

# Read in metadata from source repo CSV, 
# after manual cleaning of CSV in Excel to remove unused columns
tbl_source_repo_raw_export_UK_comp_collecn10283_4857 <- read_csv("metadata/source_repo_cleaned_export_UK_comp_collecn10283-4857.csv", 
                                                             col_types = cols(`dc.contributor[en]` = col_character(), 
                                                                              `dc.description.abstract[en_UK]` = col_skip(), 
                                                                              `dc.publisher[en_UK]` = col_skip(), 
                                                                              `dc.relation.isreferencedby[]` = col_skip(), 
                                                                              `dc.relation.isreferencedby[en_UK]` = col_skip(), 
                                                                              `dc.relation.isversionof[]` = col_skip(), 
                                                                              `dc.relation.isversionof[en_UK]` = col_skip(), 
                                                                              `dc.rights[]` = col_skip(), `dc.rights[en]` = col_skip(), 
                                                                              `dc.subject.classification[]` = col_skip(), 
                                                                              `dc.subject.classification[en_UK]` = col_skip(), 
                                                                              `dc.subject[]` = col_skip(), `dc.subject[en_UK]` = col_skip())) %>% clean_names()

# print("Imported source metadata is a tibble: ")
# print(as.character(is_tibble(tbl_source_repo_raw_export_UK_comp_collecn10283_4857)))
# print("distinct uri values:")
# print(distinct(tbl_source_repo_raw_export_UK_comp_collecn10283_4857, dc_identifier_uri))
# print("distinct uri2 values:")
# print(distinct(tbl_source_repo_raw_export_UK_comp_collecn10283_4857, dc_identifier_uri_2))

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
# Workaround - many entries say jpg in title, when in fact files are .png
# No longer need to avoid changing upper case to lower case, as we're using the intermediate fileset '/processed', already lower case. 
filtered_tbl_source$img_filename <- ""
filtered_tbl_source <- filtered_tbl_source %>% mutate(img_filename = str_replace_all(dc_title, "^.*, ", ""))


# try to fix the jpg png mismatch by storing in a new variable image_id on which to join
filtered_tbl_source$image_id <- ""
filtered_tbl_source <- filtered_tbl_source %>% mutate(image_id = str_replace(img_filename, ".jpg$", ""))

new_pattypan_metadata$image_id <- ""
new_pattypan_metadata <- new_pattypan_metadata %>% mutate(image_id = str_replace( str_replace(img_filename, ".png$", ""), ".jpg$", ""))

filtered_tbl_source <- filtered_tbl_source %>% mutate(year = str_sub(dc_coverage_temporal, start = 7, end = 10))


# jettison columns no longer needed in filtered_tb_source
filtered_tbl_source <- select(filtered_tbl_source,-dc_contributor,-dc_contributor_other, -img_filename) 

# Left join on common column ie img_filename - adds all columns
new_pattypan_metadata <-  new_pattypan_metadata %>% 
  left_join(filtered_tbl_source, by = "image_id") 

# Set pattypan description to datashare description
new_pattypan_metadata$description <- new_pattypan_metadata$dc_description_abstract

# Set pattypan title to the datashare title, but with .png where appropriate
# 
new_pattypan_metadata <- new_pattypan_metadata %>% 
  mutate(title = if_else(!str_detect(img_filename, ".png$"), dc_title, str_replace(dc_title, ".jpg$", ".png")))

# Set pattypan depicted_place to the datashare spatial coverage
new_pattypan_metadata$depicted_place = new_pattypan_metadata$dc_coverage_spatial

# Add and set pattypan column date, from chars 7-10 of the temporal coverage field of source
new_pattypan_metadata$date = new_pattypan_metadata$year

# Replace value in column 'source' with the DataShare DOI, either identifier_uri or identifier_uri_2
new_pattypan_metadata$source <- ""
new_pattypan_metadata <- new_pattypan_metadata %>% mutate(source = str_match(dc_identifier_uri, "^https://doi.org/ds/7488/[0-9]{4}$"))


# Populate the categories column, in line with the Aberdeen pilot data on Wikimedia Commons
new_pattypan_metadata$categories <- "Public housing in the United Kingdom"




# Drop pattypan name, and other redundant cols
new_pattypan_metadata <- select(new_pattypan_metadata, -name, -year, -dc_coverage_spatial, -dc_description_abstract, -id) 

# OUtput to a new file, for pasting into the xls
write_delim(new_pattypan_metadata, here("metadata", "new_pattypan_cols.csv"), delim = ",")
