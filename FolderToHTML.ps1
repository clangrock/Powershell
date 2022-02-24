#Script Version
$sScriptVersion = "0.02"

#Set Error Action to Silently Continue
$ErrorActionPreference =  "SilentlyContinue"

# define script folder
$scriptFolder = $PSScriptRoot
# $sFunctionFolder = Join-Path $scriptFolder "functions"

#Output File Info
$sOutputPath = $scriptFolder + "\temp\"
$sDate = Get-Date -Format yyyy-MM-dd
$sTime = Get-Date -Format HH:mm
$sOutputName = -Join ("FOLDER_Report_","_" ,$sDate, ".HTML")
$sOutputFile = Join-Path -Path $sOutputPath -ChildPath $sOutputName 


$InputFolder = 'D:\PALL_Projekte\@releases\MDF\'

#Get-ChildItem -LiteralPath $InputFolder -Recurse | Select-Object @{name="Link"; expression={"a href='$($_.FullName)'>$($_.Name)</a>"}} | ConvertTo-Html $sOutputFile # | Out-File $sOutputFile -Append

#$outData = Get-ChildItem -LiteralPath $InputFolder -Recurse | Select-Object @{expression={"a href='$($_.FullName)'>$($_.Name)</a>"}} #| Out-File $sOutputFile -Append
$outData2 = @{}

$outData2 = Get-ChildItem -LiteralPath $InputFolder -Recurse | Select-Object @{expression={"a href='$($_.FullName)'>$($_.Name)</a>"}} 
