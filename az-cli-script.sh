## Azure CLI commands follow. Will have to have the az cli tools installed.
## This can be downloaded from Microsoft, or used directly from the AZ Cloud Shell.

echo "Enter the Resource Group name:" &&
read resourceGroupName &&
echo "Enter the location (i.e. centralus):" &&
read location &&
echo "Enter the administrator username:" &&
read username &&
echo "Enter the administrator password:" &&
read password &&
az group create --name $resourceGroupName --location "$location" &&
az deployment group create --resource-group $resourceGroupName --template-file create-eve-ng-vm.json --parameters adminUsername=$username adminPasswordOrKey="$password" &&
az vm show --resource-group $resourceGroupName --name eve-ng-vm  --show-details --output table