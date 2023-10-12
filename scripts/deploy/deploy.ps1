# Constants
$release = "1.0"
$manifestFilePath = $PSScriptRoot + "\..\..\src\packages\imports.mf"
$importDir = Split-Path -Path $manifestFilePath

# Set parameters from config
$arasEnvConfigFile = $PSScriptRoot + "\env.config" 
$xmldoc = [xml] (Get-Content $arasEnvConfigFile)
$environment = $xmldoc.SelectSingleNode("//Environment")

$importProg = $environment.ConsoleUpgradePath
$url = $environment.Url
$db = $environment.DB
$login = $environment.User
$password = $environment.Password

$params = "server=" + $url + " database=" + $db + " login=" + $login + " password=" + $password + " dir=" + """$importDir"""  + " mfFile=" + """$manifestFilePath""" + " release=" + $release + " import merge"

# Execute Import script
$ret = Start-Process -FilePath $importProg $params -Wait -NoNewWindow -PassThru

if ($ret.ExitCode -ne 0) {
    Write-Error "Import failed"
    return $ret.ExitCode
} else {
    Write-Host -ForegroundColor Green "Import successful: $manifestFilePath"
    return 0
}
