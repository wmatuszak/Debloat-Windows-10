#   Name: experimental_unfuckery.ps1
#
#   Params:
#      -Search - Include search packages
#      -Defender - Include defender packages
#      -Maps - Include maps packages
#      -DryRun - Prints the packages to remove/exclude but does not remove them
#      -Exclude <array of strings> - Excludes any packages whose name includes an exclude string 
#
#   Description:
#      This script remove strange looking stuff which will probably result in a break
#      of your system.  It should not be used unless you want to test out a few
#      things. It is named `experimental_unfuckery.ps1` for a reason.

Param(
  [switch]$Search,
  [switch]$Defender,
  [switch]$Maps,
  [switch]$DryRun,
  [array]$Exclude = $null
)

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

echo "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

$needles = @(
    
    "BioEnrollment"
    "ContactSupport"
    "Feedback"
    "Flash"
    "Gaming"
    "OneDrive"
)

$search_needles = @(
    "Cortana"       # This will disable startmenu search.
)

$defender_needles = @(
    "Defender"
)

$map_needles = @(
    "Maps"
)

<#
$unknown_status_needles = @(

    "Anytime"
    "Browser"
    "ContentDeliveryManager" # This removes the subsystem that provides the start menu suggestions. Not sure if this causes other issues yet.
    "InternetExplorer"
    "Wallet"
)
#>

<#
$known_unstable_needles = @(
    
    #"Xbox"          # This will result in a bootloop since upgrade 1511
)
#>

if($Search){$needles += $search_needles}
if($Defender){$needles += $defender_needles}
if($Maps){$needles += $map_needles}

if($DryRun) { echo "Listing system apps to remove" }
else { echo "Force removing system apps" }

foreach ($needle in $needles) {
    
    $skip = $false
    foreach($xstring in $Exclude)
    {
        if($needle.IndexOf($xstring) -ne -1)
        {
            echo "Excluding $needle"
            $skip = $true
        }
    }

    if(-not $skip) {
    
        echo "Trying to remove all packages containing $needle"
        
        $pkgs = (ls "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" |
        where Name -Like "*$needle*")

        foreach ($pkg in $pkgs) {
            $pkgname = $pkg.Name.split('\')[-1]

            echo "Trying to remove package $pkgname"

            if(-not $DryRun) {

                Takeown-Registry($pkg.Name)
                Takeown-Registry($pkg.Name + "\Owners")

                Set-ItemProperty -Path ("HKLM:" + $pkg.Name.Substring(18)) -Name Visibility -Value 1
                New-ItemProperty -Path ("HKLM:" + $pkg.Name.Substring(18)) -Name DefVis -PropertyType DWord -Value 2
                Remove-Item      -Path ("HKLM:" + $pkg.Name.Substring(18) + "\Owners")

                dism.exe /Online /Remove-Package /PackageName:$pkgname /NoRestart
            }
        }
    }
}
