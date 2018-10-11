Install-PackageProvider -Name Chocolatey -force;
Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/ -Force -Trusted;
Find-Package graphviz -Source "http://chocolatey.org/api/v2/"  | Install-Package -ForceBootstrap -Force;
Start-Sleep -Seconds 2;

Install-PackageProvider -Name NuGet -Force;
Install-Module -Name PSGraph -Force -verbose;
Install-Module -Name PSScriptAnalyzer -Force;
Install-Module -Name Pester -Force -verbose;