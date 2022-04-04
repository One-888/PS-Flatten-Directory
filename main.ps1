
function hash-it { param ([String] $Path)
	return (Get-filehash $Path -Algorithm SHA1 | select hash) 
}

function rename-files { param ([String] $Path)
	"Rename "
	$rename_dir = $Path # "H:\Temp\MOV_ALL"

	gci -Path $rename_dir -file | ` 
	ForEach-Object { `
		$h = (hash-it $_.FullName) -replace "@{Hash=","" ; `
		$h = ($h -replace "}","").ToString().Substring(0,6);`
		$newname = $_.LastAccessTime.ToString("yyyyMMdd") +'_' + $h + $_.Extension; ` 
		Rename-Item -Path $_.FullName -Newname $newname ; `
		return ( "`n" + $h + " > " + $newname ); `` 

	}
}

function remove-dup-files { 
    param([string] $Source, [string] $Destination, [string] $FileType, [int32] $TotalFiles)
    
    $src = $Source # "C:\SourceFolder"
	$dest_in = $Destination # "C:\DestinationFolder"
	cd $dest_in 

	$tmp_dir = "\" + (Get-Date).ToString("yyyyMMdd") + "_" + (New-Guid).ToString().Substring(0,5) 
	$dest = $dest_in + $tmp_dir 
	"`n`ntmp_dir: " + $tmp_dir
	$md = mkdir $dest

	
	$ftype = $FileType # "*.*" 
	$i = 0
    "`nStart Time:" 
	Get-Date

	$row_count = $TotalFiles # Max Files = 999

	cd $dest
    
    #Where-Object DateModified -le $d | ` 	sort LastWriteTime -Descending | ` 
	$cmd = 'gci -Filter $ftype -File -Recurse -Path $src | select -First ' + $row_count 

	Write-Progress -Activity "Calulating" -PercentComplete 3
	$stat = Invoke-Expression $cmd | measure-object -Property length -Sum
	"Size (with Duplicate) MB: " + [math]::Round($stat.Sum / 1mb)
    
    # Copy files using Hash as a new name
	Write-Progress -Activity "Copying" -PercentComplete 10
	$copy_text = Invoke-Expression $cmd | `
	ForEach-Object { $i = $i + 1; $pct = [math]::Round(($i / $stat.Count)*100) ; `
		Write-Progress -Activity "Copying" -PercentComplete $pct; `
		$h = (hash-it $_.FullName) -replace "@{Hash=","" ; `
		$h = ($h -replace "}","").ToString().Substring(0,40);`
		cp -Force -Destination ($dest + "\"+$h + $_.Extension) -Path ($_.FullName ); `
		return ("`n"+ $h.ToString().Substring(0,8) + ": " + $_.Name); } 

	#"`nCopy File:" + ($copy_text)
	"`nTotal Copy Files (with Duplicate):" + ($copy_text).Count

	Write-Progress -Activity "Renaming" -PercentComplete 97
    
    # Rename files to desired format such as 20XXMMDD_Hash ; Make sure they are unique
	$rename_text = rename-files $dest

	#"`nRename File:" + ($rename_text)
	"Total Rename Files (No Duplicate):" + ($rename_text).Count
	Write-Progress -Activity "Closing" -PercentComplete 99
	"`nEnd Time:" 
    Get-Date

}

# Execute Section
 remove-dup-files -Source "C:\OneDrive" -Destination "C:\OneDrive\Export" -FileType "*.pdf" -TotalFiles 999
