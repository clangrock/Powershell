
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
    [string[]]$sTemp = ''
    [string[]]$sOut = ''
    [string]$sTemp2 = ''
    [int]$y = 0
    [bool]$writeExe = $false
    [bool]$firstWrite = $false

    $sTemp = $inString.Split()
    $sTemp2 ='| '
    foreach ($txt in $sTemp){
    $i = ($txt | Measure-Object -Character | Select-Object -Property Characters).Characters
        Write-Host $i
        #string zusammenbauen
        $y = $y+$i
        if ($y -lt ($SLength -3)) {
            $sTemp2 = $sTemp2 + $txt + ' '
            $writeExe = $false
            $y += 1
        }
        else {# write output
            If($sTemp2.Length -gt 3){
                $sTemp2 = $sTemp2.TrimEnd()
                if (!$firstWrite){
                    $sOut = $sTemp2.PadRight($SLength, ' ')
                    $firstWrite = $true
                }
                else {
                    $sOut += $sTemp2.PadRight($SLength, ' ')
                }
            }
            If ($i -ge $SLength) { # check if the string is lomger than
                if(!$firstWrite){
                    $firstWrite = $true
                    $sOut = "| " + $txt.Substring(0,($SLength-2))
                    $txt = $txt.Substring($SLength -2,($txt.Length - $SLength + 2))
                }
                do {
                    $sOut += "| " + $txt.Substring(0,($SLength -2))
                    $txt = $txt.Substring($SLength -2, ($txt.Length - $SLength + 2))
                } while ($txt.Length -ge $SLength -2)
            }
            $sTemp2 = '| ' + $txt + ' '
            $y = $i
            $writeExe = $true
        }
    }

    If (!$writeExe){
        $sTemp2 = $sTemp2.TrimEnd()
        $sOut += $sTemp2.PadRight($SLength, ' ')
    }
    return $sOut
}

[string]$stext = "LangerStringmitnochmehrtext, und 5noch mehrBydefault,stringcomparisonsarecase-insensitive. The equality operators have explicit case-sensitive and case-insensitive forms. To make a comparison operator case-sensitive, add a c after the -. For example, -ceq is the case-sensitive version of -eq. To make the case-insensitivity explicit, add an i after -. For example, -ieq is the explicitly case-insensitive version of -eq."
# start function
$result = trimString -inString $stext -SLength 30

foreach ($t in $result.GetEnumerator()){Write-host $t}

foreach ($t in $result.GetEnumerator()){$t.length}
