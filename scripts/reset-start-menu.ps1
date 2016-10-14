#   Name: reset-start-menu.ps1
#
#   Description:
#      This script resets the start menu items to remove dead links.
#
#      A reboot is recommended afterward
#

echo "Stopping Windows Explorer"
taskkill /F /IM explorer.exe
echo "Stopping Tile Data Model Service"
Stop-Service tiledatamodelsvc

echo "Resetting current user's start menu"
del $env:LOCALAPPDATA\TileDataLayer\Database\vedatamodel*

echo "Restarting Tile Data Model Service"
Start-Service tiledatamodelsvc
echo "Restarting Windows Explorer"
explorer.exe

