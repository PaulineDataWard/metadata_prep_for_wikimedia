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
                                                             col_types = cols(`dc.contributor.other[en_UK]` = col_character(), 
                                                                              `dc.contributor[en]` = col_character(), 
                                                                              `dc.coverage.spatial[en]` = col_character(), 
                                                                              `dc.coverage.spatial[en_UK]` = col_character(), 
                                                                              `dc.description.abstract[en_UK]` = col_character(), 
                                                                              `dc.identifier.uri[]` = col_character(), 
                                                                              `dc.language.iso[]` = col_skip(), 
                                                                              `dc.language.iso[en_UK]` = col_skip(), 
                                                                              `dc.publisher[en_UK]` = col_character(), 
                                                                              `dc.relation.isreferencedby[en_UK]` = col_character(), 
                                                                              `dc.relation.isversionof[]` = col_character(), 
                                                                              `dc.relation.isversionof[en_UK]` = col_character(), 
                                                                              `dc.rights[]` = col_skip(), 
                                                                              `dc.subject.classification[en_UK]` = col_skip(), 
                                                                              `dc.subject[en_UK]` = col_skip(), 
                                                                              `dc.title[en_UK]` = col_character(), 
                                                                              `dc.type[]` = col_skip(), `dc.type[en_UK]` = col_skip(), 
                                                                              `ds.not-emailable.item[en]` = col_skip())) %>% clean_names()


print("Imported source metadata is a tibble: ")
print(as.character(is_tibble(tbl_source_repo_raw_export_UK_comp_collecn10283_4857)))

# Read in metadata from pattypan with readexcel()
tbl_v1_2_PW_pattypan_2023_05_29_08_10_23 <- read_xls("metadata/v1-2_PW_pattypan 2023-05-29 08_10_23.xls", 
                                                   col_types = c("text", "text", "text", 
                                                                 "text", "text", "skip", "text", "skip", 
                                                                 "skip"))
print("Imported pattypan table is typeof: ")
print(typeof(tbl_v1_2_PW_pattypan_2023_05_29_08_10_23))
  
# Identify and then exclude the images already on wikimedia ie Aberdeen collection
filtered_tbl_source_repo_UK_comp_collection <- tbl_source_repo_raw_export_UK_comp_collecn10283_4857 %>%
  filter(! str_detect(collection, "3304"))

# Combine by join on the image filename
# Use basename from base R 
new_pattypan_metadata <- tbl_v1_2_PW_pattypan_2023_05_29_08_10_23 %>% mutate(name = basename(path))
#new_pattypan_metadata <- new_pattypan_metadata %>% mutate(Source = filtered_tbl_source_repo_UK_comp_collection$dc_identifier_uri) 
#%>% left_join(filtered_tbl_source_repo_UK_comp_collection, )

# Add a new column 'Source' for the DataShare DOI
new_pattypan_metadata$Source = ""
#new etc $Source <- 
  
# Add and set column permission to {{Cc-by-sa-4.0}} 

# Set pattypan title to the datashare title

# Set pattypan description 

# Drop pattypan name

# Set pattypan depicted_place to the datashare spatial coverage

# OUtput to a new file, for pasting into the xls
write_delim(new_pattypan_metadata, here("metadata", "new_pattypan_cols.csv"), delim = ",")
