# PS-Flatten-Directory

This Powershell script removes the duplicated files from source directories by using Hash function and copies them to a single export directory (Flatten-Directory). It also renames the file to be generic format such as timestemp YYYYMMDD. 

The useful example is the photos or media directory. It scans to all subdirectories and making into one directory for easying uploading to the cloud. The script do not remove any file from your soruce files. Instead, it creates the new directory with all the renaming files.

Before:
-\2001\*.MOV
-\2002\*.MOV
-\2002\Jan\*.MOV
-\2002\Feb\*.MOV
-\20XX\*.MOV

After
-\All Pictures\*.MOV
