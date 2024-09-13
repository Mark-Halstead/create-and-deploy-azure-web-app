# Variables
$resourceGroupName = "powershell-testing"  # Change this to your desired Resource Group
$location = "UKSouth"                    # Change this to your desired location
$appServicePlan = "myAppServicePlan"    # Change this to your desired App Service Plan name
$webAppName = "myspecialdrumkit123"      # Change this to your desired web app name (must be globally unique)
$gitRepoURL = "https://github.com/Mark-Halstead/Drum-kit.git"  # Replace with your GitHub repository URL
$branch = "main"                        # Branch to deploy from

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
