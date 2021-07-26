## Azure CLI commands follow. Will have to have the az cli tools installed.
## This can be downloaded from Microsoft, or used directly from the AZ Cloud Shell.

## Edit this script as necessary, enter the desired names when prompted.
## Choose a location closest to you.
## Supply an admin name. Standard names like root, admin, administrator are not allowed.
## Password complexity is in effect, so 'password' or the like will fail.
## Should only take a few minutes to deploy. The output will display the public IP for SSH access.

echo "Enter the Resource Group name:" &&
read resourceGroupName &&
echo "Enter the location (i.e. centralus):" &&
read location &&
echo "Enter the administrator username:" &&
read username &&
echo "Enter the administrator password:" &&
read -s password &&
az group create --name $resourceGroupName --location "$location" &&
az deployment group create --resource-group $resourceGroupName --template-uri https://raw.githubusercontent.com/kevin-on-github/azure-automation/main/create-eve-ng-vm.json --parameters adminUsername=$username adminPasswordOrKey="$password" &&
az vm show --resource-group $resourceGroupName --name eve-ng-vm  --show-details --output table