$GPO = "Disable Windows Updates"
New-GPO -Name $GPO | Set-GPRegistryValue -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Value 1 -Type "DWord" | Out-Null
(Get-GPO -Name $GPO).User.Enabled=$False
Get-GPO -Name $GPO
