
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
$global:ProfilePath = "C:\Users\Spencer\Documents\WindowsPowerShell\"
$global:ModulePath = "C:\Users\Spencer\Documents\WindowsPowerShell\Modules"

Import-Module Repo -Global
Import-Module Aliases -Global
Import-Module Posh-Git -Global