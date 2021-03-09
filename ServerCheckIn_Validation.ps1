Import-Module ActiveDirectory
$OU="OU=Enterprise Servers,DC=redmond,DC=contoso,DC=com"
$ExportPath = $(get-item -Path ".").fullname + "\verify\"
$domain_FQDN = (Get-WmiObject Win32_ComputerSystem).Domain

#Creates path in PWD, can be updated to whatever you need
if ((Test-Path -Path $ExportPath -PathType Any) -eq $False)
{
    New-Item $ExportPath -type container -Force
    
}

#Timestamp
$timestamp=(Get-Date -UFormat "%Y%m%d_%H-%M-%S")
$ServerToValidateLastCheckin_exportCSV=($ExportPath + "$domain_FQDN-ServerToValidateLastCheckin_$timestamp.csv")


#Array and Export Generation
$ServerToValidateLastCheckins=@()
$ServerToValidateLastCheckins=Get-ADComputer -Filter * -SearchBase $OU -Properties Name,SamAccountName,Enabled,OperatingSystem,LastLogonDate | Select-object -Property Name, LastLogonDate,OperatingSystem,Enabled |  Where-Object {$_.OperatingSystem -match "Windows Server 2008 R2 *" -or "Windows Server 2003" -or $_.OperatingSystem -match "Windows Storage Server 2008*" }
$ServerToValidateLastCheckin_export=(Get-ADComputer -Filter * -SearchBase $OU -Properties Name,SamAccountName,Enabled,OperatingSystem,LastLogonDate | Select-object -Property Name, LastLogonDate,OperatingSystem,Enabled | Where-Object {$_.OperatingSystem -match "Windows Server 2008 R2*" -or  $_.OperatingSystem -match "Windows Server 2003" -or $_.OperatingSystem -match "Windows Storage Server 2008*" } | Export-CSV -Path $ServerToValidateLastCheckin_exportCSV)

foreach ($ServerToValidateLastCheckin in $ServerToValidateLastCheckin)
{
    #NOTE
    #This is the date and time used to determine stale account, used for comparison
    #"%Y%m%d_%H-%M-%S
    $d1=$($ServerToValidateLastCheckin.LastLogonDate)
    $d2= (Get-Date -Format g)
    $d3=(get-date -Date 2019-05-06 -Hour 12 -Minute 00 -Second 00)
  
    if ($ServerToValidateLastCheckin.Enabled -eq $true)
        {
            if ($d1 -gt $d3 )
            {
                
                #We care about this server and should push some files to it
            }
            else
            {
                #This server has not posted to AD old and should not be touched
            }
        }
       
}

   