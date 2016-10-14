#   Name: disable-start-suggestions.ps1
#
#   Description:
#      This script disablesstart menu suggestions and ads via group policy
#

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1

echo "Disabling Cortana via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
sp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content" "DisableWindowsConsumerFeatures" 1
