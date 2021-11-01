
function FormatString {
    <#
    .SYNOPSIS
    Format a input string in a string array with the length of SLength.

    .DESCRIPTION
    Format a input string in a string array with the length of SLength.

    .PARAMETER inString
    Input string.

    .PARAMETER SLength
    Max length of string per line

    .EXAMPLE
    [string]$stext = "LangerStringmitnochmehrtext, und 5noch mehrBydefault,stringcomparisonsarecase-insensitive. The equality operators have explicit case-sensitive and case-insensitive forms. To make a comparison operator case-sensitive, add a c after the -. For example, -ceq is the case-sensitive version of -eq. To make the case-insensitivity explicit, add an i after -. For example, -ieq is the explicitly case-insensitive version of -eq."
    # start function
    $result = trimString -inString $stext -SLength 30
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]$inString,
        [int]$SLength = 20
    )
    [string[]]$sString = ''
    [string[]]$sOut = ''
    [string]$sTemp2 = ''
    [int]$y = 0
    [bool]$writeExe = $false
    [bool]$firstWrite = $false
    # split the array in strings
    $sString = $inString.Split()
    foreach ($txt in $sString){ # split strings in words
    $i = $txt.Length
    # rebuild the string
        $y = $y+$i
        if ($y -lt ($SLength -1)) {
            $sTemp2 = $sTemp2 + $txt + ' '
            $writeExe = $false
            $y += 1
        }
        else {# write output
            If($sTemp2.Length -gt 1){
                $sTemp2 = $sTemp2.TrimEnd()
                if (!$firstWrite){
                    $sOut = $sTemp2.PadRight($SLength, ' ')
                    $firstWrite = $true
                }
                else {
                    $sOut += $sTemp2.PadRight($SLength, ' ')
                    $writeExe = $true
                }
            }
            If ($i -ge $SLength) { # check if the string is lomger than
                if(!$firstWrite){
                    $firstWrite = $true
                    $sOut = $txt.Substring(0,($SLength))
                    $txt = $txt.Substring($SLength,($txt.Length - $SLength))
                }
                do {
                    if ($txt.Length -ge $SLength){
                        $sOut += $txt.Substring(0,($SLength))
                        $txt = $txt.Substring($SLength, ($txt.Length - $SLength))
                    }
                    else {
                        $sOut += $txt.PadRight($SLength, ' ')
                        $txt = ''
                    }
                } while ($txt.Length -ge 1)
            }
            $sTemp2 = $txt + ' '
            $y = $i
            $writeExe = $true
        }
    }

    If (!$writeExe){
        $sTemp2 = $sTemp2.TrimEnd()
        if(!$firstWrite){
            $sOut = $sTemp2.PadRight($SLength, ' ')
            $firstWrite = $true
        }
        else {
            $sOut += $sTemp2.PadRight($SLength, ' ')
        }
    }
    return $sOut
}


function writeTable {
        <#
    .SYNOPSIS
    Draw a table to a string array

    .DESCRIPTION
    Draw a table with free count of columns and rows..

    .PARAMETER $tContent
    Input as string array.

    .PARAMETER $config 
        = @{'Columns' = 2; 
        'ColumnWidth' = 25}

    .EXAMPLE
    # table config
    $hConfig = @{}
    $hConfig.Add("Columns", 4)
    $hConfig.Add("ColumnWidth", 25)
    # table config
    [string[]]$TableContent = "Header1; Header2; Header3; Header4;header 5"
    $TableContent += "1655ewrrwfrwgg;2;3;4"
    $TableContent += "123456 6787899 8875655655 ewrrwf rwg ge;6;7;8"
    $TableContent += "16wgg;2;3;4"
    $TableContent += "123e;6;7rrer3r3444 434343434343tt eegst5jsf uwOOEOW RRRswrett12;8"
    # exceute draw the table
    $resultTable = writeTable -tContent $TableContent -config $hConfig
    # print the result 
    foreach ($result in $resultTable.GetEnumerator()){
        Write-Host $result
    }
    
    #>
    [CmdletBinding()]
    param (
        [string[]]$tContent,
        [hashtable]$config = @{'Columns' = 2; 'ColumnWidth' = 25}
    )
    begin {
        # build the table lines
        [string]$RowSeperator = '│ '
        $SeparationLineTop = "┌"
        $SeparationLineBottom = "└"
        $SeparationLine = "├"
        $Separation = ''
        $Separation = $Separation.PadRight($config.ColumnWidth + 1, "─")

        for ($i = 1; $i -le $config.Columns; $i++) {
            $SeparationLine +=  $Separation
            $SeparationLineTop +=  $Separation
            $SeparationLineBottom +=  $Separation
            if ($i -eq $config.Columns){
                $SeparationLine += '┤'
                $SeparationLineTop += '┐'
                $SeparationLineBottom += '┘'
            }
            else {
                $SeparationLine += '┼'
                $SeparationLineTop += '┬'
                $SeparationLineBottom += '┴'
            }
        }
    
        [string[]]$OutTable = $SeparationLineTop # first table line
        [hashtable]$hContent = [ordered]@{}
        [int]$iRow = 1 
    }
    process {
        # read the content from $tContent
        foreach ($inLine in $tContent) {
            # split input string
            $arrTxt = $inLine.Split(";").Trim()
            If (!($arrTxt.length -eq $config.Columns )){
                Write-Host "Mismatch Input text and Columns"
                If ($arrTxt.length -lt $config.Columns){
                    for ($i = $arrTxt.length; $i -lt $config.Columns; $i++) {
                        $arrTxt += " "
                    }
                }
            }
        
            [int]$iColumn = 1
            [hashtable] $Column = [ordered]@{}
            foreach ($otext in $arrTxt.GetEnumerator()){
                If ($otext.length -gt 0){
                    if ($config.Columns -ge $iColumn){
                        [string[]]$otxt_x = Formatstring -inString $otext -SLength $config.ColumnWidth   # format the strings to columns width 
                    }      
                }   
                else {
                    [string[]]$otxt_x = " "
                }
                if ($config.Columns -ge $iColumn){               
                    $Column.Add("Column_"+$iColumn,$otxt_x)
                }
                $iColumn += 1   
            }
            $hContent.Add("Rows_" + $iRow,$Column)
            $iRow += 1
        }

        foreach ($RowKeys in $hContent.Keys | Sort-Object){
            [array]$Columnkeys = $hContent[$Rowkeys].Keys | Sort-Object # get a list with ordered columns keys
            $oRow = $hContent[$RowKeys]
            [int]$RowNumber = 0
            foreach ($oColumn in $Columnkeys.GetEnumerator()) {
                [string[]]$tRow = $oRow[$oColumn]
                If ($tRow.Length -gt $RowNumber){
                    $RowNumber = $tRow.Length
                }
            }
            # write the output
            for ($i = 0; $i -lt $RowNumber; $i++) {
                [string] $out =''
                for ($y = 0; $y -lt $Columnkeys.Length; $y++) {
                    $out += ($RowSeperator + $oRow[$Columnkeys[$y]][$i]).PadRight($config.ColumnWidth +2 ," ")
                }
                $out += $RowSeperator
                $OutTable += $out
            }
            $OutTable += $SeparationLine
        }
        $OutTable[-1] = $SeparationLineBottom # write the last table line
    }
    end {
        Return $OutTable
    }
}


