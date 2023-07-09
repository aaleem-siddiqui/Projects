###########################################
# FILENAME: activeDirectoryOneLiners.ps1
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Powershell one liners to retrieve information about users in active directory.
###########################################


#ListUsersWithEmail
$Path = 'C:\Users\user.name\read_only_group_name.csv';Get-AdGroupMember -Identity 'genericGroupName_read_only' | Get-AdUser -Properties LastLogonTimeStamp, Mail | Select-Object Name,Mail,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}}  | Export-csv -Path $Path -notypeinformation

#ListUsers
$Path = 'C:\Users\user.name\active_directorygroupmembers.csv';Get-AdGroupMember -Identity 'genericGroupName_read_only' | Get-AdUser -Properties * | Select Name,Mail | Export-csv -Path $Path -notypeinformation

#LastLoginWithEmail
$Path = 'C:\Users\user.name\LastLogon.csv';Get-ADUser -Filter {enabled -eq $true} -Properties LastLogonTimeStamp, Mail | Select-Object Name,Mail,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogon Timestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} | Export-Csv -Path $Path –notypeinformation

#LastLogin
$Path = 'C:\Users\user.name\LastLogon.csv';Get-ADUser -Filter {enabled -eq $true} -Properties LastLogonTimeStamp | Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} | Export-Csv -Path $Path –notypeinformation
