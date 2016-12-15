#   Name: remove-default-apps.ps1
#
#   Params:
#      -System - Include apps from the 'system' group
#      -Experimental - Include apps from the 'experimental' group
#      -DryRun - Prints the apps to remove/exclude but does not remove them
#      -Exclude <array of strings> - Excludes any packages whose name includes an exclude string 
#
#   Description:
#      This script removes unwanted Apps that come with Windows. 
#

Param(
  [switch]$System,
  [switch]$Experimental,
  [switch]$DryRun,
  [array]$Exclude = $null
)

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

echo "Elevating privileges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

$apps = @(
    # Default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
    "Microsoft.MinecraftUWP"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"

    # Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"

    # Non-Microsoft
    "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    "TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
)

$system_apps = @(

    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.OneConnect"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsCalculator"
    "Microsoft.WindowsStore"

)

$experiemental_apps = @(

    "Microsoft.Advertising.Xaml"
    "Microsoft.PurchaseStoreApp"

)

<#
$unremovable_apps = @(
    # apps which cannot be removed using Remove-AppxPackage
    "Microsoft.BioEnrollment"
    "Microsoft.MicrosoftEdge"
    "Microsoft.Windows.Cortana"
    "Microsoft.WindowsFeedback"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxIdentityProvider"
    "Windows.ContactSupport"
)
#>

if($System){$apps += $system_apps}
if($Experimental){$apps += $experiemental_apps}

if($DryRun) { echo "Listing apps to uninstall" }
else { echo "Uninstalling default apps" }

foreach ($app in $apps) {
    
    $skip = $false
    foreach($xstring in $Exclude)
    {
        if($app.IndexOf($xstring) -ne -1)
        {
            echo "Excluding $app"
            $skip = $true
        }
    }
    
    if(-not $skip) {
    
        echo "Trying to remove $app"

        if(-not $DryRun) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

        Get-AppXProvisionedPackage -Online |
            where DisplayName -EQ $app |
            Remove-AppxProvisionedPackage -Online
        }
    }
}
