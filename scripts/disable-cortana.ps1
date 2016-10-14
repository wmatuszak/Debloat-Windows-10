#   Name: disable-cortana.ps1
#
#   Description:
#      This script disables Cortana via group policy
#

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1

echo "Disabling Cortana via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
sp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
