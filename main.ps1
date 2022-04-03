function hash-it { param ([String] $Path)
return (Get-filehash $Path -Algorithm MD5  | select hash)  
}

#hash-it "H:\Temp\MOV_ALL\20190926_1929580000_989849.MOV" 

function main_run {

$dest_in = "H:\Temp\"
cd $dest_in 
$tmp_dir = (New-Guid).ToString().Substring(0,5)
"`n`ntmp_dir: " + $tmp_dir
$md = mkdir $tmp_dir 

$src = "F:\All Photos"
$dest = $dest_in + $tmp_dir 
$ftype = "*.mov" 
$i = 0
$d = (get-date).AddYears(-30)
"Files Before " + $d
Get-Date

$row_count = 9

cd $dest

$cmd = 'gci -Filter $ftype -Recurse -Path $src     |  `
 Where-Object DateModified -le $d          | `
 sort DateModified -Descending             | ` 
 select -First ' + $row_count 
#$cmd 
#Invoke-Expression $cmd | Format-Table -AutoSize

Write-Progress -Activity "Overall" -PercentComplete 5
$stat = Invoke-Expression $cmd | measure-object -Property length -Sum
"Size GB: " + [math]::Round($stat.Sum / 1gb)
"# of Files: " + $stat.Count      

Write-Progress -Activity "Overall" -PercentComplete 10
$copy_text = Invoke-Expression -Verbose $cmd | `
 ForEach-Object { $i= $i+1; $pct=[math]::Round(($i/$stat.Count)*100) ; `
                  Write-Progress -Activity "Copying" -PercentComplete $pct; `
                  $h = (hash-it $_.FullName) -replace "@{Hash=","" ; `
                  $h = ($h -replace "}","").ToString().Substring(0,32);`
                  cp -Verbose -Force -Destination ($dest+"\"+$h+$_.Extension) -Path ($_.FullName ) ;return ("`n" + $_.FullName); } 

"`nCopy File:" + ($copy_text)
"`nTotal File:" + ($copy_text).Count

Write-Progress -Activity "Overall" -PercentComplete 90
 
$temp_dest = $dest  #"H:\Temp\75557"

 $rename_text = gci -Path $temp_dest -File | `  
 ForEach-Object {    $newname = $_.LastWriteTime.toString("yyyyMMdd_HHmm") +'_' +  $_.Length.ToString() + $_.Extension; ` 
        Rename-Item -Verbose -Path $_.FullName  -Newname $newname  ; `
        return ( "`n" + ($_.FullName)  +"   >   " + $newname  ); `
 } 
 
"`nRename File:" + ($rename_text)
"`nTotalFile:" + ($rename_text).Count
Write-Progress -Activity "Overall" -PercentComplete 99
Get-Date
}

main_run >> "H:\Temp\mov9.log" 


# MoveDup
$src = "H:\Temp\MOV_ALL" #"F:\All Photos"
$dup = $src + "\Dup"
mkdir $dup -ErrorAction SilentlyContinue
$ftype = "*.mov" 
$a = gci -Path $src -Filter $ftype | Group-Object -Property Length | `
Where-Object { $_.Count -gt 1 } |  Select -ExpandProperty Group |  % {$_.FullName}  `

$a | %{Get-filehash $_.ToString() -Algorithm MD5}  | `
Group-Object -Property Hash | `
Where-Object { $_.Count -gt 1 } | `
Select -ExpandProperty group | select Hash,@{name="Move";expression={"Move-Item -Destination ""$dup"" """ + $_.path+""""}} | Format-table -AutoSize #% {$_.FullName} 


#REname 
$rename_dir = "H:\Temp\MOV_ALL"

$rename_text = gci -Path $rename_dir -File -Exclude "2*" | `  
 ForEach-Object { `
        $h = (hash-it $_.FullName) -replace "@{Hash=","" ; `
        $h = ($h -replace "}","").ToString().Substring(0,20);`
        $newname = $_.LastWriteTime.toStmaring("yyyyMMdd_HHmm") +'_' +  $h + $_.Extension; ` 
        Rename-Item -Verbose -Path $_.FullName  -Newname $newname  ; `
        return ( "`n" + ($_.FullName)  +"   >   " + $newname  ); 
        }


$src = "F:\All Photos" #"F:\All Photos"
$ftype = "*.mov" 
$a = gci -Path $src -Filter $ftype -Recurse | Group-Object -Property Length | `
Where-Object { $_.Count -gt 1 } |  Select -ExpandProperty Group |  % {$_.FullName}  `

$b = $a | %{GEt-filehash $_.ToString() -Algorithm MD5}  | `
Group-Object -Property Hash | `
Where-Object { $_.Count -gt 1 } | `
Select -ExpandProperty group | select Hash #-Unique 

$b.Count

