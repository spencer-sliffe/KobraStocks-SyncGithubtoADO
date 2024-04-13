param(
     [Parameter()]
     [string]$GitHubSourcePAT,

     [Parameter()]
     [string]$ADODestinationPAT,
     
     [Parameter()]
     [string]$AzureRepoName,
     
     [Parameter()]
     [string]$GitHubCloneURL,
     
     [Parameter()]
     [string]$ADOCloneURL
 )

Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - -'
Write-Host ' Reflect GitHub repo changes to Azure DevOps repo'
Write-Host ' - - - - - - - - - - - - - - - - - - - - - - - - - '
$AzureRepoName = "KobraStocks"
$GitHubCloneURL = "github.com/spencer-sliffe/KobraStocks.git"
$ADOCloneURL = "dev.azure.com/sliffespencer/KobraStocks/_git/KobraStocks"
$stageDir = pwd | Split-Path
Write-Host "Stage Dir is : $stageDir"
$adoDir = $stageDir + "\" + "ado"
Write-Host "ADO Dir : $adoDir"
$destination = $adoDir + "\" + $AzureRepoName + ".git"
Write-Host "Destination: $destination"
#Please make sure, you remove https from GitHub-repo-clone-url
$sourceURL = "https://" + $($GitHubSourcePAT) + "@" + "$($GitHubCloneURL)"
write-host "Source URL : $sourceURL"
#Please make sure, you remove https from ADO-repo-clone-url
$destURL = "https://" + $($ADODestinationPAT) + "@" + "$($ADOCloneURL)"
write-host "Dest URL : $destURL"
#Check if the parent directory exists and delete
if((Test-Path -path $adoDir))
{
  Remove-Item -Path $adoDir -Recurse -force
}
if(!(Test-Path -path $adoDir))
{
  New-Item -ItemType directory -Path $adoDir
  Set-Location $adoDir
  git clone --mirror $sourceURL
}
else
{
  Write-Host "The given folder path $adoDir already exists";
}
Set-Location $destination
Write-Output '*****Git removing remote secondary****'
git remote rm secondary
Write-Output '*****Git remote add****'
git remote add --mirror=fetch secondary $destURL
Write-Output '*****Git fetch origin****'
git fetch $sourceURL
Write-Output '*****Git push secondary****'
git push secondary  --all -f
Write-Output '**GitHub repo synced with Azure DevOps repo**'
Set-Location $stageDir
if((Test-Path -path $adoDir))
{
 Remove-Item -Path $adoDir -Recurse -force
}
write-host "Job completed"
