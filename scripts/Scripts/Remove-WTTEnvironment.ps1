﻿<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to remove a WingtipTickets (WTT) Demo Environment.
 .EXAMPLE
    Remove-WTTEnvironment -WTTEnvironmentApplicationName <string>
#>
function Remove-WTTEnvironment
{
    [CmdletBinding()]
    Param
    (   
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName
    )
    Process
    { 
    	#Add-AzureAccount
        $localPath = (Get-Item -Path ".\" -Verbose).FullName
        $azureStorageAccountName = $WTTEnvironmentApplicationName
        $azureSqlDatabaseServerPrimaryName = $WTTEnvironmentApplicationName + "primary"
        $azureSqlDatabaseServerSecondaryName = $WTTEnvironmentApplicationName + "secondary"        
        $azureResourceGroupName = $WTTEnvironmentApplicationName
        $azureCloudServicePrimaryName = $WTTEnvironmentApplicationName + "primary"
        $azureCloudServiceSecondaryName = $WTTEnvironmentApplicationName + "secondary"      

        
        Try 
        {
            
            ### Silence Verbose Output ###
            Write-Host "### Silencing Verbose Output. ###" -foregroundcolor "yellow"
            $global:VerbosePreference = "SilentlyContinue"

            ### Check installed PowerShell Version ###
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 0.9.3. ###" -foregroundcolor "yellow"
                        
            $installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($installedAzurePowerShellVersion -ge 0)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 0.9.3. ###" -foregroundcolor "yellow"

                ### Check if both ASM and ARM are provisioned ###
                Write-Host "### Checking whether Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                $supportedModes = (Get-AzureSubscription -Current).SupportedModes.Split(",")
                if ($supportedModes.Count -eq 2)
                {
                    Write-Host "### Both Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"                    
                    
                    Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
            
                    #Remove Storage Account
                    Write-Host "### Removing Azure Storage Account '$azureStorageAccountName'. ###" -foregroundcolor "yellow"
                    $azureStorageAccountRemoved = (Remove-AzureStorageAccount -StorageAccountName $azureStorageAccountName -ErrorVariable azureStorageAccountRemovedErrors -ErrorAction SilentlyContinue).OperationStatus
                    
                    if ($azureStorageAccountRemoved -eq "Succeeded")
                    {
                        Write-Host "### Success: Azure Storage Account '$azureStorageAccountName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureStorageAccountRemovedErrors)
                        {
                            if($error.Exception.Error.Code -eq "ResourceNotFound")
                            {
                                Write-Host "### Azure Storage Account '$azureStorageAccountName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Storage Account '$azureStorageAccountName' was not removed. ###" -foregroundcolor "red"
                                return $error.Exception.Error
                            }
                        }                      
                    }
                    
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                                        
                    #Remove Azure Resource Group
                    Write-Host "### Removing Azure Resource Group '$WTTEnvironmentApplicationName'. ###" -foregroundcolor "yellow"
                    $azureResourceGroupRemoved = (Remove-AzureResourceGroup -Name $azureResourceGroupName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureResourceGroupRemovedErrors)
                    
                    if ($azureResourceGroupRemoved)
                    {
                        Write-Host "### Success: Azure Resource Group '$WTTEnvironmentApplicationName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureResourceGroupRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Resource Group '$WTTEnvironmentApplicationName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Resource Group '$WTTEnvironmentApplicationName' was not removed because: '$error'. ###" -foregroundcolor "red"                                                        
                            }
                        }
                    }
                                
                    Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
                                        
                    #Remove Azure Cloud Services
                    Write-Host "### Removing Azure Cloud Service '$azureCloudServicePrimaryName'. ###" -foregroundcolor "yellow"                    
                    $azureCloudServicePrimaryRemoved = (Remove-AzureService -ServiceName $azureCloudServicePrimaryName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureCloudServicePrimaryRemovedErrors)
                                        
                    if ($azureCloudServicePrimaryRemoved)
                    {
                        Write-Host "### Success: Azure Cloud Service '$azureCloudServicePrimaryName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureCloudServicePrimaryRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))                        
                            {
                                Write-Host "### Azure Cloud Service '$azureCloudServicePrimaryName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Cloud Service '$azureCloudServicePrimaryName' was not removed because: '$error'. ###" -foregroundcolor "red"
                            }
                        }                      
                    }

                    Write-Host "### Removing Azure Cloud Service '$azureCloudServiceSecondaryName'. ###" -foregroundcolor "yellow"
                    $azureCloudServiceSecondaryRemoved = (Remove-AzureService -ServiceName $azureCloudServiceSecondaryName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureCloudServiceSecondaryRemovedErrors)
                                        
                    if ($azureCloudServiceSecondaryRemoved)
                    {
                        Write-Host "### Success: Azure Cloud Service '$azureCloudServiceSecondaryName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureCloudServiceSecondaryRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Cloud Service '$azureCloudServiceSecondaryName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Cloud Service '$azureCloudServiceSecondaryName' was not removed because: '$error'. ###" -foregroundcolor "red"
                            }
                        }                      
                    }                      

                    #Remove Traffic Manager Profile
                    Write-Host "### Removing Azure Traffic Manager Profile '$WTTEnvironmentApplicationName'. ###" -foregroundcolor "yellow"
                    $azureTrafficManagerProfileRemoved = (Remove-AzureTrafficManagerProfile -Name $WTTEnvironmentApplicationName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureTrafficManagerProfileRemovedErrors)
                                        
                    if ($azureTrafficManagerProfileRemoved)
                    {
                        Write-Host "### Success: Azure Traffic Manager Profile '$WTTEnvironmentApplicationName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureTrafficManagerProfileRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Traffic Manager Profile '$WTTEnvironmentApplicationName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Cloud Service '$azureCloudServiceSecondaryName' was not removed because: '$error'. ###" -foregroundcolor "red"
                            }
                        }                      
                    }                                          
                }

                else
                {
                    ### Error if both ASM and ARM aren't provisioned ###
                    Write-Host "### Error: Both Azure Service Model (ASM) and Azure Resource Model (ARM) need to be provisioned. ###" -foregroundcolor "red"
                    Write-Host "### You can run: (Get-AzureSubscription -Default).SupportedModes to verify which is/isn't provisioned. ###" -foregroundcolor "red"
                    Write-Host "### Please contact Microsoft Support to have them troubleshoot further. ###" -foregroundcolor "red"
                }
            }
            else
            {
                ### Error if installed Azure PowerShell Version is older than minimum required version ###
                Write-Host "### Error: Installed Azure PowerShell Version is older than 0.9.3.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }
 
#Check Installed Azure PowerShell Version
# Bitwise left shift
function Lsh([UInt32] $n, [Byte] $bits) 
    {
        $n * [Math]::Pow(2, $bits)
    }

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most significant 32 bits,
# and the second element is the least significant 32 bits.
function GetVersionStringAsArray([String] $version) 
{
    $parts = $version.Split(".")
    if ($parts.Count -lt 4) 
    {
        for ($n = $parts.Count; $n -lt 4; $n++) 
        {
            $parts += "0"
        }
    }
    [UInt32] ((Lsh $parts[0] 16) + $parts[1])
    [UInt32] ((Lsh $parts[2] 16) + $parts[3])
}

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShellVersion() 
    {
        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue

        $installedVersion = ((Get-Module Azure).Version.Major -as [string]) +'.'+ ((Get-Module Azure).Version.Minor -as [string]) +'.'+ ((Get-Module Azure).Version.Build -as [string])        
        $minimumRequiredVersion = '0.9.3'        
        $ver1 = GetVersionStringAsArray $installedVersion
        $ver2 = GetVersionStringAsArray $minimumRequiredVersion
        if ($ver1[0] -lt $ver2[0]) 
        {
            $out = -1
        }
        elseif ($ver1[0] -eq $ver2[0]) 
        {
            if ($ver1[1] -lt $ver2[1]) 
            {
                $out = -1
            }
            elseif ($ver1[1] -eq $ver2[1]) 
            {
                $out = 0
            }
            else 
            {
                $out = 1
            }
        }
        else 
            {
                $out = 1
            }
        return $out
}
