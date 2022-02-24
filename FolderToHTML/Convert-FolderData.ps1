#Script Version
$sScriptVersion = "0.01"

#Set Error Action to Silently Continue
$ErrorActionPreference =  "SilentlyContinue"

# define script folder
$scriptFolder = $PSScriptRoot
# $sFunctionFolder = Join-Path $scriptFolder "functions"

#Variables that need to be set for each run
$startFolder = 'D:\PALL_Projekte\@releases\MDF\' #The starting folder to analyze

# The html source template file
$sHtmlTemplate = 'HTMLTemplate.html'
$sourceHTMLFile = Join-Path -Path $scriptFolder -ChildPath $sHtmlTemplate

# define the output file
# The final html file that will be produced, #does not need to exist
$OutputFileName ="Start.html"
$destinationHTMLFile = Join-Path -Path $scriptFolder -ChildPath $OutputFileName

$htmlLines = @()

function CreateFileDetailRecord{
    param(
        [string]$FilePath
    )
    
    process{
        # read file data
        $files = Get-ChildItem -Path $FilePath -File| Select-Object Name,LastWriteTime 
        # get hash and print the result to logfile
        $newFIleRecord = New-Object -TypeName PSObject 
    
        $hash = Get-FileHash -Path $FilePath | Select-Object Hash
        $shash = $hash.Hash
        $Filename = $files.Name
        $WriteTime = $files.LastWriteTime
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name FileName -Value $Filename
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $WriteTime
        $newFIleRecord | Add-Member -MemberType NoteProperty -Name Hash -Value $shash
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


#Function that recursively creates the html for the output, given a starting location
function GetAllFolderDetails
{
    param([string]$FolderPath)    

    $recursiveHTML = @()

    #Get properties used for processing
    $folderItem = Get-Item -Path $FolderPath
    $folderDetails = CreateFolderDetailRecord -FolderPath $FolderPath
    $subFolders = Get-ChildItem $FolderPath | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object

    #If has subfolders, create hmtl drilldown. 
    if($subFolders.Count -gt 0)
    {
        $recursiveHTML += '<li><span class="caret">' + $folderItem.Name + '(<span style="color:red">' + $folderDetails.FolderSizeInUnits + " " + $folderDetails.Units + '</span>)</span></li>' + "`n"
        $recursiveHTML += '<ul class="nested">'
        #Get all file data in subfolder
        $files = Get-ChildItem -Path $folderItem.FullName -File| Select-Object Name,FullName 
        if ($files.Count -gt 0){
            $recursiveHTML += '<ul class="nested">'
            If ($files.Count -eq 1){
                $dataFile = CreateFileDetailRecord -FilePath $files.Fullname
                $recursiveHTML += '<li>' + $($dataFile.FileName) + ' (<span style="color:blue">' + $($dataFile.LastWriteTime) + " " + $($dataFile.Hash) + '</span>)</span></li>' + "`n"
            }
            foreach($file in $files.GetEnumerator()){
                $dataFile = CreateFileDetailRecord -FilePath $file.Fullname
                $recursiveHTML += '<li><span style="color:darkblue">' + $($dataFile.FileName) + '</span><li>[<span style="color:grey"> Last Write Date:</span>] (<span style="color:blue">' + $dataFile.LastWriteTime + '</span>)[<span style="color:grey"> File Hash: </span>](<span style="color:blue">' + $dataFile.Hash + '</span>)</li>' + "`n"
            }
            $recursiveHTML += '</ul>'+ "`n"
        }
    }
    else
    {
        $recursiveHTML += '<li><span class="caret">' + $folderItem.Name + ' (<span style="color:red">' + $folderDetails.FolderSizeInUnits + " " + $folderDetails.Units + '</span>)</span></li>' + "`n"
        
        #Get all file data in subfolder
        $files = Get-ChildItem -Path $folderItem -File| Select-Object Name,FullName 
        $cont = $files | Measure-Object  | Select-Object Count
        if ($cont.Count -gt 0){
            $recursiveHTML += '<ul class="nested">'
            If ($cont.Count -eq 1){
                $dataFile = CreateFileDetailRecord -FilePath $files.Fullname
                $recursiveHTML += '<li><span style="color:darkblue">' + $($dataFile.FileName) + '</span><li>[<span style="color:grey"> Last Write Date:</span>] (<span style="color:blue">' + $($dataFile.LastWriteTime) + '</span>)[<span style="color:grey"> File Hash: </span>](<span style="color:blue">'  + $($dataFile.Hash) + '</span>)</li>' + "`n"
            }

            foreach($file in $files.GetEnumerator()){
                $dataFile = CreateFileDetailRecord -FilePath $file.Fullname
                $recursiveHTML += '<li><span style="color:darkblue">' + $($dataFile.FileName) + '</span><li>[<span style="color:grey"> Last Write Date:</span>] (<span style="color:blue">' + $($dataFile.LastWriteTime) + '</span>)[<span style="color:grey"> File Hash: </span>](<span style="color:blue">' + $($dataFile.Hash) + '</span>)</li>' + "`n"
            }
            $recursiveHTML += '</ul>'+ "`n"
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

#Opening html
$htmlLines += '<ul id="myUL">'+ "`n"

#This function call will return all of the recursive html for the startign folder and below
$htmlLines += GetAllFolderDetails -FolderPath $startFolder

#Closing html
$htmlLines += '</ul>'

#Get the html template, replace the template with generated code and write to the final html file
$sourceHTML = Get-Content -Path $sourceHTMLFile;
$destinationHTML = $sourceHTML.Replace('[FinalHTML]', $htmlLines)
$destinationHTML | Set-Content $destinationHTMLFile 