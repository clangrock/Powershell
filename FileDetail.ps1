#Function that creates a file detail record
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

$files = Get-ChildItem -Path $FolderPath -File| Select-Object Name,FullName 
foreach($file in $files.GetEnumerator()){
    $dataOut = CreateFileDetailRecord -FilePath $file.Fullname
}


$dataOut