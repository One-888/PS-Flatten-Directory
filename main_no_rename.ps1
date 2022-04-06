function hash-it { param ([String] $Path)
    $h1 = (Get-filehash $Path -Algorithm SHA1  | select hash) -replace "@{Hash=",""
    $h2 = ($h1 -replace "}","").ToString().Substring(0,32)
    return $h2 
}

function main_run {

$dest_in = "h:\exp\"
cd $dest_in 

$src = "C:\Amazon Photos\2015"
$dest = $dest_in  
$ftype = "*.*" 
$i = 0
$d = (get-date).AddYears(1)
"Files Before " + $d
Get-Date

$row_count = 9

cd $dest

$cmd = 'gci -Filter $ftype -Recurse -Path $src -file   |  `
 Where-Object DateModified -le $d          | `
 sort DateModified -Descending             | ` 
 select -First ' + $row_count 

Write-Progress -Activity "Overall" -PercentComplete 5
$stat = Invoke-Expression $cmd | measure-object -Property length -Sum
"Size GB: " + [math]::Round($stat.Sum / 1gb)
"# of Files: " + $stat.Count      

Write-Progress -Activity "Overall" -PercentComplete 10
$copy_text = Invoke-Expression -Verbose $cmd | `
 ForEach-Object { $i= $i+1; $pct=[math]::Round(($i/$stat.Count)*100) ; `
                  Write-Progress -Activity ("Copying "+ $pct ) -PercentComplete $pct; `
                  $h = (hash-it $_.FullName) 
                  cp -Verbose -Force -Destination ($dest+"\"+$h+$_.Extension) -Path ($_.FullName ) ;return ("`n" + $_.FullName); } 

"`nCopy File:" + ($copy_text)
"`nTotal File:" + ($copy_text).Count

Write-Progress -Activity "Overall" -PercentComplete 90
 
$temp_dest = $dest  #"H:\Temp\75557"
 
Write-Progress -Activity "Overall" -PercentComplete 99
Get-Date
}

main_run

