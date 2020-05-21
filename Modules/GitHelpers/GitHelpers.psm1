# Git Helpers

#region Storage Locations
$global:GitHelpersStorageRoot = "$($global:ModulePath)\GitHelpers\"
$global:GitHelpersStorage_LastCommit = "$($global:GitHelpersStorageRoot)\lastCommit.xml"
$global:GitHelpersStorage_LastCommits = "$($global:GitHelpersStorageRoot)\lastCommits.xml"
#endregion

#region State
$global:LastCommit = ""
$global:LastCommits = @{}
#endregion

#region Public Static Variables
$global:GitHelperCommandBranches = "branches"
$global:GitHelperCommandBranch = "branche"
$global:GitHelperCommandCommit = "commit"
$global:GitHelperCommandPush = "push"
$global:GitHelperCommandClean = "clean"
$global:GitHelperCommandCherry = "cherry"
$global:GitHelperCommands = @(
	$GitHelperCommandBranches,
	$GitHelperCommandBranch,
	$GitHelperCommandCommit,
	$GitHelperCommandPush,
	$GitHelperCommandClean,
	$GitHelperCommandCherry
)
#endregion


#region Private Helper Functions
function Get-Last-Commit()
{
	return $global:LastCommit
}

function Set-Last-Commit()
{
	Param( [string] $Commit )
	
	if( -not $Commit ) { $Commit = Determine-Last-Commit }
	$global:LastCommit = $Commit
	Save-Commit-History
}

function Determine-Last-Commit()
{
	return (git log | Select-String -Pattern "commit" | Select-Object -First 1 | ForEach-Object { ($_ -split " ")[1] })
}

function Get-Initials()
{
	return git config --global user.initials
}

function Set-Initials()
{
	Param( [string] $Intials )
	git config --global --add user.initials $Initials
}

function Get-Current-Branch()
{
	return (git branch | Select-String "\*" | Select-Object -First 1 | ForEach-Object { ($_ -split " ")[1] })
}

#endregion


#region State Permanence
function Git-Helpers-Initialize-Module()
{

	if( Get-Item $global:GitHelpers_LastCommit -ErrorAction Ignore )
	{
		Load-Commit-History
	}
	
	else
	{
		Save-Commit-History
	}
	
	
	if( -not (Get-Initials) )
	{
		$initials = Read-Host "Please enter your initials. These will be used to create new branches.`t"
		Set-Initials $initials
	}
}

function Load-Commit-History()
{
	$global:LastCommit = Import-CliXml -LiteralPath $global:GitHelpersStorage_LastCommit
	$global:LastCommits = Import-CliXml -LiteralPath $global:GitHelpersStorage_LastCommits
}

function Save-Commit-History()
{
	Export-CliXml -LiteralPath $global:GitHelpersStorage_LastCommit -InputObject $global:LastCommit
	Export-CliXml -LiteralPath $global:GitHelpersStorage_LastCommits -InputObject $global:LastCommits
}
#endregion

#region Public Facing API

function Git-Branches() { git branch -vv }
function Git-Branch()
{
	Param( [string] $Branch, [string] $Version="master", [switch] $KeepLocalChanges )

	$Initials = Get-Initials
	$Branch = "$Initials/$Version/$Branch"
	if( $KeepLocalChanges )
	{
		git stash
		git branch $Branch
		git checkout $Branch
		git stash pop
	}
	else
	{
		git stash
		git checkout $Version
		git pull
		git branch $Branch
		git checkout $Branch
	}
}

function Git-Commit()
{
	Param( [string] $Message )
	
	git fetch
	git commit -m $Message
	Set-Last-Commit
	Git-Push
}

function Git-Push()
{
	$branch = Get-Current-Branch
	git push -u origin $branch
}

function Git-Clean()
{
	$branch = Get-Current-Branch
	git stash
	git checkout master
	
	git fetch
	git remote prune origin
	Git-Branches | Select-String -Pattern "gone" | Select-String -Pattern (Get-Initials) | ForEach { git branch -D ($_.ToString().Trim().Split(" ")[0]) }
	
	git checkout $branch
	git stash pop
}

function Git-Cherry()
{
	Param( [string] $Hash, [switch] $UseLast )
	
	if( -not $Hash -and $UseLast )
	{
		$Hash = Get-Last-Commit
	}
	
	git fetch
	git cherry-pick $Hash
}
#endregion

#region Public Global Dynamic Functions

function Git-Helper()
{
	Param( [string] $Argument, [string[]] $Parameters )
	switch ($Argument)
	{
		$GitHelperCommandBranches
		{
			Git-Branches @Parameters
		}
			
		$GitHelperCommandBranch
		{
			Git-Branch @Parameters
		}
		
		$GitHelperCommandCommit
		{
			Git-Commit @Parameters
		}

		$GitHelperCommandPush
		{
			Git-Push @Parameters
		}
		
		$GitHelperCommandClean
		{
			Git-Clean @Parameters
		}
		
		$GitHelperCommandCherry
		{
			Git-Cherry @Parameters
		}
	}

}

function GH()
{
	Param(
		[Parameter(Position=0)] [string] $Argument,
		[Parameter(Position=1, ValueFromRemainingArguments)] [string[]] $Parameters
	)
	
	if( -not $Argument )
	{
		return git status
	}
	
	if( -not $global:GitHelperCommands.Contains($Argument) )
	{
		Write-Host "Illegal argument $Argument. Argument must be empty or in the set {" ($global:GitHelperCommands -join ", ") "}"
		return
	}
	
	Git-Helper $Argument $Parameters
}
#endregion

