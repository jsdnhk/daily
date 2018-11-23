##### Join Domain #####
$JoinDomain = @"
`$DomainName = "XXX"
`$DomainUsername = "XXX"
`$DomainPassword = "XXX"
`$OUPath = "OU=XXX,OU=XXX,DC=XXX,DC=XXX,DC=XXX"
`$Credential = New-Object System.Management.Automation.PSCredential (`$DomainUsername, (ConvertTo-SecureString `$DomainPassword -AsPlainText -Force))

echo "joining domain"
NBTSTAT -R
ipconfig /flushdns
Add-Computer -DomainName `$DomainName -Credential `$Credential -OUPath `$OUPath -ErrorAction Stop
"@

Invoke-VMScript -VM $SerName -ScriptText $JoinDomain -Verbose -GuestUser $AdminLogin -GuestPassword $Password_2K16

##### Disable VM Firewall #####
Invoke-VMScript -VM $SerName -ScriptText "Set-NetFirewallProfile -Profile Domain -Enabled False" -GuestUser $AdminLogin -GuestPassword $Password_2K16
$FirewallStatus = Invoke-VMScript -VM $SerName { Get-NetFirewallProfile -Profile Domain | Select-Object -ExpandProperty Enabled} -ErrorAction SilentlyContinue -GuestUser $AdminLogin -GuestPassword $Password_2K16 | Select -ExpandProperty ScriptOutput
$FirewallStatus | Select @{Name="Name";Expression={$SerName}}, @{N="Domain Firewall Status (False = Turned Off)";E={$FirewallStatus}}

##### ADD User (ALIAS) After Join Domain & Rebooted #####
$AddUser = @" 
Add-LocalGroupMember -Group "Administrators" -Member "XXX\$PlatOwner", "XXX\$AppOwner", "XXX\$DefaultAdminID1", "XXX\$DefaultAdminID2", "XXX\$DefaultAdminID3"
"@
Invoke-VMScript -VM $SerName -ScriptText $AddUser  -ScriptType Powershell -GuestUser $AdminLogin -GuestPassword $Password_2K16 | Select -ExpandProperty ScriptOutput