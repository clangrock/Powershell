    
$fFunction1 = join-Path $PSScriptRoot "Formater.ps1"
#load powershell functions
."$fFunction1"
    
    
# table config
$hConfig = @{}
$hConfig.Add("Columns", 5)
$hConfig.Add("ColumnWidth", '25;20;15;10')
# table config
[string[]]$TableContent = "vHeader1; xHeader2; zHeader3; 4Header4;1header 5"
$TableContent += "1655ewrrwfrwgg;2;3;4;23354grgfbfbngnghnjdmndmhm gertz"
$TableContent += "123456 6787899 8875655655 ewrrwf rwg ge;6;7;87rrer3r3444 434343434343tt eegst5jsf uwOOEOW RRRswrett12, und 5noch mehrBydefault,stringcomparisonsarecase-insensitive"
$TableContent += "16wgg;2;3;4"
$TableContent += "123e;6;7rrer3r3444 434343434343tt eegst5jsf uwOOEOW RRRswrett12;8;23354grgfbfbngnghnjdmndmhm gertz"
# exceute draw the table
$resultTable = drawTable -tContent $TableContent -config $hConfig
# print the result 
foreach ($result in $resultTable.GetEnumerator()){
    Write-Host $result
}

#[string]$stext = "123e;6;7rrer3r3444 434343434343tt eegst5jsf uwOOEOW RRRswrett12"#, und 5noch mehrBydefault,stringcomparisonsarecase-insensitive. The equality operators have explicit case-sensitive and case-insensitive forms. To make a comparison operator case-sensitive, add a c after the -. For example, -ceq is the case-sensitive version of -eq. To make the case-insensitivity explicit, add an i after -. For example, -ieq is the explicitly case-insensitive version of -eq."
# start function
#$result = FormatString -inString $stext -SLength 20

#$result