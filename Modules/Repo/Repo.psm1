# Repo

#region Public Static Variables
$global:RepositoryStorageRoot = "$ModulePath\Repo\"
$global:RepositoryStorage_Repositories = "$RepositoryStorageRoot\repositories.xml"
$global:RepositoryStorage_RelativePath = "$RepositoryStorageRoot\relativePath.xml"
#endregion

#region Internal State
$global:Repositories = @{}
$global:RelativePath = "$Home\Documents\Development"
#endregion

#region Internal Helpers
function Validate-Repository()
{
	Param(
		[string] $Name,
		[switch] $ForNewRepository
	)

	if( $ForNewRepository )
	{
		if( Repository-Exists $Name )
		{
			Throw "Repository $Name already exists"
		}
	}
	else
	{
		if( -not (Repository-Exists $Name) )
		{
			Throw "Repository $Name does not exist"
		}
	}
}

function Current-Location()
{
	return (Resolve-Path .).ToString()
}

function Get-Repository-Names()
{
	return $global:Repositories.Keys
}

function Get-Repository-Locations()
{
	return $global:Repositories.Values
}

function Get-Repository()
{
	Param( [string] $Name )
	return $Repositories[$Name]
}

function Set-Repository()
{
	Param( [string] $Name, [string] $Location )
	$Repositories[$Name] = $Location
}

function Repository-Exists()
{
	Param( [string] $Name )
	return $Repositories.Contains($Name)
}

function Get-Relative-Path()
{
	return $RelativePath
}
#endregion

#region State Permanence
function Repository-Initialize-Module()
{
	$reposXml = (Get-Item "$global:Storage\repositories.xml" -ErrorAction Ignore)
	if( $reposXml )
	{
		Load-Repositories
	}
	else
	{
		$inputPath = Read-Host "Please enter a path to the root of your development. Current value is '$global:RelativePath'"
		if( $inputPath -ne "" ) { $RelativePath = $inputPath }
		if( -not (Get-Item $RelativePath -ErrorAction Ignore) ) { mkdir $inputPath }

		Create-Repository -Name "~" -Path "~"
		Create-Repository -Name "root" -Path $global:RelativePath
		Save-Repositories
	}
}

function Load-Repositories()
{
	Import-CliXml -LiteralPath $RepositoryStorage_Repositories -OutVariable $Repositories
	Import-CliXml -LiteralPath $RepositoryStorage_RelativePath -OutVariable $RelativePath
}

function Save-Repositories()
{
	Export-CliXml -LiteralPath $RepositoryStorage_Repositories -InputObject $Repositories
	Export-CliXml -LiteralPath $RepositoryStorage_RelativePath -InputObject $RelativePath
}
#endregion

#region Public Functions
function Display-Repositories()
{
	$output = "
	Repositories

	~~				$RelativePath
	-----------------------------------


	" 
	Echo $output
}

function Create-Repository()
{
	Param(
		[string] $Name,
		[string] $Path,
		[switch] $UseCurrentLocation
	)

	Validate-Repository $Name -ForNewRepository

	if( -not $Path )
	{
		if( -not $UseCurrentLocation )
		{
			Throw 'Either $Path or $UseCurrentLocation must be set'
		}

		$Path = Current-Location
	}

	Set-Repository $Name $Path
	Save-Repositories
}

function Alter-Repository()
{
	Param(
		[string] [Parameter(Required=$true, Position=0)] $Repo,
		[string] $Path,
		[string] $Name,
		[switch] $UseCurrentLocation
	)

	Validate-Repository $Repo

	if( (-not $Path) -and $UseCurrentLocation )
	{
		$Path = Current-Location
	}

	if( $Path )
	{
		Set-Repository $Repo $Path
	}

	if( $Name )
	{
		Create-Repository $Name (Get-Repository $Repo)
		Delete-Repository $Repo
	}

}

function Delete-Repository()
{
	Param(
		[string] $Name
	)
	Validate-Repository $Name
	$Repositories.Remove($Name)
}

function Open-Repository()
{
	Param(
		[string] $Name
	)

	Get-Repository $Name | Set-Location
}

function Repository()
{
    [CmdletBinding()]
    Param ()
    DynamicParam {
        
    }
    process {
        # Do stuff
    }
}

function Repo()
{

}

#endregion

#region Tab Complete

$global:tabCompletion_AlterRepository_Repo = 
{
	Param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	
	$validRepoNames = Get-Rpository-Names | Where { $_ -like "*$wordToComplete*" }
	$validRepoNames | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_.Name,
            $_.Name,
            "ParameterValue",
            $_.Name
    }
	
}
Register-ArgumentCompleter -CommandName Alter-Repository -ParameterName Repo -ScriptBlock $global:tabCompletion_AlterRepository_Repo

#endregion

#region Aliases and Exports
Repository-Initialize-Module
#endregion

