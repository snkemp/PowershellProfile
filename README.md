Powershell Profile
==================

This is a powershell profile, including some helpful self-built modules.


<details>
<summary><h2>Profile</h2></summary>

The profile is used simply to import-modules and setup some helper variables for location
</details>
<details>

Repo
----

This module was built to help manage your different work locations and to be able to quickly move between them.
This can be helpful when you are working on several different projects or even when working on multiple versions of a project.

This module keeps it's state accross sessions. 
We store two items: a relative path (the root of all your development),
and a map of repository names and repository locations.

<details>
<summary><h4>Repo</h4></summary>

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

</details>
<summary><h4>Repository</h4></summary>

The same as `repo` with the exception that you must provide the shorthand name (otherwise it will throw an error).

</details>
<details>
<summary><h4>Open-Repository</h4></summary>

Shorthand Name:	`open`
Arguments:		`<repository-name>`

</details>
<details>
<summary><h4>Create-Repository</h4></summary>

Shorthand Name:	`save`
Arguments:		`<repository-name> <path-to-directory>`

</details>
<details>
<summary><h4>Alter-Repository</h4></summary>

Shorthand Name: `alter`, `mv`, `set`
Arguments:		`<repository-name> Name:<new-name> Path:<new-path> UseCurrentLocation:<use-current-location>

`Alter-Repository` is a special function when written shorthand.
You may use `alter` to both `mv` and `set` in one function call.
`mv` requires a `Name` parameter and will rename the repository. 
This is effectively the same as making a new repository with the new name and the old path and then deleting the old repository.
`set` requires a `Path` parameter and will set the path location of the repository to the new location.
Alternatively, you may substitute the `Path` argument with a `UseCurrentLocation` flag.
This is effectively the save as calling `repo set <repo-name> .`

</details>
<details>
<summary><h4>Delete-Repository</h4></summary>

Shorthand Name:	`rm`
Arguments:		`<repository-name>`

Deletes the repository. Cannot be undone (yet).

</details>
<details>
<summary><h4>Display-Repositories</h4></summary>

Shorthand Name: `list`
Arguments:		NONE

Will display the repositories as well as the relative path (root of development).

</details>
<details>
<summary><h4>Repository-Help</h4></summary>

Shorthand Name:	`help`, NONE
Arguments:		NONE

Will display the help.


</details>
</details>
