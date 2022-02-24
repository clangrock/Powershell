$GPO = "Disable Windows Updates"
New-GPO -Name $GPO | Set-GPRegistryValue -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Value 1 -Type "DWord" | Out-Null
(Get-GPO -Name $GPO).User.Enabled=$False
Get-GPO -Name $GPO

# get OU for_PALL
$DC1 = Get-ADOrganizationalUnit -Filter 'Name -like "_PALL"' | select DistinguishedName
# Link GPO to _PALL
New-GPLink -Name "Disable Windows Updates" -Target $DC1.DistinguishedName -Enforced No

# Check if GPO is enabled
$Result = (Get-ADOrganizationalUnit -filter * | Get-GPInheritance).GpoLinks | Where-Object {$_.Displayname -like $GPO} | Select-Object Enabled

If ($Result.Enabled -eq "True"){
    
   [System.Windows.Forms.MessageBox]::Show("Success $([System.Environment]::NewLine)" + "Windows Update is Disabled","Disable Windows Update",0,[System.Windows.Forms.MessageBoxIcon]::Information)
}
else{
    [System.Windows.Forms.MessageBox]::Show("Success $([System.Environment]::NewLine)" + "Windows Update is not  Disabled","Disable Windows Update",0,[System.Windows.Forms.MessageBoxIcon]::Exclamation)
}