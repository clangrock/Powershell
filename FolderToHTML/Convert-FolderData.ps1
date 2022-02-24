# Script Version
# $sScriptVersion = "0.02"

#Set Error Action to Silently Continue
$ErrorActionPreference =  "SilentlyContinue"

# define functions 
$fFunction1 = join-Path $scriptFolder "openFolder.ps1"

#load powershell functions
."$fFunction1"

# define script folder
$scriptFolder = $PSScriptRoot

# The html source template file
$sHtmlTemplate = 'HTMLTemplate.html'
$sourceHTMLFile = Join-Path -Path $scriptFolder -ChildPath $sHtmlTemplate

# select folder
#The starting folder to analyze
$startFolder = Get-SHDOpenFolderDialog -Title "Select the root folder for the Table of Contents"


# define the output file
# The final html file that will be produced, #does not need to exist
$OutputFileName ="TableOfContent.html"
$destinationHTMLFile = Join-Path -Path $startFolder -ChildPath $OutputFileName



$htmlLines = @()

function CreateFileDetailRecord{
    param(
        [string]$FilePath
    )
    
    process{
        # read file data
        $files = Get-ChildItem -Path $FilePath -File | Select-Object Name,LastWriteTime,Fullname,Length  
        # get hash and print the result to logfile
        $newFIleRecord = New-Object -TypeName PSObject 
    
        $hash = Get-FileHash -Path $FilePath | Select-Object Hash
        $shash = $hash.Hash
        $Filename = $files.Name
        $WriteTime = $files.LastWriteTime
        $FullFileName = $files.Fullname
        $Size = $files.Length

        #Determine units for a more friendly output
    if(($Size / 1GB) -ge 1){
        [string]$units = "GB"
        $fileSize = [math]::Round(($Size / 1GB),2)
    }
    else
    {
        if(($Size / 1MB) -ge 1){
            $units = "MB"
            $fileSize = [math]::Round(($Size / 1MB),2)
        }
        else{
            $units = "KB"
            $fileSize = [math]::Round(($Size / 1KB),2)
        }
    }

        $newFIleRecord | Add-Member -MemberType NoteProperty -Name FileName -Value $Filename
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $WriteTime
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name Hash -Value $shash
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name Fullname -Value $FullFileName
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name Size -Value $fileSize
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name Units -Value $units
        
    }
    end{
        return $newFIleRecord;
    }
}

#Function that creates a folder detail record
function CreateFolderDetailRecord{
    param(
        [string]$FolderPath
    )
    
    process{
    #Get the total size of the folder by recursively summing its children
    $subFolderItems = Get-ChildItem $FolderPath -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
    $folderSizeRaw = 0
    $folderSize = 0
    $units = ""

    #Account for no children
    if($subFolderItems.sum -gt 0){
        $folderSizeRaw = $subFolderItems.sum     
    }    

    #Determine units for a more friendly output
    if(($subFolderItems.sum / 1GB) -ge 1){
        $units = "GB"
        $folderSize = [math]::Round(($subFolderItems.sum / 1GB),2)
    }
    else
    {
        if(($subFolderItems.sum / 1MB) -ge 1){
            $units = "MB"
            $folderSize = [math]::Round(($subFolderItems.sum / 1MB),2)
        }
        else{
            $units = "KB"
            $folderSize = [math]::Round(($subFolderItems.sum / 1KB),2)
        }
    }

    #Create an object with the given properties
    $newFolderRecord = New-Object -TypeName PSObject
    $newFolderRecord | Add-Member -MemberType NoteProperty -Name FolderPath -Value $FolderPath
    $newFolderRecord | Add-Member -MemberType NoteProperty -Name FolderSizeRaw -Value $folderSizeRaw
    $newFolderRecord | Add-Member -MemberType NoteProperty -Name FolderSizeInUnits -Value $folderSize
    $newFolderRecord | Add-Member -MemberType NoteProperty -Name Units -Value $units
    }
    end{
        return $newFolderRecord;
    }
}

function Convert-FileDataToHTML {
    [CmdletBinding()]
    param (
        [string]$FilePath
    )
    
    begin {
        # Read file data
        $dataFile = CreateFileDetailRecord -FilePath $FilePath
    }
    
    process {
        [DateTime]$date = $dataFile.LastWriteTime 
        [string]$dateFormat = $date.tostring("dd-MMM-yyyy hh.mm.ss")
        $FileLink = Resolve-Path -Path $dataFile.Fullname -Relative
        # convert to HTML link
        $FileLink = $FileLink.Replace("\","/").Replace(" ", "%20")
        $HTMLOutput = '<li><span style="color:darkblue"><a href="'+ $FileLink +'">' + $($dataFile.FileName) + '</a></span>' + "`n" +
            '<ul>' + "`n" +
                '<li> &ensp; [<span style="color:grey"> Last Write Date: </span>] &ensp; (<span style="color:blue">' + $dateFormat + '</span>)</li>' + 
                '<li> &ensp; [<span style="color:grey"> File Size: </span>] &emsp; &emsp; &emsp;(<span style="color:blue">' + $($dataFile.Size) +' ' + $($dataFile.Units) + '</span>)</li>' + 
                '<li> &ensp; [<span style="color:grey"> File Hash: </span>] &emsp; &emsp; &ensp; (<span style="color:blue">' + $($dataFile.Hash) + '</span>)</li>' + 
            '</ul>' + "`n" +
        '</li>' + "`n"    
    }
    
    end {
        Return $HTMLOutput
    }
}

#Function that recursively creates the html for the output, given a starting location
function GetAllFolderDetails
{
    param([string]$FolderPath)    

    $recursiveHTML = @()
    [int]$cont = 0
    #Get properties used for processing
    $folderItem = Get-Item -Path $FolderPath
    $folderDetails = CreateFolderDetailRecord -FolderPath $FolderPath
    $subFolders = Get-ChildItem $FolderPath | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object

    #If has subfolders, create hmtl drilldown. 
    if($subFolders.Count -gt 0)
    {
        $recursiveHTML += '<li><span class="caret">' + $folderItem.Name + '(<span style="color:red">' + $folderDetails.FolderSizeInUnits + " " + $folderDetails.Units + '</span>)</span></li>' + "`n"
        $recursiveHTML += '<li><ul class="nested">'
        #Get all file data in subfolder
        $files = Get-ChildItem -Path $folderItem.FullName -File| Select-Object Name,FullName
        $cont = ($files | Measure-Object  | Select-Object Count).Count  
        if ($cont -gt 0){
            $recursiveHTML += '<li><ul class="nested">'
            #$recursiveHTML += '<li>'
            If ($cont -eq 1){
                $recursiveHTML += Convert-FileDataToHTML -FilePath $files.Fullname
            }
            else {
#                $recursiveHTML += '<li>'
                foreach($file in $files.GetEnumerator()){
                    $recursiveHTML += Convert-FileDataToHTML -FilePath $file.Fullname
                }
            }
#            $recursiveHTML += '</li>'+ "`n"
            $recursiveHTML += '</ul></li>'+ "`n"
        }
    }
    else
    {
        $recursiveHTML += '<li><span class="caret">' + $folderItem.Name + ' (<span style="color:red">' + $folderDetails.FolderSizeInUnits + " " + $folderDetails.Units + '</span>)</span></li>' + "`n"
        
        #Get all file data in subfolder
        $files = Get-ChildItem -Path $folderItem -File| Select-Object Name,FullName 
        $cont = ($files | Measure-Object  | Select-Object Count).Count 
        if ($cont -gt 0){
            $recursiveHTML += '<li><ul class="nested">'
            If ($cont -eq 1){
                $recursiveHTML += Convert-FileDataToHTML -FilePath $files.Fullname
            }
        
            else{
                foreach($file in $files.GetEnumerator()){
                    $recursiveHTML += Convert-FileDataToHTML -FilePath $file.Fullname
                }
            }
            $recursiveHTML += '</ul></li>'+ "`n"
        }

    }

    #Recursively call this function for all subfolders
    foreach($subFolder in $subFolders)
    {
        $recursiveHTML += GetAllFolderDetails -FolderPath $subFolder.FullName;
    }

    #Close up all tags
    if($subFolders.Count -gt 0)
    {
        $recursiveHTML += '</ul>' + "`n"
    }

    # $recursiveHTML += '</li>'+ "`n"
    
    return $recursiveHTML
}

#Processing Starts Here

Set-Location -Path $startFolder

# delete the HtmlFile
Remove-Item -Path $destinationHTMLFile
#Opening html
$htmlLines += '<ul id="myUL">'+ "`n"

#This function call will return all of the recursive html for the starting folder and below
$htmlLines += GetAllFolderDetails -FolderPath $startFolder

#Closing html
$htmlLines += '</ul>'

#Get the html template, replace the template with generated code and write to the final html file
$sourceHTML = Get-Content -Path $sourceHTMLFile;
$destinationHTML = $sourceHTML.Replace('[FinalHTML]', $htmlLines)
$destinationHTML | Set-Content $destinationHTMLFile -encoding utf8