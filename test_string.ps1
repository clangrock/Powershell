
function trimString {
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
    foreach ($txt in $sString){ # split strings in worde
    # $i = ($txt | Measure-Object -Character | Select-Object -Property Characters).Characters
    $i = $txt.Length
    # string zusammenbauen
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

 #[string]$stext = "LangerStringmitnochmehrtext, und 5noch mehrBydefault,stringcomparisonsarecase-insensitive. The equality operators have explicit case-sensitive and case-insensitive forms. To make a comparison operator case-sensitive, add a c after the -. For example, -ceq is the case-sensitive version of -eq. To make the case-insensitivity explicit, add an i after -. For example, -ieq is the explicitly case-insensitive version of -eq."
# start function
 #$result = trimString -inString $stext -SLength 30

 #foreach ($t in $result.GetEnumerator()){Write-host $t}

 #foreach ($t in $result.GetEnumerator()){$t.length}

function writeTable {
    [CmdletBinding()]
    param (
        [string[]]$tContent,
        [hashtable]$config = @{}
    )
    begin {
        $SeparationLine = "-"
        $SeparationLine = $SeparationLine.PadRight((($config.Columns * 2) +($config.Columns * $config.ColumnWidth)+1), "-" )
        [string[]]$OutTable =$SeparationLine # first table line
    }
    process {
        foreach ($inLine in $tContent) {
            # split input string
            $arrTxt = $inLine.Split(";").Trim()
            [string[]]$otxt_1 = trimString -inString $arrTxt[0] -SLength $config.ColumnWidth
            [string[]]$otxt_2 = trimString -inString $arrTxt[1] -SLength $config.ColumnWidth
            [string[]]$otxt_3 = trimString -inString $arrTxt[2] -SLength $config.ColumnWidth
            [string[]]$otxt_4 = trimString -inString $arrTxt[3] -SLength $config.ColumnWidth
            [array]$aLines = $otxt_1.Length
            $aLines += $otxt_2.Length
            $aLines += $otxt_3.Length
            $aLines += $otxt_4.Length
            # get max lines in row
            [int]$maxlines = ($aLines | measure -Maximum).Maximum
            # check if all array has the same items count
            [int]$minLines = ($aLines | measure -Minimum).Minimum
            If (!($minLines -eq $maxlines)){
                # add lines to the arrays
                for ($i = $otxt_1.Length; $i -lt $maxlines; $i++) {
                    [string]$rtemp = " "
                    $rtemp = $rtemp.PadRight($config.ColumnWidth, " ")
                    $otxt_1 += $rtemp
                }
                for ($i = $otxt_2.Length; $i -lt $maxlines; $i++) {
                    [string]$rtemp = " "
                    $rtemp = $rtemp.PadRight($config.ColumnWidth, " ")
                    $otxt_2 += $rtemp
                }
                for ($i = $otxt_3.Length; $i -lt $maxlines; $i++) {
                    [string]$rtemp = " "
                    $rtemp = $rtemp.PadRight($config.ColumnWidth, " ")
                    $otxt_3 += $rtemp
                }
                for ($i = $otxt_4.Length; $i -lt $maxlines; $i++) {
                    [string]$rtemp = " "
                    $rtemp = $rtemp.PadRight($config.ColumnWidth, " ")
                    $otxt_4 += $rtemp
                }
            }

            for ($i = 0; $i -lt $maxlines; $i++) {
                [string]$stemp = '| ' + $otxt_1[$i] + '| ' + $otxt_2[$i] +'| ' + $otxt_3[$i] +'| ' + $otxt_4[$i] + '|'
                $OutTable += $stemp
            }
           # [string]$stemp = '| ' + $otxt_1[1] + '| ' + $otxt_2[1] +'| ' + $otxt_3[1] +'| ' + $otxt_4[1] + '|'
           # $OutTable += $stemp
            $OutTable += $SeparationLine
        }
    }
    end {
        Return $OutTable
    }
}

$hConfig = @{}
$hConfig.Add("Columns", 4)
$hConfig.Add("ColumnWidth", 25)

[string[]]$TableContent = "Header1; Header2; Header3; Header4"
$TableContent += "1655ewrrwfrwgg;2;3;4 "
$TableContent += "123456 6787899 8875655655 ewrrwf rwg ge;6;7;8 "
$TableContent += "16wgg;2;3;4 "
$TableContent += "123e;6;7rrer3r3444 434343434343tt eegst5jsf uwOOEOW RRRswrett12;8 "

$resultTable = writeTable -tContent $TableContent -config $hConfig

Write-Host $resultTable
