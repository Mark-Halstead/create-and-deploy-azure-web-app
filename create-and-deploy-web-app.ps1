# variables
$resourceGroupName = Read-Host "enter rg name:"  
$location = Read-Host "enter location"                 
$appServicePlan = Read-Host "enter app service plan"   
$webAppName = Read-Host "enter web app name"   
$gitRepoURL = Read-Host "enter git repository url:"  
$branch = Read-Host "enter branch of repo you want to deploy:" 

# Check if the resource group exists, if not create it
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "Creating Resource Group: $resourceGroupName"
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
    Write-Host "Resource Group $resourceGroupName already exists."
}

# Check if the App Service Plan exists, if not create it
$appServicePlanResource = Get-AzAppServicePlan -Name $appServicePlan -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $appServicePlanResource) {
    Write-Host "Creating App Service Plan: $appServicePlan"
    New-AzAppServicePlan -Name $appServicePlan -Location $location -ResourceGroupName $resourceGroupName -Tier "Free"
} else {
    Write-Host "App Service Plan $appServicePlan already exists."
}

# Check if the Web App exists, if not create it
$webApp = Get-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (-not $webApp) {
    Write-Host "Creating Web App: $webAppName"
    New-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName -Location $location -AppServicePlan $appServicePlan
} else {
    Write-Host "Web App $webAppName already exists."
}

# Configure GitHub deployment for the Web App
Write-Host "Configuring GitHub deployment for $webAppName from public repository $gitRepoURL"
$PropertiesObject = @{
    repoUrl = $gitRepoURL;
    branch  = $branch;
}
Set-AzResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Web/sites/sourcecontrols" -ResourceName "$webAppName/web" -ApiVersion "2015-08-01" -Force

Write-Host "Web App $webAppName configured to deploy from public GitHub repository $gitRepoURL."
Write-Host "Browse to https://$webAppName.azurewebsites.net once the deployment is complete."
