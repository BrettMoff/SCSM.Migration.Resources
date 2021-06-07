Param([string]$Username,[string]$ObjectName)

Import-Module SMLets
Import-Module ActiveDirectory

function Show-Permissions($Userrolename)
{
    $Containment = Get-SCSMRelationshipClass -Name System.Containment
    $Response = Read-Host "Do you want to see the permissions of this user role? Enter 'Y' or 'N'";
    if($Response -eq "Y")
    {
        $Role = Get-SCSMUserRole -Name $Userrolename

        Write-Host "=================================================="
        Write-Host $Role.DisplayName "(" $Role.ProfileDisplayName ")"
        Write-Host $Role.Description
        Write-Host "=================================================="
        Write-Host "USERS"
        ForEach ($User in $Role.Users)
        {
            Write-Host "  " $User
        }
        Write-Host " "
        Write-Host "VIEWS"
        ForEach ($View in $Role.Views)
        {
            Write-Host "  " $View.DisplayName
        }
    
        Write-Host " "
        Write-Host "OBJECT SCOPES"
        ForEach ($Object in $Role.Objects)
        {
            
            if($Object.Name -ne "System.GlobalSetting" -and $Object.Name -ne "System.StarRating" -and $Object.Name -ne "System.ConfigItem" -and $Object.Name -ne "Microsoft.SystemCenter.ResourceAccessLayer.DwSdkResourceStore" -and $Object.Name -ne "System.WorkItem" -and $Object.Name -ne "System.Domain.User" -and $Object.Name -ne "Microsoft.SystemCenter.ConfigurationManager.Package" -and $Object.Name -ne "System.Announcement.Item" -and $Object.Name -ne "System.Knowledge.Article" -and $Object.Name -ne "Microsoft.SystemCenter.ServiceManager.SoftwareDeployment.Process")
            {
                Write-Host "  " $Object.DisplayName
                $ContainerObject = Get-SCSMObject -Class (Get-SCSMClass -ID $Object.Id)
                ForEach ($ContainedObject in Get-SCSMRelatedObject -SMObject $ContainerObject -Relationship $Containment -Depth Recursive)
                {
                    If($ContainedObject.DisplayName -eq $ObjectName)
                    {
                        Write-Host "     " $ContainedObject.DisplayName -ForegroundColor Cyan
                        $AccessToObject = $true
                    }
                    else
                    {
                        Write-Host "     " $ContainedObject.DisplayName
                    }
                    
                }
            }
            else
            {
                Write-Host "   ALL Objects of " $Object.DisplayName " class"
            }
        }
    
        Write-Host " "
        Write-Host "TEMPLATES"
        ForEach ($Template in $Role.Templates)
        {
            Write-Host "  " $Template.DisplayName
        }
    
        Write-Host " "
        Write-Host "CLASSES"
        ForEach ($Class in $Role.Classes)
        {
            Write-Host "  " $Class.DisplayName
        }
    
        Write-Host " "
        Write-Host "CONSOLE TASKS"
        ForEach ($CredentialTask in $Role.CredentialTasks)
        {
            $T = Get-SCSMConsoleTask $CredentialTask.First 
            Write-Host " " $T.DisplayName
        }

        #There is some bug with this right now and it's not really that interesting anyway
        #Write-Host " "
        #Write-Host "RUNTIME TASKS"
        #ForEach ($NonCredentialTask in $Role.NonCredentialTasks)
        #{
        #    $T = Get-SCSMTask $NonCredentialTask.First 
        #    Write-Host " " $T.DisplayName
        #}
        
        $Continue = Read-Host "Do you want to continue? Enter 'Y' or 'N'"
        if($Continue -ne "Y")
        {
            exit
        }

    }
}

get-scsmuserrole | %{$UserRoleName = $_.Name;Write-host "USER ROLE: " $_.DisplayName; $_.Users | %{Write-Host "`tDIRECT USER/GROUP: $_";$ObjectDisplayName = $_.Substring($_.IndexOf("\")+1);if($ObjectDisplayName -eq $Username){Write-Host -ForegroundColor Green "`t`tUser $Username is directly a member of this user role.";Show-Permissions($UserRoleName)}else{if((Get-ADObject -Filter "name -eq '$ObjectDisplayName'").ObjectClass -eq 'group'){Get-ADGroupMember -Identity (Get-ADGroup $_.Substring($_.IndexOf("\")+1)) -Recursive | %{if($_.samaccountname -eq $Username){Write-Host -ForegroundColor Green "`t`tUser $Username is a member of this user role through membership in this group.";Show-Permissions($UserRoleName)}}}}}}



