Powershell Profile
==================

This is a powershell profile, including some helpful self-built modules.
The profile is used simply to import-modules and setup some helper variables for location


Repo
----

This module was built to help manage your different work locations and to be able to quickly move between them.
This can be helpful when you are working on several different projects or even when working on multiple versions of a project.

This module keeps it's state accross sessions. 
We store two items: a relative path (the root of all your development),
and a map of repository names and repository locations.

#### Repo
This is the shorthand method for accessing all the other functions. 
Simply call `repo` and the short name of the method you want and then use the parameters as normal.

```powershell
$> repo
$> repo <repository-name>
$> repo <method-shorthand-name> [ <arguments> ]
```

Providing no arguments is the same as `repo help`

`<repository-name>` must be a valid saved repository.
 Otherwise it will throw an error and display the help.

`<method-short-hand-name>` must be of the set `{ list, help, save, alter, mv, set, rm, open }`
`<arguments>` are dependent of the method chosen.
In general they would be either names for your repositories or directories for the path location.

#### Repository

The same as `repo` with the exception that you must provide the shorthand name (otherwise it will throw an error).


#### Open-Repository

Shorthand Name:	`open`  
Arguments:		`<repository-name>`

#### Create-Repository

Shorthand Name:	`save`  
Arguments:		`<repository-name> <path-to-directory>`


#### Alter-Repository

Shorthand Name: `alter`, `mv`, `set`  
Arguments:		`<repository-name> Name:<new-name> Path:<new-path> UseCurrentLocation:<use-current-location>`

`Alter-Repository` is a special function when written shorthand.
You may use `alter` to both `mv` and `set` in one function call.
`mv` requires a `Name` parameter and will rename the repository. 
This is effectively the same as making a new repository with the new name and the old path and then deleting the old repository.
`set` requires a `Path` parameter and will set the path location of the repository to the new location.
Alternatively, you may substitute the `Path` argument with a `UseCurrentLocation` flag.
This is effectively the save as calling `repo set <repo-name> .`


#### Remove-Repository

Shorthand Name:	`rm`  
Arguments:		`<repository-name>`

Deletes the repository. Cannot be undone (yet).


#### Display-Repositories

Shorthand Name: `list`  
Arguments:		NONE

Will display the repositories as well as the relative path (root of development).


#### Repository-Help

Shorthand Name:	`help`, NONE  
Arguments:		NONE

Will display the help.





GitHelpers
-----------

This module was built to fast track many common git functions. Note that this module is used to help facilitate Versions.
To keep this running smoothly it is necessary that there exists a branch for each version. If you wanted to make changes to some remote branch `Development`
then you need to call `git checkout -b Development --track origin/Development`. You must do this for every version you will be making changes to.


#### Git-Branches
Exactly equivalent to calling `git branch -vv`. This outputs a verbose listing of the current branches.


#### Git-Branch
Using a branch name and an optional version name (defaults to master). This method will create and checkout a local branch. You must have a valid version branch.
That is if you are making changes for some branch `Development` and you want alter a feature `Logging` you must already have a local branch `Development`.

This will checkout your version and pull from the remote origin. Then we create and checkout a branch of the form `<intials>/<version>/<branch>`.
- `<intials>` are using the `git config --global user.initials`.
- `<version>` defaults to `master` but can be set to anything. 
- `<branch>` is the name of the branch you passed in.

There is also an optional parameter `KeepLocalChanges` this will not checkout the version branch,
and will `git stash pop` your changes after checking out the new branch.

#### Git-Commit
This will commit your changes using the given message, and call `Git-Push`. This commit hash gets saved for usage of `Git-Cherry`


#### Git-Push`
This will push your commits to the remote branch (usually creating a new remote branch)

#### Git-Clean
This will clean all local branches whose remote branch has been deleted. Note this will checkout master first in case the branch you are on will be deleted.

#### Git-Cherry`
This is used in conjunction with `Git-Commit` when the `-UseLast` parameter is set, we will use the last commit to cherry-pick from.
Note, this will not update the cached commit hash in case merge conflicts require you to make changes that should not go into other branches in future cherry-picks.
