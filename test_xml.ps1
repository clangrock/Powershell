$ErrorActionPreference = "Stop"

function Compare-Hashtable {
<#
.SYNOPSIS
Compare two Hashtable and returns an array of differences.

.DESCRIPTION
The Compare-Hashtable function computes differences between two Hashtables. Results are returned as
an array of objects with the properties: "key" (the name of the key that caused a difference),
"side" (one of "<=", "!=" or "=>"), "lvalue" an "rvalue" (resp. the left and right value
associated with the key).

.PARAMETER left
The left hand side Hashtable to compare.

.PARAMETER right
The right hand side Hashtable to compare.

.EXAMPLE

Returns a difference for ("3 <="), c (3 "!=" 4) and e ("=>" 5).

Compare-Hashtable @{ a = 1; b = 2; c = 3 } @{ b = 2; c = 4; e = 5}

.EXAMPLE

Returns a difference for a ("3 <="), c (3 "!=" 4), e ("=>" 5) and g (6 "<=").

$left = @{ a = 1; b = 2; c = 3; f = $Null; g = 6 }
$right = @{ b = 2; c = 4; e = 5; f = $Null; g = $Null }

Compare-Hashtable $left $right

#>
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Right
	)
	function New-Result($Key, $LValue, $Side, $RValue) {
		New-Object -Type PSObject -Property @{
					key    = $Key
					lvalue = $LValue
					rvalue = $RValue
					side   = $Side
			}
	}
	[Object[]]$Results = $Left.Keys | % {
		if ($Left.ContainsKey($_) -and !$Right.ContainsKey($_)) {
			New-Result $_ $Left[$_] "<=" $Null
		} else {
			    $LValue, $RValue = $Left[$_], $Right[$_]
			    if ($LValue -ne $RValue) {
				    New-Result $_ $LValue "!=" $RValue
            }
           # else {
            #    New-Result $_ $LValue "==" $RValue
            #}
		}
	}
	$Results += $Right.Keys | % {
		if (!$Left.ContainsKey($_) -and $Right.ContainsKey($_)) {
			New-Result $_ $Null "=>" $Right[$_]
		}
	}
	return $Results
}


$hTable = @{}
$rTable = @{}
$h1 = @{}
$h1a = @{}
$h2 = @{}
$h3 = @{}
$h4 = @{}

$h1.Add( "ID", "31466")
$h1.Add( "Revision", "2")
$h1a.Add( "ID", "31466")
$h1a.Add( "Revision", "2.4")
$h2.Add( "ID","5563")
$h2.Add( "Revision", "1")
$h3.Add( "ID","5163")
$h3.Add( "Revision", "2.3")
$h4.Add( "ID","5161")
$h4.Add( "Revision", "4.3")


$hTable.Add( "qwer-244-qew-fe4qq-erf", $h1)
$hTable.Add( "qwer-244-qew-fe4qq-et4trf", $h2)
$hTable.Add( "qwer-244-qew-fe4aq-et432rf", $h3)

$rTable.Add( "qwer-244-qew-fe4qq-erf", $h1a)
$rTable.Add( "qwer-244-qew-fe4qq-et4trf", $h2)
$rTable.Add( "qwer-244-qew-fe4aq-et432rf", $h3)

 foreach ($hitem in $hTable.Keys) {
    $data = $hTable[$hitem]
     foreach ($item2 in $data.GetEnumerator()){
         Write-Host  "GUID:" $hitem "Ausgabe" $item2.Name ": " $item2.Value
     }
    #Write-Host    $hitem.Name $hitem.Value  $hitem.Key
}

$hTable | Export-Clixml ./Downloads/export.xml
$rTable | Export-Clixml ./Downloads/export_rTable.xml

[hashtable]$rTable = Import-Clixml ./Downloads/export.xml

#$rTable.Add("23456-655776-654", $h4)

#$rTable | Export-Clixml ./Downloads/export_rTable.xml


# ohne lesen kein vergeleich
[hashtable]$hTable_2 = Import-Clixml ./Downloads/export.xml
[hashtable]$hTable_1 = Import-Clixml ./Downloads/export_rTable.xml

foreach ($comp in $hTable_1.Keys){
    if ($hTable_2.ContainsKey($comp)){
        $lcomp = @{}
        $rcomp = @{}
        foreach ($ldata in $hTable_1[$comp].GetEnumerator()){
            $lcomp.Add($ldata.Name, $ldata.Value)
        }
        foreach ($rdata in $hTable_2[$comp].GetEnumerator()){
            $rcomp.Add($rdata.Name, $rdata.Value)
        }
        #$lcomp.Add($hTable_1[$comp].keys, $hTable_1[$comp].Values)
        #$rcomp.Add($hTable_2[$comp].keys, $hTable_2[$comp].Values)

        $result = Compare-Hashtable -Left $lcomp -Right $rcomp
        #Write-Host $result
        $sResult_1 = $sResult_1 + $result
    }
    else {
    Write-Host "Key $comp nicht gefunden"
    }
}
#$result = Compare-Hashtable -Left $hTable_1 -Right $rTable_1
Write-Host $sResult_1
$sResult_1.Clear()