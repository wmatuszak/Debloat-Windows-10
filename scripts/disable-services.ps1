#   Name: remove-default-apps.ps1
#
#   Params:
#      -Wifi - Include wifi services
#      -Search - Include search services
#      -Redstone - Include redstone services
#      -DryRun - Prints the apps to remove/exclude but does not remove them
#      -Exclude <array of strings> - Excludes any packages whose name includes an exclude string 
#
#   Description:
#      This script disables unwanted Windows services. 
#

Param(
  [switch]$Wifi,
  [switch]$Search,
  [switch]$Redstone,
  [switch]$DryRun,
  [array]$Exclude = $null
)

$services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service
    "HomeGroupListener"                        # HomeGroup Listener
    "HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "wscsvc"                                   # Windows Security Center Service
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service

)

$wifi_services = @(
    "WlanSvc"                                  # WLAN AutoConfig
)

$search_services = @(
    "WSearch"                                  # Windows Search
)

$redstone_services = @(
    "CDPUserSvc_*"                             # Connected Device Platform User Service
    "PimIndexMaintenanceSvc_*"                 # Contact Data Maintenance Service
    "MessagingService_*"                       # Text Messaging Service
    "OneSyncSvc_*"                             # Syncs User Data
    "UserDataSvc_*"                            # Handles User Data Access
    "UnistoreSvc_*"                            # Handles User Data Storage 
    "WpnUserService_*"                         # Windows Push Notification User Service 
)

<#
$unstoppable_services = @(
    # Services which cannot be disabled
    #"WdNisSvc"
)
#>

if($Wifi){$services += $wifi_services}
if($Search){$services += $search_services}
if($Redstone){$services += $redstone_services}

foreach ($service in $services) {

    $skip = $false
    foreach($xstring in $Exclude)
    {
        if($service.IndexOf($xstring) -ne -1)
        {
            echo "Excluding $service"
            $skip = $true
        }
    }
    
    if(-not $skip) {
    
        echo "Trying to disable $service"
        if(-not $DryRun) {
            $svcreg = ls ("HKLM:\SYSTEM\CurrentControlSet\Services\" + $service)
            foreach($reg in $svcreg){sp $reg "Start" 4}
        }
    }
}
