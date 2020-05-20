# Repo


#region Public Static Variables
$global:RepositoryStorageRoot = "$($global:ModulePath)\Repo\"
$global:RepositoryStorage_Repositories = "$($global:RepositoryStorageRoot)\repositories.xml"
$global:RepositoryStorage_RelativePath = "$($global:RepositoryStorageRoot)\relativePath.xml"

$global:CommandList = "list"
$global:CommandHelp = "help"
$global:CommandSave = "save"
$global:CommandAlter = "alter"
$global:CommandAlterName = "mv"
$global:CommandAlterPath = "set"
$global:CommandDelete = "rm"
$global:CommandOpen = "open"
$global:RepositoryCommands = [System.Collections.Generic.HashSet[string]] @(
	$CommandList,
	$CommandHelp,
	$CommandSave,
	$CommandAlter,
	$CommandAlterName,
	$CommandAlterPath,
	$CommandDelete,
	$CommandOpen)
#endregion

#region Internal State
$global:Repositories = @{}
$global:RelativePath = (Resolve-Path "~\Documents\Development").Path
#endregion

#region Internal Helpers

function Path-Name()
{
	Param([string] $Path)
	Write-Host $Path
	return (Resolve-Path $Path).Path;
}

function Current-Location()
{
	return (Path-Name .)
}

function Get-Relative-Path()
{
	return $global:RelativePath
}

function Set-Relative-Path()
{
	Param( [string] $Path )
	$global:RelativePath = (Path-Name $Path)
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
	return (Path-Name $global:Repositories[$Name])
}

function Set-Repository()
{
	Param( [string] $Name, [string] $Location )
	$global:Repositories[$Name] = $Location
}

function Repository-Exists()
{
	Param( [string] $Name )
	return $global:Repositories.Contains($Name)
}

function Is-Repository()
{
	Param( [string] $Path )
	$Path = Path-Name $Path
	foreach($key in (Get-Repository-Names))
	{
		if( (Get-Repository $key) -eq $Path )
		{
			return $key
		}
	}
	
	return $false
}

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

function Format-Repository()
{
	Param( [string] $Repo )
	$Path = (Get-Repository $Repo).Replace((Get-Relative-Path), "~~\")
	return "`t$Repo`t`t`t$Path"
}

function Format-Repositories()
{
	return (( Get-Repository-Names | Sort-Object -Descending | ForEach { (Format-Repository $_) } ) -join "`n")
}
#endregion

#region State Permanence
function Repository-Initialize-Module()
{
	$reposXml = (Get-Item $global:RepositoryStorage_Repositories -ErrorAction Ignore)
	if( $reposXml )
	{
		Load-Repositories
	}
	else
	{
		$inputPath = Read-Host "Please enter a path to the root of your development. Current value is '$RelativePath'"
		if( $inputPath -ne "" ) { Set-Relative-Path $inputPath }
		if( -not (Get-Item (Get-Relative-Path) -ErrorAction Ignore) ) { mkdir $inputPath }

		Create-Repository -Name "~" -Path "~"
		Create-Repository -Name "root" -Path $RelativePath
		Save-Repositories
	}
}

function Load-Repositories()
{
	$global:Repositories = Import-CliXml -LiteralPath $global:RepositoryStorage_Repositories
	$global:RelativePath = Import-CliXml -LiteralPath $global:RepositoryStorage_RelativePath
}

function Save-Repositories()
{
	Export-CliXml -LiteralPath $RepositoryStorage_Repositories -InputObject Repositories
	Export-CliXml -LiteralPath $RepositoryStorage_RelativePath -InputObject RelativePath
}
#endregion

#region Public API
function Display-Repositories()
{
	$output = "
`tRepositories`t`t~~ = $(Get-Relative-Path)

`tName`t`t`tPath
`t----`t`t`t----
$(Format-Repositories)

" 
	Write-Host $output
}

function Repository-Help()
{
	# TODO
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
	
	$key = Is-Repository $Path
	while( $key )
	{
		$continue = Read-Host "This location is already saved as repo '$key`. Would you like to continue?`nY/N:"
		if($continue -eq "Y")
		{
			break
		}
		elseif($continue -eq "N")
		{
			return
		}
	}

	Set-Repository $Name $Path
	Save-Repositories
}

function Alter-Repository()
{
	Param(
		[string] [Parameter(Position=0)] $Repo,
		[string] $Name,
		[string] $Path,
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

#endregion

#region Public global Dynamic Functions

function Repository()
{
    Param( [string] $Command, [string[]] $Arguments )
	
	if( -not $RepositoryCommands.Contains($Command) )
	{
		Write-Host "Invalid command '$Command'. command must be an element of the set {" ($RepositoryCommands -join ", ") "}
or "
		Repository-Help
		Display-Repositories
	}
	
	switch( $Command )
	{
	
		$CommandList
		{
			Display-Repositories
		}
		
		$CommandHelp
		{
			Repository-Help
			Repository-List
		}
		
		$CommandSave
		{
			Create-Repository @Arguments
		}
		
		{ $_ -in ($CommandAlter, $CommandAlterName, $CommandAlterPath) }
		{
			Alter-Repository @Arguments
		}
		
		$CommandDelete
		{
			Delete-Repository @Arguments
		}

		$CommandOpen
		{
			Open-Repository @Arguments
		}
		
		Default
		{
			Write-Host "That functionality has not been implemented yet.. We should probably fix that"
		}
	}
}

function Repo()
{
	[CmdletBinding()]
	Param( [string] $Argument, [string[]] $Parameters )
	
	if( $Parameters -eq $null )
	{
		$Parameters = @()
	}
	
	if( -not $Argument )
	{
		$Argument = $global:CommandList
	}
	elseif( Repository-Exists $Argument )
	{
		$Parameters = $Argument + $Parameters
		$Argument = $global:CommandOpen
	}

	return (Repository $Argument @Parameters)
}

#endregion

#region Dynamic Parameters and Tab Completion

function RepositoryTabCompletion()
{

}

function LocationTabCompletion()
{

}

function FunctionTabCompletion()
{

}


#endregion

#region Aliases and Exports
Repository-Initialize-Module

Export-ModuleMember `
	-Function Display-Repositories, Repository-Help, Create-Repository, Alter-Repository, Delete-Repository, Open-Repository, Repository, Repo
#endregion

