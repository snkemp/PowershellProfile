# Define Aliases
Set-Alias -Name ConEmu	-Value "C:\Program Files (x86)\ConEmu\ConEmu.exe"
Set-Alias -Name Chrome	-Value "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
Set-Alias -Name IIS		-Value "C:\Program Files (x86)\IIS Express\iisexpress.exe"

# IDEs
Set-Alias -Name NPP		-Value "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias -Name Android	-Value "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe"
Set-Alias -Name Atom	-Value "C:\Users\Spencer\AppData\Local\atom\atom.exe"

# Games
Set-Alias -Name WoW		-Value "C:\Program Files (x86)\Battle.net\Battle.net.exe"
Set-Alias -Name Origin	-Value "C:\Program Files (x86)\Origin\Origin.exe"
Set-Alias -Name Steam	-Value "C:\Program Files (x86)\Steam\steam.exe"

# Other
Set-Alias -Name ip		-Value "ipconfig"
Set-Alias -Name spotify	-Value "C:\Users\Spencer\AppData\Roaming\Spotify\Spotify.exe"
Set-Alias -Name restart	-Value "powershell"


# Export Aliases
Export-ModuleMember -Alias -Name WoW
Export-ModuleMember -Alias -Name Chrome
Export-ModuleMember -Alias -Name IIS
Export-ModuleMember -Alias -Name NPP
Export-ModuleMember -Alias -Name Origin
Export-ModuleMember -Alias -Name Steam
Export-ModuleMember -Alias -Name Android
Export-ModuleMember -Alias -Name Atom