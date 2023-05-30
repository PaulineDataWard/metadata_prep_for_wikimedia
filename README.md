# metadata_prep_for_wikimedia
Prepare metadata for upload to Wikimedia Commons etc

I'm preparing a collection of photos so that I can use Pattypan bulk upload tool to upload them to Wikimedia Commons. I've run pattypan over the local collection of files already, so I have that output, a .xls file containing paths to all the image files. I need to join that on the list of DOIs from the source repository (Edinburgh DataShare), based on the image filename (it is unique in the collection), so that I can upload the DataShare DOIs along with the image names and filenames. That is a CSV file, the result of a standard DSpace metadata export (logged in as admin, using the 'export metadata' button on the collection page in the GUI). 

I'm going to use python to create a joined table. And I'll copy and paste that table back into pattypan's .xls file, to allow me to run the upload. 