# metadata_prep_for_wikimedia
Prepare metadata for upload to Wikimedia Commons etc

I'm preparing a collection of photos so that I can use Pattypan bulk upload tool to upload them to Wikimedia Commons. I've run pattypan over the local collection of files already, so I have that output, a .xls file containing paths to all the image files. I need to join that to the list of DOIs from the source repository (Edinburgh DataShare), joining on the image filename (because it is unique in the collection), so that I can upload the DataShare DOIs along with the image names and filenames. The DataShare metadata is a CSV file, the result of a standard DSpace metadata export (logged in as admin, using the 'export metadata' button on the collection page in the GUI). 

I've decided to use R instead of python to create a joined table (using the merge feature from the pandas package). And I'll copy and paste that table back into pattypan's .xls file, to allow me to run the upload. 