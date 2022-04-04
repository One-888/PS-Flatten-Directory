# PS-Flatten-Directory

This Powershell script removes the duplicated files from source directoies and copy to a single export directory (Flatten-Directory). It also renames the file to be generic format such as timestemp YYYYMMDD. 

The useful example is the photos directory. It scans to all subdirectory and making into one directory for easy upload to the cloud. The script do not remove any file from your soruce directory. It creates the new directory with all the renaming files.

Before:
-\2001
-\2002
-\20XX

After
-\All Pictures
