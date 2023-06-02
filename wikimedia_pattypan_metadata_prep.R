# Combine metadata from source repo and pattypan, 
# in preparation for upload of photo collection to Wikimedia Commons 

library(tidyverse) 
library(here) 
library(readr) 
library(janitor)

# Read in metadata from source repo CSV
# df_datashare_metadata <- read_csv(here("metadata", "source_repo_raw_export_UK_comp_collecn10283-4857.csv"))

tbl_source_repo_raw_export_UK_comp_collecn10283_4857 <-    read_csv("metadata/source_repo_raw_export_UK_comp_collecn10283-4857.csv", 
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
                                                                              `dc.rights[]` = col_character(), 
                                                                              `dc.subject.classification[en_UK]` = col_character(), 
                                                                              `dc.subject[en_UK]` = col_character(), 
                                                                              `dc.title[en_UK]` = col_character(), 
                                                                              `dc.type[en_UK]` = col_character(), 
                                                                              `ds.not-emailable.item[en]` = col_skip())) %>% clean_names()
                                                              

# Read in metadata from pattypan with readexcel()

# Combine by join on the image filename

# OUtput to a new file, for pasting into the xls