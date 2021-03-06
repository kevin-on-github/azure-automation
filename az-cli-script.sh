#! /bin/bash
## Azure CLI commands follow. Will have to have the az cli tools installed.
## This can be downloaded from Microsoft, or used directly from the AZ Cloud Shell.

## Edit this script as necessary, enter the desired names when prompted.
## Choose a location closest to you.
## Supply an admin name. Standard names like root, admin, administrator are not allowed.
## Password complexity is in effect, so 'password' or the like will fail.
## Should only take a few minutes to deploy. The output will display the public IP for SSH access.

read -p "Name of the new Ubuntu 20.04 LTS virtual machine: " vmName
read -p "Username of the new virtual machine  [Linux VM names may only contain letters, numbers, '.', and '-'.]: " username
read -s -p "Password of the vm  [The value must not be empty. Password must be complex: 1 lower case, 1 upper case, and 1 number. Must be between 6 and 72 characters.]: " password

az group create --name $vmName --location eastus

# Run the script using the github arm template
az deployment group create --resource-group $vmName --template-uri https://raw.githubusercontent.com/kevin-on-github/azure-automation/main/create-eve-ng-vm.json --parameters adminUsername=$username adminPassword=$password 
#az deployment group create --resource-group $vmName --template-file create-eve-ng-vm.json --parameters adminUsername=$username adminPassword=$password 


# Run the script pointing to a github bicep template. Azure cli does not currently support remote bicep files.
#az deployment group create --resource-group $vmName --template-file create-eve-ng-vm.bicep --parameters adminUsername=$username adminPassword=$password 

# Output the public ip address of the vm
echo ''
echo The vm $vmName public ip is:
az vm show -d -g $vmName -n $vmName --query publicIps -o tsv
